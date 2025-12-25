import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';



/// ------------------------------
/// APP + THEME
/// ------------------------------


class AppTheme {
  static const Color primary = Color(0xFF0DF2F2);
  static const Color bgDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceDarker = Color(0xFF111827);
  static const Color dimText = Color(0xFF94A3B8);

 
}

/// ------------------------------
/// STATE (GetX)
/// ------------------------------
class DashboardController extends GetxController {
  DashboardController({
    required this.monthLabel,
    required this.mealRate,
    required this.totalExpense,
    required this.budget,
    required this.totalMeals,
    required this.bazarCost,
    required this.utilitiesCost,
    required this.dailyMealsSeries,
    required this.expenseSplit,
    required this.members,
  });

  String monthLabel;
  double mealRate;
  double totalExpense;
  double budget;

  int totalMeals;
  double bazarCost;
  double utilitiesCost;

  /// Simple daily series (0..1 normalized or real values)
  List<double> dailyMealsSeries;

  /// expenseSplit must sum to 1.0 (Food/Util/Rent)
  ExpenseSplit expenseSplit;

  List<MemberBalance> members;

  int _bottomTabIndex = 0;
  int get bottomTabIndex => _bottomTabIndex;

  void setTab(int index) {
    if (_bottomTabIndex == index) return;
    _bottomTabIndex = index;
    update();
  }

  /// FAB action: add one meal & tweak series
  void addMeal() {
    totalMeals += 1;
    // bump last point slightly
    if (dailyMealsSeries.isNotEmpty) {
      dailyMealsSeries = List<double>.from(dailyMealsSeries);
      dailyMealsSeries[dailyMealsSeries.length - 1] =
          (dailyMealsSeries.last + 0.03).clamp(0.0, 1.0);
    }
    update();
  }

  static DashboardController seeded() {
    return DashboardController(
      monthLabel: 'October 2023',
      mealRate: 4.50,
      totalExpense: 1240,
      budget: 1500,
      totalMeals: 345,
      bazarCost: 850,
      utilitiesCost: 390,
      dailyMealsSeries: const [0.70, 0.62, 0.78, 0.55, 0.72, 0.40, 0.60],
      expenseSplit: const ExpenseSplit(food: 0.65, util: 0.20, rent: 0.15),
      members: const [
        MemberBalance(
          name: 'John Doe',
          meals: 45,
          paid: 200,
          balanceType: BalanceType.due,
          balanceAmount: 25,
          lastLabel: 'Today',
        ),
        MemberBalance(
          name: 'Jane Smith',
          meals: 40,
          paid: 250,
          balanceType: BalanceType.refund,
          balanceAmount: 70,
          lastLabel: 'Yesterday',
        ),
        MemberBalance(
          name: 'Robert Fox',
          meals: 32,
          paid: 150,
          balanceType: BalanceType.zero,
          balanceAmount: 0,
          lastLabel: '2 days ago',
        ),
      ],
    );
  }
}

enum BalanceType { due, refund, zero }

class MemberBalance {
  const MemberBalance({
    required this.name,
    required this.meals,
    required this.paid,
    required this.balanceType,
    required this.balanceAmount,
    required this.lastLabel,
  });

  final String name;
  final int meals;
  final double paid;
  final BalanceType balanceType;
  final double balanceAmount;
  final String lastLabel;
}

class ExpenseSplit {
  const ExpenseSplit({required this.food, required this.util, required this.rent});
  final double food;
  final double util;
  final double rent;
}

/// ------------------------------
/// SHELL WITH BOTTOM NAV
/// ------------------------------
class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController.seeded());
    }

    return GetBuilder<DashboardController>(
      builder: (c) {
        final tab = c.bottomTabIndex;

        Widget body;
        switch (tab) {
          case 0:
            body = const DashboardPage();
            break;
          case 1:
            body = const PlaceholderPage(title: 'Members');
            break;
          case 2:
            body = const PlaceholderPage(title: 'Bazar');
            break;
          default:
            body = const PlaceholderPage(title: 'More');
        }

        return Scaffold(
          body: SafeArea(child: body),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _CenterFab(onPressed: c.addMeal),
          bottomNavigationBar: GlassBottomNav(
            currentIndex: c.bottomTabIndex,
            onTap: (i) {
              // Map indexes excluding FAB slot
              // UI: Home, Members, (FAB), Bazar, More
              if (i == 0) c.setTab(0);
              if (i == 1) c.setTab(1);
              if (i == 3) c.setTab(2);
              if (i == 4) c.setTab(3);
            },
          ),
        );
      },
    );
  }
}

class _CenterFab extends StatelessWidget {
  const _CenterFab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.25),
            blurRadius: 22,
            spreadRadius: 2,
          )
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.bgDark,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// ------------------------------
/// DASHBOARD PAGE
/// ------------------------------
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (c) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: TopBar(
                titleTop: 'Mess Admin',
                monthLabel: c.monthLabel,
                onSearch: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search tapped')),
                  );
                },
              ),
            ),

            // Content padding
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // HERO STATS
                    Row(
                      children: [
                        Expanded(
                          child: HighlightStatCard(
                            icon: Icons.restaurant,
                            label: 'Meal Rate',
                            value: '\$${c.mealRate.toStringAsFixed(2)}',
                            trendLabel: '+2.4% vs last mo',
                            trendUp: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: Colors.orange,
                            label: 'Total Exp',
                            value: '\$${c.totalExpense.toStringAsFixed(0)}',
                            subLabel: 'Budget: \$${c.budget.toStringAsFixed(0)}',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // MINI STATS
                    Row(
                      children: [
                        Expanded(
                          child: MiniStatTile(
                            label: 'Meals',
                            value: '${c.totalMeals}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MiniStatTile(
                            label: 'Bazar',
                            value: '\$${c.bazarCost.toStringAsFixed(0)}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MiniStatTile(
                            label: 'Utils',
                            value: '\$${c.utilitiesCost.toStringAsFixed(0)}',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ANALYTICS HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Analytics',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            backgroundColor: AppTheme.primary.withOpacity(0.12),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Report coming soon')),
                            );
                          },
                          child: const Text('View Report', style: TextStyle(fontSize: 12)),
                        )
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ANALYTICS CAROUSEL
                    SizedBox(
                      height: 210,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.85,
                            child: AnalyticsCardLine(
                              title: 'Daily Meal Trend',
                              mainValue: '${c.totalMeals}',
                              mainSuffix: 'Meals',
                              badgeText: '+12 today',
                              series: c.dailyMealsSeries,
                              xLabels: const ['1 Oct', '15 Oct', '30 Oct'],
                            ),
                          ),
                          const SizedBox(width: 14),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.85,
                            child: AnalyticsCardDonut(
                              title: 'Expense Split',
                              totalText: '\$${c.totalExpense.toStringAsFixed(0)}',
                              split: c.expenseSplit,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Member Balances',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),

                    // MEMBER LIST
                    ListView.separated(
                      itemCount: c.members.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final m = c.members[index];
                        return MemberBalanceTile(
                          member: m,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Open ${m.name} details')),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// ------------------------------
/// TOP BAR
/// ------------------------------
class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.titleTop,
    required this.monthLabel,
    required this.onSearch,
  });

  final String titleTop;
  final String monthLabel;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.surfaceDark, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://i.pravatar.cc/150?img=12',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.bgDark, width: 2),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleTop.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.dimText,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {},
                    child: Row(
                      children: [
                        Text(
                          monthLabel,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.expand_more, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.surfaceDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------
/// REUSABLE CARDS
/// ------------------------------
class BaseCard extends StatelessWidget {
  const BaseCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: child,
    );
  }
}

class HighlightStatCard extends StatelessWidget {
  const HighlightStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.trendLabel,
    required this.trendUp,
  });

  final IconData icon;
  final String label;
  final String value;
  final String trendLabel;
  final bool trendUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.surfaceDark, AppTheme.surfaceDarker],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: AppTheme.primary, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.dimText,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                  shadows: [
                    Shadow(
                      blurRadius: 18,
                      color: AppTheme.primary.withOpacity(0.25),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    trendUp ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: trendUp ? Colors.greenAccent : Colors.redAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trendLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: trendUp ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subLabel,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subLabel;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.dimText,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            subLabel,
            style: const TextStyle(fontSize: 11, color: AppTheme.dimText),
          ),
        ],
      ),
    );
  }
}

class MiniStatTile extends StatelessWidget {
  const MiniStatTile({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.dimText,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------
/// ANALYTICS CARDS
/// ------------------------------
class AnalyticsCardLine extends StatelessWidget {
  const AnalyticsCardLine({
    super.key,
    required this.title,
    required this.mainValue,
    required this.mainSuffix,
    required this.badgeText,
    required this.series,
    required this.xLabels,
  });

  final String title;
  final String mainValue;
  final String mainSuffix;
  final String badgeText;
  final List<double> series;
  final List<String> xLabels;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.dimText,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: mainValue,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: ' $mainSuffix',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.dimText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Chart
          Expanded(
            child: LineAreaChart(
              values: series,
              lineColor: AppTheme.primary,
              fillColor: AppTheme.primary.withOpacity(0.14),
              dotIndex: math.max(0, (series.length / 2).floor()),
            ),
          ),

          const SizedBox(height: 10),

          // X labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: xLabels
                .map((e) => Text(e, style: const TextStyle(fontSize: 10, color: AppTheme.dimText)))
                .toList(),
          )
        ],
      ),
    );
  }
}

class AnalyticsCardDonut extends StatelessWidget {
  const AnalyticsCardDonut({
    super.key,
    required this.title,
    required this.totalText,
    required this.split,
  });

  final String title;
  final String totalText;
  final ExpenseSplit split;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.dimText,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: totalText,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const TextSpan(
                          text: ' Total',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.dimText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Icon(Icons.pie_chart_outline, color: AppTheme.dimText),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 118,
                  height: 118,
                  child: DonutChart(
                    segments: [
                      DonutSegment(value: split.food, color: AppTheme.primary),
                      DonutSegment(value: split.util, color: Colors.orange),
                      DonutSegment(value: split.rent, color: Colors.greenAccent),
                    ],
                    centerTop: 'Top',
                    centerBottom: 'Food',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LegendRow(label: 'Food', color: AppTheme.primary, pct: split.food),
                      const SizedBox(height: 10),
                      LegendRow(label: 'Util', color: Colors.orange, pct: split.util),
                      const SizedBox(height: 10),
                      LegendRow(label: 'Rent', color: Colors.greenAccent, pct: split.rent),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LegendRow extends StatelessWidget {
  const LegendRow({
    super.key,
    required this.label,
    required this.color,
    required this.pct,
  });

  final String label;
  final Color color;
  final double pct;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        Text('${(pct * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, color: AppTheme.dimText, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// ------------------------------
/// MEMBER TILE
/// ------------------------------
class MemberBalanceTile extends StatelessWidget {
  const MemberBalanceTile({
    super.key,
    required this.member,
    required this.onTap,
  });

  final MemberBalance member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (chipBg, chipFg, chipText) = _chipFor(member);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            // Avatar (network placeholder)
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.transparent, width: 2),
                image: DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/150?u=${Uri.encodeComponent(member.name)}'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.restaurant_menu, size: 14, color: AppTheme.dimText),
                      const SizedBox(width: 4),
                      Text('${member.meals}', style: const TextStyle(fontSize: 12, color: AppTheme.dimText, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 10),
                      Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Text(
                        'Paid \$${member.paid.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12, color: Colors.greenAccent, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: member.balanceType == BalanceType.zero
                          ? Colors.white.withOpacity(0.12)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    chipText,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: chipFg),
                  ),
                ),
                const SizedBox(height: 6),
                Text('Last: ${member.lastLabel}',
                    style: const TextStyle(fontSize: 10, color: AppTheme.dimText)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color, String) _chipFor(MemberBalance m) {
    switch (m.balanceType) {
      case BalanceType.due:
        return (Colors.redAccent.withOpacity(0.12), Colors.redAccent, 'Due \$${m.balanceAmount.toStringAsFixed(2)}');
      case BalanceType.refund:
        return (Colors.greenAccent.withOpacity(0.12), Colors.greenAccent, 'Ref \$${m.balanceAmount.toStringAsFixed(2)}');
      case BalanceType.zero:
        return (AppTheme.surfaceDarker, AppTheme.dimText, '\$0.00');
    }
  }
}

/// ------------------------------
/// LINE + AREA CHART (no packages)
/// values must be 0..1
/// ------------------------------
class LineAreaChart extends StatelessWidget {
  const LineAreaChart({
    super.key,
    required this.values,
    required this.lineColor,
    required this.fillColor,
    required this.dotIndex,
  });

  final List<double> values;
  final Color lineColor;
  final Color fillColor;
  final int dotIndex;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineAreaPainter(
        values: values,
        lineColor: lineColor,
        fillColor: fillColor,
        dotIndex: dotIndex.clamp(0, math.max(0, values.length - 1)),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _LineAreaPainter extends CustomPainter {
  _LineAreaPainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
    required this.dotIndex,
  });

  final List<double> values;
  final Color lineColor;
  final Color fillColor;
  final int dotIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final w = size.width;
    final h = size.height;

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = (w * i) / (values.length - 1);
      final y = h * (1 - values[i].clamp(0.0, 1.0));
      points.add(Offset(x, y));
    }

    // Line path (smooth-ish using quadratic)
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      linePath.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    linePath.lineTo(points.last.dx, points.last.dy);

    // Area path
    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, h)
      ..lineTo(points.first.dx, h)
      ..close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = lineColor;

    canvas.drawPath(areaPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    // Dots
    final dotPaint = Paint()..color = lineColor;
    final dot = points[dotIndex];
    canvas.drawCircle(dot, 3.0, dotPaint);

    // A second dot near end for that “active” feel
    if (points.length >= 2) {
      canvas.drawCircle(points[points.length - 2], 2.6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineAreaPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.dotIndex != dotIndex;
  }
}

/// ------------------------------
/// DONUT CHART (no packages)
/// ------------------------------
class DonutSegment {
  const DonutSegment({required this.value, required this.color});
  final double value;
  final Color color;
}

class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.segments,
    required this.centerTop,
    required this.centerBottom,
  });

  final List<DonutSegment> segments;
  final String centerTop;
  final String centerBottom;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          painter: _DonutPainter(segments: segments),
          child: const SizedBox.expand(),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(centerTop, style: const TextStyle(fontSize: 11, color: AppTheme.dimText, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(centerBottom, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
          ],
        )
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments});

  final List<DonutSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 10.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2 - stroke / 2;

    // Background ring
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withOpacity(0.10);

    canvas.drawCircle(center, radius, bgPaint);

    // Segments
    double start = -math.pi / 2; // start at top
    for (final s in segments) {
      final sweep = (2 * math.pi) * s.value.clamp(0.0, 1.0);
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt
        ..color = s.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        p,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}

/// ------------------------------
/// GLASS BOTTOM NAV
/// ------------------------------
class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
      decoration: BoxDecoration(
        color: AppTheme.bgDark.withOpacity(0.86),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: Icons.dashboard,
            label: 'Home',
            active: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.group,
            label: 'Members',
            active: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          const SizedBox(width: 56), // space for FAB
          _NavItem(
            icon: Icons.shopping_cart,
            label: 'Bazar',
            active: currentIndex == 2,
            onTap: () => onTap(3),
          ),
          _NavItem(
            icon: Icons.more_horiz,
            label: 'More',
            active: currentIndex == 3,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.primary : AppTheme.dimText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
