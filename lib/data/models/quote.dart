/// A real-time quote row, mirroring the field layout that the akshare
/// Eastmoney wrappers return.
class Quote {
  final String code;
  final String name;
  final String market;
  final double? price;
  final double? change;
  final double? changePct;
  final double? open;
  final double? high;
  final double? low;
  final double? prevClose;
  final double? volume;
  final double? amount;
  final double? turnover;
  final double? pe;
  final double? marketCap;
  final double? floatCap;
  final double? netInflow;
  final bool margin;
  final List<double> spark;

  const Quote({
    required this.code,
    required this.name,
    this.market = 'sh',
    this.price,
    this.change,
    this.changePct,
    this.open,
    this.high,
    this.low,
    this.prevClose,
    this.volume,
    this.amount,
    this.turnover,
    this.pe,
    this.marketCap,
    this.floatCap,
    this.netInflow,
    this.margin = false,
    this.spark = const <double>[],
  });

  Quote copyWith({List<double>? spark}) {
    return Quote(
      code: code,
      name: name,
      market: market,
      price: price,
      change: change,
      changePct: changePct,
      open: open,
      high: high,
      low: low,
      prevClose: prevClose,
      volume: volume,
      amount: amount,
      turnover: turnover,
      pe: pe,
      marketCap: marketCap,
      floatCap: floatCap,
      netInflow: netInflow,
      margin: margin,
      spark: spark ?? this.spark,
    );
  }
}

class TrendPoint {
  final DateTime time;
  final double price;
  final double avg;
  final double volume;

  const TrendPoint({
    required this.time,
    required this.price,
    required this.avg,
    required this.volume,
  });
}

class KlineBar {
  final DateTime time;
  final double open;
  final double close;
  final double high;
  final double low;
  final double volume;
  final double amount;
  final double changePct;
  final double turnover;

  const KlineBar({
    required this.time,
    required this.open,
    required this.close,
    required this.high,
    required this.low,
    required this.volume,
    required this.amount,
    required this.changePct,
    required this.turnover,
  });
}

/// 板块 (industry / concept) row.
class BoardRow {
  final String code;
  final String name;
  final double? changePct;
  final double? change;
  final double? netInflow;
  final int upCount;
  final int downCount;
  final String leaderName;
  final double? leaderPct;

  const BoardRow({
    required this.code,
    required this.name,
    this.changePct,
    this.change,
    this.netInflow,
    this.upCount = 0,
    this.downCount = 0,
    this.leaderName = '',
    this.leaderPct,
  });
}

/// 涨跌分布 used by the market page summary card.
class MarketActivity {
  final int limitUp;
  final int over7;
  final int from5to7;
  final int from2to5;
  final int from0to2;
  final int flat;
  final int down0to2;
  final int down2to5;
  final int down5to7;
  final int downOver7;
  final int limitDown;
  final double amount;
  final double amountDelta;
  final double marginBalance;
  final double mainNetInflow;

  const MarketActivity({
    this.limitUp = 0,
    this.over7 = 0,
    this.from5to7 = 0,
    this.from2to5 = 0,
    this.from0to2 = 0,
    this.flat = 0,
    this.down0to2 = 0,
    this.down2to5 = 0,
    this.down5to7 = 0,
    this.downOver7 = 0,
    this.limitDown = 0,
    this.amount = 0,
    this.amountDelta = 0,
    this.marginBalance = 0,
    this.mainNetInflow = 0,
  });

  int get upCount => limitUp + over7 + from5to7 + from2to5 + from0to2;
  int get downCount => down0to2 + down2to5 + down5to7 + downOver7 + limitDown;
}

class NewsItem {
  final String id;
  final String title;
  final String summary;
  final DateTime time;
  final String source;
  final String url;

  const NewsItem({
    required this.id,
    required this.title,
    this.summary = '',
    required this.time,
    this.source = '',
    this.url = '',
  });
}

class ResearchReport {
  final String title;
  final String industry;
  final String org;
  final String rating;
  final DateTime time;

  const ResearchReport({
    required this.title,
    this.industry = '',
    this.org = '',
    this.rating = '',
    required this.time,
  });
}

class FundRow {
  final String code;
  final String name;
  final double? nav;
  final double? dayPct;
  final double? monthPct;
  final double? yearPct;
  final double? threeYearPct;
  final String type;

  const FundRow({
    required this.code,
    required this.name,
    this.nav,
    this.dayPct,
    this.monthPct,
    this.yearPct,
    this.threeYearPct,
    this.type = '',
  });
}

class HotTopic {
  final String name;
  final double? changePct;
  final String upDownRatio;
  final double? netInflow;
  final String description;
  final List<HotStock> stocks;
  final List<double> spark;

  const HotTopic({
    required this.name,
    this.changePct,
    this.upDownRatio = '',
    this.netInflow,
    this.description = '',
    this.stocks = const <HotStock>[],
    this.spark = const <double>[],
  });
}

class HotStock {
  final String name;
  final double? changePct;

  const HotStock({required this.name, this.changePct});
}
