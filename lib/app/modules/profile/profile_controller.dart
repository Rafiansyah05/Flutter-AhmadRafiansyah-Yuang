import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/services/storage_service.dart';
import '../home/home_controller.dart';
import '../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final RxBool isEditing = false.obs;

  Rx<UserModel?> user = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void loadUser() {
    user.value = _storage.getUser();
    if (user.value != null) {
      nameCtrl.text = user.value!.name;
      emailCtrl.text = user.value!.email;
      phoneCtrl.text = user.value!.phone;
    }
  }

  void startEdit() => isEditing.value = true;

  Future<void> saveProfile() async {
    if (nameCtrl.text.isEmpty) return;
    final updated = user.value!.copyWith(
      name: nameCtrl.text,
      email: emailCtrl.text,
      phone: phoneCtrl.text,
    );
    await _storage.saveUser(updated);
    user.value = updated;
    isEditing.value = false;
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadData();
    }
    Get.snackbar(
      'Berhasil',
      'Profil berhasil diperbarui',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void cancelEdit() {
    loadUser();
    isEditing.value = false;
  }

  void resetApp() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Aplikasi?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Semua data termasuk saldo dan riwayat transaksi akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await _storage.clearAll();
              Get.back();
              Get.offAllNamed(AppRoutes.SPLASH);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }
}
