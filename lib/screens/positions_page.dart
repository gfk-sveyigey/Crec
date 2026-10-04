import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models/trading.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'stock_detail_page.dart';

/// 持仓 / 当日委托 / 当日成交 / 历史成交, all backed by the simulated
/// counter implemented in MockTradeApi.
class PositionsPage extends StatefulWidget {
  const PositionsPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<PositionsPage> createState() => _PositionsPageState();
}

class _PositionsPageState extends State<PositionsPage> {
  static const List<String> _tabs = <String>['持仓', '当日委托', '当日成交', '历史成交'];

  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final AccountAsset asset = state.asset;
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: Text(_tabs[_tab])),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: PillTabs(
              labels: _tabs,
              selected: _tab,
              onSelected: (int i) => setState(() => _tab = i),
            ),
          ),
          _assetStrip(asset),
          Expanded(child: _list(state)),
        ],
      ),
    );
  }

  Widget _assetStrip(AccountAsset a) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
      child: Row(
        children: <Widget>[
          _cell('总资产', two(a.totalAsset)),
          _cell('可用', two(a.available)),
          _cell('市值', two(a.marketValue)),
          _cell('累计盈亏', signed(a.totalPnl), color: changeColor(a.totalPnl)),
        ],
      ),
    );
  }

  Widget _cell(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 11, color: kTextSub)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color ?? kText),
          ),
        ],
      ),
    );
  }

  Widget _list(AppState state) {
    if (!state.tradeOpened) {
      return const Center(
        child: Text('请先登录交易账户', style: TextStyle(color: kTextSub, fontSize: 13)),
      );
    }
    switch (_tab) {
      case 0:
        return _positions(state);
      case 1:
        return _orders(state);
      case 2:
        return _deals(state);
      default:
        return _deals(state);
    }
  }

  Widget _positions(AppState state) {
    final List<Position> list = state.positions;
    if (list.isEmpty) {
      return const Center(
        child: Text('暂无持仓', style: TextStyle(color: kTextSub, fontSize: 13)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 24),
      itemCount: list.length,
      itemBuilder: (BuildContext context, int i) {
        final Position p = list[i];
        final Color c = changeColor(p.pnl);
        return SectionCard(
          onTap: () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => StockDetailPage(code: p.code, name: p.name),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    p.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kText),
                  ),
                  const SizedBox(width: 6),
                  Text(p.code, style: const TextStyle(fontSize: 12, color: kTextSub)),
                  const Spacer(),
                  Text(
                    two(p.price),
                    style: TextStyle(fontSize: 16, color: c, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  _cell('持仓/可用', p.quantity.toString() + '/' + p.available.toString()),
                  _cell('成本价', two(p.cost)),
                  _cell('市值', two(p.marketValue)),
                  _cell('浮动盈亏', signed(p.pnl) + '  ' + signedPct(p.pnlPct), color: c),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _orders(AppState state) {
    final List<OrderRecord> list = state.trade.orders();
    if (list.isEmpty) {
      return const Center(
        child: Text('暂无委托', style: TextStyle(color: kTextSub, fontSize: 13)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 10, bottom: 24),
      itemCount: list.length,
      separatorBuilder: (BuildContext context, int i) => const SizedBox(height: 1),
      itemBuilder: (BuildContext context, int i) {
        final OrderRecord o = list[i];
        final Color c = changeColor(o.side == '买入' ? 1 : -1);
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 40,
                child: Text(o.side, style: TextStyle(fontSize: 14, color: c)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      o.name + '  ' + o.code,
                      style: const TextStyle(fontSize: 14, color: kText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      o.time + '  ' + o.kind,
                      style: const TextStyle(fontSize: 11, color: kTextSub),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    two(o.price) + ' × ' + o.quantity.toString(),
                    style: const TextStyle(fontSize: 13, color: kText),
                  ),
                  const SizedBox(height: 4),
                  Text(o.status, style: const TextStyle(fontSize: 11, color: kTextSub)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _deals(AppState state) {
    final List<DealRecord> list = state.trade.deals();
    if (list.isEmpty) {
      return const Center(
        child: Text('暂无成交', style: TextStyle(color: kTextSub, fontSize: 13)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 10, bottom: 24),
      itemCount: list.length,
      separatorBuilder: (BuildContext context, int i) => const SizedBox(height: 1),
      itemBuilder: (BuildContext context, int i) {
        final DealRecord d = list[i];
        final Color c = d.side == '买入' ? kUp : kDown;
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 40,
                child: Text(d.side, style: TextStyle(fontSize: 14, color: c)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      d.name + '  ' + d.code,
                      style: const TextStyle(fontSize: 14, color: kText),
                    ),
                    const SizedBox(height: 4),
                    Text(d.time, style: const TextStyle(fontSize: 11, color: kTextSub)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    two(d.price) + ' × ' + d.quantity.toString(),
                    style: const TextStyle(fontSize: 13, color: kText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '成交额 ' + two(d.amount),
                    style: const TextStyle(fontSize: 11, color: kTextSub),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
