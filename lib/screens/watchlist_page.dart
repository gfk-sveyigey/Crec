import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models/quote.dart';
import '../state/app_state.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import 'search_page.dart';
import 'stock_detail_page.dart';

/// 自选 - index header, watchlist quotes with sparklines.
class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key, this.onOpenTab});

  final ValueChanged<int>? onOpenTab;

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  int _tab = 0;
  bool _editing = false;
  /// 列表排序：-1 不排序，0 按最新价，1 按涨跌幅。
  int _sortCol = -1;
  bool _sortDesc = true;

  static const List<String> _tabs = <String>['全部', '持仓股', '最近浏览', '基金'];

  /// 可空行情字段比较：空值永远排末尾。
  static int _cmpNullable(double? a, double? b, bool desc) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return desc ? b.compareTo(a) : a.compareTo(b);
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final List<Quote> quotes = List<Quote>.of(state.watchQuotes);
    if (_sortCol == 0) {
      quotes.sort((Quote a, Quote b) => _cmpNullable(a.price, b.price, _sortDesc));
    } else if (_sortCol == 1) {
      quotes.sort((Quote a, Quote b) => _cmpNullable(a.changePct, b.changePct, _sortDesc));
    }
    final Quote? index = state.indexes.isEmpty ? null : state.indexes.first;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: <Widget>[
          AppTopBar(title: '自选', onSearch: () => _openSearch(state)),
          _indexStrip(index),
          Expanded(
            child: RefreshIndicator(
              color: kBrandRed,
              onRefresh: state.refreshWatch,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _tableCard(state, quotes),
                  _footer(state),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _indexStrip(Quote? index) {
    final Color c = changeColor(index?.changePct);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 2, 10, 10),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    index == null ? '--' : two(index.price),
                    style: numStyle(TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    index == null ? '--' : signed(index.change),
                    style: numStyle(TextStyle(fontSize: 13, color: c)),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: <Widget>[
                  Text(
                    index == null ? '上证指数' : index.name,
                    style: const TextStyle(fontSize: 13, color: kText),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    index == null ? '--' : signedPct(index.changePct),
                    style: numStyle(TextStyle(fontSize: 13, color: c)),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18, color: kTextSub),
                ],
              ),
            ],
          ),
          const Spacer(),
          // 四个入口图标取自脱壳 IPA 的 Assets.car（tztzf_hq_userstock_*）。
          _stripAction('assets/icons/watch/ai_stock.png', 'AI识股', badge: '免费'),
          _stripAction('assets/icons/watch/analysis.png', '分析'),
          _stripAction('assets/icons/watch/fund.png', '资金'),
          _stripAction('assets/icons/watch/news.png', '资讯'),
        ],
      ),
    );
  }

  Widget _stripAction(String asset, String label, {String? badge}) {
    return GestureDetector(
      onTap: () => _toast(label),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 30,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  AssetIcon(asset, width: 25),
                  if (badge != null)
                    Positioned(
                      right: -14,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: kBrandRed,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(color: Colors.white, fontSize: 8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: kTextSub)),
          ],
        ),
      ),
    );
  }

  Widget _tableCard(AppState state, List<Quote> quotes) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: PillTabs(
                    labels: _tabs,
                    selected: _tab,
                    onSelected: (int i) => setState(() => _tab = i),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            color: const Color(0xFFFAFBFC),
            child: Row(
              children: <Widget>[
                // 与参考截图一致：左列是「编辑 / 多股」，右三列带排序箭头。
                Expanded(
                  flex: 4,
                  child: Row(
                    children: <Widget>[
                      _headAction(
                        'assets/icons/watch/edit.png',
                        _editing ? '完成' : '编辑',
                        () => setState(() => _editing = !_editing),
                      ),
                      const SizedBox(width: 10),
                      _headAction(
                        'assets/icons/watch/multi_column.png',
                        '多股',
                        () => _toast('多股同列'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _toast('分时预览'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Text('分时预览', style: _headStyle),
                        SizedBox(width: 2),
                        AssetIcon('assets/icons/watch/preview.png', width: 13),
                      ],
                    ),
                  ),
                ),
                Expanded(flex: 3, child: _sortHeader('最新', 0)),
                Expanded(flex: 3, child: _sortHeader('涨幅', 1)),
              ],
            ),
          ),
          if (quotes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('暂无自选股', style: TextStyle(color: kTextSub, fontSize: 13)),
            ),
          ...quotes.map((Quote q) => _quoteRow(state, q)),
        ],
      ),
    );
  }

  Widget _quoteRow(AppState state, Quote q) {
    final Color c = changeColor(q.changePct);
    return InkWell(
      onTap: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => StockDetailPage(code: q.code, name: q.name)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          q.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, color: kText),
                        ),
                      ),
                      if (q.margin) ...<Widget>[
                        const SizedBox(width: 4),
                        const AssetIcon('assets/icons/watch/rong.png', width: 15),
                      ],
                      if (_editing) ...<Widget>[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => state.removeWatch(q.code),
                          child: const Icon(Icons.remove_circle, size: 16, color: kBrandRed),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(q.code, style: const TextStyle(fontSize: 12, color: kTextSub)),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Sparkline(
                  values: q.spark,
                  color: c,
                  height: 30,
                  baseline: q.prevClose,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                two(q.price),
                textAlign: TextAlign.right,
                style: numStyle(TextStyle(fontSize: 16, color: c, fontWeight: FontWeight.w500)),
              ),
            ),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 62,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    signedPct(q.changePct),
                    style: numStyle(const TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer(AppState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final String? code = await Navigator.of(context).push<String>(
                  MaterialPageRoute<String>(builder: (_) => const SearchPage()),
                );
                if (code != null && code.isNotEmpty) {
                  await state.addWatch(code, code);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  AssetIcon('assets/icons/watch/add.png', width: 17),
                  SizedBox(width: 4),
                  Text('添加自选', style: TextStyle(fontSize: 14, color: kTextSub)),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 16, color: kDivider),
          Expanded(
            child: GestureDetector(
              onTap: () => _toast('识别图片'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  AssetIcon('assets/icons/watch/orc.png', width: 17),
                  SizedBox(width: 4),
                  Text('识别图片', style: TextStyle(fontSize: 14, color: kTextSub)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headAction(String asset, String label, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: <Widget>[
          AssetIcon(asset, width: 14),
          const SizedBox(width: 3),
          Text(label, style: _headStyle),
        ],
      ),
    );
  }

  Widget _sortHeader(String label, int col) {
    final bool active = _sortCol == col;
    final String asset = !active
        ? 'assets/icons/watch/sort_default.png'
        : (_sortDesc ? 'assets/icons/watch/sort_down.png' : 'assets/icons/watch/sort_up.png');
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        if (_sortCol == col) {
          _sortDesc = !_sortDesc;
        } else {
          _sortCol = col;
          _sortDesc = true;
        }
      }),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(label, style: _headStyle),
          const SizedBox(width: 2),
          AssetIcon(asset, width: 6, height: 12),
        ],
      ),
    );
  }

  Future<void> _openSearch(AppState state) async {
    final String? code = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const SearchPage()),
    );
    if (code != null && code.isNotEmpty) {
      await state.addWatch(code, code);
    }
  }

  void _toast(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(label), duration: const Duration(seconds: 1)),
    );
  }
}

const TextStyle _headStyle = TextStyle(fontSize: 11, color: kTextFaint);
