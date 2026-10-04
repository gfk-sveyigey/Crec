import '../core/net.dart';
import 'em.dart';
import 'models/quote.dart';

/// akshare.fund_em_open_fund_rank / fund_open_fund_info_em
class FundApi {
  FundApi._();

  static const String _rankReferer =
      'https://fund.eastmoney.com/data/fundranking.html';

  /// akshare.fund_em_open_fund_rank
  ///
  /// The ranking endpoint answers with javascript:
  ///   var rankData = {datas:["code,name,pinyin,date,nav,accNav,..."],...}
  /// so the payload is sliced manually instead of being parsed as JSON.
  static Future<List<FundRow>> ranking({
    int pageSize = 30,
    String sortField = '1nzf',
  }) async {
    final String? body = await Net.text(
      Em.fundRankUrl(pageSize: pageSize, sortField: sortField),
      referer: _rankReferer,
    );
    if (body == null) return <FundRow>[];
    final int start = body.indexOf('datas:[');
    if (start < 0) return <FundRow>[];
    final int end = body.indexOf(']', start + 7);
    if (end <= start) return <FundRow>[];
    final String block = body.substring(start + 7, end);
    final List<String> chunks = block.split('","');
    final List<FundRow> out = <FundRow>[];
    for (final String rawChunk in chunks) {
      final List<String> parts = rawChunk.replaceAll('"', '').split(',');
      if (parts.length < 14) continue;
      final String code = parts[0];
      final String name = parts[1];
      if (code.isEmpty || name.isEmpty) continue;
      out.add(FundRow(
        code: code,
        name: name,
        nav: double.tryParse(parts[4]),
        dayPct: double.tryParse(parts[6]),
        monthPct: double.tryParse(parts[8]),
        yearPct: double.tryParse(parts[11]),
        threeYearPct: double.tryParse(parts[13]),
        type: parts.length > 17 ? parts[17] : '',
      ));
    }
    return out;
  }

  /// akshare.fund_open_fund_info_em -> historical NAV series.
  static Future<List<double>> navHistory(String code) async {
    final Map<String, dynamic>? json =
        await Em.get(Em.fundNavUrl(code), referer: Em.fundReferer);
    if (json == null) return <double>[];
    final Object? data = json['Data'];
    if (data is! Map) return <double>[];
    final Object? list = data['LSJZList'];
    if (list is! List) return <double>[];
    final List<double> out = <double>[];
    for (final Object? item in list) {
      if (item is! Map) continue;
      final double? v = Em.numOrNull(item['DWJZ']);
      if (v != null) out.add(v);
    }
    return out;
  }
}
