import 'dart:convert';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final String note;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.note = '',
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      category: map['category'],
      note: map['note'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }

  String toJson() => json.encode(toMap());
  factory TransactionModel.fromJson(String source) =>
      TransactionModel.fromMap(json.decode(source));
}

// Expense categories
class TransactionCategories {
  static const List<String> expense = [
    'Makanan & Minuman',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Kesehatan',
    'Hiburan',
    'Pendidikan',
    'Lainnya',
  ];

  static const List<String> income = [
    'Gaji',
    'Freelance',
    'Bisnis',
    'Investasi',
    'Hadiah',
    'Lainnya',
  ];

  static String iconForCategory(String category) {
    const icons = {
      'Makanan & Minuman': '🍔',
      'Transportasi': '🚗',
      'Belanja': '🛍️',
      'Tagihan': '💡',
      'Kesehatan': '🏥',
      'Hiburan': '🎬',
      'Pendidikan': '📚',
      'Gaji': '💼',
      'Freelance': '💻',
      'Bisnis': '📊',
      'Investasi': '📈',
      'Hadiah': '🎁',
      'Lainnya': '📦',
    };
    return icons[category] ?? '📦';
  }
}
