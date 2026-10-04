/// Mock brokerage domain models. The real product talks to a counter
/// system; here everything is simulated locally so the flows remain
/// demonstrable without a backend.

class TradingUser {
  final String phone;
  final String name;
  final String customerNo;
  final String avatarSeed;

  const TradingUser({
    required this.phone,
    this.name = '投资者',
    this.customerNo = '8800123456',
    this.avatarSeed = 'cow',
  });
}

class AccountAsset {
  final double totalAsset;
  final double marketValue;
  final double available;
  final double frozen;
  final double dayPnl;
  final double dayPnlPct;
  final double totalPnl;

  const AccountAsset({
    required this.totalAsset,
    required this.marketValue,
    required this.available,
    required this.frozen,
    required this.dayPnl,
    required this.dayPnlPct,
    required this.totalPnl,
  });

  static const AccountAsset empty = AccountAsset(
    totalAsset: 0,
    marketValue: 0,
    available: 0,
    frozen: 0,
    dayPnl: 0,
    dayPnlPct: 0,
    totalPnl: 0,
  );
}

class Position {
  final String code;
  final String name;
  final int quantity;
  final int available;
  final double cost;
  final double price;
  final double marketValue;
  final double pnl;
  final double pnlPct;

  const Position({
    required this.code,
    required this.name,
    required this.quantity,
    required this.available,
    required this.cost,
    required this.price,
    required this.marketValue,
    required this.pnl,
    required this.pnlPct,
  });
}

class OrderRecord {
  final String time;
  final String code;
  final String name;
  final String side;
  final double price;
  final int quantity;
  final int filled;
  final String status;
  final String kind;

  const OrderRecord({
    required this.time,
    required this.code,
    required this.name,
    required this.side,
    required this.price,
    required this.quantity,
    this.filled = 0,
    this.status = '已报',
    this.kind = '普通',
  });
}

class DealRecord {
  final String time;
  final String code;
  final String name;
  final String side;
  final double price;
  final int quantity;
  final double amount;
  final double fee;

  const DealRecord({
    required this.time,
    required this.code,
    required this.name,
    required this.side,
    required this.price,
    required this.quantity,
    required this.amount,
    this.fee = 0,
  });
}

class IpoItem {
  final String code;
  final String name;
  final double issuePrice;
  final String applyDate;
  final double? expectedLotteryRate;

  const IpoItem({
    required this.code,
    required this.name,
    required this.issuePrice,
    required this.applyDate,
    this.expectedLotteryRate,
  });
}
