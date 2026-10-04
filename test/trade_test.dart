import 'package:crec/data/mock_trade_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('simulated account opens, trades and settles', () {
    final MockTradeApi api = MockTradeApi.instance;
    api.close();
    expect(api.opened, isFalse);
    expect(api.asset().totalAsset, 0);

    api.open(initialCash: 100000);
    expect(api.opened, isTrue);
    expect(api.positions().length, 5);
    expect(api.asset().totalAsset, greaterThan(100000));

    final String? ok = api.place(
      code: '000001',
      name: '平安银行',
      side: '买入',
      price: 10,
      quantity: 100,
    );
    expect(ok, isNull);
    expect(api.orders().length, 1);
    expect(api.deals().length, 1);

    final String? odd = api.place(
      code: '000001',
      name: '平安银行',
      side: '买入',
      price: 10,
      quantity: 50,
    );
    expect(odd, '委托数量必须为100股的整数倍');

    final String? oversell = api.place(
      code: '601865',
      name: '福莱特',
      side: '卖出',
      price: 9,
      quantity: 900000,
    );
    expect(oversell, '持仓可用数量不足');

    api.close();
  });
}

