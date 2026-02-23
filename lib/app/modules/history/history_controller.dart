import 'package:get/get.dart';
import '../../data/models/transaction_model.dart';
import '../../data/services/storage_service.dart';
import '../home/home_controller.dart';

class HistoryController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final RxList<TransactionModel> allTransactions = <TransactionModel>[].obs;
  final RxString filter = 'all'.obs; // all, income, expense

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  void loadTransactions() {
    allTransactions.value = _storage.getTransactions();
  }

  List<TransactionModel> get filtered {
    if (filter.value == 'income') {
      return allTransactions
          .where((t) => t.type == TransactionType.income)
          .toList();
    } else if (filter.value == 'expense') {
      return allTransactions
          .where((t) => t.type == TransactionType.expense)
          .toList();
    }
    return allTransactions;
  }

  Future<void> delete(String id, double amount, TransactionType type) async {
    await _storage.deleteTransaction(id);
    // Revert balance
    final user = _storage.getUser();
    if (user != null) {
      final newBalance = type == TransactionType.income
          ? user.balance - amount
          : user.balance + amount;
      await _storage.updateBalance(newBalance);
    }
    loadTransactions();
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadData();
    }
  }

  void setFilter(String f) => filter.value = f;
}
