import 'package:flutter/material.dart';

import '../core/theme.dart';

/// White rounded container used by every page section.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin = const EdgeInsets.fromLTRB(12, 10, 12, 0),
    this.radius = 12,
    this.color = Colors.white,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget body = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
    if (onTap == null) return body;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: body);
  }
}

/// Section title with an optional trailing link.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onMore,
    this.accent,
    this.padding = const EdgeInsets.fromLTRB(12, 14, 12, 6),
  });

  final String title;
  final String? trailing;
  final VoidCallback? onMore;
  final Widget? accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          if (accent != null) ...<Widget>[accent!, const SizedBox(width: 6)],
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(fontSize: 12, color: kTextSub),
            ),
          if (onMore != null)
            const Icon(Icons.chevron_right, size: 18, color: kTextFaint),
        ],
      ),
    );
  }
}

/// One icon + label entry of a shortcut grid.
class NavEntry {
  const NavEntry({
    required this.icon,
    required this.label,
    this.color,
    this.badge,
    this.filled = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final String? badge;
  final bool filled;
  final VoidCallback? onTap;
}

/// Grid of shortcut entries, laid out manually so it can live inside any
/// scroll view without nested scrolling problems.
class NavGridView extends StatelessWidget {
  const NavGridView({
    super.key,
    required this.entries,
    this.columns = 5,
    this.iconSize = 24,
    this.labelSize = 12,
    this.verticalPadding = 10,
  });

  final List<NavEntry> entries;
  final int columns;
  final double iconSize;
  final double labelSize;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < entries.length; i += columns) {
      final List<NavEntry> slice = entries.sublist(
        i,
        (i + columns) > entries.length ? entries.length : i + columns,
      );
      final List<Widget> cells = slice.map((NavEntry e) => _cell(e)).toList();
      while (cells.length < columns) {
        cells.add(const Expanded(child: SizedBox.shrink()));
      }
      rows.add(Row(children: cells.map((Widget c) => c).toList()));
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Column(children: rows),
    );
  }

  Widget _cell(NavEntry e) {
    final Color tint = e.color ?? kBrandRed;
    final Widget iconBox = e.filled
        ? Container(
            width: iconSize + 22,
            height: iconSize + 22,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[tint.withOpacity(0.16), tint.withOpacity(0.06)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(e.icon, size: iconSize, color: tint),
          )
        : Icon(e.icon, size: iconSize + 4, color: tint);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: e.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: iconSize + 24,
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      iconBox,
                      if (e.badge != null)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: kBrandRed,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              e.badge!,
                              style: const TextStyle(color: Colors.white, fontSize: 8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                e.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: labelSize, color: kText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal pill / chip selector.
class PillTabs extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.labels,
    required this.selected,
    this.onSelected,
    this.pill = true,
    this.dense = false,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int>? onSelected;
  final bool pill;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: dense ? 12 : 12, vertical: 6),
      child: Row(
        children: List<Widget>.generate(labels.length, (int i) {
          final bool active = i == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: onSelected == null ? null : () => onSelected!(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFFFDECEA) : const Color(0xFFF2F3F5),
                  borderRadius: BorderRadius.circular(pill ? 16 : 6),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: dense ? 12 : 13,
                    color: active ? kBrandRed : kTextSub,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Underlined tabs used in the page header (行情 / 发现 / 开户|交易 ...).
class UnderlineTabs extends StatelessWidget {
  const UnderlineTabs({
    super.key,
    required this.labels,
    required this.selected,
    this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(labels.length, (int i) {
        final bool active = i == selected;
        return GestureDetector(
          onTap: onSelected == null ? null : () => onSelected!(i),
          child: Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: active ? 21 : 17,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    color: active ? kText : kTextSub,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 2.5,
                  width: active ? 22 : 0,
                  decoration: BoxDecoration(
                    color: kBrandRed,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Page header: brand title, optional tabs, search and message actions.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.tabs,
    this.selectedTab = 0,
    this.onTabSelected,
    this.showActions = true,
    this.trailing,
    this.onSearch,
    this.onMessage,
  });

  final String title;
  final List<String>? tabs;
  final int selectedTab;
  final ValueChanged<int>? onTabSelected;
  final bool showActions;
  final Widget? trailing;
  final VoidCallback? onSearch;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    final List<String>? tabLabels = tabs;
    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: <Widget>[
              if (tabLabels == null || tabLabels.isEmpty)
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
              if (tabLabels != null && tabLabels.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: UnderlineTabs(
                      labels: tabLabels,
                      selected: selectedTab,
                      onSelected: onTabSelected,
                    ),
                  ),
                )
              else
                const Spacer(),
              if (trailing != null) trailing!,
              if (showActions) ...<Widget>[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onSearch,
                  child: const Icon(Icons.search, size: 23, color: kText),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: onMessage,
                  child: const Icon(Icons.chat_bubble_outline, size: 22, color: kText),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Gradient brand button (开户领取 / 立即登录 ...).
class BrandButton extends StatelessWidget {
  const BrandButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 44,
    this.gradient,
    this.textColor = Colors.white,
    this.outlined = false,
    this.fontSize = 16,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final List<Color>? gradient;
  final Color textColor;
  final bool outlined;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors =
        gradient ?? <Color>[const Color(0xFFFFA34A), const Color(0xFFFFD466)];
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: outlined ? null : LinearGradient(colors: colors),
          color: outlined ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(height / 2),
          border: outlined
              ? Border.all(color: kBrandRed.withOpacity(0.6), width: 1)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Simple row with a title, optional value and chevron.
class LinkRow extends StatelessWidget {
  const LinkRow({
    super.key,
    required this.title,
    this.value,
    this.icon,
    this.onTap,
    this.badge,
    this.showChevron = true,
  });

  final String title;
  final String? value;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? badge;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 19, color: kTextSub),
              const SizedBox(width: 8),
            ],
            Text(title, style: const TextStyle(fontSize: 15, color: kText)),
            if (badge != null) ...<Widget>[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: kBrandRed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
            ],
            const Spacer(),
            if (value != null)
              Text(value!, style: const TextStyle(fontSize: 13, color: kTextSub)),
            if (showChevron) const Icon(Icons.chevron_right, size: 18, color: kTextFaint),
          ],
        ),
      ),
    );
  }
}

/// The red hexagon used by the centre tab of the bottom navigation bar.
class HexagonIcon extends StatelessWidget {
  const HexagonIcon({
    super.key,
    this.size = 34,
    this.color = kBrandRed,
    this.icon = Icons.sync,
    this.iconSize = 20,
  });

  final double size;
  final Color color;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HexPainter(color),
        child: Center(child: Icon(icon, size: iconSize, color: Colors.white)),
      ),
    );
  }
}

class _HexPainter extends CustomPainter {
  _HexPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Path p = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.26)
      ..lineTo(w, h * 0.74)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.74)
      ..lineTo(0, h * 0.26)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _HexPainter old) => old.color != color;
}
