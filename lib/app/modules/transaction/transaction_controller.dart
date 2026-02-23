import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/transaction_model.dart';
import '../../data/services/storage_service.dart';
import '../home/home_controller.dart';
import '../../themes/app_theme.dart';
import '../../../../utils/currency_formatter.dart';

class TransactionController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  late TransactionType type;
  final RxString selectedCategory = ''.obs;
  final RxBool isLoading = false.obs;

  // Untuk preview "Rp 12.000" di bawah input
  final RxString amountDisplay = ''.obs;

  List<String> get categories => type == TransactionType.income
      ? TransactionCategories.income
      : TransactionCategories.expense;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments as String?;
    type = arg == 'income' ? TransactionType.income : TransactionType.expense;
    selectedCategory.value = categories.first;

    // Listener untuk update preview rupiah
    amountCtrl.addListener(() {
      final raw = CurrencyFormatter.parseInput(amountCtrl.text);
      if (raw > 0) {
        amountDisplay.value = CurrencyFormatter.format(raw);
      } else {
        amountDisplay.value = '';
      }
    });
  }

  Future<void> save() async {
    if (titleCtrl.text.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Nama transaksi wajib diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[50],
        colorText: Colors.orange[800],
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    // Parse amount dari format "12.000" → 12000
    final amount = CurrencyFormatter.parseInput(amountCtrl.text);
    if (amount <= 0) {
      Get.snackbar(
        'Perhatian',
        'Masukkan jumlah yang valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[50],
        colorText: Colors.orange[800],
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    isLoading.value = true;

    final transaction = TransactionModel(
      id: const Uuid().v4(),
      title: titleCtrl.text,
      amount: amount,
      type: type,
      category: selectedCategory.value,
      note: noteCtrl.text,
      date: DateTime.now(),
    );

    await _storage.saveTransaction(transaction);

    // Update saldo
    final user = _storage.getUser();
    if (user != null) {
      final newBalance = type == TransactionType.income
          ? user.balance + amount
          : user.balance - amount;
      await _storage.updateBalance(newBalance);
    }

    // Refresh home
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadData();
    }

    isLoading.value = false;
    Get.back();

    Get.snackbar(
      'Berhasil! ✓',
      '${type == TransactionType.income ? 'Pemasukan' : 'Pengeluaran'} ${CurrencyFormatter.format(amount)} disimpan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: type == TransactionType.income
          ? AppTheme.incomeLight
          : AppTheme.expenseLight,
      colorText:
          type == TransactionType.income ? AppTheme.income : AppTheme.expense,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }
}
