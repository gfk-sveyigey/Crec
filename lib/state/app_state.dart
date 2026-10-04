import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/fallback_data.dart';
import '../data/fund_api.dart';
import '../data/market_api.dart';
import '../data/mock_trade_api.dart';
import '../data/news_api.dart';
import '../data/models/quote.dart';
import '../data/models/trading.dart';

/// Single source of truth for the whole app. Everything is either fetched
/// from the public endpoints or simulated locally - there is no backend.
class AppState extends ChangeNotifier {
  static const String _kPhone = 'crec.phone';
  static const String _kTrade = 'crec.tradeOpened';
  static const String _kWatch = 'crec.watchlist';

  AppState({this.autoRefresh = true});

  /// When false, [bootstrap] only loads local state and paints the bundled
  /// sample data - no HTTP at all (used by widget tests).
  final bool autoRefresh;

  final MockTradeApi trade = MockTradeApi.instance;

  String? phone;
  bool tradeOpened = false;

  List<String> watchCodes = <String>[];
  List<Quote> watchQuotes = <Quote>[];

  List<Quote> indexes = <Quote>[];
  MarketActivity? activity;
  List<BoardRow> industryBoards = <BoardRow>[];
  List<BoardRow> conceptBoards = <BoardRow>[];
  List<HotTopic> hotTopics = <HotTopic>[];
  List<FundRow> funds = <FundRow>[];
  List<NewsItem> news = <NewsItem>[];
  List<ResearchReport> reports = <ResearchReport>[];

  DateTime? updatedAt;
  bool refreshing = false;
  bool offline = false;

  bool get loggedIn => phone != null && phone!.isNotEmpty;

  SharedPreferences? _prefs;

  /// Public re-render hook for the local (mock) trading state.
  void refresh() => notifyListeners();

  Future<void> bootstrap() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      phone = _prefs!.getString(_kPhone);
      tradeOpened = _prefs!.getBool(_kTrade) ?? false;
      if (tradeOpened) {
        trade.open();
      }
      final List<String>? saved = _prefs!.getStringList(_kWatch);
      watchCodes = (saved == null || saved.isEmpty)
          ? FallbackData.watchlistSeed.map((List<String> r) => r[0]).toList()
          : List<String>.from(saved);
    } catch (_) {
      watchCodes = FallbackData.watchlistSeed.map((List<String> r) => r[0]).toList();
    }
    // Paint the offline sample data immediately, then refresh in place.
    _applyFallback();
    notifyListeners();
    if (!autoRefresh) return;
    await refreshMarket();
  }

  void _applyFallback() {
    indexes = FallbackData.indexes();
    activity = FallbackData.activity();
    industryBoards = FallbackData.industryBoards();
    conceptBoards = FallbackData.conceptBoards();
    hotTopics = FallbackData.hotTopics();
    funds = FallbackData.funds();
    watchQuotes = FallbackData.watchlist();
    for (final Quote q in watchQuotes) {
      MarketApi.put(q);
    }
    news = _sampleNews();
  }

  List<NewsItem> _sampleNews() {
    final DateTime now = DateTime.now();
    return <NewsItem>[
      NewsItem(
        id: 'n1',
        title: '十二部门发文 推动多式联运高质量发展',
        summary: '多部门联合印发意见，明确到2030年多式联运发展目标与重点任务。',
        time: now.subtract(const Duration(minutes: 24)),
        source: '东方财富',
      ),
      NewsItem(
        id: 'n2',
        title: '两融余额升至2.61万亿 杠杆资金持续加仓科技板块',
        summary: '沪深两市融资融券余额连续第五个交易日回升。',
        time: now.subtract(const Duration(minutes: 96)),
        source: '证券时报',
      ),
      NewsItem(
        id: 'n3',
        title: '创新药出海提速 生物制品板块集体走强',
        summary: '多家创新药企披露海外授权合作，板块主力资金净流入居前。',
        time: now.subtract(const Duration(hours: 3)),
        source: '上海证券报',
      ),
    ];
  }

  Future<void> refreshMarket() async {
    if (refreshing) return;
    refreshing = true;
    notifyListeners();
    bool anyOnline = false;

    try {
      final List<Quote> idx = await MarketApi.indexes();
      if (idx.isNotEmpty && idx.first.price != null) {
        indexes = idx;
        for (final Quote q in idx) {
          MarketApi.put(q);
        }
        anyOnline = true;
      }
    } catch (_) {}

    try {
      final MarketActivity? act = await MarketApi.activity();
      if (act != null && act.upCount + act.downCount > 0) {
        activity = act;
        anyOnline = true;
      }
    } catch (_) {}

    try {
      final List<BoardRow> boards = await MarketApi.boards();
      if (boards.isNotEmpty) {
        industryBoards = boards;
        anyOnline = true;
      }
    } catch (_) {}

    try {
      final List<BoardRow> concepts = await MarketApi.boards(concept: true, pz: 20);
      if (concepts.isNotEmpty) {
        conceptBoards = concepts;
        anyOnline = true;
      }
    } catch (_) {}

    try {
      final List<FundRow> f = await FundApi.ranking(pageSize: 20);
      if (f.isNotEmpty) {
        funds = f;
        anyOnline = true;
      }
    } catch (_) {}

    try {
      final List<NewsItem> n = await NewsApi.fastNews(pageSize: 30);
      if (n.isNotEmpty) {
        news = n;
        anyOnline = true;
      }
    } catch (_) {}

    try {
      final List<ResearchReport> r = await NewsApi.reports(pageSize: 10);
      if (r.isNotEmpty) reports = r;
    } catch (_) {}

    hotTopics = _buildHotTopics();

    await refreshWatch();
    offline = !anyOnline;
    updatedAt = DateTime.now();
    refreshing = false;
    notifyListeners();
  }

  /// Derives the 今日热点 shelf from the concept board ranking.
  List<HotTopic> _buildHotTopics() {
    final List<HotTopic> base = conceptBoards.isEmpty
        ? FallbackData.hotTopics()
        : conceptBoards.take(5).map((BoardRow b) {
            final int down = b.downCount == 0 ? 1 : b.downCount;
            return HotTopic(
              name: b.name,
              changePct: b.changePct,
              upDownRatio: b.upCount.toString() + ':' + down.toString(),
              netInflow: b.netInflow,
              description: '今日' + b.name + '概念表现活跃，主力资金与市场关注度居前。',
              spark: FallbackData.walk(
                start: 0,
                end: 1,
                points: 48,
                seed: b.name.hashCode,
              ),
            );
          }).toList();
    if (base.isNotEmpty && base.first.stocks.isEmpty) {
      final HotTopic first = base.first;
      base[0] = HotTopic(
        name: first.name,
        changePct: first.changePct,
        upDownRatio: first.upDownRatio,
        netInflow: first.netInflow,
        description: first.description,
        stocks: FallbackData.hotLeaders(),
        spark: first.spark,
      );
    }
    return base;
  }

  Future<void> refreshWatch() async {
    final List<String> codes = List<String>.from(watchCodes);
    List<Quote> quotes = <Quote>[];
    try {
      quotes = await MarketApi.quotesFor(codes);
    } catch (_) {
      quotes = <Quote>[];
    }
    if (quotes.isEmpty || quotes.every((Quote q) => q.price == null)) {
      quotes = FallbackData.watchlist();
    } else {
      // Fill in the intraday sparkline for the visible rows.
      final int limit = quotes.length < 6 ? quotes.length : 6;
      final List<Future<List<TrendPoint>>> pending = <Future<List<TrendPoint>>>[];
      for (int i = 0; i < limit; i++) {
        pending.add(MarketApi.trends(quotes[i].code));
      }
      try {
        final List<List<TrendPoint>> trends = await Future.wait(pending);
        for (int i = 0; i < trends.length; i++) {
          final List<TrendPoint> points = trends[i];
          if (points.length < 2) continue;
          final List<double> spark =
              points.map((TrendPoint p) => p.price).toList(growable: false);
          quotes[i] = quotes[i].copyWith(spark: spark);
          MarketApi.put(quotes[i]);
        }
      } catch (_) {}
      for (int i = 0; i < quotes.length; i++) {
        if (quotes[i].spark.length >= 2) continue;
        final double price = quotes[i].price ?? 1;
        final double prev = quotes[i].prevClose ?? price;
        quotes[i] = quotes[i].copyWith(
          spark: FallbackData.walk(start: prev, end: price, seed: quotes[i].code.hashCode),
        );
      }
    }
    watchQuotes = quotes;
    notifyListeners();
  }

  Future<void> addWatch(String code, String name) async {
    final String clean = code.trim();
    if (clean.isEmpty || watchCodes.contains(clean)) return;
    watchCodes = List<String>.from(watchCodes)..add(clean);
    await _persistWatch();
    try {
      final Quote? q = await MarketApi.quote(clean);
      if (q != null) MarketApi.put(q);
    } catch (_) {}
    await refreshWatch();
  }

  Future<void> removeWatch(String code) async {
    watchCodes = List<String>.from(watchCodes)..remove(code);
    await _persistWatch();
    await refreshWatch();
  }

  Future<void> moveWatch(int oldIndex, int newIndex) async {
    final List<String> next = List<String>.from(watchCodes);
    final String item = next.removeAt(oldIndex);
    next.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    watchCodes = next;
    await _persistWatch();
    await refreshWatch();
  }

  Future<void> _persistWatch() async {
    try {
      await _prefs?.setStringList(_kWatch, watchCodes);
    } catch (_) {}
  }

  Future<void> login(String phoneNumber, String password) async {
    phone = phoneNumber;
    try {
      await _prefs?.setString(_kPhone, phoneNumber);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> logout() async {
    phone = null;
    try {
      await _prefs?.remove(_kPhone);
    } catch (_) {}
    notifyListeners();
  }

  /// 开户 / 交易登录 - binds the simulated brokerage account.
  Future<void> openTradeAccount() async {
    tradeOpened = true;
    trade.open();
    try {
      await _prefs?.setBool(_kTrade, true);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> closeTradeAccount() async {
    tradeOpened = false;
    trade.close();
    try {
      await _prefs?.setBool(_kTrade, false);
    } catch (_) {}
    notifyListeners();
  }

  AccountAsset get asset => trade.asset();

  List<Position> get positions => trade.positions();
}

/// Inherited access to the single AppState instance.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final AppScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (scope == null || scope.notifier == null) {
      throw FlutterError('AppScope is missing from the widget tree');
    }
    return scope.notifier!;
  }
}
