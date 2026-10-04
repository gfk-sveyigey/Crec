import 'em.dart';
import 'models/quote.dart';

/// akshare.stock_info_global_em / stock_news_em / stock_research_report_em
class NewsApi {
  NewsApi._();

  static DateTime _time(Object? value) {
    final String raw = Em.str(value);
    if (raw.isEmpty) return DateTime.now();
    final String normalized = raw.replaceAll('/', '-').replaceAll('T', ' ');
    return DateTime.tryParse(normalized) ?? DateTime.now();
  }

  /// akshare.stock_info_global_em -> 7x24 快讯
  static Future<List<NewsItem>> fastNews({int pageSize = 40}) async {
    final Map<String, dynamic>? json =
        await Em.get(Em.fastNewsUrl(pageSize: pageSize));
    final List<NewsItem> out = <NewsItem>[];
    if (json == null) return out;
    final Object? data = json['data'];
    if (data is! Map) return out;
    final Object? list = data['fastNewsList'];
    if (list is! List) return out;
    for (final Object? item in list) {
      if (item is! Map) continue;
      out.add(NewsItem(
        id: Em.str(item['code']),
        title: Em.str(item['title']).isEmpty
            ? Em.str(item['summary'])
            : Em.str(item['title']),
        summary: Em.str(item['summary']),
        time: _time(item['showTime']),
        source: '东方财富快讯',
      ));
    }
    return out;
  }

  /// akshare.stock_news_em -> 栏目资讯
  static Future<List<NewsItem>> columnNews({
    String column = '345',
    int pageSize = 20,
  }) async {
    final Map<String, dynamic>? json =
        await Em.get(Em.columnNewsUrl(column: column, pageSize: pageSize));
    final List<NewsItem> out = <NewsItem>[];
    if (json == null) return out;
    final Object? data = json['data'];
    if (data is! Map) return out;
    final Object? list = data['list'];
    if (list is! List) return out;
    for (final Object? item in list) {
      if (item is! Map) continue;
      out.add(NewsItem(
        id: Em.str(item['code']),
        title: Em.str(item['title']),
        summary: Em.str(item['summary']),
        time: _time(item['showTime']),
        source: Em.str(item['mediaName']).isEmpty
            ? '东方财富'
            : Em.str(item['mediaName']),
        url: Em.str(item['url_unique']),
      ));
    }
    return out;
  }

  /// akshare.stock_research_report_em
  static Future<List<ResearchReport>> reports({int pageSize = 20}) async {
    final Map<String, dynamic>? json =
        await Em.get(Em.reportUrl(pageSize: pageSize));
    final List<ResearchReport> out = <ResearchReport>[];
    if (json == null) return out;
    final Object? data = json['data'];
    if (data is! List) return out;
    for (final Object? item in data) {
      if (item is! Map) continue;
      out.add(ResearchReport(
        title: Em.str(item['title']),
        industry: Em.str(item['industryName']),
        org: Em.str(item['orgSName']),
        rating: Em.str(item['emRatingName']),
        time: _time(item['publishDate']),
      ));
    }
    return out;
  }
}
