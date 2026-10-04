import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/common.dart';
import 'discover_page.dart';
import 'finance_page.dart';
import 'market_page.dart';
import 'profile_page.dart';
import 'trade_page.dart';
import 'watchlist_page.dart';

/// Bottom navigation shell with the six product tabs of the reference app.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _go(int index) {
    if (_index == index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: <Widget>[
          WatchlistPage(onOpenTab: _go),
          const MarketPage(),
          const DiscoverPage(),
          const TradePage(),
          const FinancePage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: _BottomBar(index: _index, onChanged: _go),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const List<String> _labels = <String>[
    '自选',
    '行情',
    '发现',
    '开户|交易',
    '理财',
    '我的',
  ];

  static const List<IconData> _icons = <IconData>[
    Icons.add_box_outlined,
    Icons.stacked_line_chart,
    Icons.pentagon_outlined,
    Icons.hexagon_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.person_outline,
  ];

  static const List<IconData> _activeIcons = <IconData>[
    Icons.add_box,
    Icons.stacked_line_chart,
    Icons.pentagon,
    Icons.hexagon,
    Icons.account_balance_wallet,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: kDivider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: List<Widget>.generate(6, (int i) {
              final bool active = i == index;
              final Color color = active ? kBrandRed : const Color(0xFF9AA0A6);
              if (i == 3) {
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        HexagonIcon(
                          size: 30,
                          color: active ? kBrandRed : const Color(0xFFB6BBC2),
                          icon: Icons.sync,
                          iconSize: 17,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _labels[i],
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(active ? _activeIcons[i] : _icons[i], size: 24, color: color),
                      const SizedBox(height: 2),
                      Text(
                        _labels[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
