import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import '../../themes/app_theme.dart';
import '../../../../utils/currency_formatter.dart';
import '../home/home_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  ProfileController get _ctrl {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    return Get.find<ProfileController>();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _ctrl;
    ctrl.loadUser();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryDark, AppTheme.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Obx(() {
              final user = ctrl.user.value;
              if (user == null) return const SizedBox();
              return Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user.avatarInitial,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email.isEmpty ? 'Yuang Member' : user.email,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Member sejak ${CurrencyFormatter.day(user.memberSince)}',
                    style: const TextStyle(fontSize: 11, color: Colors.white60),
                  ),
                ],
              );
            }),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats
                Obx(() {
                  final home = Get.isRegistered<HomeController>()
                      ? Get.find<HomeController>()
                      : null;
                  return Row(
                    children: [
                      _StatCard(
                        label: 'Total Transaksi',
                        value: '${home?.transactions.length ?? 0}',
                        icon: Icons.receipt_rounded,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Total Pemasukan',
                        value: CurrencyFormatter.formatCompact(
                            home?.totalIncome ?? 0),
                        icon: Icons.arrow_downward_rounded,
                        color: AppTheme.income,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Total Keluar',
                        value: CurrencyFormatter.formatCompact(
                            home?.totalExpense ?? 0),
                        icon: Icons.arrow_upward_rounded,
                        color: AppTheme.expense,
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 24),

                // Edit profile section
                _SectionTitle('Informasi Profil'),
                const SizedBox(height: 12),
                Obx(() => ctrl.isEditing.value
                    ? _EditForm(ctrl: ctrl)
                    : _ProfileInfo(ctrl: ctrl)),

                const SizedBox(height: 24),
                _SectionTitle('Pengaturan'),
                const SizedBox(height: 12),

                _SettingItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifikasi',
                  onTap: () => Get.snackbar(
                    'Info',
                    'Fitur segera hadir',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  ),
                ),
                _SettingItem(
                  icon: Icons.security_outlined,
                  label: 'Keamanan',
                  onTap: () {},
                ),
                _SettingItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Bantuan',
                  onTap: () {},
                ),
                _SettingItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Reset Semua Data',
                  onTap: ctrl.resetApp,
                  textColor: AppTheme.expense,
                  iconColor: AppTheme.expense,
                ),
                const SizedBox(height: 12),

                // App version
                const Center(
                  child: Text(
                    'Yuang v1.0.0 • Made with ❤️',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: AppTheme.textGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final ProfileController ctrl;

  const _ProfileInfo({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = ctrl.user.value;
      if (user == null) return const SizedBox();
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            _InfoRow(
                icon: Icons.person_outline, label: 'Nama', value: user.name),
            const Divider(height: 1, indent: 56),
            _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email.isEmpty ? '-' : user.email),
            const Divider(height: 1, indent: 56),
            _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Telepon',
                value: user.phone.isEmpty ? '-' : user.phone),
            const Divider(height: 1),
            ListTile(
              onTap: ctrl.startEdit,
              leading: const Icon(Icons.edit_outlined, color: AppTheme.primary),
              title: const Text(
                'Edit Profil',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppTheme.primary),
            ),
          ],
        ),
      );
    });
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textGrey, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditForm extends StatelessWidget {
  final ProfileController ctrl;

  const _EditForm({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: ctrl.nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nama',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl.emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl.phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telepon',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: ctrl.cancelEdit,
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: ctrl.saveProfile,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color textColor;
  final Color iconColor;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor = AppTheme.textDark,
    this.iconColor = AppTheme.textGrey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: Colors.grey[400]),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
