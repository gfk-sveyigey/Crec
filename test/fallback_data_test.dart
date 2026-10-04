import 'package:crec/data/fallback_data.dart';
import 'package:crec/data/models/quote.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sample watchlist mirrors the reference screenshots', () {
    final List<Quote> rows = FallbackData.watchlist();
    expect(rows.length, 6);
    expect(rows.first.name, '金地集团');
    expect(rows.first.changePct, 7.45);
  });

  test('sample breadth data is internally consistent', () {
    final MarketActivity activity = FallbackData.activity();
    expect(activity.upCount, greaterThan(0));
    expect(activity.downCount, greaterThan(activity.upCount));
  });

  test('sparkline walk always matches its end point', () {
    final List<double> values = FallbackData.walk(start: 10, end: 12, points: 30);
    expect(values.length, 30);
    expect(values.last, 12);
  });
}

