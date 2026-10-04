import 'package:crec/core/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compact uses Chinese units', () {
    expect(compact(1440000000000), '1.44万亿');
    expect(compact(1259000000), '12.59亿');
    expect(compact(32000), '3.20万');
    expect(compact(null), '--');
  });

  test('signed always marks the direction', () {
    expect(signed(1.5), '+1.50');
    expect(signed(-2.25), '-2.25');
    expect(signed(0), '0.00');
    expect(signedPct(0.31), '+0.31%');
  });

  test('secidOf maps the exchange prefix', () {
    expect(secidOf('600519'), '1.600519');
    expect(secidOf('000001'), '0.000001');
    expect(secidOf('300750'), '0.300750');
    expect(secidOf('1.000001'), '1.000001');
  });

  test('maskPhone hides the middle digits', () {
    expect(maskPhone('15500002274'), '155****2274');
  });
}

