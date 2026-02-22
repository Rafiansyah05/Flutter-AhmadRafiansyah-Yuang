import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/supabase_service.dart';
import '../models/user_model.dart';
import '../views/home/home_view.dart';
import '../views/auth/login_view.dart';

class AuthController extends GetxController {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      currentUser.value = await SupabaseService.getProfile();
    } catch (_) {}
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (fullName.trim().isEmpty) {
      Get.snackbar('Error', 'Nama lengkap tidak boleh kosong',
          backgroundColor: Colors.red.shade100);
      return;
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      Get.snackbar('Error', 'Email tidak valid',
          backgroundColor: Colors.red.shade100);
      return;
    }
    if (password.length < 6) {
      Get.snackbar('Error', 'Password minimal 6 karakter',
          backgroundColor: Colors.red.shade100);
      return;
    }

    isLoading.value = true;
    try {
      await SupabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      await loadUser();
      Get.offAll(() => const HomeView());
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendaftar: ${e.toString()}',
          backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      await SupabaseService.signIn(email: email, password: password);
      await loadUser();
      Get.offAll(() => const HomeView());
    } catch (e) {
      Get.snackbar('Error', 'Email atau password salah',
          backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    currentUser.value = null;
    Get.offAll(() => const LoginView());
  }
}
