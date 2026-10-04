import fs from "node:fs";
import path from "node:path";

const root = process.argv[2];
const files = [];
function walk(dir) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) walk(p);
    else if (e.name.endsWith(".dart")) files.push(p);
  }
}
walk(root);

const declared = new Set();
const declByFile = new Map();
const reDecl = /^\s*(?:abstract\s+|sealed\s+|final\s+|base\s+|mixin\s+)*(class|enum|mixin|typedef|extension)\s+([A-Za-z_][A-Za-z0-9_]*)/gm;
const reTopVar = /^(?:const|final|var|late)\s+[A-Za-z_][A-Za-z0-9_<>,? ]*\s+([A-Za-z_][A-Za-z0-9_]*)\s*=/gm;

for (const f of files) {
  const src = fs.readFileSync(f, "utf8");
  let m;
  const names = [];
  while ((m = reDecl.exec(src))) { declared.add(m[2]); names.push(m[2]); }
  while ((m = reTopVar.exec(src))) { declared.add(m[1]); names.push(m[1]); }
  declByFile.set(f, names);
}

// import resolution
const importErrs = [];
for (const f of files) {
  const src = fs.readFileSync(f, "utf8");
  const re = /import\s+'([^']+)'/g;
  let m;
  while ((m = re.exec(src))) {
    const spec = m[1];
    if (spec.startsWith("package:") || spec.startsWith("dart:")) continue;
    const target = path.resolve(path.dirname(f), spec);
    if (!fs.existsSync(target)) {
      importErrs.push(path.relative(root, f) + " -> " + spec);
    } else {
      // also verify every named import exists
      const line = src.slice(m.index, src.indexOf(";", m.index));
      const show = /show\s+([^;]+)/.exec(line);
      if (show) {
        for (const nm of show[1].split(",").map((s) => s.trim()).filter(Boolean)) {
          const targetNames = declByFile.get(target) || [];
          if (!targetNames.includes(nm)) {
            importErrs.push(path.relative(root, f) + " -> " + spec + " show " + nm + " (not declared in target)");
          }
        }
      }
    }
  }
}

const flutterNames = new Set(("Widget StatelessWidget StatefulWidget State InheritedNotifier InheritedWidget BuildContext " +
"Key ValueKey GlobalKey MaterialApp Scaffold AppBar Text TextField TextEditingController EdgeInsets EdgeInsetsGeometry " +
"Color Colors Icon Icons Row Column Expanded Flex Spacer Container Padding Center Align SizedBox Stack Positioned " +
"ListView ListViewBuilder SliverList GridView Wrap SingleChildScrollView CustomPaint CustomPainter Canvas Paint " +
"Path Offset Rect Size TextStyle FontWeight TextAlign TextOverflow BoxDecoration BoxConstraints Border BorderRadius " +
"BorderRadiusGeometry Radius LinearGradient Gradient RadialGradient Alignment MainAxisAlignment CrossAxisAlignment " +
"MainAxisSize Axis TextInputType TextInputAction InputDecoration InputBorder OutlineInputBorder UnderlineInputBorder " +
"Divider ThemeData Theme AppBarTheme DividerThemeData ColorScheme ScaffoldMessenger SnackBar SnackBarBehavior " +
"Navigator MaterialPageRoute RouteSettings PageRouteBuilder MediaQuery RefreshIndicator InkWell GestureDetector " +
"InkDecoration Material ShapeBorder RoundedRectangleBorder CircleBorder CircleAvatar Dismissible AnimatedBuilder " +
"ValueListenableBuilder ValueNotifier Listenable ChangeNotifier Notifier ShapeBorderClipper ClipRect ClipRRect " +
"Image AssetImage NetworkImage IconButton FloatingActionButton TabBar TabBarView TabController DefaultTabController " +
"BottomNavigationBar BottomNavigationBarItem DropdownButton DropdownButtonFormField DropdownMenuItem AlertDialog " +
"SimpleDialog Dialog showDialog showModalBottomSheet BottomSheet Slider Switch Checkbox Radio Chip CircleAvatar " +
"TextButton ElevatedButton OutlinedButton IconTheme TextButtonTheme Tooltip Drawer AppBarThemeData PopupMenuButton " +
"PopupMenuItem EdgeInsetsDirectional Matrix4 Transform CurvedAnimation AnimationController Tween TweenAnimationBuilder " +
"AnimatedContainer AnimatedOpacity AnimatedSwitcher Opacity ClipOval ClipPath CustomClipper FlutterError VoidCallback " +
"FutureBuilder StreamBuilder Timer Duration DateTime DateFormat CanvasPaintingStyle PaintingStyle StrokeCap StrokeJoin " +
"Rect Point Offset Colors BlendMode TextPainter TextSpan InlineSpan TextDirection BoxShape ImageProvider " +
"BorderStyle ScrollController ScrollPhysics AlwaysScrollableScrollPhysics BouncingScrollPhysics ClampingScrollPhysics " +
"Clip ClipRRect EdgeInsetsGeometry HitTestBehavior Notification UserScrollNotification Orientation " +
"Animation AnimationStyle ScaleTransition FadeTransition SlideTransition SizeTransition RotationTransition " +
"MaterialStateProperty WidgetStateProperty SystemMouseCursors MouseRegion Focus FocusNode Shortcuts Actions " +
"LinearProgressIndicator CircularProgressIndicator Placeholder Hero SafeArea AspectRatio FractionallySizedBox " +
"IntrinsicHeight IntrinsicWidth Flexible LimitedBox Offstage Visibility Flow Table TableRow TableCell " +
"PillTabs UnderlineTabs NavGridView NavEntry AppTopBar SectionCard SectionHeader BrandButton LinkRow HexagonIcon " +
"AppState AppScope WatchlistPage MarketPage DiscoverPage TradePage FinancePage ProfilePage StockDetailPage " +
"SearchPage LoginPage PositionsPage PlaceholderPage Sparkline TimeShareChart CandleChart DistributionChart " +
"MarketApi NewsApi FundApi MockTradeApi FallbackData Em Net Quote TrendPoint KlineBar BoardRow MarketActivity " +
"NewsItem ResearchReport FundRow HotTopic HotStock TradingUser AccountAsset Position OrderRecord DealRecord IpoItem " +
"kBrandRed kBrandOrange kUp kDown kFlat kBg kText kTextSub kTextFaint kDivider kGolden changeColor buildAppTheme " +
"two signed signedPct compact compactHand clockLabel shortTimeLabel dateLabel ymd dateTimeLabel maskPhone secidOf " +
"_Bucket _Lot _HexPainter _SparkPainter _TimeSharePainter _CandlePainter _OrderSheet _BottomBar _HomeShellState " +
"Random math").split(/\s+/));

const unknown = new Map();
for (const f of files) {
  const src = fs.readFileSync(f, "utf8");
  const stripped = src
    .replace(/\/\/[^\n]*/g, " ")
    .replace(/\/\*[\s\S]*?\*\//g, " ")
    .replace(/'(?:[^'\\\n]|\\.)*'/g, "''")
    .replace(/"(?:[^"\\\n]|\\.)*"/g, '""');
  const re = /\b([A-Z][A-Za-z0-9_]{2,})\b/g;
  let m;
  while ((m = re.exec(stripped))) {
    const nm = m[1];
    if (declared.has(nm) || flutterNames.has(nm)) continue;
    if (/^[A-Z][A-Z0-9_]*$/.test(nm)) continue;
    const key = nm;
    if (!unknown.has(key)) unknown.set(key, new Set());
    unknown.get(key).add(path.relative(root, f));
  }
}

console.log("declared top-level names: " + declared.size);
console.log("import issues: " + importErrs.length);
for (const e of importErrs) console.log("  " + e);
console.log("--- possibly unknown identifiers ---");
const keys = Array.from(unknown.keys()).sort();
for (const k of keys) console.log(k + "  (" + Array.from(unknown.get(k)).join(", ") + ")");
