import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/bottom_navbar.dart';
import '../../themes/app_theme.dart';
import '../../data/models/transaction_model.dart';
import '../history/history_view.dart';
import '../profile/profile_view.dart';
import '../../data/services/storage_service.dart';
import '../../../../utils/currency_formatter.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    return Scaffold(
      body: Obx(() {
        switch (ctrl.currentIndex.value) {
          case 1:
            return const HistoryView();
          case 3:
            return const _StatisticsTab();
          case 4:
            return const ProfileView();
          default:
            return const _HomeTab();
        }
      }),
      bottomNavigationBar: const BottomNavBar(),
      floatingActionButton: null,
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding:
                const EdgeInsets.only(top: 56, left: 20, right: 20, bottom: 20),
            child: Obx(() => Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${ctrl.user.value?.name.split(' ').first ?? 'Pengguna'} 👋',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const Text(
                            'Pantau keuanganmu hari ini',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ctrl.changeTab(4),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryDark, AppTheme.accent],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            ctrl.user.value?.avatarInitial ?? 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ),
        const SliverToBoxAdapter(child: BalanceCard()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaksi Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => ctrl.changeTab(1),
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(() {
          final recent = ctrl.recentTransactions;
          if (recent.isEmpty) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 56, color: AppTheme.textGrey),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada transaksi',
                        style: TextStyle(color: AppTheme.textGrey),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => TransactionTile(transaction: recent[i]),
                childCount: recent.length,
              ),
            ),
          );
        }),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

class _StatisticsTab extends StatelessWidget {
  const _StatisticsTab();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistik',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.monthYear(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Obx(() {
            final income = ctrl.monthlyIncome;
            final expense = ctrl.monthlyExpense;
            final total = income + expense;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Summary cards
                  Row(
                    children: [
                      _SummaryCard(
                        label: 'Pemasukan',
                        amount: income,
                        color: AppTheme.income,
                        icon: Icons.arrow_downward_rounded,
                      ),
                      const SizedBox(width: 12),
                      _SummaryCard(
                        label: 'Pengeluaran',
                        amount: expense,
                        color: AppTheme.expense,
                        icon: Icons.arrow_upward_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (total > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Perbandingan',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 180,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: income,
                                    color: AppTheme.income,
                                    title: income > 0
                                        ? '${(income / total * 100).toStringAsFixed(0)}%'
                                        : '',
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: expense,
                                    color: AppTheme.expense,
                                    title: expense > 0
                                        ? '${(expense / total * 100).toStringAsFixed(0)}%'
                                        : '',
                                    radius: 60,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                                centerSpaceRadius: 40,
                                sectionsSpace: 4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _Legend(
                                  color: AppTheme.income, label: 'Pemasukan'),
                              const SizedBox(width: 24),
                              _Legend(
                                  color: AppTheme.expense,
                                  label: 'Pengeluaran'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          'Belum ada data bulan ini',
                          style: TextStyle(color: AppTheme.textGrey),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        // Category breakdown
        Obx(() {
          final expenses = ctrl.monthlyTransactions
              .where((t) => t.type == TransactionType.expense)
              .toList();
          if (expenses.isEmpty)
            return const SliverToBoxAdapter(child: SizedBox(height: 80));

          final categoryTotals = <String, double>{};
          for (final t in expenses) {
            categoryTotals[t.category] =
                (categoryTotals[t.category] ?? 0) + t.amount;
          }
          final sorted = categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final total = expenses.fold(0.0, (s, t) => s + t.amount);

          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pengeluaran per Kategori',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...sorted.map((e) {
                      final pct = total > 0 ? e.value / total : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  TransactionCategories.iconForCategory(e.key),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(e.value),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.expense,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: AppTheme.expenseLight,
                                valueColor: const AlwaysStoppedAnimation(
                                    AppTheme.expense),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        }),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.formatCompact(amount),
              style: TextStyle(
                fontSize: 16,
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

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
      ],
    );
  }
}
