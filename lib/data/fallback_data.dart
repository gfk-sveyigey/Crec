import 'dart:math';

import 'models/quote.dart';

/// Bundled sample data mirroring the reference screenshots. It keeps the
/// app fully browsable when the public endpoints are unreachable
/// (no network, rate limiting, market holiday ...).
class FallbackData {
  FallbackData._();

  /// Deterministic pseudo random walk used for sparklines.
  static List<double> walk({
    required double start,
    required double end,
    int points = 60,
    int seed = 7,
  }) {
    final List<double> out = <double>[];
    final Random rng = Random(seed);
    double v = start;
    final double step = (end - start) / points;
    for (int i = 0; i < points; i++) {
      v += step + (rng.nextDouble() - 0.5) * (start.abs() * 0.004 + 0.01);
      out.add(v);
    }
    out[out.length - 1] = end;
    return out;
  }

  static const List<List<String>> watchlistSeed = <List<String>>[
    <String>['600383', '金地集团', '2.74', '7.45'],
    <String>['601865', '福莱特', '9.22', '1.32'],
    <String>['605011', '杭州热电', '19.21', '10.02'],
    <String>['001246', 'N力勤', '65.09', '206.59'],
    <String>['605499', '东鹏饮料', '112.25', '1.87'],
    <String>['600211', '西藏药业', '36.35', '1.65'],
  ];

  static List<Quote> watchlist() {
    return watchlistSeed.map((List<String> row) {
      final double price = double.parse(row[2]);
      final double pct = double.parse(row[3]);
      final double prev = price / (1 + pct / 100);
      return Quote(
        code: row[0],
        name: row[1],
        price: price,
        changePct: pct,
        change: price - prev,
        prevClose: prev,
        margin: true,
        spark: walk(start: prev, end: price, seed: price.hashCode + 11),
      );
    }).toList();
  }

  static List<Quote> indexes() {
    return const <List<String>>[
      <String>['000001', '上证指数', '3842.19', '0.31'],
      <String>['399001', '深证成指', '12887.62', '-0.11'],
      <String>['899050', '北证50', '1039.61', '0.70'],
    ].map((List<String> row) {
      final double price = double.parse(row[2]);
      final double pct = double.parse(row[3]);
      final double prev = price / (1 + pct / 100);
      return Quote(
        code: row[0],
        name: row[1],
        price: price,
        changePct: pct,
        change: price - prev,
        prevClose: prev,
        spark: walk(start: prev, end: price, seed: price.hashCode + 3),
      );
    }).toList();
  }

  static MarketActivity activity() => const MarketActivity(
        limitUp: 56,
        over7: 97,
        from5to7: 50,
        from2to5: 544,
        from0to2: 1876,
        flat: 170,
        down0to2: 1848,
        down2to5: 845,
        down5to7: 87,
        downOver7: 44,
        limitDown: 12,
        amount: 1440000000000,
        amountDelta: 28800000000,
        marginBalance: 2610000000000,
        mainNetInflow: -9684000000,
      );

  static List<BoardRow> industryBoards() => const <BoardRow>[
        BoardRow(code: 'BK0465', name: '生物制品', changePct: 4.52, netInflow: 1259000000, upCount: 56, downCount: 1, leaderName: '康希诺'),
        BoardRow(code: 'BK0727', name: '医疗服务', changePct: 3.11, netInflow: 860000000, upCount: 42, downCount: 6, leaderName: '泰格医药'),
        BoardRow(code: 'BK0477', name: '酒类', changePct: 2.04, netInflow: 640000000, upCount: 21, downCount: 5, leaderName: '东鹏饮料'),
        BoardRow(code: 'BK1036', name: '半导体', changePct: 1.68, netInflow: 520000000, upCount: 88, downCount: 24, leaderName: '中芯国际'),
        BoardRow(code: 'BK0910', name: '光伏设备', changePct: -1.24, netInflow: -430000000, upCount: 12, downCount: 46, leaderName: '福莱特'),
        BoardRow(code: 'BK0733', name: '房地产开发', changePct: 0.86, netInflow: 210000000, upCount: 63, downCount: 40, leaderName: '金地集团'),
      ];

  static List<BoardRow> conceptBoards() => const <BoardRow>[
        BoardRow(code: 'BK1158', name: '生物制品', changePct: 4.52, netInflow: 1259000000, upCount: 56, downCount: 1, leaderName: '康希诺'),
        BoardRow(code: 'BK0964', name: '重组蛋白', changePct: 3.86, netInflow: 720000000, upCount: 18, downCount: 2, leaderName: '义翘神州'),
        BoardRow(code: 'BK0816', name: 'CRO', changePct: 3.02, netInflow: 560000000, upCount: 15, downCount: 3, leaderName: '药明康德'),
        BoardRow(code: 'BK0965', name: '转基因', changePct: 2.44, netInflow: 320000000, upCount: 22, downCount: 6, leaderName: '大北农'),
        BoardRow(code: 'BK0988', name: 'CAR-T细胞', changePct: 2.10, netInflow: 210000000, upCount: 12, downCount: 4, leaderName: '金斯瑞'),
      ];

  static List<FundRow> funds() => const <FundRow>[
        FundRow(code: '020653', name: '恒生前海兴泰混合A', nav: 1.2345, dayPct: 0.51, monthPct: 6.71, yearPct: 12.34, threeYearPct: 21.05, type: '混合型'),
        FundRow(code: '020654', name: '恒生前海兴泰混合C', nav: 1.2288, dayPct: 0.49, monthPct: 6.62, yearPct: 12.02, threeYearPct: 20.11, type: '混合型'),
        FundRow(code: '000001', name: '华夏成长混合', nav: 1.0230, dayPct: 0.29, monthPct: 3.42, yearPct: 8.76, threeYearPct: 15.30, type: '混合型'),
        FundRow(code: '110022', name: '易方达消费行业', nav: 3.4520, dayPct: -0.18, monthPct: 2.10, yearPct: 6.44, threeYearPct: 9.87, type: '股票型'),
        FundRow(code: '161725', name: '招商中证白酒指数', nav: 0.9876, dayPct: 1.02, monthPct: 4.55, yearPct: -3.21, threeYearPct: -8.40, type: '指数型'),
      ];

  static List<Quote> hotLeaders() => const <Quote>[
        Quote(code: '688185', name: '康希诺', price: 84.20, changePct: 20.00, change: 14.03, market: 'sh'),
        Quote(code: '688798', name: '泰诺麦博-U', price: 62.15, changePct: 19.99, change: 10.35, market: 'sh'),
      ];

  static List<HotTopic> hotTopics() => <HotTopic>[
        HotTopic(
          name: '生物制品',
          changePct: 4.52,
          upDownRatio: '56:1',
          netInflow: 1259000000,
          description: '生物制品，是指用微生物、细胞、动物或人源组织、体液等生物材料，通过生物技术制备的药品。',
          stocks: hotLeaders(),
          spark: walk(start: 0, end: 1, points: 48, seed: 21),
        ),
        HotTopic(
          name: '重组蛋白',
          changePct: 3.86,
          upDownRatio: '18:2',
          netInflow: 720000000,
          description: '重组蛋白是应用基因重组技术表达的蛋白产品，广泛用于科研、诊断与生物药生产。',
          stocks: const <HotStock>[
            HotStock(name: '义翘神州', changePct: 11.40),
            HotStock(name: '百普赛斯', changePct: 8.62),
          ],
          spark: walk(start: 0, end: 1, points: 48, seed: 22),
        ),
        HotTopic(
          name: 'CRO',
          changePct: 3.02,
          upDownRatio: '15:3',
          netInflow: 560000000,
          description: 'CRO 即医药研发合同外包服务，为药企提供从药物发现到临床研究的一体化服务。',
          stocks: const <HotStock>[
            HotStock(name: '药明康德', changePct: 6.21),
            HotStock(name: '泰格医药', changePct: 5.04),
          ],
          spark: walk(start: 0, end: 1, points: 48, seed: 23),
        ),
        HotTopic(
          name: '转基因',
          changePct: 2.44,
          upDownRatio: '22:6',
          netInflow: 320000000,
          description: '转基因技术通过基因工程改良作物性状，是种业振兴的重要方向。',
          stocks: const <HotStock>[
            HotStock(name: '大北农', changePct: 7.30),
            HotStock(name: '隆平高科', changePct: 4.18),
          ],
          spark: walk(start: 0, end: 1, points: 48, seed: 24),
        ),
        HotTopic(
          name: 'CAR-T细胞',
          changePct: 2.10,
          upDownRatio: '12:4',
          netInflow: 210000000,
          description: 'CAR-T 是嵌合抗原受体T细胞免疫疗法，在血液肿瘤治疗领域进展迅速。',
          stocks: const <HotStock>[
            HotStock(name: '金斯瑞生物', changePct: 9.10),
            HotStock(name: '复星医药', changePct: 3.42),
          ],
          spark: walk(start: 0, end: 1, points: 48, seed: 25),
        ),
      ];
}
