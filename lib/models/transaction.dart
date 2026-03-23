import 'item.dart';

class Transaction {
  final String id;
  final String date;
  final List<Item> items;
  final double totalAmount;
  final double paidAmount;
  final double balance;
  final double previousBalance;

  Transaction({
    required this.id,
    required this.date,
    required this.items,
    required this.totalAmount,
    required this.paidAmount,
    required this.balance,
    required this.previousBalance,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'balance': balance,
      'previousBalance': previousBalance,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: json['date'],
      items: (json['items'] as List)
          .map((item) => Item.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      previousBalance: (json['previousBalance'] as num).toDouble(),
    );
  }
}