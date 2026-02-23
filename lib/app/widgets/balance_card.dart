import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../modules/home/home_controller.dart';
import '../themes/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/rupiah_input_formatter.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    return Obx(() => Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryDark, AppTheme.primary],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Saldo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: ctrl.toggleBalanceVisibility,
                        child: Icon(
                          ctrl.balanceVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _showTopUpDialog(context, ctrl),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Top Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ctrl.balanceVisible.value
                    ? CurrencyFormatter.format(ctrl.balance)
                    : 'Rp ••••••',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatItem(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Pemasukan',
                    value: CurrencyFormatter.formatCompact(ctrl.monthlyIncome),
                    color: AppTheme.income,
                    bgColor: AppTheme.incomeLight,
                  ),
                  const SizedBox(width: 16),
                  Container(width: 1, height: 36, color: Colors.white24),
                  const SizedBox(width: 16),
                  _StatItem(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Pengeluaran',
                    value: CurrencyFormatter.formatCompact(ctrl.monthlyExpense),
                    color: AppTheme.expense,
                    bgColor: AppTheme.expenseLight,
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  void _showTopUpDialog(BuildContext context, HomeController ctrl) {
    final amountCtrl = TextEditingController();
    final preview = ''.obs;

    amountCtrl.addListener(() {
      final raw = CurrencyFormatter.parseInput(amountCtrl.text);
      preview.value = raw > 0 ? CurrencyFormatter.format(raw) : '';
    });

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Top Up Saldo',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                RupiahInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                prefixText: 'Rp ',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
            ),
            const SizedBox(height: 6),
            Obx(() => preview.value.isEmpty
                ? const SizedBox()
                : Text(
                    preview.value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = CurrencyFormatter.parseInput(amountCtrl.text);
              if (amount > 0) {
                ctrl.addBalance(amount);
                Get.back();
                Get.snackbar(
                  'Berhasil! ✓',
                  '${CurrencyFormatter.format(amount)} berhasil ditambahkan',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppTheme.incomeLight,
                  colorText: AppTheme.income,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                );
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
