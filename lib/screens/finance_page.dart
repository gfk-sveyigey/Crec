import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models/quote.dart';
import '../data/models/trading.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'login_page.dart';
import 'placeholder_page.dart';

/// 理财 - wealth management shelf, strategy cards and the fund ranking.
class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  int _category = 0;

  static const List<String> _categories = <String>['全部', '公募', '信托', '私募'];

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: <Widget>[
          const AppTopBar(title: '理财'),
          Expanded(
            child: RefreshIndicator(
              color: kBrandRed,
              onRefresh: state.refreshMarket,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: <Widget>[
                  _assetBanner(state),
                  SectionCard(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: NavGridView(
                      entries: <NavEntry>[
                        NavEntry(icon: Icons.savings_outlined, label: '国新牛基', color: const Color(0xFFE8933A), onTap: () => _go('国新牛基')),
                        NavEntry(icon: Icons.currency_yuan, label: '活钱管理', color: const Color(0xFFE8933A), onTap: () => _go('活钱管理')),
                        NavEntry(icon: Icons.shield_outlined, label: '稳健理财', color: const Color(0xFFE8933A), onTap: () => _go('稳健理财')),
                        NavEntry(icon: Icons.trending_up, label: '进阶投资', color: const Color(0xFFE8933A), onTap: () => _go('进阶投资')),
                        NavEntry(icon: Icons.diamond_outlined, label: '高端理财', color: const Color(0xFFE8933A), onTap: () => _go('高端理财')),
                        NavEntry(icon: Icons.timer_outlined, label: '定投专区', color: const Color(0xFFE8933A), onTap: () => _go('定投专区')),
                        NavEntry(icon: Icons.pie_chart_outline, label: '星基ETF', color: const Color(0xFFE8933A), onTap: () => _go('星基ETF')),
                        NavEntry(icon: Icons.swap_calls, label: '资产配置', color: const Color(0xFFE8933A), onTap: () => _go('资产配置')),
                        NavEntry(icon: Icons.favorite_border, label: '家庭信托', color: const Color(0xFFE8933A), onTap: () => _go('家庭信托')),
                        NavEntry(icon: Icons.more_horiz, label: '更多', color: const Color(0xFFE8933A), onTap: () => _go('更多')),
                      ],
                    ),
                  ),
                  _promoRow(),
                  SectionHeader(
                    title: '火热发售',
                    accent: const Icon(Icons.local_fire_department, size: 18, color: kBrandRed),
                    onMore: () {},
                  ),
                  PillTabs(
                    labels: _categories,
                    selected: _category,
                    dense: true,
                    onSelected: (int i) => setState(() => _category = i),
                  ),
                  ...state.funds.take(6).map((FundRow f) => _fundCard(f)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _assetBanner(AppState state) {
    if (state.tradeOpened) {
      final AccountAsset a = state.asset;
      return SectionCard(
        color: const Color(0xFFFFF8EC),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('总资产（元）', style: TextStyle(fontSize: 12, color: kTextSub)),
                const SizedBox(height: 6),
                Text(
                  two(a.totalAsset),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kText),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '今日盈亏 ' + signed(a.dayPnl),
                style: TextStyle(fontSize: 13, color: changeColor(a.dayPnl)),
              ),
            ),
          ],
        ),
      );
    }
    return SectionCard(
      color: const Color(0xFFFFF8EC),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              '登录后可查看资产与盈亏',
              style: TextStyle(fontSize: 14, color: kText),
            ),
          ),
          BrandButton(
            label: '立即登录',
            height: 34,
            fontSize: 13,
            gradient: const <Color>[Color(0xFFF5453A), Color(0xFFE93323)],
            onPressed: () => _login(state),
          ),
        ],
      ),
    );
  }

  Widget _promoRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => _go('恒生前海兴泰混合'),
              child: Container(
                height: 210,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFFE23B2E), Color(0xFFC0271C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      '恒生前海',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '挖掘红利机遇\n时间见证价值',
                      style: TextStyle(color: Colors.white, fontSize: 15, height: 1.3),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD466),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '火热销售中',
                        style: TextStyle(fontSize: 10, color: Color(0xFF8A2B12)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '恒生前海兴泰混合基金',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'A类020653 C类020654',
                      style: TextStyle(color: Color(0xFFFFD9B0), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () => _go('产品配置策略'),
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFFFF3E2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          '产品配置策略',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF8A4B12)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDCA8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '2026年10月',
                            style: TextStyle(fontSize: 10, color: Color(0xFF8A4B12)),
                          ),
                        ),
                        const Spacer(),
                        const Text('国新证券', style: TextStyle(fontSize: 11, color: Color(0xFF9A7040))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _go('定投'),
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFEDF4FF),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        Text(
                          '稳稳赢取微笑曲线',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF23539E)),
                        ),
                        Spacer(),
                        Text('试试定投 >', style: TextStyle(fontSize: 12, color: Color(0xFF3E7BD4))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fundCard(FundRow f) {
    final Color c = changeColor(f.monthPct);
    return SectionCard(
      onTap: () => _go(f.name),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        f.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, color: kText),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(f.code, style: const TextStyle(fontSize: 12, color: kTextSub)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      signedPct(f.monthPct),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        '近1月',
                        style: const TextStyle(fontSize: 11, color: kTextSub),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '净值 ' + two(f.nav) + '   近1年 ' + signedPct(f.yearPct),
                  style: const TextStyle(fontSize: 11, color: kTextSub),
                ),
              ],
            ),
          ),
          const Icon(Icons.add_circle_outline, size: 22, color: kTextFaint),
        ],
      ),
    );
  }

  Future<void> _login(AppState state) async {
    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const LoginPage(trade: true)),
    );
    if (ok == true) await state.openTradeAccount();
  }

  void _go(String title) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => PlaceholderPage(title: title)),
    );
  }
}
