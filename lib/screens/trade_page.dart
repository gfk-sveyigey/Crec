import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models/quote.dart';
import '../data/models/trading.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'login_page.dart';
import 'positions_page.dart';
import 'placeholder_page.dart';

/// 开户|交易 - 开户 / 普通 / 信用 / 期权 sub tabs.
class TradePage extends StatefulWidget {
  const TradePage({super.key});

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  static const List<String> _tabs = <String>['开户', '普通', '信用', '期权'];

  int _tab = 0;

  static const Color _buyColor = Color(0xFFE93323);
  static const Color _sellColor = Color(0xFF2B6BE4);
  static const Color _holdColor = Color(0xFFC79A2E);
  static const Color _cancelColor = Color(0xFF8A9099);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: <Widget>[
          AppTopBar(
            title: '开户',
            tabs: _tabs,
            selectedTab: _tab,
            onTabSelected: (int i) => setState(() => _tab = i),
            onSearch: () {},
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    switch (_tab) {
      case 1:
        return _normalTab();
      case 2:
        return _creditTab();
      case 3:
        return _optionTab();
      default:
        return _openAccountTab();
    }
  }

  // -------------------------------------------------------------- 开户 tab

  Widget _openAccountTab() {
    final AppState state = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Color(0xFFF5453A), Color(0xFFE93323)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '开户即享',
                style: TextStyle(
                  color: Color(0xFFFFE3A8),
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const Text(
                '多重福利',
                style: TextStyle(
                  color: Color(0xFFFFC24A),
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7EC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: <Widget>[
                    const Text(
                      '新客专享六大福利',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC8391F),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                    BrandButton(
                      label: '开户领取',
                      fontSize: 18,
                      height: 46,
                      onPressed: () => _requireLogin(state, thenOpen: true),
                    ),
                    const SizedBox(height: 10),
                    BrandButton(
                      label: '已有账户，去登录',
                      fontSize: 18,
                      height: 46,
                      gradient: const <Color>[Color(0xFFE93323), Color(0xFFF5453A)],
                      onPressed: () => _requireLogin(state),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SectionCard(
          child: Row(
            children: <Widget>[
              const Icon(Icons.verified_user_outlined, size: 34, color: kBrandRed),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '7x24小时在线开户',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '准备好身份证和银行卡，最快3分钟完成',
                      style: TextStyle(fontSize: 12, color: kTextSub),
                    ),
                  ],
                ),
              ),
              BrandButton(
                label: '立即开户',
                height: 34,
                fontSize: 13,
                onPressed: () => _requireLogin(state, thenOpen: true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------- 普通 tab

  Widget _normalTab() {
    final AppState state = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: <Widget>[
        _accountBar(state),
        if (state.tradeOpened) _assetCard(state),
        SectionCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: NavGridView(
            columns: 4,
            iconSize: 22,
            entries: <NavEntry>[
              NavEntry(icon: Icons.arrow_downward, label: '买入', color: _buyColor, onTap: () => _order(state, '买入')),
              NavEntry(icon: Icons.arrow_upward, label: '卖出', color: _sellColor, onTap: () => _order(state, '卖出')),
              NavEntry(icon: Icons.inventory_2_outlined, label: '持仓', color: _holdColor, onTap: () => _openPositions(state, 0)),
              NavEntry(icon: Icons.undo, label: '撤单', color: _cancelColor, onTap: () => _openPositions(state, 1)),
              NavEntry(icon: Icons.swap_horiz, label: '银证转账', color: kBrandRed, onTap: () => _transfer(state)),
              NavEntry(icon: Icons.receipt_long_outlined, label: '当日成交', color: kBrandRed, onTap: () => _openPositions(state, 2)),
              NavEntry(icon: Icons.history, label: '历史成交', color: kBrandRed, onTap: () => _openPositions(state, 3)),
              NavEntry(icon: Icons.search, label: '更多查询', color: kBrandRed, onTap: () => _placeholder('更多查询')),
            ],
          ),
        ),
        _ipoCard(state),
        _featuresCard(
          title: '特色交易',
          rows: <List<NavEntry>>[
            <NavEntry>[
              NavEntry(icon: Icons.assignment_outlined, label: '智能条件单', onTap: () => _placeholder('智能条件单')),
              NavEntry(icon: Icons.swap_horiz, label: '通用回购', onTap: () => _placeholder('通用回购')),
            ],
            <NavEntry>[
              NavEntry(icon: Icons.currency_yuan, label: '债券交易', onTap: () => _placeholder('债券交易')),
              NavEntry(icon: Icons.public, label: '港股通', onTap: () => _placeholder('港股通')),
            ],
            <NavEntry>[
              NavEntry(icon: Icons.pie_chart_outline, label: '场内基金', onTap: () => _placeholder('场内基金')),
              NavEntry(icon: Icons.apartment, label: '北交所', onTap: () => _placeholder('北交所')),
            ],
            <NavEntry>[
              NavEntry(icon: Icons.bar_chart, label: '新三板', onTap: () => _placeholder('新三板')),
              NavEntry(icon: Icons.donut_large, label: '大宗交易', onTap: () => _placeholder('大宗交易')),
            ],
          ],
        ),
        SectionCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              LinkRow(title: '日内回转交易', icon: Icons.autorenew, onTap: () => _placeholder('日内回转交易')),
              const Divider(height: 1, indent: 12, endIndent: 12),
              LinkRow(
                title: '网格回测',
                icon: Icons.grid_on,
                badge: '新增',
                onTap: () => _placeholder('网格回测'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------- 信用 tab

  Widget _creditTab() {
    final AppState state = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: <Widget>[
        _accountBar(state, credit: true),
        if (state.tradeOpened) _assetCard(state),
        SectionCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: NavGridView(
            columns: 4,
            iconSize: 22,
            entries: <NavEntry>[
              NavEntry(icon: Icons.arrow_downward, label: '担保品买入', color: _buyColor, onTap: () => _order(state, '买入')),
              NavEntry(icon: Icons.arrow_upward, label: '担保品卖出', color: _sellColor, onTap: () => _order(state, '卖出')),
              NavEntry(icon: Icons.trending_down, label: '融资买入', color: _buyColor, onTap: () => _order(state, '买入', kind: '融资')),
              NavEntry(icon: Icons.trending_up, label: '融券卖出', color: _sellColor, onTap: () => _order(state, '卖出', kind: '融券')),
              NavEntry(icon: Icons.payments_outlined, label: '卖券还款', color: _sellColor, onTap: () => _placeholder('卖券还款')),
              NavEntry(icon: Icons.assignment_return_outlined, label: '买券还券', color: _buyColor, onTap: () => _placeholder('买券还券')),
              NavEntry(icon: Icons.undo, label: '撤单', color: _cancelColor, onTap: () => _openPositions(state, 1)),
              NavEntry(icon: Icons.inventory_2_outlined, label: '持仓', color: _holdColor, onTap: () => _openPositions(state, 0)),
              NavEntry(icon: Icons.receipt_long_outlined, label: '当日委托', color: kBrandRed, onTap: () => _openPositions(state, 1)),
              NavEntry(icon: Icons.event_available_outlined, label: '当日成交', color: kBrandRed, onTap: () => _openPositions(state, 2)),
              NavEntry(icon: Icons.swap_horiz, label: '银证转账', color: kBrandRed, onTap: () => _transfer(state)),
              NavEntry(icon: Icons.search, label: '更多查询', color: kBrandRed, onTap: () => _placeholder('更多查询')),
            ],
          ),
        ),
        _ipoCard(state),
        SectionCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              LinkRow(title: '融E惠', icon: Icons.card_membership, onTap: () => _placeholder('融E惠')),
              const Divider(height: 1, indent: 12, endIndent: 12),
              LinkRow(title: '智能条件单', icon: Icons.assignment_outlined, badge: '新增', onTap: () => _placeholder('智能条件单')),
              const Divider(height: 1, indent: 12, endIndent: 12),
              LinkRow(title: '专用券源', icon: Icons.source_outlined, onTap: () => _placeholder('专用券源')),
              const Divider(height: 1, indent: 12, endIndent: 12),
              LinkRow(title: '直接还款', icon: Icons.payments_outlined, onTap: () => _placeholder('直接还款')),
              const Divider(height: 1, indent: 12, endIndent: 12),
              LinkRow(title: '现券还券', icon: Icons.inventory_outlined, onTap: () => _placeholder('现券还券')),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------- 期权 tab

  Widget _optionTab() {
    final AppState state = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Color(0xFFF7F9FC), Color(0xFFEDF2F9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: <Widget>[
              const Text(
                '极速登录，查看用户明细',
                style: TextStyle(fontSize: 15, color: kTextSub),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 150,
                child: BrandButton(
                  label: state.tradeOpened ? '已登录' : '登录',
                  outlined: true,
                  height: 40,
                  textColor: kBrandRed,
                  fontSize: 16,
                  onPressed: () => _requireLogin(state),
                ),
              ),
            ],
          ),
        ),
        SectionCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: NavGridView(
            columns: 4,
            iconSize: 22,
            entries: <NavEntry>[
              NavEntry(icon: Icons.show_chart, label: '行情', color: kBrandRed, onTap: () => _placeholder('期权行情')),
              NavEntry(icon: Icons.assignment_outlined, label: '下单', color: kBrandRed, onTap: () => _order(state, '买入', kind: '期权')),
              NavEntry(icon: Icons.undo, label: '撤单', color: kBrandRed, onTap: () => _openPositions(state, 1)),
              NavEntry(icon: Icons.search, label: '查询', color: const Color(0xFF2B6BE4), onTap: () => _placeholder('期权查询')),
              NavEntry(icon: Icons.inventory_2_outlined, label: '持仓', color: const Color(0xFF8E44AD), onTap: () => _openPositions(state, 0)),
              NavEntry(icon: Icons.gavel, label: '行权', color: _holdColor, onTap: () => _placeholder('行权')),
              NavEntry(icon: Icons.lock_outline, label: '锁定', color: _holdColor, onTap: () => _placeholder('锁定')),
              NavEntry(icon: Icons.swap_horiz, label: '转账', color: kBrandRed, onTap: () => _transfer(state)),
            ],
          ),
        ),
        SectionCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              LinkRow(title: '重要通知', onTap: () => _placeholder('重要通知')),
              const Divider(height: 1, indent: 12, endIndent: 12),
              LinkRow(title: '波动指数', onTap: () => _placeholder('波动指数')),
              const Divider(height: 1, indent: 12, endIndent: 12),
              LinkRow(title: '组合申报', onTap: () => _placeholder('组合申报')),
              const Divider(height: 1, indent: 12, endIndent: 12),
              LinkRow(title: '合并行权', onTap: () => _placeholder('合并行权')),
              const Divider(height: 1, indent: 12, endIndent: 12),
              LinkRow(title: '合约筛选', onTap: () => _placeholder('合约筛选')),
              const Divider(height: 1, indent: 12, endIndent: 12),
              LinkRow(title: '策略交易', onTap: () => _placeholder('策略交易')),
              const Divider(height: 1, indent: 12, endIndent: 12),
              LinkRow(title: '委托设置', onTap: () => _placeholder('委托设置')),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ shared bits

  Widget _accountBar(AppState state, {bool credit = false}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Row(
        children: <Widget>[
          const Text('还没有账户? ', style: TextStyle(fontSize: 13, color: kTextSub)),
          GestureDetector(
            onTap: () => _requireLogin(state, thenOpen: true),
            child: const Text(
              '立即开户',
              style: TextStyle(fontSize: 13, color: kBrandRed),
            ),
          ),
          const Spacer(),
          BrandButton(
            label: state.tradeOpened ? '已登录' : '立即登录',
            outlined: true,
            height: 34,
            fontSize: 13,
            textColor: kBrandRed,
            onPressed: () => _requireLogin(state),
          ),
        ],
      ),
    );
  }

  Widget _assetCard(AppState state) {
    final AccountAsset a = state.asset;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('我的资产', style: TextStyle(fontSize: 13, color: kTextSub)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                two(a.totalAsset),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: kText),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '今日盈亏 ' + signed(a.dayPnl),
                  style: TextStyle(fontSize: 12, color: changeColor(a.dayPnl)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _assetCell('可用资金', two(a.available)),
              _assetCell('持仓市值', two(a.marketValue)),
              _assetCell('累计盈亏', signed(a.totalPnl), color: changeColor(a.totalPnl)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _assetCell(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 12, color: kTextSub)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: color ?? kText, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _ipoCard(AppState state) {
    final List<IpoItem> list = state.trade.ipos();
    return SectionCard(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'IPO打新',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kText),
              ),
              const Spacer(),
              Text(
                list.length.toString() + '支新股',
                style: const TextStyle(fontSize: 13, color: kBrandRed),
              ),
              const SizedBox(width: 8),
              const Text('|', style: TextStyle(color: kDivider)),
              const SizedBox(width: 8),
              const Text('0支新债', style: TextStyle(fontSize: 13, color: kBrandRed)),
            ],
          ),
          const SizedBox(height: 6),
          ...list.map((IpoItem ipo) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 96,
                      child: Text(
                        ipo.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, color: kText),
                      ),
                    ),
                    Text(ipo.code, style: const TextStyle(fontSize: 12, color: kTextSub)),
                    const Spacer(),
                    Text(
                      '发行价 ' + two(ipo.issuePrice),
                      style: const TextStyle(fontSize: 12, color: kTextSub),
                    ),
                    const SizedBox(width: 8),
                    Text(ipo.applyDate, style: const TextStyle(fontSize: 12, color: kTextSub)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _placeholder('申购 ' + ipo.name),
                      child: const Text('申购', style: TextStyle(fontSize: 13, color: kBrandRed)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _featuresCard({
    required String title,
    required List<List<NavEntry>> rows,
  }) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kText),
          ),
          const SizedBox(height: 4),
          ...rows.map((List<NavEntry> row) => Row(
                children: row
                    .map((NavEntry e) => Expanded(
                          child: InkWell(
                            onTap: e.onTap,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              child: Row(
                                children: <Widget>[
                                  Icon(e.icon, size: 18, color: kBrandRed),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      e.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14, color: kText),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              )),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- actions

  Future<void> _requireLogin(AppState state, {bool thenOpen = false}) async {
    if (state.tradeOpened) {
      _toast('交易账户已登录');
      return;
    }
    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const LoginPage(trade: true)),
    );
    if (ok == true) {
      await state.openTradeAccount();
      _toast(thenOpen ? '开户成功，已绑定模拟交易账户' : '交易登录成功');
    }
  }

  Future<void> _order(AppState state, String side, {String kind = '普通'}) async {
    if (!state.tradeOpened) {
      await _requireLogin(state);
      if (!state.tradeOpened) return;
    }
    final List<Quote> picks = state.watchQuotes;
    final String? code = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) => _OrderSheet(side: side, kind: kind, picks: picks),
    );
    if (code == null || !mounted) return;
    _toast(side + '委托已提交：' + code);
  }

  void _openPositions(AppState state, int tab) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => PositionsPage(initialTab: tab)),
    );
  }

  Future<void> _transfer(AppState state) async {
    if (!state.tradeOpened) {
      await _requireLogin(state);
      if (!state.tradeOpened) return;
    }
    final TextEditingController controller = TextEditingController(text: '50000');
    final bool? done = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('银证转账', style: TextStyle(fontSize: 17)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '转账金额（元）'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final double amount = double.tryParse(controller.text) ?? 0;
              final String? error = state.trade.transferIn(amount);
              Navigator.of(ctx).pop(error == null);
              if (error != null) _toast(error);
            },
            child: const Text('转入'),
          ),
        ],
      ),
    );
    if (done == true) {
      state.refresh();
      _toast('转账成功');
    }
    controller.dispose();
  }

  void _placeholder(String title) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => PlaceholderPage(title: title)),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}

/// Bottom sheet that collects a simple 买入 / 卖出 order.
class _OrderSheet extends StatefulWidget {
  const _OrderSheet({required this.side, required this.kind, required this.picks});

  final String side;
  final String kind;
  final List<Quote> picks;

  @override
  State<_OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends State<_OrderSheet> {
  late String _code;
  final TextEditingController _price = TextEditingController();
  final TextEditingController _qty = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _code = widget.picks.isEmpty ? '600519' : widget.picks.first.code;
    _price.text = _defaultPrice();
  }

  String _defaultPrice() {
    for (final Quote q in widget.picks) {
      if (q.code == _code && q.price != null) return two(q.price);
    }
    return '10.00';
  }

  String _nameOf(String code) {
    for (final Quote q in widget.picks) {
      if (q.code == code) return q.name;
    }
    return code;
  }

  @override
  void dispose() {
    _price.dispose();
    _qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final Color accent = widget.side == '买入' ? const Color(0xFFE93323) : const Color(0xFF2B6BE4);
    final List<Quote> picks = widget.picks.isEmpty
        ? <Quote>[Quote(code: _code, name: _code)]
        : widget.picks;
    bool hasCurrent = false;
    for (final Quote q in picks) {
      if (q.code == _code) hasCurrent = true;
    }
    final List<Quote> options = hasCurrent
        ? picks
        : <Quote>[Quote(code: _code, name: _code)] + picks;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                widget.side + '（' + widget.kind + '）',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kText),
              ),
              const Spacer(),
              Text(
                '可用 ' + two(state.asset.available),
                style: const TextStyle(fontSize: 12, color: kTextSub),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _code,
            decoration: const InputDecoration(labelText: '证券代码'),
            items: options
                .map((Quote q) => DropdownMenuItem<String>(
                      value: q.code,
                      child: Text(q.code + '  ' + q.name),
                    ))
                .toList(),
            onChanged: (String? v) {
              if (v == null) return;
              setState(() {
                _code = v;
                _price.text = _defaultPrice();
              });
            },
          ),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '委托价格'),
          ),
          TextField(
            controller: _qty,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '委托数量（股）'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: BrandButton(
              label: widget.side,
              height: 44,
              gradient: <Color>[accent, accent],
              onPressed: () {
                final String? error = state.trade.place(
                  code: _code,
                  name: _nameOf(_code),
                  side: widget.side,
                  price: double.tryParse(_price.text) ?? 0,
                  quantity: int.tryParse(_qty.text) ?? 0,
                  kind: widget.kind,
                );
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), duration: const Duration(seconds: 1)),
                  );
                  return;
                }
                state.refresh();
                Navigator.of(context).pop(_code);
              },
            ),
          ),
        ],
      ),
    );
  }
}
