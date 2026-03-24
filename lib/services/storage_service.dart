import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';
import '../models/stored_data.dart';
import '../models/transaction.dart';

class StorageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Single shop document — all phones share this
  static const String _shopDoc = 'shop';
  static const String _collection = 'marketData';
  static const String _txCollection = 'transactions';

  DocumentReference get _shopRef =>
      _db.collection(_collection).doc(_shopDoc);

  CollectionReference get _txRef =>
      _shopRef.collection(_txCollection);

  // ── Real-time stream so all phones update instantly ──────────────────────
  Stream<StoredData> streamData() {
    return _shopRef.snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return StoredData(
          previousBalance: 0.0,
          currentItems: [],
          transactions: [],
        );
      }
      final data = snap.data() as Map<String, dynamic>;
      return StoredData(
        previousBalance: (data['previousBalance'] as num?)?.toDouble() ?? 0.0,
        currentItems: data['currentItems'] != null
            ? (data['currentItems'] as List)
                .map((i) => Item.fromJson(i as Map<String, dynamic>))
                .toList()
            : [],
        transactions: [], // loaded separately
      );
    });
  }

  Stream<List<Transaction>> streamTransactions() {
    return _txRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                Transaction.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // ── One-time load (used for payment processing) ──────────────────────────
  Future<StoredData> loadData() async {
    final snap = await _shopRef.get();
    if (!snap.exists || snap.data() == null) {
      return StoredData(previousBalance: 0.0, currentItems: [], transactions: []);
    }
    final data = snap.data() as Map<String, dynamic>;
    final txSnap = await _txRef.orderBy('createdAt', descending: true).get();
    final transactions = txSnap.docs
        .map((doc) => Transaction.fromJson(doc.data() as Map<String, dynamic>))
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

  // ── Save current items (assistant saves) ─────────────────────────────────
  Future<void> saveCurrentItems(List<Item> items) async {
    await _shopRef.set(
      {'currentItems': items.map((i) => i.toJson()).toList()},
      SetOptions(merge: true),
    );
  }

  // ── Process payment (owner pays) ─────────────────────────────────────────
  Future<void> processPayment({
    required Transaction transaction,
    required double newBalance,
  }) async {
    final batch = _db.batch();

    // Update shop doc
    batch.set(
      _shopRef,
      {
        'previousBalance': newBalance,
        'currentItems': [],
      },
      SetOptions(merge: true),
    );

    // Add transaction record
    final txDoc = _txRef.doc(transaction.id);
    final txData = transaction.toJson();
    txData['createdAt'] = FieldValue.serverTimestamp();
    batch.set(txDoc, txData);

    await batch.commit();
  }
}
