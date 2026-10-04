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

  static const List<String> _tabs = <String>['全部', '持仓股', '最近浏览', '基金'];

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final List<Quote> quotes = state.watchQuotes;
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    index == null ? '--' : signed(index.change),
                    style: TextStyle(fontSize: 13, color: c),
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
                    style: TextStyle(fontSize: 13, color: c),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18, color: kTextSub),
                ],
              ),
            ],
          ),
          const Spacer(),
          _stripAction(Icons.memory, 'AI识股', badge: '免费'),
          _stripAction(Icons.bar_chart, '分析'),
          _stripAction(Icons.currency_yuan, '资金'),
          _stripAction(Icons.article_outlined, '资讯'),
        ],
      ),
    );
  }

  Widget _stripAction(IconData icon, String label, {String? badge}) {
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
                  Icon(icon, size: 24, color: kText),
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
                GestureDetector(
                  onTap: () => setState(() => _editing = !_editing),
                  child: Text(
                    _editing ? '完成' : '编辑',
                    style: const TextStyle(fontSize: 13, color: kTextSub),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            color: const Color(0xFFFAFBFC),
            child: Row(
              children: const <Widget>[
                Expanded(flex: 4, child: Text('名称/代码', style: _headStyle)),
                Expanded(
                  flex: 3,
                  child: Text('分时预览', textAlign: TextAlign.center, style: _headStyle),
                ),
                Expanded(
                  flex: 3,
                  child: Text('最新', textAlign: TextAlign.right, style: _headStyle),
                ),
                Expanded(
                  flex: 3,
                  child: Text('涨幅', textAlign: TextAlign.right, style: _headStyle),
                ),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                          decoration: BoxDecoration(
                            border: Border.all(color: kBrandRed, width: 0.8),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text(
                            '融',
                            style: TextStyle(fontSize: 9, color: kBrandRed, height: 1),
                          ),
                        ),
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
                style: TextStyle(fontSize: 16, color: c, fontWeight: FontWeight.w500),
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
                    style: const TextStyle(color: Colors.white, fontSize: 13),
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
                  Icon(Icons.add, size: 17, color: kTextSub),
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
                  Icon(Icons.image_outlined, size: 17, color: kTextSub),
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
