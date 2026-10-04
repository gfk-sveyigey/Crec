import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models/quote.dart';
import '../state/app_state.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import 'placeholder_page.dart';

/// 发现 - research shortcuts, banner, hot topics and event calendar.
class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  static const List<String> _tabs = <String>['发现', '资讯', '投顾'];

  int _tab = 0;
  int _topic = 0;

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final List<HotTopic> topics = state.hotTopics;
    final HotTopic? current = topics.isEmpty
        ? null
        : topics[_topic < topics.length ? _topic : 0];

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: <Widget>[
          AppTopBar(
            title: '发现',
            tabs: _tabs,
            selectedTab: _tab,
            onTabSelected: (int i) => setState(() => _tab = i),
          ),
          Expanded(
            child: _tab == 0
                ? _informationTab(state, topics, current)
                : _newsTab(state),
          ),
        ],
      ),
    );
  }

  Widget _informationTab(
    AppState state,
    List<HotTopic> topics,
    HotTopic? current,
  ) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: <Widget>[
        SectionCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: NavGridView(
            entries: <NavEntry>[
              NavEntry(icon: Icons.description_outlined, label: '慧投研报', color: kBrandRed, onTap: () {}),
              NavEntry(icon: Icons.assignment_add, label: '一键打新', color: kBrandRed, badge: 'NEW', onTap: () {}),
              NavEntry(icon: Icons.savings_outlined, label: 'ETF新基遇', color: kBrandRed, onTap: () {}),
              NavEntry(icon: Icons.currency_exchange, label: '两融开户', color: kBrandRed, onTap: () {}),
              NavEntry(icon: Icons.work_outline, label: '业务办理', color: kBrandRed, onTap: () {}),
              NavEntry(icon: Icons.storefront_outlined, label: '理财商城', color: kBrandRed, onTap: () {}),
              NavEntry(icon: Icons.task_alt, label: '普通条件单', color: kBrandRed, onTap: () {}),
              NavEntry(icon: Icons.swap_horiz, label: '通用回购', color: kBrandRed, onTap: () {}),
              NavEntry(icon: Icons.pie_chart_outline, label: '中签查询', color: kBrandRed, onTap: () {}),
              NavEntry(icon: Icons.more_horiz, label: '更多', color: kBrandRed, onTap: () {}),
            ],
          ),
        ),
        _banner(),
        SectionHeader(
          title: '今日热点',
          accent: const Icon(Icons.local_fire_department, size: 18, color: kBrandRed),
          onMore: () {},
        ),
        if (topics.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: PillTabs(
              labels: topics.map((HotTopic t) => t.name).toList(),
              selected: _topic,
              dense: true,
              onSelected: (int i) => setState(() => _topic = i),
            ),
          ),
        if (current != null) _topicCard(current),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: _calendarCard()),
              const SizedBox(width: 10),
              Expanded(child: _eventCard(state)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _banner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF2C6BE4), Color(0xFF1B49A8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 16,
            top: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  'ETF巅峰对决',
                  style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                Text(
                  '选你的阵营，冲榜赢好礼！',
                  style: TextStyle(color: Color(0xFFDAE4FF), fontSize: 12),
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A3D),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                '潜 心 研 判',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const Positioned(
            right: 12,
            bottom: 8,
            child: Text(
              '市场有风险 · 投资需谨慎',
              style: TextStyle(color: Color(0xFFB9C8EE), fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topicCard(HotTopic topic) {
    final Color c = changeColor(topic.changePct);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    topic.name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    signedPct(topic.changePct),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Sparkline(values: topic.spark, color: c, height: 40, filled: true),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    topic.upDownRatio,
                    style: const TextStyle(fontSize: 15, color: kUp, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  const Text('涨跌家数', style: TextStyle(fontSize: 11, color: kTextSub)),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    compact(topic.netInflow),
                    style: const TextStyle(fontSize: 15, color: kText, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  const Text('主力净流入', style: TextStyle(fontSize: 11, color: kTextSub)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            topic.description,
            style: const TextStyle(fontSize: 13, color: kText, height: 1.5),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            children: topic.stocks.map((HotStock s) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(s.name, style: const TextStyle(fontSize: 12, color: kTextSub)),
                  const SizedBox(width: 4),
                  Text(
                    signedPct(s.changePct),
                    style: TextStyle(fontSize: 12, color: changeColor(s.changePct)),
                  ),
                ],
              );
            }).toList(),
          ),
          if (topic.stocks.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Row(
              children: topic.stocks.map((HotStock s) {
                return Expanded(
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF3F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s.name + ' ' + signedPct(s.changePct),
                        style: TextStyle(fontSize: 12, color: changeColor(s.changePct)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _calendarCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: const <Widget>[
              Icon(Icons.calendar_month, size: 16, color: kBrandRed),
              SizedBox(width: 6),
              Text('热点日历', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
              Spacer(),
              Icon(Icons.chevron_right, size: 16, color: kTextFaint),
            ],
          ),
          const SizedBox(height: 12),
          const Text('--', style: TextStyle(fontSize: 13, color: kTextSub)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _eventCard(AppState state) {
    final NewsItem? news = state.news.isEmpty ? null : state.news.first;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: const <Widget>[
              Icon(Icons.article_outlined, size: 16, color: Color(0xFFE8933A)),
              SizedBox(width: 6),
              Text('重要事件', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
              Spacer(),
              Icon(Icons.chevron_right, size: 16, color: kTextFaint),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            news == null ? '暂无重要事件' : news.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: kText, height: 1.45),
          ),
          const SizedBox(height: 8),
          Row(
            children: const <Widget>[
              Text('嘉友国际', style: TextStyle(fontSize: 12, color: kTextSub)),
              SizedBox(width: 4),
              Text('+1.52%', style: TextStyle(fontSize: 12, color: kUp)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _newsTab(AppState state) {
    final List<NewsItem> items = state.news;
    return RefreshIndicator(
      color: kBrandRed,
      onRefresh: state.refreshMarket,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: items.isEmpty ? 1 : items.length,
        itemBuilder: (BuildContext context, int i) {
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Text('暂无资讯', style: TextStyle(color: kTextSub, fontSize: 13)),
              ),
            );
          }
          final NewsItem n = items[i];
          return SectionCard(
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => PlaceholderPage(title: '资讯详情', message: n.title),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  n.title,
                  style: const TextStyle(fontSize: 15, color: kText, height: 1.4),
                ),
                if (n.summary.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    n.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: kTextSub, height: 1.4),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  n.source + ' · ' + shortTimeLabel(n.time),
                  style: const TextStyle(fontSize: 11, color: kTextFaint),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
