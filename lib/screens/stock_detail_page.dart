import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/fallback_data.dart';
import '../data/market_api.dart';
import '../data/models/quote.dart';
import '../state/app_state.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

/// Individual security page: quote header, 分时 / K线 charts and details.
class StockDetailPage extends StatefulWidget {
  const StockDetailPage({super.key, required this.code, required this.name});

  final String code;
  final String name;

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  static const List<String> _tabs = <String>['分时', '五日', '日K', '周K', '月K'];

  Quote? _quote;
  List<TrendPoint> _trends = <TrendPoint>[];
  List<KlineBar> _klines = <KlineBar>[];
  int _tab = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _quote = MarketApi.cached(widget.code);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    Quote? quote = _quote;
    try {
      final Quote? fetched = await MarketApi.quote(widget.code);
      if (fetched != null) quote = fetched;
    } catch (_) {}
    List<TrendPoint> trends = <TrendPoint>[];
    List<KlineBar> klines = <KlineBar>[];
    try {
      trends = await MarketApi.trends(widget.code, days: _tab == 1 ? 5 : 1);
    } catch (_) {}
    try {
      klines = await MarketApi.klines(widget.code, klt: _klt());
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _quote = quote;
      _trends = trends;
      _klines = klines;
      _loading = false;
    });
  }

  int _klt() {
    switch (_tab) {
      case 2:
        return 101;
      case 3:
        return 102;
      case 4:
        return 103;
      default:
        return 101;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final Quote? q = _quote;
    final Color c = changeColor(q?.changePct);
    final bool watched = state.watchCodes.contains(widget.code);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              q == null ? widget.name : q.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            Text(
              widget.code,
              style: const TextStyle(fontSize: 11, color: kTextSub),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              if (watched) {
                await state.removeWatch(widget.code);
              } else {
                await state.addWatch(widget.code, q == null ? widget.name : q.name);
              }
            },
            icon: Icon(
              watched ? Icons.star : Icons.star_border,
              color: watched ? kBrandRed : kText,
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _priceHeader(q, c),
          Container(
            color: Colors.white,
            child: PillTabs(
              labels: _tabs,
              selected: _tab,
              onSelected: (int i) {
                setState(() => _tab = i);
                _load();
              },
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: kBrandRed),
              ),
            ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _chart(q),
                _details(q),
                const SizedBox(height: 24),
              ],
            ),
          ),
          _bottomBar(state, q),
        ],
      ),
    );
  }

  Widget _priceHeader(Quote? q, Color c) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                two(q?.price),
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: c),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  signed(q?.change) + '   ' + signedPct(q?.changePct),
                  style: TextStyle(fontSize: 15, color: c),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '今开 ' + two(q?.open) + '   最高 ' + two(q?.high) + '   最低 ' + two(q?.low),
            style: const TextStyle(fontSize: 12, color: kTextSub),
          ),
        ],
      ),
    );
  }

  Widget _chart(Quote? q) {
    if (_tab <= 1) {
      final List<TrendPoint> points = _trends.isEmpty ? _fakeTrends(q) : _trends;
      return TimeShareChart(points: points, prevClose: q?.prevClose ?? 0, height: 240);
    }
    final List<KlineBar> bars = _klines.isEmpty ? _fakeKlines(q) : _klines;
    return CandleChart(bars: bars, height: 260);
  }

  List<TrendPoint> _fakeTrends(Quote? q) {
    final double price = q?.price ?? 10;
    final List<double> spark = q?.spark.isNotEmpty == true
        ? q.spark
        : FallbackData.walk(start: q?.prevClose ?? price, end: price, seed: widget.code.hashCode);
    final DateTime start = DateTime.now();
    final List<TrendPoint> out = <TrendPoint>[];
    for (int i = 0; i < spark.length; i++) {
      out.add(TrendPoint(
        time: start.add(Duration(minutes: i * 5)),
        price: spark[i],
        avg: (spark[i] + price) / 2,
        volume: (i % 7 + 1) * 1200,
      ));
    }
    return out;
  }

  List<KlineBar> _fakeKlines(Quote? q) {
    final double end = q?.price ?? 10;
    final List<double> walk = FallbackData.walk(
      start: end * 0.9,
      end: end,
      points: 60,
      seed: widget.code.hashCode + 5,
    );
    final DateTime now = DateTime.now();
    final List<KlineBar> out = <KlineBar>[];
    for (int i = 0; i < walk.length; i++) {
      final double close = walk[i];
      final double open = i == 0 ? close * 0.99 : walk[i - 1];
      out.add(KlineBar(
        time: now.subtract(Duration(days: walk.length - i)),
        open: open,
        close: close,
        high: (open > close ? open : close) * 1.01,
        low: (open < close ? open : close) * 0.99,
        volume: (i % 9 + 1) * 120000,
        amount: 0,
        changePct: open == 0 ? 0 : (close - open) / open * 100,
        turnover: 1.2,
      ));
    }
    return out;
  }

  Widget _details(Quote? q) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
      child: Column(
        children: <Widget>[
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _detailCell('昨收', two(q?.prevClose)),
              _detailCell('成交量', compactHand(q?.volume)),
              _detailCell('成交额', compact(q?.amount)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _detailCell('换手率', q?.turnover == null ? '--' : two(q!.turnover) + '%'),
              _detailCell('市盈率', two(q?.pe)),
              _detailCell('总市值', compact(q?.marketCap)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailCell(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 12, color: kTextSub)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, color: kText)),
        ],
      ),
    );
  }

  Widget _bottomBar(AppState state, Quote? q) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: kDivider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: BrandButton(
                  label: '买入',
                  height: 42,
                  gradient: const <Color>[Color(0xFFF5453A), Color(0xFFE93323)],
                  onPressed: () => _order(state, '买入'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BrandButton(
                  label: '卖出',
                  height: 42,
                  gradient: const <Color>[Color(0xFF3E7BD4), Color(0xFF2B6BE4)],
                  onPressed: () => _order(state, '卖出'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BrandButton(
                  label: state.watchCodes.contains(widget.code) ? '已自选' : '加自选',
                  height: 42,
                  outlined: true,
                  textColor: kBrandRed,
                  onPressed: () async {
                    if (state.watchCodes.contains(widget.code)) {
                      await state.removeWatch(widget.code);
                    } else {
                      await state.addWatch(widget.code, q == null ? widget.name : q.name);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _order(AppState state, String side) async {
    if (!state.tradeOpened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先在 开户|交易 中登录交易账户'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    final String? error = state.trade.place(
      code: widget.code,
      name: widget.name,
      side: side,
      price: _quote?.price ?? 0,
      quantity: 100,
    );
    state.refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? ('已' + side + '100股 ' + widget.name)),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
