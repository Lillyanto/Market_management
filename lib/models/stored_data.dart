import 'dart:convert';
import 'item.dart';
import 'transaction.dart';

class StoredData {
  final double previousBalance;
  final List<Item> currentItems;
  final List<Transaction> transactions;

  StoredData({
    required this.previousBalance,
    required this.currentItems,
    required this.transactions,
  });

  Map<String, dynamic> toJson() {
    return {
      'previousBalance': previousBalance,
      'currentItems': currentItems.map((item) => item.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }

  factory StoredData.fromJson(Map<String, dynamic> json) {
    return StoredData(
      previousBalance: (json['previousBalance'] as num?)?.toDouble() ?? 0.0,
      currentItems: json['currentItems'] != null
          ? (json['currentItems'] as List)
              .map((item) => Item.fromJson(item))
              .toList()
          : [],
      transactions: json['transactions'] != null
          ? (json['transactions'] as List)
              .map((t) => Transaction.fromJson(t))
              .toList()
          : [],
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory StoredData.fromJsonString(String jsonString) {
    return StoredData.fromJson(jsonDecode(jsonString));
  }
}