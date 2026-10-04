# 国新证券 CREC 客户端（Flutter / Android + iOS）

一个模仿 **国新证券** App 的跨平台客户端示例：单套 Flutter 代码同时构建 Android 与 iOS，
**不自建后端**，而是直接调用 akshare 所封装的公开行情接口（东方财富 push2 / 天天基金 / 资讯），
并内置一套**模拟登录 / 开户 / 交易**逻辑，用于展示完整的股票软件信息查询体验。

- 应用名：国新证券
- Bundle ID / applicationId：`com.aholic.crec`
- 包名：`crec`（`pubspec.yaml` 中的 `name`）
- 版本：0.0.1

## 1. 技术选型

| 项 | 选择 | 原因 |
| --- | --- | --- |
| 框架 | Flutter (Dart >= 3.3) | 一套代码同时发布 Android / iOS |
| 网络 | `dart:io` 的 `HttpClient`（自研 `core/net.dart`） | 不引入第三方网络库，直接发请求 |
| 状态 | `ChangeNotifier` + 自定义 `InheritedNotifier` | 无 provider / bloc 依赖 |
| 图表 | 自研 `CustomPainter`（分时、K 线、柱状、迷你走势） | 不依赖 fl_chart，避免版本耦合 |
| 持久化 | `shared_preferences` | 唯一第三方依赖，保存登录态与自选 |
| 图标 | 由 `icon.jpg` 用 `tool/make_icons.py` 生成 | Android mipmap + iOS AppIcon 全套 |

## 2. 目录结构

```
lib/
  main.dart                 入口
  app.dart                  MaterialApp + 全局 AppScope
  core/
    theme.dart              品牌红/涨绿跌红配色、ThemeData
    format.dart             金额万亿亿、涨跌幅、secid 映射等
    net.dart                dart:io HttpClient 封装（UA / Referer / 超时 / JSON 提取）
  data/
    em.dart                 ★ 东方财富公开接口 + 字段解析（akshare 映射）
    market_api.dart         指数 / 列表 / 单只 / 分时 / K线 / 板块 / 涨跌分布 / 两融
    news_api.dart           7x24 快讯 / 栏目资讯 / 研报
    fund_api.dart           基金排行 / 历史净值
    mock_trade_api.dart     模拟柜台（开户、下单、持仓、成交、银证转账、打新）
    fallback_data.dart      离线兜底样例数据（与截图一致）
    models/quote.dart       Quote / TrendPoint / KlineBar / BoardRow / MarketActivity ...
    models/trading.dart     账户资产 / 持仓 / 委托 / 成交 / 新股
  state/app_state.dart      全局状态（登录态、自选、行情缓存、模拟账户）
  widgets/
    charts.dart             Sparkline / 分时 / K线 / 涨跌分布
    common.dart             SectionCard / NavGridView / AppTopBar / BrandButton / 六边形图标 ...
  screens/
    shell.dart              底部 6 个 Tab
    watchlist_page.dart     自选
    market_page.dart        行情
    discover_page.dart      发现
    trade_page.dart         开户|交易（开户 / 普通 / 信用 / 期权）
    finance_page.dart       理财
    profile_page.dart       我的
    stock_detail_page.dart  个股详情（分时 / 日K / 周K / 月K）
    positions_page.dart     持仓 / 当日委托 / 当日成交 / 历史成交
    login_page.dart         模拟登录
    search_page.dart        代码/名称搜索
    placeholder_page.dart   二级入口占位页
test/                      单元测试 + 冒烟测试
tool/                      图标生成、Dart 静态检查脚本
```

## 3. 数据层：akshare 接口映射

akshare 本身是纯 HTTP 爬虫库，因此把它的 URL 与字段语义搬到客户端即可，**无需后端**。
实现集中在 `lib/data/em.dart`，每个方法都标注了对应的 akshare 函数：

| akshare 函数 | 实际 HTTP 接口 | 本项目 |
| --- | --- | --- |
| `stock_zh_a_spot_em` | `push2.eastmoney.com/api/qt/clist/get` | `Em.listUrl` / `MarketApi.list` |
| `stock_zh_index_spot_em` | `push2/api/qt/ulist.np/get` | `Em.batchUrl` / `MarketApi.indexes` |
| `stock_bid_ask_em` | `push2/api/qt/stock/get` | `Em.stockUrl` / `MarketApi.quote` |
| `stock_zh_a_hist_min_em` | `push2his/api/qt/stock/trends2/get` | `Em.trendsUrl` / `MarketApi.trends` |
| `stock_zh_a_hist` | `push2his/api/qt/stock/kline/get` | `Em.klineUrl` / `MarketApi.klines` |
| `stock_board_industry_name_em` | `clist/get?fs=m:90+t:2` | `MarketApi.boards` |
| `stock_board_concept_name_em` | `clist/get?fs=m:90+t:3` | `MarketApi.boards(concept: true)` |
| `stock_margin_sse/szse` | `datacenter-web.eastmoney.com/api/data/v1/get`（RPTA_RZRQ_LSHJ） | `MarketApi.marginBalance` |
| `stock_info_global_em` | `np-listapi.eastmoney.com/comm/web/getFastNewsList` | `NewsApi.fastNews` |
| `stock_news_em` | `np-listapi.eastmoney.com/comm/web/getNewsByColumns` | `NewsApi.columnNews` |
| `stock_research_report_em` | `reportapi.eastmoney.com/report/list` | `NewsApi.reports` |
| `fund_em_open_fund_rank` | `fund.eastmoney.com/data/rankhandler.aspx` | `FundApi.ranking` |
| `fund_open_fund_info_em` | `api.fund.eastmoney.com/f10/lsjz` | `FundApi.navHistory` |
| （搜索框） | `searchapi.eastmoney.com/api/suggest/get` | `MarketApi.search` |

市场选择器（`fs`）已内置：沪深京 A 股 / 沪 A / 深 A / 创业板 / 科创板 / 北交所 / 基金 / ETF / 可转债。
指数篮子：上证 `1.000001`、深证成指 `0.399001`、创业板指 `0.399006`、沪深 300 `1.000300`、科创 50 `1.000688`、北证 50 `0.899050`。

### 涨跌分布 / 成交额 / 主力净流入
`MarketApi.activity()` 用一次全市场快照（`fields=f3,f6,f62`，`pz=6000`）本地聚合出
涨跌家数分布、两市成交额与主力净流入，与行情页截图一致；两融余额单独取自数据中心接口。

## 4. 页面清单（对应 example/ 截图）

| 截图 | 页面 | 实现要点 |
| --- | --- | --- |
| 15501a35… | 自选 | 指数条 + AI识股/分析/资金/资讯、全部/持仓股/最近浏览/基金、编辑删除、分时迷你走势、涨幅色块 |
| 643c6649… | 行情 | 全球/A股/基金/ETF/可转债/新三板、三指数卡、节假日休盘（涨跌分布柱状图、成交额、两融）、工具入口、行业板块、涨幅榜 |
| 43bbe314… | 发现 | 十大功能入口、ETF 横幅、今日热点（概念切换 + 折线 + 涨跌家数 + 主力净流入 + 领涨股）、热点日历/重要事件 |
| 04a0bab9… | 开户|交易·开户 | 开户即享多重福利、新客专享六大福利、开户领取 / 已有账户去登录 |
| b7730a77… | 开户|交易·普通 | 立即开户/立即登录、买/卖/持/撤 + 银证转账/当日成交/历史成交、IPO 打新、特色交易、日内回转、网格回测 |
| eaf34268… | 开户|交易·信用 | 担保品买卖、融资买入、融券卖出、卖券还款、买券还券、融E惠、专用券源、直接还款、现券还券 |
| 5728e739… | 开户|交易·期权 | 极速登录、行情/下单/撤单/查询/持仓/行权/锁定/转账、重要通知…委托设置 |
| 11cd2794… | 理财 | 登录后可查看资产与盈亏、十大理财入口、广告位与策略卡、火热发售（公募/信托/私募）+ 基金排行 |
| ac0e3dfb… | 我的 | 红色头部（交易登录 + 手机号脱敏）、我的卡券/星级/服务专员/设置、新户专享、资产分析、服务&工具 |

## 5. 模拟登录与开户/交易

两级登录，与截图状态一致（登录了 App 账号，但未登录开户号）：

1. **App 账号**：`我的 → 交易登录`，任意 11 位手机号 + 任意密码即可登录，手机号脱敏显示为 `155****2274` 形式。
2. **交易/开户账户**：`开户|交易` 中的 `立即登录 / 开户领取` 触发 `AppState.openTradeAccount()`，
   即在 `MockTradeApi` 中开出一个模拟账户（初始资金 26.8 万 + 5 只底仓），随后 `普通 / 信用 / 期权` 页显示资产与持仓。

`MockTradeApi` 支持：买入 / 卖出（100 股整数倍校验、资金与持仓校验、成交回报、手续费）、
撤单、银证转账（转入/转出）、持仓浮动盈亏按最新价重估、IPO 打新列表。
所有数据仅存于内存 + `shared_preferences`（登录态、自选列表），不涉及任何真实资金。

## 6. 运行与构建

```bash
# 1) 依赖
flutter pub get

# 2) 运行（连接真机或模拟器）
flutter run

# 3) 打包
flutter build apk --release          # Android
flutter build appbundle --release    # Android (Play)
flutter build ipa --release          # iOS（需 macOS + Xcode）

# 4) 测试与静态检查
flutter test
flutter analyze
```

## 7. 平台脚手架说明（重要）

本仓库的 `android/`、`ios/` 只保留**平台定制文件**（应用名、包名、图标、权限、启动背景、
`Info.plist`、`AppDelegate.swift`、`Main.storyboard` 等）；与 Flutter SDK 强耦合的**生成类文件**都不提交，
由 CI（或本地一条命令）用 `flutter create` 按当前 SDK 版本补齐：

- iOS：`ios/Runner.xcodeproj/`（Xcode 工程文件）。
- Android：`android/settings.gradle*`、`android/build.gradle*`、`android/app/build.gradle*`、
  `android/gradle.properties`、`android/gradle/wrapper/`（含 `gradlew` / `gradle-wrapper.jar`）。

补齐方式（`rsync --ignore-existing` 只会新增缺失文件，不会覆盖已提交的定制文件）：

```bash
flutter create --platforms=android,ios --org com.aholic --project-name crec /tmp/crec_scaffold
rsync -a --ignore-existing /tmp/crec_scaffold/android/ android/
rsync -a --ignore-existing /tmp/crec_scaffold/ios/ ios/
```

> 包名由 `--org com.aholic` + 项目名 `crec` 推导为 `com.aholic.crec`，与仓库配置一致。
> 这样 AGP / Kotlin / Gradle 版本始终跟随当前 Flutter SDK，避免手工写死版本导致构建失败。

## 8. 离线兜底数据

所有网络请求失败（无网络、被限流、休市等）都会回退到 `FallbackData`，
其中的数值刻意与截图一致（上证 3842.19 +0.31%、涨跌分布 2567:2824、主力净流入 -96.84 亿、
两融 2.61 万亿、成交额 1.44 万亿、金地集团 2.74 +7.45% 等），保证界面在任何环境下都可完整展示。

## 9. 已知限制

- 接口均为第三方公开接口，无 SLA；字段顺序若上游调整需要同步修改 `em.dart` 的解析。
- 涨跌分布由全市场快照本地聚合，首次加载数据量约 5000+ 行，弱网下会稍慢（失败则用兜底数据）。
- 「较上一日此时」的增量、热点日历等少数展示项为静态/近似值。
- `icon.jpg` 原始分辨率仅 152×152，生成的 1024 图标为放大结果；上架前请替换为 1024×1024 高清图标后重跑 `tool/make_icons.py`。
- 真实开户、行情授权、消息推送等合规能力需要持牌机构柜台与备案域名，本例仅做交互演示。

## 10. CI（GitHub Actions）

构建工作流已按本项目（Flutter，而非 XcodeGen）改写，**一次运行同时产出 iOS 与 Android 安装包**：

| 文件 | 触发 | 作业图 | 做什么 |
| --- | --- | --- | --- |
| `.github/workflows/build-dev.yml` | push 到 `dev`（仅改 `VERSION` 不触发）/ 手动 | `verify` → `build-ios` ∥ `build-android` | 静态检查只跑一次；两个平台并行编译 Debug 无签名包，IPA / APK 各上传为 Actions 工件，**不发 Release** |
| `.github/workflows/build-release.yml` | PR 合并进 `main` | `prepare` → (`build-ios` ∥ `build-android`) → `release` | 读 `VERSION` 并校验 `v<VERSION>` 标签是否已存在；两个平台并行编译 Release 包；全部成功后用一个 Release 同时挂上 IPA + APK + SHA256 |
| `.github/workflows/extract-assets.yml` | **仅手动**（`workflow_dispatch`，不随 push/PR 运行） | `extract` | 在 macOS runner 上用 Xcode 自带的 `assetutil` 解 iPhone 版 `Assets.car`：必定产出 `assets.json`（命名颜色 RGBA + 资源名/尺寸）与 `asset-names.txt`，并尽力导出 PNG（acextract / cartool）；只上传 Actions 工件，不改动仓库 |

产物命名：

- iOS 无签名 IPA：dev 为 `Crec-<VERSION>-dev<run>-unsigned.ipa`，release 为 `Crec-<VERSION>-unsigned.ipa`。
- Android APK：dev 为 `Crec-<VERSION>-dev<run>.apk`，release 为 `Crec-<VERSION>.apk`。

与原 XcodeGen 版本的对应关系：

- `xcodegen generate` + `xcodebuild -project Burette.xcodeproj` → `flutter build ios --no-codesign`（Flutter 内部调用 xcodebuild，并自动 `pod install`）；Android 用 `flutter build apk`（`flutter` 自带 Gradle wrapper）。
- 前置校验从 `UIFileSharingEnabled / LSSupportsOpeningDocumentsInPlace`（Burette 专属）改为 `ios/Runner/Info.plist` 的 plutil 校验与 `CFBundleDisplayName` 输出；Android 侧校验 `android/app/build.gradle(.kts)` 的 `applicationId` / `namespace` 必须为 `com.aholic.crec`（由 `--org com.aholic` 生成）。
- 产物名 `Burette-…-unsigned.ipa` → `Crec-…-unsigned.ipa`，并新增 `Crec-….apk`；`Runner.app` 位置由 `find build/ios -name Runner.app` 动态定位，APK 由 `find build/app/outputs -name '*.apk'` 动态定位，Debug / Release 输出目录不同也无需改脚本。
- 版本号除写入 `MARKETING_VERSION` 外，还通过 `--build-name` / `--build-number` 传给 Flutter，因此 `VERSION` 仍是唯一版本来源；构建号用 `github.run_number`。
- `ios/Runner.xcodeproj` 与 Android 的 Gradle 配置（`settings.gradle*` / `build.gradle*` / `app/build.gradle*` / `gradle.properties` / `gradlew` / `gradle-wrapper.jar`）均不提交：CI 先 `flutter create --platforms=... --org com.aholic --project-name crec` 生成到临时目录，再用 `rsync -a --ignore-existing` 只补缺失文件；已提交的 `Info.plist` / `AppDelegate.swift` / storyboard / AppIcon / `AndroidManifest.xml` / `MainActivity.kt` / `res/` 图标不会被覆盖。
- Android 构建前先执行 `yes | flutter doctor --android-licenses` 接受 SDK 许可：runner 上新增的 SDK 组件常因未接受许可（`flutter doctor` 提示 `Some Android licenses not accepted`）而使 `flutter build apk` 失败。

> 本地构建前请先执行第 7 节的 `flutter create` + `rsync` 补齐命令；这些生成文件已在 `.gitignore` 中，请勿提交回仓库。

## 11. 自检脚本

```bash
python tool/make_icons.py                                            # 重新生成 Android / iOS 图标
node tool/check_dart.mjs lib                                         # Dart 括号/字符串结构检查
node tool/check_symbols.mjs lib                                      # import 解析与跨文件符号检查
node tool/check_workflows.mjs .github/workflows/*.yml
python tool/summarize_assets.py out/assets.json out/asset-names.txt   # 整理 assetutil --info 输出（供 extract-assets 工作流使用）
```
