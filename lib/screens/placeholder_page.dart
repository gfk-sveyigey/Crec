import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Generic destination for the many secondary entries of the app.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title, this.message});

  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.construction_outlined, size: 48, color: kTextFaint),
              const SizedBox(height: 16),
              Text(
                message ?? title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: kTextSub, height: 1.6),
              ),
              const SizedBox(height: 8),
              const Text(
                '该功能为界面占位示例',
                style: TextStyle(fontSize: 12, color: kTextFaint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
