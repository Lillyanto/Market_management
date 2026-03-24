import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';
import '../models/stored_data.dart';
import '../models/transaction.dart' as app_models;

class StorageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _shopDoc = 'shop';
  static const String _collection = 'marketData';
  static const String _txCollection = 'transactions';

  DocumentReference get _shopRef =>
      _db.collection(_collection).doc(_shopDoc);

  CollectionReference get _txRef =>
      _shopRef.collection(_txCollection);

  Stream<StoredData> streamData() {
    return _shopRef.snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return StoredData(previousBalance: 0.0, currentItems: [], transactions: []);
      }
      final data = snap.data() as Map<String, dynamic>;
      return StoredData(
        previousBalance: (data['previousBalance'] as num?)?.toDouble() ?? 0.0,
        currentItems: data['currentItems'] != null
            ? (data['currentItems'] as List)
                .map((i) => Item.fromJson(i as Map<String, dynamic>))
                .toList()
            : [],
        transactions: [],
      );
    });
  }

  Stream<List<app_models.Transaction>> streamTransactions() {
    return _txRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => app_models.Transaction.fromJson(
                doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<StoredData> loadData() async {
    final snap = await _shopRef.get();
    if (!snap.exists || snap.data() == null) {
      return StoredData(previousBalance: 0.0, currentItems: [], transactions: []);
    }
    final data = snap.data() as Map<String, dynamic>;
    final txSnap = await _txRef.orderBy('createdAt', descending: true).get();
    final transactions = txSnap.docs
        .map((doc) => app_models.Transaction.fromJson(
            doc.data() as Map<String, dynamic>))
        .toList();
    return StoredData(
      previousBalance: (data['previousBalance'] as num?)?.toDouble() ?? 0.0,
      currentItems: data['currentItems'] != null
          ? (data['currentItems'] as List)
              .map((i) => Item.fromJson(i as Map<String, dynamic>))
              .toList()
          : [],
      transactions: transactions,
    );
  }

  Future<void> saveCurrentItems(List<Item> items) async {
    await _shopRef.set(
      {'currentItems': items.map((i) => i.toJson()).toList()},
      SetOptions(merge: true),
    );
  }

  Future<void> processPayment({
    required app_models.Transaction transaction,
    required double newBalance,
  }) async {
    final batch = _db.batch();
    batch.set(
      _shopRef,
      {'previousBalance': newBalance, 'currentItems': []},
      SetOptions(merge: true),
    );
    final txDoc = _txRef.doc(transaction.id);
    final txData = transaction.toJson();
    txData['createdAt'] = FieldValue.serverTimestamp();
    batch.set(txDoc, txData);
    await batch.commit();
  }
}
