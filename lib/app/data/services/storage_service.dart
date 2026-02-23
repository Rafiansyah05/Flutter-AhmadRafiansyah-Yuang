import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class StorageService extends GetxService {
  static const String _userKey = 'yuang_user';
  static const String _transactionsKey = 'yuang_transactions';

  late SharedPreferences _prefs;

  // Dipanggil dari main() setelah prefs siap
  void initWithPrefs(SharedPreferences prefs) {
    _prefs = prefs;
  }

  // ---- USER ----
  UserModel? getUser() {
    final data = _prefs.getString(_userKey);
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_userKey, user.toJson());
  }

  Future<void> updateBalance(double newBalance) async {
    final user = getUser();
    if (user != null) {
      await saveUser(user.copyWith(balance: newBalance));
    }
  }

  // ---- TRANSACTIONS ----
  List<TransactionModel> getTransactions() {
    final data = _prefs.getStringList(_transactionsKey);
    if (data == null) return [];
    return data.map((e) => TransactionModel.fromJson(e)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveTransaction(TransactionModel transaction) async {
    final list = getTransactions();
    list.add(transaction);
    await _prefs.setStringList(
      _transactionsKey,
      list.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> deleteTransaction(String id) async {
    final list = getTransactions();
    list.removeWhere((e) => e.id == id);
    await _prefs.setStringList(
      _transactionsKey,
      list.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
