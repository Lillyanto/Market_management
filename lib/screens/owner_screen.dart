import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/item.dart';
import '../models/stored_data.dart';
import '../models/transaction.dart' as models;
import '../services/storage_service.dart';

class OwnerScreen extends StatefulWidget {
  const OwnerScreen({Key? key}) : super(key: key);

  @override
  State<OwnerScreen> createState() => _OwnerScreenState();
}

class _OwnerScreenState extends State<OwnerScreen> {
  final StorageService _storageService = StorageService();
  final TextEditingController _paymentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.green.shade50, Colors.green.shade100],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Owner - Review & Pay',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(text: 'Current Purchase'),
                    Tab(text: 'Transaction History'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildCurrentPurchaseTab(),
                      _buildHistoryTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPurchaseTab() {
    // StreamBuilder keeps UI in sync with Firestore in real time
    return StreamBuilder<StoredData>(
      stream: _storageService.streamData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ??
            StoredData(
                previousBalance: 0.0, currentItems: [], transactions: []);
        final currentItems = data.currentItems;
        final previousBalance = data.previousBalance;
        final currentTotal =
            currentItems.fold(0.0, (sum, item) => sum + item.price);
        final grandTotal = currentTotal + previousBalance;

        if (currentItems.isEmpty) {
          return Center(
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No pending items',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'The assistant hasn\'t added any new items yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    if (previousBalance > 0) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Outstanding Balance: \$${previousBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (previousBalance > 0)
                Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Previous Balance (Unpaid):',
                            style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold)),
                        Text('\$${previousBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.amber,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Items to Review',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ...currentItems.map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.name),
                                Text('\$${item.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Current Items Total:'),
                          Text('\$${currentTotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      if (previousBalance > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Previous Balance:',
                                style: TextStyle(color: Colors.amber)),
                            Text('\$${previousBalance.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.amber)),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount Due:',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          Text('\$${grandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Make Payment',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _paymentController,
                        decoration: InputDecoration(
                          labelText: 'Payment Amount (\$)',
                          hintText: '0.00',
                          border: const OutlineInputBorder(),
                          helperText:
                              'Maximum: \$${grandTotal.toStringAsFixed(2)}',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() {
                                _paymentController.text =
                                    (grandTotal * 0.25).toStringAsFixed(2);
                              }),
                              child: const Text('25%'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() {
                                _paymentController.text =
                                    (grandTotal * 0.5).toStringAsFixed(2);
                              }),
                              child: const Text('50%'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() {
                                _paymentController.text =
                                    grandTotal.toStringAsFixed(2);
                              }),
                              child: const Text('Full'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _processPayment(
                            currentItems: currentItems,
                            currentTotal: currentTotal,
                            previousBalance: previousBalance,
                            grandTotal: grandTotal,
                          ),
                          icon: const Icon(Icons.attach_money),
                          label: const Text('Process Payment'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processPayment({
    required List<Item> currentItems,
    required double currentTotal,
    required double previousBalance,
    required double grandTotal,
  }) async {
    if (_paymentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter payment amount')),
      );
      return;
    }

    final amount = double.tryParse(_paymentController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (amount > grandTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Payment amount cannot exceed total amount')),
      );
      return;
    }

    final newBalance = grandTotal - amount;

    final newTransaction = models.Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now()),
      items: List.from(currentItems),
      totalAmount: currentTotal,
      paidAmount: amount,
      balance: newBalance,
      previousBalance: previousBalance,
    );

    await _storageService.processPayment(
      transaction: newTransaction,
      newBalance: newBalance,
    );

    _paymentController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newBalance > 0
              ? 'Payment recorded! Remaining: \$${newBalance.toStringAsFixed(2)}'
              : 'Payment complete! No balance remaining.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildHistoryTab() {
    return StreamBuilder<List<models.Transaction>>(
      stream: _storageService.streamTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data ?? [];

        if (transactions.isEmpty) {
          return const Center(
            child: Text('No transactions yet',
                style: TextStyle(fontSize: 16, color: Colors.black54)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(transaction.date,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                        Text(
                            'ID: ${transaction.id.substring(transaction.id.length - 6)}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Items:',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...transaction.items.map((item) => Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(fontSize: 14)),
                              Text('\$${item.price.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        )),
                    const Divider(height: 24),
                    if (transaction.previousBalance > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Previous Balance:',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.amber)),
                            Text(
                                '\$${transaction.previousBalance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.amber)),
                          ],
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Items Total:',
                            style: TextStyle(fontSize: 14)),
                        Text('\$${transaction.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Paid:',
                            style:
                                TextStyle(fontSize: 14, color: Colors.green)),
                        Text('-\$${transaction.paidAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.green)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Remaining Balance:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '\$${transaction.balance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: transaction.balance > 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }
}
