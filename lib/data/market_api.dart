import '../core/format.dart';
import 'em.dart';
import 'fallback_data.dart';
import 'models/quote.dart';

/// Market data facade. Each method maps to one public endpoint (and to the
/// akshare function that documents it) and degrades gracefully by
/// returning an empty result when the network is unavailable, so callers
/// can substitute bundled sample data.
class MarketApi {
  MarketApi._();

  static final Map<String, Quote> _cache = <String, Quote>{};

  static Quote? cached(String code) => _cache[code];

  static void put(Quote quote) => _cache[quote.code] = quote;

  /// akshare.stock_zh_index_spot_em
  static Future<List<Quote>> indexes({bool headlineOnly = true}) async {
    final List<List<String>> spec =
        headlineOnly ? Em.headlineIndexes : Em.moreIndexes;
    final List<String> secids =
        spec.map((List<String> e) => e.first).toList(growable: false);
    final Map<String, dynamic>? json =
        await Em.get(Em.batchUrl(secids, fields: Em.indexFields));
    final List<Map<String, dynamic>> rows = Em.rows(json);
    final List<Quote> out = <Quote>[];
    for (int i = 0; i < spec.length; i++) {
      final List<String> parts = spec[i].first.split('.');
      final String code = parts.last;
      final String marketId = parts.first;
      final String displayName = spec[i].last;
      Map<String, dynamic>? match;
      for (final Map<String, dynamic> row in rows) {
        if (Em.str(row['f12']) == code &&
            Em.intOrNull(row['f13']).toString() == marketId) {
          match = row;
          break;
        }
      }
      if (match == null && i < rows.length) match = rows[i];
      if (match == null) {
        out.add(Quote(code: code, name: displayName));
        continue;
      }
      final Quote q = Em.quoteFromRow(match);
      out.add(Quote(
        code: code,
        name: q.name.isEmpty ? displayName : q.name,
        market: marketId == '1' ? 'sh' : 'sz',
        price: q.price,
        change: q.change,
        changePct: q.changePct,
        open: q.open,
        high: q.high,
        low: q.low,
        prevClose: q.prevClose,
        volume: q.volume,
        amount: q.amount,
        spark: q.spark,
      ));
    }
    return out;
  }

  /// akshare.stock_zh_a_spot_em
  static Future<List<Quote>> list({
    String fs = Em.fsAllA,
    int pn = 1,
    int pz = 20,
    String fid = 'f3',
    int po = 1,
  }) async {
    final Map<String, dynamic>? json =
        await Em.get(Em.listUrl(fs: fs, pn: pn, pz: pz, fid: fid, po: po));
    final List<Quote> out = <Quote>[];
    for (final Map<String, dynamic> row in Em.rows(json)) {
      final Quote q = Em.quoteFromRow(row);
      if (q.code.isEmpty || q.name.isEmpty) continue;
      put(q);
      out.add(q);
    }
    return out;
  }

  /// Batch quotes for the watchlist (akshare.stock_zh_index_spot_em style
  /// ulist endpoint); keeps the caller supplied ordering.
  static Future<List<Quote>> quotesFor(List<String> codes) async {
    if (codes.isEmpty) return <Quote>[];
    final List<String> secids =
        codes.map((String c) => secidOf(c)).toList(growable: false);
    final Map<String, dynamic>? json =
        await Em.get(Em.batchUrl(secids, fields: Em.indexFields));
    final List<Map<String, dynamic>> rows = Em.rows(json);
    final List<Quote> out = <Quote>[];
    for (int i = 0; i < codes.length; i++) {
      final String code = codes[i];
      final String marketId = secids[i].split('.').first;
      Map<String, dynamic>? match;
      for (final Map<String, dynamic> row in rows) {
        if (Em.str(row['f12']) == code &&
            Em.intOrNull(row['f13']).toString() == marketId) {
          match = row;
          break;
        }
      }
      if (match == null) {
        for (final Map<String, dynamic> row in rows) {
          if (Em.str(row['f12']) == code) {
            match = row;
            break;
          }
        }
      }
      if (match == null) {
        out.add(Quote(code: code, name: code));
        continue;
      }
      final Quote q = Em.quoteFromRow(match);
      put(q);
      out.add(q);
    }
    return out;
  }

  /// Symbol search backing the 搜索 box; falls back to a local match over
  /// the bundled sample list when the suggest service is unreachable.
  static Future<List<Quote>> search(String keyword) async {
    final String key = keyword.trim();
    if (key.isEmpty) return <Quote>[];
    try {
      final Map<String, dynamic>? json = await Em.get(Em.searchUrl(key));
      final List<Quote> found = Em.searchResults(json);
      if (found.isNotEmpty) return found;
    } catch (_) {}
    final List<Quote> local = <Quote>[];
    for (final Quote q in FallbackData.watchlist()) {
      if (q.code.contains(key) || q.name.contains(key)) local.add(q);
    }
    for (final List<String> row in FallbackData.watchlistSeed) {
      if (row[0].contains(key) || row[1].contains(key)) {
        final Quote q = Quote(code: row[0], name: row[1]);
        bool exists = false;
        for (final Quote e in local) {
          if (e.code == q.code) exists = true;
        }
        if (!exists) local.add(q);
      }
    }
    return local;
  }

  /// akshare.stock_bid_ask_em
  static Future<Quote?> quote(String code) async {
    final Map<String, dynamic>? json =
        await Em.get(Em.stockUrl(secidOf(code)));
    if (json == null) return null;
    final Object? data = json['data'];
    if (data is! Map) return null;
    final Map<String, dynamic> row = <String, dynamic>{
      'f12': Em.str(data['f57']).isEmpty ? code : data['f57'],
      'f14': data['f58'],
      'f13': data['f107'],
      'f2': data['f43'],
      'f3': data['f170'],
      'f4': data['f169'],
      'f5': data['f47'],
      'f6': data['f48'],
      'f8': data['f168'],
      'f9': data['f162'],
      'f15': data['f44'],
      'f16': data['f45'],
      'f17': data['f46'],
      'f18': data['f60'],
      'f20': data['f116'],
      'f21': data['f117'],
    };
    final Quote q = Em.quoteFromRow(row);
    put(q);
    return q;
  }

  /// akshare.stock_zh_a_hist_min_em -> intraday minute line.
  static Future<List<TrendPoint>> trends(String code, {int days = 1}) async {
    final Map<String, dynamic>? json =
        await Em.get(Em.trendsUrl(secidOf(code), days: days));
    final List<TrendPoint> out = <TrendPoint>[];
    if (json == null) return out;
    final Object? data = json['data'];
    if (data is! Map) return out;
    final Object? raw = data['trends'];
    if (raw is! List) return out;
    for (final Object? item in raw) {
      final List<String> parts = Em.str(item).split(',');
      if (parts.length < 8) continue;
      final DateTime? t = _trendTime(parts[0]);
      if (t == null) continue;
      out.add(TrendPoint(
        time: t,
        price: double.tryParse(parts[2]) ?? 0,
        avg: double.tryParse(parts[7]) ?? 0,
        volume: double.tryParse(parts[5]) ?? 0,
      ));
    }
    return out;
  }

  /// akshare.stock_zh_a_hist
  static Future<List<KlineBar>> klines(
    String code, {
    int klt = 101,
    int fqt = 1,
    int limit = 180,
  }) async {
    final Map<String, dynamic>? json = await Em.get(
      Em.klineUrl(secidOf(code), klt: klt, fqt: fqt, limit: limit),
    );
    final List<KlineBar> out = <KlineBar>[];
    if (json == null) return out;
    final Object? data = json['data'];
    if (data is! Map) return out;
    final Object? raw = data['klines'];
    if (raw is! List) return out;
    for (final Object? item in raw) {
      final List<String> parts = Em.str(item).split(',');
      if (parts.length < 11) continue;
      final DateTime? t = DateTime.tryParse(parts[0]);
      if (t == null) continue;
      out.add(KlineBar(
        time: t,
        open: double.tryParse(parts[1]) ?? 0,
        close: double.tryParse(parts[2]) ?? 0,
        high: double.tryParse(parts[3]) ?? 0,
        low: double.tryParse(parts[4]) ?? 0,
        volume: double.tryParse(parts[5]) ?? 0,
        amount: double.tryParse(parts[6]) ?? 0,
        changePct: double.tryParse(parts[8]) ?? 0,
        turnover: double.tryParse(parts[10]) ?? 0,
      ));
    }
    return out;
  }

  /// akshare.stock_board_industry_name_em / stock_board_concept_name_em
  static Future<List<BoardRow>> boards({
    bool concept = false,
    int pz = 40,
    String fid = 'f3',
  }) async {
    final Map<String, dynamic>? json = await Em.get(Em.boardUrl(
      fs: concept ? Em.fsConcept : Em.fsIndustry,
      pz: pz,
      fid: fid,
    ));
    return Em.rows(json)
        .map((Map<String, dynamic> r) => Em.boardFromRow(r))
        .where((BoardRow b) => b.name.isNotEmpty)
        .toList();
  }

  /// Constituents of one board.
  static Future<List<Quote>> boardMembers(String boardCode) async {
    final Map<String, dynamic>? json =
        await Em.get(Em.listUrl(fs: 'b:' + boardCode, pz: 30));
    final List<Quote> out = <Quote>[];
    for (final Map<String, dynamic> row in Em.rows(json)) {
      final Quote q = Em.quoteFromRow(row);
      if (q.code.isEmpty) continue;
      out.add(q);
    }
    return out;
  }

  /// Aggregated 涨跌分布 / 成交额 / 主力净流入 for the market page card.
  static Future<MarketActivity?> activity() async {
    final Map<String, dynamic>? json = await Em.get(Em.listUrl(
      fs: Em.fsAllA,
      pz: 6000,
      fid: 'f3',
      fields: 'f3,f6,f62',
    ));
    final List<Map<String, dynamic>> rows = Em.rows(json);
    if (rows.isEmpty) return null;
    int limitUp = 0;
    int over7 = 0;
    int f5to7 = 0;
    int f2to5 = 0;
    int f0to2 = 0;
    int flat = 0;
    int d0to2 = 0;
    int d2to5 = 0;
    int d5to7 = 0;
    int dOver7 = 0;
    int limitDown = 0;
    double amount = 0;
    double flow = 0;
    for (final Map<String, dynamic> row in rows) {
      amount += Em.numOrNull(row['f6']) ?? 0;
      flow += Em.numOrNull(row['f62']) ?? 0;
      final double? pct = Em.numOrNull(row['f3']);
      if (pct == null) continue;
      if (pct >= 9.9) {
        limitUp++;
      } else if (pct > 7) {
        over7++;
      } else if (pct > 5) {
        f5to7++;
      } else if (pct > 2) {
        f2to5++;
      } else if (pct > 0) {
        f0to2++;
      } else if (pct == 0) {
        flat++;
      } else if (pct > -2) {
        d0to2++;
      } else if (pct > -5) {
        d2to5++;
      } else if (pct > -7) {
        d5to7++;
      } else if (pct > -9.9) {
        dOver7++;
      } else {
        limitDown++;
      }
    }
    return MarketActivity(
      limitUp: limitUp,
      over7: over7,
      from5to7: f5to7,
      from2to5: f2to5,
      from0to2: f0to2,
      flat: flat,
      down0to2: d0to2,
      down2to5: d2to5,
      down5to7: d5to7,
      downOver7: dOver7,
      limitDown: limitDown,
      amount: amount,
      marginBalance: await marginBalance(),
      mainNetInflow: flow,
    );
  }

  /// akshare.stock_margin_sse / stock_margin_szse equivalent.
  static Future<double> marginBalance() async {
    final Map<String, dynamic>? json = await Em.get(Em.marginUrl());
    if (json == null) return 0;
    final Object? result = json['result'];
    if (result is! Map) return 0;
    final Object? data = result['data'];
    if (data is! List || data.isEmpty) return 0;
    final Object? first = data.first;
    if (first is! Map) return 0;
    return Em.numOrNull(first['RZRQYE']) ?? Em.numOrNull(first['RZYE']) ?? 0;
  }

  static DateTime? _trendTime(String raw) {
    final List<String> parts = raw.trim().split(' ');
    if (parts.length < 2) return null;
    return DateTime.tryParse(parts[0] + ' ' + parts[1] + ':00');
  }
}
