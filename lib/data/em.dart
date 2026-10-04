import '../core/net.dart';
import 'models/quote.dart';

/// Every endpoint below is the public HTTP interface that the Python
/// akshare library scrapes; the comments name the akshare function that
/// documents the URL and field layout. akshare is a pure HTTP scraper,
/// so there is no server side to write - the client calls the endpoints
/// itself and parses the payloads with the same semantics.
class Em {
  Em._();

  static const String push2 = 'https://push2.eastmoney.com';
  static const String push2his = 'https://push2his.eastmoney.com';
  static const String datacenter = 'https://datacenter-web.eastmoney.com';
  static const String newsApi = 'https://np-listapi.eastmoney.com';
  static const String reportApi = 'https://reportapi.eastmoney.com';
  static const String fundWeb = 'https://fund.eastmoney.com';
  static const String fundApi = 'https://api.fund.eastmoney.com';

  /// akshare.stock_zh_a_spot_em / stock_board_industry_name_em field set.
  static const String listFields =
      'f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,f14,f15,f16,f17,f18,'
      'f20,f21,f22,f23,f24,f25,f26,f33,f62,f115,f128,f136,f152,f184';

  static const String indexFields =
      'f1,f2,f3,f4,f5,f6,f12,f13,f14,f15,f16,f17,f18,f124';

  static const String stockFields =
      'f43,f44,f45,f46,f47,f48,f50,f51,f52,f57,f58,f60,f107,f116,f117,'
      'f162,f167,f168,f169,f170,f171,f127,f128,f129,f130,f131,f132,f221,f222';

  /// Market selectors used by the fs query parameter.
  static const String fsAllA =
      'm:0+t:6,m:0+t:80,m:1+t:2,m:1+t:23,m:0+t:81+s:2048';
  static const String fsShA = 'm:1+t:2,m:1+t:23';
  static const String fsSzA = 'm:0+t:6,m:0+t:80';
  static const String fsBj = 'm:0+t:81+s:2048';
  static const String fsGem = 'm:0+t:80';
  static const String fsStar = 'm:1+t:23';
  static const String fsIndustry = 'm:90+t:2';
  static const String fsConcept = 'm:90+t:3';
  static const String fsEtf = 'b:MK0021,b:MK0022,b:MK0023,b:MK0024';
  static const String fsBond = 'b:MK0354';
  static const String fsFund = 'b:MK0404,b:MK0405,b:MK0406,b:MK0407';

  static const String boardFields =
      'f1,f2,f3,f4,f8,f12,f13,f14,f20,f62,f104,f105,f106,f128,f136,f140,f141';

  /// Headline index basket rendered by the market page.
  static const List<List<String>> headlineIndexes = <List<String>>[
    <String>['1.000001', '上证指数'],
    <String>['0.399001', '深证成指'],
    <String>['0.899050', '北证50'],
  ];

  static const List<List<String>> moreIndexes = <List<String>>[
    <String>['1.000001', '上证指数'],
    <String>['0.399001', '深证成指'],
    <String>['0.399006', '创业板指'],
    <String>['1.000300', '沪深300'],
    <String>['1.000688', '科创50'],
    <String>['0.899050', '北证50'],
  ];

  static const String fundReferer = 'https://fundf10.eastmoney.com/';
  static const String sinaReferer = 'https://finance.sina.com.cn';

  static String stamp() => DateTime.now().millisecondsSinceEpoch.toString();

  /// akshare.stock_zh_a_spot_em -> push2 /api/qt/clist/get
  static String listUrl({
    required String fs,
    int pn = 1,
    int pz = 20,
    String fid = 'f3',
    int po = 1,
    String fields = listFields,
  }) {
    return push2 +
        '/api/qt/clist/get?pn=' +
        pn.toString() +
        '&pz=' +
        pz.toString() +
        '&po=' +
        po.toString() +
        '&np=1&fltt=2&invt=2&dect=1&ut=bd1d9ddb04089700cf9c27f6f7426281&fid=' +
        fid +
        '&fs=' +
        fs +
        '&fields=' +
        fields +
        '&_=' +
        stamp();
  }

  /// akshare.stock_zh_index_spot_em -> push2 /api/qt/ulist.np/get
  static String batchUrl(List<String> secids, {String fields = indexFields}) {
    return push2 +
        '/api/qt/ulist.np/get?fltt=2&invt=2&dect=1&ut=bd1d9ddb04089700cf9c27f6f7426281&secids=' +
        secids.join(',') +
        '&fields=' +
        fields +
        '&_=' +
        stamp();
  }

  /// akshare.stock_bid_ask_em -> push2 /api/qt/stock/get
  static String stockUrl(String secid, {String fields = stockFields}) {
    return push2 +
        '/api/qt/stock/get?fltt=2&invt=2&dect=1&ut=fa5fd1943c7b386f172d6893dbfba10b&secid=' +
        secid +
        '&fields=' +
        fields +
        '&_=' +
        stamp();
  }

  /// akshare.stock_zh_a_hist_min_em -> push2his /api/qt/stock/trends2/get
  static String trendsUrl(String secid, {int days = 1}) {
    return push2his +
        '/api/qt/stock/trends2/get?secid=' +
        secid +
        '&ut=fa5fd1943c7b386f172d6893dbfba10b'
        '&fields1=f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13'
        '&fields2=f51,f52,f53,f54,f55,f56,f57,f58&iscr=0&iscca=0&ndays=' +
        days.toString() +
        '&_=' +
        stamp();
  }

  /// akshare.stock_zh_a_hist -> push2his /api/qt/stock/kline/get
  static String klineUrl(
    String secid, {
    int klt = 101,
    int fqt = 1,
    int limit = 180,
  }) {
    return push2his +
        '/api/qt/stock/kline/get?secid=' +
        secid +
        '&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1,f2,f3,f4,f5,f6'
        '&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61&klt=' +
        klt.toString() +
        '&fqt=' +
        fqt.toString() +
        '&beg=0&end=20500101&lmt=' +
        limit.toString() +
        '&_=' +
        stamp();
  }

  /// akshare.stock_board_industry_name_em / stock_board_concept_name_em
  static String boardUrl({
    String fs = fsIndustry,
    int pz = 100,
    String fid = 'f3',
  }) {
    return listUrl(fs: fs, pz: pz, fid: fid, fields: boardFields);
  }

  /// Quote lookup used by the search box (Eastmoney suggest service).
  static String searchUrl(String keyword) {
    return 'https://searchapi.eastmoney.com/api/suggest/get?input=' +
        Uri.encodeComponent(keyword) +
        '&type=14&token=D43BF722C8E33BDC906FB84D85E326E8&count=12&_=' +
        stamp();
  }

  /// akshare.stock_margin_sse style margin balance summary.
  static String marginUrl() {
    return datacenter +
        '/api/data/v1/get?reportName=RPTA_RZRQ_LSHJ&columns=ALL&pageNumber=1'
        '&pageSize=1&sortColumns=DIM_DATE&sortTypes=-1&source=WEB&client=WEB';
  }

  /// akshare.stock_info_global_em -> 7x24 fast news feed.
  static String fastNewsUrl({int pageSize = 50, String column = '102'}) {
    return newsApi +
        '/comm/web/getFastNewsList?client=web&biz=web_724&fastColumn=' +
        column +
        '&sortEnd=&pageSize=' +
        pageSize.toString() +
        '&req_trace=' +
        stamp();
  }

  /// akshare.stock_news_em -> column based news feed.
  static String columnNewsUrl({String column = '345', int pageSize = 20}) {
    return newsApi +
        '/comm/web/getNewsByColumns?client=web&biz=web_news_col&column=' +
        column +
        '&order=1&needInteractData=0&page_index=1&page_size=' +
        pageSize.toString() +
        '&req_trace=' +
        stamp();
  }

  /// akshare.stock_research_report_em -> research report list.
  static String reportUrl({int pageSize = 20}) {
    final DateTime now = DateTime.now();
    final DateTime begin = DateTime(now.year - 1, now.month, now.day);
    return reportApi +
        '/report/list?industryCode=*&pageSize=' +
        pageSize.toString() +
        '&industry=*&rating=&ratingChange=&beginTime=' +
        _d(begin) +
        '&endTime=' +
        _d(now) +
        '&pageNo=1&fields=&qType=0&orgCode=&code=*&rcode=&p=1&pageNum=1'
        '&pageNumber=1&_=' +
        stamp();
  }

  /// akshare.fund_em_open_fund_rank -> open fund ranking board.
  static String fundRankUrl({int pageSize = 30, String sortField = '1nzf'}) {
    final DateTime now = DateTime.now();
    final DateTime begin = DateTime(now.year - 1, now.month, now.day);
    return fundWeb +
        '/data/rankhandler.aspx?op=ph&dt=kf&ft=all&rs=&gs=0&sc=' +
        sortField +
        '&st=desc&sd=' +
        _d(begin) +
        '&ed=' +
        _d(now) +
        '&qdii=&tabSubtype=,,,,,&pi=1&pn=' +
        pageSize.toString() +
        '&dx=1&v=' +
        stamp();
  }

  /// akshare.fund_open_fund_info_em -> historical NAV.
  static String fundNavUrl(String code) {
    return fundApi +
        '/f10/lsjz?fundCode=' +
        code +
        '&pageIndex=1&pageSize=20&_=' +
        stamp();
  }

  static String _d(DateTime t) {
    String p(int n) => n < 10 ? '0' + n.toString() : n.toString();
    return t.year.toString() + '-' + p(t.month) + '-' + p(t.day);
  }

  // ---------------------------------------------------------------- parsing

  static double? numOrNull(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final String v = value.trim();
      if (v.isEmpty || v == '-') return null;
      return double.tryParse(v);
    }
    return null;
  }

  static int intOrNull(Object? value) {
    final double? d = numOrNull(value);
    if (d == null) return 0;
    return d.round();
  }

  static String str(Object? value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  /// Extracts the row list out of a clist / ulist response.
  static List<Map<String, dynamic>> rows(Map<String, dynamic>? json) {
    final List<Map<String, dynamic>> out = <Map<String, dynamic>>[];
    if (json == null) return out;
    final Object? data = json['data'];
    if (data is! Map) return out;
    final Object? diff = data['diff'];
    if (diff is List) {
      for (final Object? item in diff) {
        if (item is Map<String, dynamic>) out.add(item);
      }
    } else if (diff is Map) {
      for (final Object? item in diff.values) {
        if (item is Map<String, dynamic>) out.add(item);
      }
    }
    return out;
  }

  /// Maps a clist row onto the shared Quote model.
  static Quote quoteFromRow(Map<String, dynamic> row) {
    final String code = str(row['f12']);
    final int market = intOrNull(row['f13']);
    return Quote(
      code: code,
      name: str(row['f14']),
      market: market == 1 ? 'sh' : 'sz',
      price: numOrNull(row['f2']),
      changePct: numOrNull(row['f3']),
      change: numOrNull(row['f4']),
      volume: numOrNull(row['f5']),
      amount: numOrNull(row['f6']),
      turnover: numOrNull(row['f8']),
      pe: numOrNull(row['f9']) ?? numOrNull(row['f115']),
      high: numOrNull(row['f15']),
      low: numOrNull(row['f16']),
      open: numOrNull(row['f17']),
      prevClose: numOrNull(row['f18']),
      marketCap: numOrNull(row['f20']),
      floatCap: numOrNull(row['f21']),
      netInflow: numOrNull(row['f62']),
      margin: !(market == 0 && (code.startsWith('4') || code.startsWith('8'))),
    );
  }

  /// Maps a board row (industry / concept 板块).
  static BoardRow boardFromRow(Map<String, dynamic> row) {
    return BoardRow(
      code: str(row['f12']),
      name: str(row['f14']),
      changePct: numOrNull(row['f3']),
      change: numOrNull(row['f4']),
      netInflow: numOrNull(row['f62']),
      upCount: intOrNull(row['f104']),
      downCount: intOrNull(row['f105']),
      leaderName: str(row['f128']),
    );
  }

  static Future<Map<String, dynamic>?> get(String url, {String? referer}) {
    return Net.json(url, referer: referer);
  }

  /// Parses the suggest service payload into Quote placeholders.
  static List<Quote> searchResults(Map<String, dynamic>? json) {
    final List<Quote> out = <Quote>[];
    if (json == null) return out;
    final Object? table = json['QuotationCodeTable'];
    if (table is! Map) return out;
    final Object? data = table['Data'];
    if (data is! List) return out;
    for (final Object? item in data) {
      if (item is! Map) continue;
      final String code = str(item['Code']);
      final String name = str(item['Name']);
      if (code.isEmpty || name.isEmpty) continue;
      final String type = str(item['SecurityTypeName']);
      out.add(Quote(
        code: code,
        name: name,
        market: str(item['MktNum']) == '1' ? 'sh' : 'sz',
      ));
      if (type.isNotEmpty) {
        // kept intentionally: callers only need code + name here
      }
    }
    return out;
  }
}
