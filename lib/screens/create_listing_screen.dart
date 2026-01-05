import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firestore_service.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  static const routeName = '/create-listing';

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = 'Electronics';
  String _selectedCurrency = 'TRY';
  bool _hasDelivery = false;

  bool _isPosting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double? _parsePrice(String input) {
    // Allows "12,5" or "12.5"
    final cleaned = input.trim().replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  Future<void> _submit() async {
    if (_isPosting) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      // Show AlertDialog when validation fails
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Validation Error'),
            content: const Text(
              'Please fill in all required fields correctly before submitting.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final price = _parsePrice(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid price greater than 0.')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final firestore = context.read<FirestoreService>();

      // ✅ Firestore CREATE
      await firestore.createListing(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        category: _selectedCategory,
        imageUrl: null, // Upload not implemented yet
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Listing posted! (${_selectedCurrency == 'TRY' ? '₺' : r'$'}${price.toStringAsFixed(2)})'
            '${_hasDelivery ? ' • Delivery available' : ''}',
          ),
        ),
      );

      Navigator.of(context).pop(); // Back to Home; stream updates instantly
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post listing: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _saveDraft() async {
    if (_isPosting) return;

    setState(() => _isPosting = true);

    try {
      final firestore = context.read<FirestoreService>();
      final price = _parsePrice(_priceController.text) ?? 0.0;

      await firestore.createListing(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        category: _selectedCategory,
        imageUrl: null,
        isDraft: true,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save draft: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Photo upload not implemented yet.'),
                    ),
                  );
                },
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 32),
                        SizedBox(height: 8),
                        Text('Upload Photos'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ['Electronics', 'Fridges', 'Furniture', 'Books']
                    .map(
                      (category) => ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: _isPosting
                            ? null
                            : (_) =>
                                setState(() => _selectedCategory = category),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  prefixIcon: const Icon(Icons.title_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Please enter a title';
                  return null;
                },
                enabled: !_isPosting,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Please enter a description';
                  return null;
                },
                enabled: !_isPosting,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        prefixIcon: const Icon(Icons.currency_exchange),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Enter a price';
                        final p = _parsePrice(v);
                        if (p == null) return 'Enter a valid number';
                        if (p <= 0) return 'Price must be greater than 0';
                        return null;
                      },
                      enabled: !_isPosting,
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _selectedCurrency,
                    items: const [
                      DropdownMenuItem(value: 'TRY', child: Text('₺')),
                      DropdownMenuItem(value: 'USD', child: Text(r'$')),
                    ],
                    onChanged: _isPosting
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _selectedCurrency = value);
                            }
                          },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _hasDelivery,
                onChanged: _isPosting
                    ? null
                    : (value) => setState(() => _hasDelivery = value),
                title: const Text('Delivery Available'),
                subtitle: const Text('Offer delivery to buyers'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isPosting ? null : _saveDraft,
                      child: const Text('Save as Draft'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isPosting ? null : _submit,
                      child: _isPosting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Post Listing'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
