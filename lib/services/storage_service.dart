#import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stored_data.dart';

class StorageService {
  static const String _key = 'marketData';

  Future<StoredData> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    
    if (jsonString != null) {
      return StoredData.fromJsonString(jsonString);
    }
    
    return StoredData(
      previousBalance: 0.0,
      currentItems: [],
      transactions: [],
    );
  }

  Future<void> saveData(StoredData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, data.toJsonString());
  }
}
