import 'package:flutter/material.dart';

import '../core/theme.dart';
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

  /// 图标取自脱壳 IPA 的 Assets.car（tztzf_toolbar_*），与原 App 一致。
  static const List<String> _names = <String>[
    'watchlist',
    'market',
    'discover',
    'trade',
    'finance',
    'profile',
  ];

  static const List<String> _labels = <String>[
    '自选',
    '行情',
    '发现',
    '开户|交易',
    '理财',
    '我的',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: kTabBarBorder)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: Row(
            children: List<Widget>.generate(6, (int i) {
              final bool active = i == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/tab/' +
                            _names[i] +
                            (active ? '_active' : '') +
                            '.png',
                        width: 24,
                        height: 24,
                        filterQuality: FilterQuality.high,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _labels[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: active ? kBrandRed : kTextSub,
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
