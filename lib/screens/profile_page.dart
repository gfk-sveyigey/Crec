import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'login_page.dart';
import 'placeholder_page.dart';

/// 我的 - account header, new-customer benefits and service entries.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    return Scaffold(
      backgroundColor: kBg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _header(context, state),
          _benefits(context, state),
          _assetCard(context, state),
          _services(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, AppState state) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFFF04A3C), Color(0xFFE93323)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => _login(context, state),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFE3B8),
                          ),
                          child: const Icon(Icons.pets, size: 28, color: Color(0xFFE93323)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  state.tradeOpened ? '我的交易账户' : '交易登录',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const AssetIcon(
                                  'assets/icons/action/arrow_right.png',
                                  width: 9,
                                  height: 18,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.loggedIn
                                  ? maskPhone(state.phone ?? '')
                                  : '点击登录，体验完整功能',
                              style: const TextStyle(color: Color(0xFFFFD9CF), fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chat_bubble_outline, size: 22, color: Colors.white),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 8, 18),
              child: Row(
                children: <Widget>[
                  _headerAction(context, Icons.confirmation_number_outlined, '我的卡券'),
                  _headerAction(context, Icons.star_border, '我的星级'),
                  _headerAction(context, Icons.headset_mic_outlined, '服务专员'),
                  _headerAction(context, Icons.settings_outlined, '设置'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerAction(BuildContext context, IconData icon, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _go(context, label),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _benefits(BuildContext context, AppState state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFF6E6), Color(0xFFFFEFD6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: <Widget>[
          const Text(
            '新户专享',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFC8391F)),
          ),
          const SizedBox(height: 10),
          NavGridView(
            columns: 2,
            iconSize: 20,
            labelSize: 14,
            entries: const <NavEntry>[
              NavEntry(icon: Icons.savings, label: '国新牛基', color: Color(0xFFE93323)),
              NavEntry(icon: Icons.school_outlined, label: '小白理财课', color: Color(0xFFE93323)),
              NavEntry(icon: Icons.assignment_turned_in_outlined, label: '智能条件单', color: Color(0xFFE93323)),
              NavEntry(icon: Icons.live_tv_outlined, label: '精彩直播', color: Color(0xFFE93323)),
              NavEntry(icon: Icons.support_agent, label: '专属服务', color: Color(0xFFE93323)),
              NavEntry(icon: Icons.card_giftcard, label: '多重投教好礼', color: Color(0xFFE93323)),
            ],
          ),
          const Text(
            '市场有风险，投资需谨慎',
            style: TextStyle(fontSize: 11, color: kTextFaint),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: BrandButton(
                  label: '已有账号，去登录',
                  outlined: true,
                  height: 44,
                  fontSize: 15,
                  textColor: kBrandRed,
                  onPressed: () => _login(context, state),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BrandButton(
                  label: '开户领取',
                  height: 44,
                  fontSize: 15,
                  gradient: const <Color>[Color(0xFFF5453A), Color(0xFFE93323)],
                  onPressed: () => _login(context, state),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _assetCard(BuildContext context, AppState state) {
    if (state.tradeOpened) {
      final double pnl = state.asset.totalPnl;
      return SectionCard(
        child: Row(
          children: <Widget>[
            const Text(
              '资产分析',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kText),
            ),
            const Spacer(),
            Text(
              '累计盈亏 ' + signed(pnl),
              style: TextStyle(fontSize: 14, color: changeColor(pnl)),
            ),
            const AssetIcon('assets/icons/action/arrow_right.png', width: 9, height: 18),
          ],
        ),
      );
    }
    return SectionCard(
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '资产分析',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kText),
                ),
                SizedBox(height: 6),
                Text(
                  '登录证券账户后可查看资产与分析',
                  style: TextStyle(fontSize: 12, color: kTextSub),
                ),
              ],
            ),
          ),
          BrandButton(
            label: '立即登录',
            height: 34,
            fontSize: 13,
            gradient: const <Color>[Color(0xFFF5453A), Color(0xFFE93323)],
            onPressed: () => _login(context, state),
          ),
        ],
      ),
    );
  }

  Widget _services(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '服务&工具',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kText),
            ),
          ),
          NavGridView(
            columns: 4,
            iconSize: 26,
            entries: <NavEntry>[
              NavEntry(icon: Icons.work_outline, label: '业务办理', color: kTextSub, onTap: () => _go(context, '业务办理')),
              NavEntry(icon: Icons.chrome_reader_mode_outlined, label: '信息公示', color: kTextSub, onTap: () => _go(context, '信息公示')),
              NavEntry(icon: Icons.verified_outlined, label: '参与回访', color: kTextSub, onTap: () => _go(context, '参与回访')),
              NavEntry(icon: Icons.explore_outlined, label: '操作指南', color: kTextSub, onTap: () => _go(context, '操作指南')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _login(BuildContext context, AppState state) async {
    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const LoginPage(trade: true)),
    );
    if (ok == true) await state.openTradeAccount();
  }

  void _go(BuildContext context, String title) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => PlaceholderPage(title: title)),
    );
  }
}
