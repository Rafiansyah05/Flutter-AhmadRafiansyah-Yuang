import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'history_controller.dart';
import '../../widgets/transaction_tile.dart';
import '../../themes/app_theme.dart';
import '../../../../utils/currency_formatter.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  HistoryController get _ctrl {
    if (!Get.isRegistered<HistoryController>()) {
      Get.put(HistoryController());
    }
    return Get.find<HistoryController>();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _ctrl;
    ctrl.loadTransactions();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
          color: AppTheme.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Riwayat Transaksi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              // Filter chips
              Obx(() => Row(
                    children: [
                      _FilterChip(
                        label: 'Semua',
                        selected: ctrl.filter.value == 'all',
                        onTap: () => ctrl.setFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Pemasukan',
                        selected: ctrl.filter.value == 'income',
                        onTap: () => ctrl.setFilter('income'),
                        color: AppTheme.income,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Pengeluaran',
                        selected: ctrl.filter.value == 'expense',
                        onTap: () => ctrl.setFilter('expense'),
                        color: AppTheme.expense,
                      ),
                    ],
                  )),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final list = ctrl.filtered;
            if (list.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 64, color: AppTheme.textGrey),
                    SizedBox(height: 12),
                    Text(
                      'Tidak ada transaksi',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 15),
                    ),
                  ],
                ),
              );
            }

            // Group by date
            final grouped = <String, List>{};
            for (final t in list) {
              final key = CurrencyFormatter.day(t.date);
              grouped.putIfAbsent(key, () => []).add(t);
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: grouped.length,
              itemBuilder: (ctx, i) {
                final dateKey = grouped.keys.elementAt(i);
                final items = grouped[dateKey]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        dateKey,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ),
                    ...items.map((t) => TransactionTile(
                          transaction: t,
                          onDelete: () => _confirmDelete(t, ctrl),
                        )),
                  ],
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _confirmDelete(dynamic t, HistoryController ctrl) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Transaksi?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Transaksi ini akan dihapus dan saldo akan disesuaikan.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              ctrl.delete(t.id, t.amount, t.type);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.expense),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.grey[300]!,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.textGrey,
          ),
        ),
      ),
    );
  }
}
