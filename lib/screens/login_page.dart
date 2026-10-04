import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

/// Simulated login. Any 11 digit phone number plus a password is accepted;
/// [trade] switches between the app account and the brokerage (交易) login.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.trade = false});

  final bool trade;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phone = TextEditingController(text: '15500002274');
  final TextEditingController _password = TextEditingController(text: '123456');
  final TextEditingController _code = TextEditingController(text: '6688');
  bool _agreed = true;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.trade ? '交易登录' : '登录'),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: <Widget>[
          const SizedBox(height: 8),
          Center(
            child: Image.asset(
              'assets/images/login_logo.png',
              width: 72,
              height: 72,
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              '国新证券',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kText),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.trade ? '登录后查看资金、持仓与委托' : '登录后同步自选与资产信息',
            style: const TextStyle(fontSize: 13, color: kTextSub),
          ),
          const SizedBox(height: 28),
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kDivider)),
            ),
            child: TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: InputBorder.none,
                labelText: '手机号',
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kDivider)),
            ),
            child: TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                labelText: '密码',
              ),
            ),
          ),
          const SizedBox(height: 24),
          BrandButton(
            label: widget.trade ? '登录交易账户' : '登录',
            height: 46,
            fontSize: 17,
            gradient: const <Color>[Color(0xFFF5453A), Color(0xFFE93323)],
            onPressed: () => _submit(state),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _submit(state),
            child: const Center(
              child: Text(
                '验证码登录 / 快速注册',
                style: TextStyle(fontSize: 13, color: kBrandRed),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: <Widget>[
              GestureDetector(
                onTap: () => setState(() => _agreed = !_agreed),
                child: Icon(
                  _agreed ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: _agreed ? kBrandRed : kTextFaint,
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  '已阅读并同意《用户协议》与《隐私政策》',
                  style: TextStyle(fontSize: 11, color: kTextSub),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '演示环境：任意11位手机号与任意密码均可登录，数据全部在本地模拟。',
            style: TextStyle(fontSize: 11, color: kTextFaint),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(AppState state) async {
    final String phone = _phone.text.trim();
    if (phone.length != 11) {
      _toast('请输入11位手机号');
      return;
    }
    if (_password.text.isEmpty) {
      _toast('请输入密码');
      return;
    }
    if (!_agreed) {
      _toast('请先同意用户协议');
      return;
    }
    if (!widget.trade) {
      await state.login(phone, _password.text);
    }
    if (!mounted) return;
    _toast(widget.trade ? '登录成功' : '登录成功，' + maskPhone(phone));
    Navigator.of(context).pop(true);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}
