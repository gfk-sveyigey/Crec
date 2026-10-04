/// Number / date formatting helpers shared across the UI.
library;

String two(double? v) {
  if (v == null) return '--';
  return v.toStringAsFixed(2);
}

/// Always shows a leading sign for positive numbers, e.g. +1.32 / -0.45.
String signed(num? v, {int digits = 2, String suffix = ''}) {
  if (v == null) return '--';
  final double d = v.toDouble();
  final String body = d.abs().toStringAsFixed(digits);
  if (d > 0) return '+' + body + suffix;
  if (d < 0) return '-' + body + suffix;
  return body + suffix;
}

String signedPct(num? v) => signed(v, suffix: '%');

/// 1.44万亿 / 12.59亿 / 3.20万
String compact(num? v) {
  if (v == null) return '--';
  final double d = v.toDouble();
  final double a = d.abs();
  if (a >= 1000000000000) return (d / 1000000000000).toStringAsFixed(2) + '万亿';
  if (a >= 100000000) return (d / 100000000).toStringAsFixed(2) + '亿';
  if (a >= 10000) return (d / 10000).toStringAsFixed(2) + '万';
  return d.toStringAsFixed(2);
}

/// Formats a volume expressed in 手 (lots).
String compactHand(num? v) {
  if (v == null) return '--';
  final double lots = v.toDouble();
  if (lots >= 100000000) return (lots / 100000000).toStringAsFixed(2) + '亿手';
  if (lots >= 10000) return (lots / 10000).toStringAsFixed(2) + '万手';
  return lots.toStringAsFixed(0) + '手';
}

String clockLabel(DateTime t) {
  String p(int n) => n < 10 ? '0' + n.toString() : n.toString();
  return p(t.hour) + ':' + p(t.minute) + ':' + p(t.second);
}

String shortTimeLabel(DateTime t) {
  String p(int n) => n < 10 ? '0' + n.toString() : n.toString();
  return p(t.hour) + ':' + p(t.minute);
}

String dateLabel(DateTime t) {
  String p(int n) => n < 10 ? '0' + n.toString() : n.toString();
  return p(t.month) + '-' + p(t.day);
}

String ymd(DateTime t) {
  String p(int n) => n < 10 ? '0' + n.toString() : n.toString();
  return t.year.toString() + '-' + p(t.month) + '-' + p(t.day);
}

String dateTimeLabel(DateTime t) => ymd(t) + ' ' + clockLabel(t);

/// 155****2274
String maskPhone(String phone) {
  if (phone.length < 7) return phone;
  return phone.substring(0, 3) + '****' + phone.substring(phone.length - 4);
}

/// Stock code to Eastmoney secid, e.g. 600519 -> 1.600519, 000001 -> 0.000001.
String secidOf(String code) {
  final String c = code.trim();
  if (c.contains('.')) return c;
  if (c.isEmpty) return '1.000001';
  final String head = c.substring(0, 1);
  if (head == '6' || head == '5' || head == '9') return '1.' + c;
  return '0.' + c;
}
