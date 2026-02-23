import 'package:get/get.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/storage_service.dart';

class HomeController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool balanceVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() {
    user.value = _storage.getUser();
    transactions.value = _storage.getTransactions();
  }

  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => user.value?.balance ?? 0;

  List<TransactionModel> get recentTransactions =>
      transactions.take(5).toList();

  // Monthly transactions for current month
  List<TransactionModel> get monthlyTransactions {
    final now = DateTime.now();
    return transactions
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();
  }

  double get monthlyIncome => monthlyTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get monthlyExpense => monthlyTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  void toggleBalanceVisibility() {
    balanceVisible.toggle();
  }

  void addBalance(double amount) {
    final newBalance = balance + amount;
    _storage.updateBalance(newBalance);
    loadData();
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
