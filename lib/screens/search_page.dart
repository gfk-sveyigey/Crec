import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/market_api.dart';
import '../data/models/quote.dart';

/// Symbol search. Pops with the selected code so the caller can add it to
/// the watchlist.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<Quote> _results = <Quote>[];
  bool _loading = false;

  static const List<String> _hot = <String>[
    '600519',
    '000001',
    '601865',
    '605499',
    '300750',
    '688185',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () => _search(value));
  }

  Future<void> _search(String keyword) async {
    if (keyword.trim().isEmpty) {
      setState(() => _results = <Quote>[]);
      return;
    }
    setState(() => _loading = true);
    List<Quote> found = <Quote>[];
    try {
      found = await MarketApi.search(keyword);
    } catch (_) {
      found = <Quote>[];
    }
    if (!mounted) return;
    setState(() {
      _results = found;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: Container(
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F3F5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            onSubmitted: _search,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              prefixIcon: Icon(Icons.search, size: 18, color: kTextSub),
              hintText: '输入代码或名称，如 600519',
              hintStyle: TextStyle(fontSize: 13, color: kTextFaint),
              contentPadding: EdgeInsets.symmetric(vertical: 9),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消', style: TextStyle(color: kTextSub)),
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 1.6, color: kBrandRed),
          ),
        ),
      );
    }
    if (_results.isNotEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.only(top: 8),
        itemCount: _results.length,
        separatorBuilder: (BuildContext context, int i) =>
            const Divider(height: 1, indent: 14, endIndent: 14),
        itemBuilder: (BuildContext context, int i) {
          final Quote q = _results[i];
          return ListTile(
            tileColor: Colors.white,
            title: Text(q.name, style: const TextStyle(fontSize: 15)),
            subtitle: Text(q.code, style: const TextStyle(fontSize: 12, color: kTextSub)),
            trailing: const Icon(Icons.add_circle_outline, size: 20, color: kBrandRed),
            onTap: () => Navigator.of(context).pop(q.code),
          );
        },
      );
    }
    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        const Text('热门搜索', style: TextStyle(fontSize: 13, color: kTextSub)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _hot.map((String code) {
            return GestureDetector(
              onTap: () {
                _controller.text = code;
                _search(code);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(code, style: const TextStyle(fontSize: 13, color: kText)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
