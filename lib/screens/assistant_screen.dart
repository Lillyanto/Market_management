import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/storage_service.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({Key? key}) : super(key: key);

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final StorageService _storageService = StorageService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Item> _items = [];
  double _previousBalance = 0.0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _storageService.streamData().first.then((data) {
      if (mounted) {
        setState(() {
          _previousBalance = data.previousBalance;
          _items = List.from(data.currentItems);
        });
      }
    });
  }

  void _addItem() {
    if (_formKey.currentState!.validate()) {
      final newItem = Item(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
      );
      setState(() => _items.add(newItem));
      _nameController.clear();
      _priceController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added')),
      );
    }
  }

  void _removeItem(String id) {
    setState(() => _items.removeWhere((item) => item.id == id));
  }

  Future<void> _saveItems() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }
    setState(() => _isSaving = true);
    await _storageService.saveCurrentItems(_items);
    setState(() {
      _isSaving = false;
      _items = [];
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Items saved! Owner can now review and pay.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  double get _totalAmount => _items.fold(0.0, (sum, item) => sum + item.price);
  double get _grandTotal => _totalAmount + _previousBalance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.indigo.shade100],
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
                        'Assistant - Add Items',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_previousBalance > 0)
                        Card(
                          color: Colors.amber.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Previous Balance:',
                                    style: TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold)),
                                Text('\$${_previousBalance.toStringAsFixed(2)}',
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Add New Item',
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Item Name',
                                    hintText: 'e.g., Rice',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                          ? 'Please enter item name'
                                          : null,
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context).nextFocus(),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _priceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Price (\$)',
                                    hintText: '0.00',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Please enter price';
                                    final price = double.tryParse(value);
                                    if (price == null || price <= 0) return 'Please enter a valid price';
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _addItem(),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _addItem,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Item'),
                                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                                  ),
                                ),
                              ],
                            ),
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
                              const Text('Items List',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              if (_items.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Text(
                                      'No items added yet.\nAdd items above to get started.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  children: [
                                    ..._items.map((item) => Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(child: Text(item.name)),
                                              Text('\$${item.price.toStringAsFixed(2)}',
                                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                onPressed: () => _removeItem(item.id),
                                              ),
                                            ],
                                          ),
                                        )),
                                    const Divider(height: 32),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Current Items Total:'),
                                        Text('\$${_totalAmount.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                    if (_previousBalance > 0) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Previous Balance:',
                                              style: TextStyle(color: Colors.amber)),
                                          Text('\$${_previousBalance.toStringAsFixed(2)}',
                                              style: const TextStyle(color: Colors.amber)),
                                        ],
                                      ),
                                      const Divider(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Grand Total:',
                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                          Text('\$${_grandTotal.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue)),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _isSaving ? null : _saveItems,
                                        icon: _isSaving
                                            ? const SizedBox(
                                                height: 18,
                                                width: 18,
                                                child: CircularProgressIndicator(
                                                    strokeWidth: 2, color: Colors.white),
                                              )
                                            : const Icon(Icons.save),
                                        label: const Text('Save & Send to Owner'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(16),
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
