import 'dart:convert';

class UserModel {
  final String name;
  final String email;
  final String phone;
  final String avatarInitial;
  final double balance;
  final DateTime memberSince;

  UserModel({
    required this.name,
    required this.email,
    this.phone = '',
    required this.balance,
    DateTime? memberSince,
  })  : avatarInitial = name.isNotEmpty ? name[0].toUpperCase() : 'U',
        memberSince = memberSince ?? DateTime.now();

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    double? balance,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
      memberSince: memberSince,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'balance': balance,
      'memberSince': memberSince.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
      memberSince: map['memberSince'] != null
          ? DateTime.parse(map['memberSince'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
