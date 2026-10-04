import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/em.dart';
import '../data/fallback_data.dart';
import '../data/market_api.dart';
import '../data/models/quote.dart';
import '../state/app_state.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import 'stock_detail_page.dart';

/// 行情 - index overview, market breadth, tool shortcuts and boards.
class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  static const List<String> _topTabs = <String>[
    '行情',
    '全球',
    'A股',
    '基金',
    'ETF',
    '可转债',
    '新三板',
    '更多',
  ];
  static const List<String> _subTabs = <String>['沪深京', '板块', '创业', '科创', '京市'];

  int _top = 2;
  int _sub = 0;
  final Map<int, List<Quote>> _lists = <int, List<Quote>>{};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load(_top);
  }

  String _fsFor(int tab) {
    switch (tab) {
      case 3:
        return Em.fsFund;
      case 4:
        return Em.fsEtf;
      case 5:
        return Em.fsBond;
      case 6:
        return 'm:0+t:82';
      default:
        return Em.fsAllA;
    }
  }

  Future<void> _load(int tab, {bool force = false}) async {
    if (!force && _lists.containsKey(tab)) return;
    setState(() => _loading = true);
    List<Quote> result = <Quote>[];
    try {
      result = await MarketApi.list(fs: _fsFor(tab), pz: 20, fid: 'f3');
    } catch (_) {
      result = <Quote>[];
    }
    if (result.isEmpty) result = FallbackData.watchlist();
    if (!mounted) return;
    setState(() {
      _lists[tab] = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: <Widget>[
          AppTopBar(
            title: '行情',
            tabs: _topTabs,
            selectedTab: _top,
            onTabSelected: (int i) {
              setState(() => _top = i);
              _load(i);
            },
            onSearch: () {},
          ),
          Expanded(
            child: RefreshIndicator(
              color: kBrandRed,
              onRefresh: () async {
                await state.refreshMarket();
                _lists.clear();
                await _load(_top, force: true);
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    child: PillTabs(
                      labels: _subTabs,
                      selected: _sub,
                      dense: true,
                      onSelected: (int i) => setState(() => _sub = i),
                    ),
                  ),
                  _indexCards(state),
                  _breadthCard(state),
                  SectionCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: NavGridView(
                      entries: <NavEntry>[
                        NavEntry(icon: Icons.candlestick_chart_outlined, label: '神奇色阶', color: kText, onTap: () {}),
                        NavEntry(icon: Icons.filter_9_outlined, label: '神奇九转', color: kText, onTap: () {}),
                        NavEntry(icon: Icons.assignment_turned_in_outlined, label: '一键打新', color: kText, badge: 'NEW', onTap: () {}),
                        NavEntry(icon: Icons.local_fire_department_outlined, label: '涨停揭秘', color: kText, onTap: () {}),
                        NavEntry(icon: Icons.check_circle_outline, label: '条件选股', color: kText, onTap: () {}),
                      ],
                    ),
                  ),
                  _boardsCard(state),
                  _stockListCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _indexCards(AppState state) {
    final List<Quote> indexes = state.indexes;
    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Row(
        children: List<Widget>.generate(indexes.length, (int i) {
          final Quote q = indexes[i];
          return Expanded(child: _indexCard(q, i == 1));
        }),
      ),
    );
  }

  Widget _indexCard(Quote q, bool middle) {
    final Color c = changeColor(q.changePct);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            two(q.price),
            style: numStyle(TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c)),
          ),
          const SizedBox(height: 2),
          Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  q.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: kTextSub),
                ),
              ),
              const SizedBox(width: 3),
              Text(signedPct(q.changePct), style: numStyle(TextStyle(fontSize: 12, color: c))),
            ],
          ),
          const SizedBox(height: 6),
          Sparkline(values: q.spark, color: c, height: 26, baseline: q.prevClose),
        ],
      ),
    );
  }

  Widget _breadthCard(AppState state) {
    final MarketActivity? a = state.activity;
    if (a == null) return const SizedBox.shrink();
    final Color flowColor = changeColor(a.mainNetInflow);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                '节假日休盘',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kText),
              ),
              const SizedBox(width: 8),
              Text(
                '下方为' + _lastTradingDay() + '交易数据',
                style: const TextStyle(fontSize: 12, color: kTextSub),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              _statTile(
                '涨跌分布',
                a.upCount.toString() + ' : ' + a.downCount.toString(),
                color: null,
              ),
              const SizedBox(width: 8),
              _statTile('主力净流入', compact(a.mainNetInflow), color: flowColor),
              const SizedBox(width: 8),
              _statTile('两融余额', compact(a.marginBalance), color: null),
            ],
          ),
          const SizedBox(height: 14),
          DistributionChart(activity: a),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Text('今日两市成交额', style: TextStyle(fontSize: 13, color: kTextSub)),
              const SizedBox(width: 6),
              Text(
                compact(a.amount),
                style: const TextStyle(fontSize: 14, color: kText, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              const Text('较上一日此时', style: TextStyle(fontSize: 12, color: kTextSub)),
              const SizedBox(width: 4),
              Text(
                signed(a.amountDelta / 100000000),
                style: const TextStyle(fontSize: 13, color: kUp),
              ),
              const Text('亿', style: TextStyle(fontSize: 12, color: kUp)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: <Widget>[
            Text(label, style: const TextStyle(fontSize: 12, color: kTextSub)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color ?? kText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boardsCard(AppState state) {
    final List<BoardRow> boards = state.industryBoards;
    int up = 0;
    int down = 0;
    int flat = 0;
    for (final BoardRow b in boards) {
      final double pct = b.changePct ?? 0;
      if (pct > 0) {
        up++;
      } else if (pct < 0) {
        down++;
      } else {
        flat++;
      }
    }
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                '行业板块',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kText),
              ),
              const SizedBox(width: 10),
              Text('涨:' + up.toString(), style: const TextStyle(fontSize: 13, color: kUp)),
              const SizedBox(width: 8),
              Text('平:' + flat.toString(), style: const TextStyle(fontSize: 13, color: kFlat)),
              const SizedBox(width: 8),
              Text('跌:' + down.toString(), style: const TextStyle(fontSize: 13, color: kDown)),
              const Spacer(),
              const Icon(Icons.chevron_right, size: 18, color: kTextFaint),
            ],
          ),
          const SizedBox(height: 6),
          ...boards.take(5).map((BoardRow b) => _boardRow(b)),
        ],
      ),
    );
  }

  Widget _boardRow(BoardRow b) {
    final Color c = changeColor(b.changePct);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 84,
            child: Text(
              b.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, color: kText),
            ),
          ),
          if (b.leaderName.isNotEmpty)
            Expanded(
              child: Text(
                '领涨 ' + b.leaderName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: kTextSub),
              ),
            )
          else
            const Spacer(),
          SizedBox(
            width: 78,
            child: Text(
              compact(b.netInflow),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, color: changeColor(b.netInflow)),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              signedPct(b.changePct),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockListCard() {
    final List<Quote> list = _lists[_top] ?? <Quote>[];
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                _topTabs[_top] + '涨幅榜',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: kText,
                ),
              ),
              const Spacer(),
              if (_loading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: kBrandRed),
                )
              else
                GestureDetector(
                  onTap: () => _load(_top, force: true),
                  child: const Icon(Icons.refresh, size: 16, color: kTextSub),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('暂无数据', style: TextStyle(fontSize: 12, color: kTextSub)),
              ),
            ),
          ...list.take(12).map((Quote q) => _stockRow(q)),
        ],
      ),
    );
  }

  Widget _stockRow(Quote q) {
    final Color c = changeColor(q.changePct);
    return InkWell(
      onTap: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => StockDetailPage(code: q.code, name: q.name),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    q.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, color: kText),
                  ),
                  const SizedBox(height: 2),
                  Text(q.code, style: const TextStyle(fontSize: 11, color: kTextSub)),
                ],
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                two(q.price),
                textAlign: TextAlign.right,
                style: numStyle(TextStyle(fontSize: 15, color: c)),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 66,
              padding: const EdgeInsets.symmetric(vertical: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
              child: Text(
                signedPct(q.changePct),
                style: numStyle(const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _lastTradingDay() {
    final DateTime now = DateTime.now();
    final DateTime d = now.subtract(const Duration(days: 1));
    String p(int n) => n < 10 ? '0' + n.toString() : n.toString();
    return p(d.month) + '月' + p(d.day) + '日';
  }
}
