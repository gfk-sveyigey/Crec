import 'market_api.dart';
import 'models/quote.dart';
import 'models/trading.dart';

/// Local simulation of the counter (交易) system. The reference app is
/// logged in with a phone number but has not bound a brokerage account,
/// so the trade tab shows the "立即登录" state until [open] is called.
class MockTradeApi {
  MockTradeApi._();

  static final MockTradeApi instance = MockTradeApi._();

  bool _opened = false;
  double _cash = 0;
  double _frozen = 0;
  final Map<String, _Lot> _lots = <String, _Lot>{};
  final List<OrderRecord> _orders = <OrderRecord>[];
  final List<DealRecord> _deals = <DealRecord>[];

  bool get opened => _opened;

  /// Simulated account opening / 交易登录.
  void open({double initialCash = 268000}) {
    _opened = true;
    _cash = initialCash;
    _frozen = 0;
    _lots.clear();
    _orders.clear();
    _deals.clear();
    _seed('600519', '贵州茅台', 100, 1620.00);
    _seed('000001', '平安银行', 2000, 11.20);
    _seed('601865', '福莱特', 1500, 8.90);
    _seed('300750', '宁德时代', 200, 208.50);
    _seed('605499', '东鹏饮料', 300, 108.30);
  }

  void close() {
    _opened = false;
    _cash = 0;
    _lots.clear();
  }

  void _seed(String code, String name, int qty, double cost) {
    _lots[code] = _Lot(code: code, name: name, quantity: qty, cost: cost);
  }

  double _price(String code, double fallback) {
    final Quote? q = MarketApi.cached(code);
    final double? p = q?.price;
    if (p == null || p <= 0) return fallback;
    return p;
  }

  AccountAsset asset() {
    if (!_opened) return AccountAsset.empty;
    double marketValue = 0;
    double totalCost = 0;
    for (final _Lot lot in _lots.values) {
      final double price = _price(lot.code, lot.cost);
      marketValue += price * lot.quantity;
      totalCost += lot.cost * lot.quantity;
    }
    final double total = _cash + marketValue;
    final double pnl = marketValue - totalCost;
    return AccountAsset(
      totalAsset: total,
      marketValue: marketValue,
      available: _cash,
      frozen: _frozen,
      dayPnl: pnl * 0.12,
      dayPnlPct: marketValue == 0 ? 0 : (pnl * 0.12) / total * 100,
      totalPnl: pnl,
    );
  }

  List<Position> positions() {
    final List<Position> out = <Position>[];
    for (final _Lot lot in _lots.values) {
      if (lot.quantity <= 0) continue;
      final double price = _price(lot.code, lot.cost);
      final double mv = price * lot.quantity;
      final double pnl = (price - lot.cost) * lot.quantity;
      out.add(Position(
        code: lot.code,
        name: lot.name,
        quantity: lot.quantity,
        available: lot.quantity,
        cost: lot.cost,
        price: price,
        marketValue: mv,
        pnl: pnl,
        pnlPct: lot.cost == 0 ? 0 : (price - lot.cost) / lot.cost * 100,
      ));
    }
    out.sort((Position a, Position b) => b.marketValue.compareTo(a.marketValue));
    return out;
  }

  List<OrderRecord> orders() => List<OrderRecord>.unmodifiable(_orders.reversed);

  List<DealRecord> deals() => List<DealRecord>.unmodifiable(_deals.reversed);

  String _now() {
    final DateTime t = DateTime.now();
    String p(int n) => n < 10 ? '0' + n.toString() : n.toString();
    return p(t.hour) + ':' + p(t.minute) + ':' + p(t.second);
  }

  /// Returns an error message, or null when the order is accepted.
  String? place({
    required String code,
    required String name,
    required String side,
    required double price,
    required int quantity,
    String kind = '普通',
  }) {
    if (!_opened) return '请先登录交易账户';
    if (quantity <= 0 || quantity % 100 != 0) return '委托数量必须为100股的整数倍';
    if (price <= 0) return '请输入有效的委托价格';
    final double amount = price * quantity;
    if (side == '买入') {
      if (amount > _cash) return '可用资金不足';
      _cash -= amount;
    } else {
      final _Lot? lot = _lots[code];
      if (lot == null || lot.quantity < quantity) return '持仓可用数量不足';
      lot.quantity -= quantity;
    }
    _orders.add(OrderRecord(
      time: _now(),
      code: code,
      name: name,
      side: side,
      price: price,
      quantity: quantity,
      filled: quantity,
      status: '已成',
      kind: kind,
    ));
    _deals.add(DealRecord(
      time: _now(),
      code: code,
      name: name,
      side: side,
      price: price,
      quantity: quantity,
      amount: amount,
      fee: amount * 0.00025 < 5 ? 5 : amount * 0.00025,
    ));
    if (side == '买入') {
      final _Lot? lot = _lots[code];
      if (lot == null) {
        _lots[code] = _Lot(code: code, name: name, quantity: quantity, cost: price);
      } else {
        final int total = lot.quantity + quantity;
        lot.cost = (lot.cost * lot.quantity + price * quantity) / total;
        lot.quantity = total;
      }
    }
    return null;
  }

  void cancel(int reversedIndex) {
    final int index = _orders.length - 1 - reversedIndex;
    if (index < 0 || index >= _orders.length) return;
    final OrderRecord o = _orders[index];
    if (o.status == '已成') return;
    _orders[index] = OrderRecord(
      time: o.time,
      code: o.code,
      name: o.name,
      side: o.side,
      price: o.price,
      quantity: o.quantity,
      filled: o.filled,
      status: '已撤',
      kind: o.kind,
    );
  }

  String? transferIn(double amount) {
    if (!_opened) return '请先登录交易账户';
    if (amount <= 0) return '请输入有效金额';
    _cash += amount;
    return null;
  }

  String? transferOut(double amount) {
    if (!_opened) return '请先登录交易账户';
    if (amount <= 0) return '请输入有效金额';
    if (amount > _cash) return '可用资金不足';
    _cash -= amount;
    return null;
  }

  List<IpoItem> ipos() => const <IpoItem>[
        IpoItem(code: '301655', name: '思泉新材', issuePrice: 21.66, applyDate: '10-09'),
        IpoItem(code: '787313', name: '中科飞测', issuePrice: 30.15, applyDate: '10-10'),
        IpoItem(code: '001388', name: '国科天成', issuePrice: 12.80, applyDate: '10-11'),
      ];
}

class _Lot {
  _Lot({
    required this.code,
    required this.name,
    required this.quantity,
    required this.cost,
  });

  final String code;
  final String name;
  int quantity;
  double cost;
}
