import 'dart:math';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/models/quote.dart';

/// Minimal line sparkline used across the watchlist, index cards and
/// hot-topic shelves.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    required this.color,
    this.height = 32,
    this.filled = true,
    this.baseline,
    this.strokeWidth = 1.2,
  });

  final List<double> values;
  final Color color;
  final double height;
  final bool filled;
  final double? baseline;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparkPainter(
          values: values,
          color: color,
          filled: filled,
          baseline: baseline,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({
    required this.values,
    required this.color,
    required this.filled,
    required this.baseline,
    required this.strokeWidth,
  });

  final List<double> values;
  final Color color;
  final bool filled;
  final double? baseline;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    double min = values.first;
    double max = values.first;
    for (final double v in values) {
      if (v < min) min = v;
      if (v > max) max = v;
    }
    if (baseline != null) {
      if (baseline! < min) min = baseline!;
      if (baseline! > max) max = baseline!;
    }
    if (max - min < 1e-9) max = min + 1;
    final double pad = 1.5;
    final double usable = size.height - pad * 2;
    double y(double v) => size.height - pad - (v - min) / (max - min) * usable;
    final double dx = size.width / (values.length - 1);

    if (baseline != null) {
      final Paint dash = Paint()
        ..color = const Color(0xFFBFC4CC)
        ..strokeWidth = 0.8;
      _dashedLine(canvas, Offset(0, y(baseline!)), Offset(size.width, y(baseline!)), dash);
    }

    final Path path = Path();
    for (int i = 0; i < values.length; i++) {
      final double x = dx * i;
      final double yy = y(values[i]);
      if (i == 0) {
        path.moveTo(x, yy);
      } else {
        path.lineTo(x, yy);
      }
    }

    if (filled) {
      final Path fill = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(fill, Paint()..color = color.withOpacity(0.10));
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const double dash = 3;
    const double gap = 3;
    final double total = (b - a).distance;
    if (total <= 0) return;
    final Offset dir = (b - a) / total;
    double walked = 0;
    while (walked < total) {
      final double end = walked + dash > total ? total : walked + dash;
      canvas.drawLine(a + dir * walked, a + dir * end, paint);
      walked = end + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) =>
      old.values != values || old.color != color || old.filled != filled;
}

/// 分时图: price line, average line and the volume histogram underneath.
class TimeShareChart extends StatelessWidget {
  const TimeShareChart({
    super.key,
    required this.points,
    required this.prevClose,
    this.height = 240,
  });

  final List<TrendPoint> points;
  final double prevClose;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('暂无分时数据', style: TextStyle(color: kTextSub, fontSize: 12)),
        ),
      );
    }
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _TimeSharePainter(points: points, prevClose: prevClose),
      ),
    );
  }
}

class _TimeSharePainter extends CustomPainter {
  _TimeSharePainter({required this.points, required this.prevClose});

  final List<TrendPoint> points;
  final double prevClose;

  @override
  void paint(Canvas canvas, Size size) {
    final double volHeight = size.height * 0.24;
    final double priceHeight = size.height - volHeight - 4;

    double min = prevClose;
    double max = prevClose;
    double maxVol = 1;
    for (final TrendPoint p in points) {
      if (p.price < min) min = p.price;
      if (p.price > max) max = p.price;
      if (p.avg < min && p.avg > 0) min = p.avg;
      if (p.avg > max) max = p.avg;
      if (p.volume > maxVol) maxVol = p.volume;
    }
    final double span = (max - min) < 1e-9 ? 1 : (max - min);
    final double pad = span * 0.08;
    min -= pad;
    max += pad;

    double y(double v) => priceHeight - (v - min) / (max - min) * priceHeight;

    final Paint grid = Paint()
      ..color = const Color(0xFFEDEFF2)
      ..strokeWidth = 0.8;
    for (int i = 0; i <= 4; i++) {
      final double yy = priceHeight / 4 * i;
      canvas.drawLine(Offset(0, yy), Offset(size.width, yy), grid);
    }
    canvas.drawLine(
      Offset(0, size.height - volHeight - 2),
      Offset(size.width, size.height - volHeight - 2),
      grid,
    );

    final Paint baseDash = Paint()
      ..color = const Color(0xFFBFC4CC)
      ..strokeWidth = 0.8;
    final double baseY = y(prevClose);
    double walked = 0;
    while (walked < size.width) {
      final double end = walked + 4 > size.width ? size.width : walked + 4;
      canvas.drawLine(Offset(walked, baseY), Offset(end, baseY), baseDash);
      walked = end + 4;
    }

    final Color main = points.last.price >= prevClose ? kUp : kDown;
    final double dx = size.width / (points.length - 1);

    final Path pricePath = Path();
    final Path avgPath = Path();
    for (int i = 0; i < points.length; i++) {
      final double x = dx * i;
      if (i == 0) {
        pricePath.moveTo(x, y(points[i].price));
        avgPath.moveTo(x, y(points[i].avg));
      } else {
        pricePath.lineTo(x, y(points[i].price));
        avgPath.lineTo(x, y(points[i].avg));
      }
    }
    final Path fill = Path.from(pricePath)
      ..lineTo(size.width, priceHeight)
      ..lineTo(0, priceHeight)
      ..close();
    canvas.drawPath(fill, Paint()..color = main.withOpacity(0.10));
    canvas.drawPath(
      pricePath,
      Paint()
        ..color = main
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawPath(
      avgPath,
      Paint()
        ..color = const Color(0xFFE8A33D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final Paint volPaint = Paint();
    final double barWidth = dx < 1 ? 1 : dx * 0.8;
    for (int i = 0; i < points.length; i++) {
      final double h = points[i].volume / maxVol * (volHeight - 6);
      if (h <= 0) continue;
      final bool up = i == 0
          ? points[i].price >= prevClose
          : points[i].price >= points[i - 1].price;
      volPaint.color = (up ? kUp : kDown).withOpacity(0.7);
      canvas.drawRect(
        Rect.fromLTWH(dx * i, size.height - h, barWidth, h),
        volPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimeSharePainter old) =>
      old.points != points || old.prevClose != prevClose;
}

/// Candlestick chart with a volume pane, used on the stock detail page.
class CandleChart extends StatelessWidget {
  const CandleChart({super.key, required this.bars, this.height = 260});

  final List<KlineBar> bars;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (bars.length < 2) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('暂无K线数据', style: TextStyle(color: kTextSub, fontSize: 12)),
        ),
      );
    }
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _CandlePainter(bars: bars)),
    );
  }
}

class _CandlePainter extends CustomPainter {
  _CandlePainter({required this.bars});

  final List<KlineBar> bars;

  @override
  void paint(Canvas canvas, Size size) {
    const int maxBars = 70;
    final List<KlineBar> data = bars.length > maxBars
        ? bars.sublist(bars.length - maxBars)
        : bars;
    final double volHeight = size.height * 0.22;
    final double priceHeight = size.height - volHeight - 6;

    double min = data.first.low;
    double max = data.first.high;
    double maxVol = 1;
    for (final KlineBar b in data) {
      if (b.low < min) min = b.low;
      if (b.high > max) max = b.high;
      if (b.volume > maxVol) maxVol = b.volume;
    }
    if (max - min < 1e-9) max = min + 1;
    double y(double v) => priceHeight - (v - min) / (max - min) * priceHeight;

    final Paint grid = Paint()
      ..color = const Color(0xFFEDEFF2)
      ..strokeWidth = 0.8;
    for (int i = 0; i <= 4; i++) {
      final double yy = priceHeight / 4 * i;
      canvas.drawLine(Offset(0, yy), Offset(size.width, yy), grid);
    }

    final double slot = size.width / data.length;
    final double body = slot * 0.62 < 1 ? 1 : slot * 0.62;
    final Paint volPaint = Paint();
    for (int i = 0; i < data.length; i++) {
      final KlineBar b = data[i];
      final bool up = b.close >= b.open;
      final Color c = up ? kUp : kDown;
      final double cx = slot * i + slot / 2;
      final Paint stroke = Paint()
        ..color = c
        ..strokeWidth = 1;
      canvas.drawLine(Offset(cx, y(b.high)), Offset(cx, y(b.low)), stroke);
      final double top = y(b.open > b.close ? b.open : b.close);
      final double bottom = y(b.open > b.close ? b.close : b.open);
      final Rect rect = Rect.fromLTRB(
        cx - body / 2,
        top,
        cx + body / 2,
        bottom < top + 1 ? top + 1 : bottom,
      );
      if (up) {
        canvas.drawRect(rect, Paint()..color = Colors.white);
        canvas.drawRect(
          rect,
          Paint()
            ..color = c
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      } else {
        canvas.drawRect(rect, Paint()..color = c);
      }
      final double vh = b.volume / maxVol * (volHeight - 6);
      volPaint.color = c.withOpacity(0.75);
      canvas.drawRect(
        Rect.fromLTWH(cx - body / 2, size.height - vh, body, vh),
        volPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandlePainter old) => old.bars != bars;
}

/// 涨跌分布 histogram used by the market page.
class DistributionChart extends StatelessWidget {
  const DistributionChart({super.key, required this.activity, this.height = 132});

  final MarketActivity activity;
  final double height;

  @override
  Widget build(BuildContext context) {
    final List<_Bucket> buckets = <_Bucket>[
      _Bucket('涨停', activity.limitUp, kUp),
      _Bucket('>7%', activity.over7, kUp),
      _Bucket('5-7%', activity.from5to7, kUp),
      _Bucket('2-5%', activity.from2to5, kUp),
      _Bucket('0-2%', activity.from0to2, kUp),
      _Bucket('0%', activity.flat, kFlat),
      _Bucket('0-2%', activity.down0to2, kDown),
      _Bucket('2-5%', activity.down2to5, kDown),
      _Bucket('5-7%', activity.down5to7, kDown),
      _Bucket('>7%', activity.downOver7, kDown),
      _Bucket('跌停', activity.limitDown, kDown),
    ];
    int maxValue = 1;
    for (final _Bucket b in buckets) {
      if (b.value > maxValue) maxValue = b.value;
    }
    final int up = activity.upCount;
    final int down = activity.downCount;
    final int total = up + down == 0 ? 1 : up + down;
    final double upRatio = up / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: buckets.map((_Bucket b) {
              final double h = b.value / maxValue * (height - 34);
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      b.value.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: b.value == 0 ? kTextFaint : b.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: h < 2 ? 2 : h,
                      decoration: BoxDecoration(
                        color: b.color.withOpacity(b.value == 0 ? 0.35 : 1),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: buckets
              .map((_Bucket b) => Expanded(
                    child: Text(
                      b.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(fontSize: 9, color: kTextSub),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            const Icon(Icons.arrow_upward, size: 12, color: kUp),
            const SizedBox(width: 2),
            Text(up.toString(), style: const TextStyle(fontSize: 11, color: kUp)),
            const SizedBox(width: 6),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: max(1, (upRatio * 1000).round()),
                      child: Container(height: 6, color: kUp),
                    ),
                    Expanded(
                      flex: max(1, ((1 - upRatio) * 1000).round()),
                      child: Container(height: 6, color: kDown),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(down.toString(), style: const TextStyle(fontSize: 11, color: kDown)),
            const Icon(Icons.arrow_downward, size: 12, color: kDown),
          ],
        ),
      ],
    );
  }
}

class _Bucket {
  const _Bucket(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

/// Tiny helper for deterministic sample curves.
List<double> fakeCurve({
  required double from,
  required double to,
  int points = 48,
  int seed = 1,
}) {
  final Random rng = Random(seed);
  final List<double> out = <double>[];
  double v = from;
  final double step = (to - from) / points;
  for (int i = 0; i < points; i++) {
    v += step + (rng.nextDouble() - 0.5) * ((from.abs() * 0.003) + 0.02);
    out.add(v);
  }
  out[out.length - 1] = to;
  return out;
}
