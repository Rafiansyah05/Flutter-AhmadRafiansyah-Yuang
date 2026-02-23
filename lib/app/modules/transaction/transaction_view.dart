import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'transaction_controller.dart';
import '../../data/models/transaction_model.dart';
import '../../themes/app_theme.dart';
import '../../../../utils/rupiah_input_formatter.dart';

class TransactionView extends StatelessWidget {
  const TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TransactionController>();
    final isIncome = ctrl.type == TransactionType.income;
    final color = isIncome ? AppTheme.income : AppTheme.expense;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                isIncome ? 'Tambah Pemasukan' : 'Tambah Pengeluaran',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isIncome
                        ? [const Color(0xFF2E7D32), AppTheme.income]
                        : [const Color(0xFFB71C1C), AppTheme.expense],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isIncome
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    size: 60,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input jumlah besar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jumlah',
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Rp',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: ctrl.amountCtrl,
                                keyboardType: TextInputType.number,
                                autofocus: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  RupiahInputFormatter(),
                                ],
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  fillColor: Colors.transparent,
                                  hintText: '0',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Preview format rupiah
                        Obx(() {
                          final raw = ctrl.amountDisplay.value;
                          if (raw.isEmpty || raw == '0') {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              raw,
                              style: TextStyle(
                                fontSize: 12,
                                color: color.withOpacity(0.6),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form fields
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: ctrl.titleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nama Transaksi',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            prefixIcon: Icon(Icons.edit_note_rounded,
                                color: AppTheme.primary),
                          ),
                        ),
                        const Divider(height: 1),
                        Obx(() => DropdownButtonFormField<String>(
                              value: ctrl.selectedCategory.value,
                              decoration: const InputDecoration(
                                labelText: 'Kategori',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                                prefixIcon: Icon(Icons.category_outlined,
                                    color: AppTheme.primary),
                              ),
                              items: ctrl.categories
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                            '${TransactionCategories.iconForCategory(c)}  $c'),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  ctrl.selectedCategory.value = val;
                                }
                              },
                            )),
                        const Divider(height: 1),
                        TextField(
                          controller: ctrl.noteCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Catatan (opsional)',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            prefixIcon: Icon(Icons.note_outlined,
                                color: AppTheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol simpan
                  Obx(() => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: ctrl.isLoading.value ? null : ctrl.save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            disabledBackgroundColor: color.withOpacity(0.6),
                          ),
                          child: ctrl.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isIncome
                                      ? 'Simpan Pemasukan'
                                      : 'Simpan Pengeluaran',
                                ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
