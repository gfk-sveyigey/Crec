import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'screens/shell.dart';
import 'state/app_state.dart';

class CrecApp extends StatefulWidget {
  const CrecApp({super.key, this.state});

  /// Optional injected state, mainly so widget tests can run without
  /// touching the network.
  final AppState? state;

  @override
  State<CrecApp> createState() => _CrecAppState();
}

class _CrecAppState extends State<CrecApp> {
  late final AppState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.state ?? AppState();
    _state.bootstrap();
  }

  @override
  void dispose() {
    if (widget.state == null) {
      _state.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: '国新证券',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeShell(),
      ),
    );
  }
}
