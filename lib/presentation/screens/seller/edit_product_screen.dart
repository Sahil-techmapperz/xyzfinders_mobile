import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../core/utils/toast_utils.dart';
import 'add_product_images_screen.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;

  final ProductService _productService = ProductService();
  bool _isLoading = false;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _locations = [];
  final List<Map<String, String>> _conditions = [
    {'value': 'new', 'label': 'New'},
    {'value': 'like_new', 'label': 'Like New'},
    {'value': 'good', 'label': 'Good'},
    {'value': 'fair', 'label': 'Fair'},
    {'value': 'poor', 'label': 'Poor'},
  ];

  int? _selectedCategoryId;
  int? _selectedLocationId;
  String? _selectedCondition;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _originalPriceController = TextEditingController(
      text: widget.product.originalPrice?.toString() ?? '',
    );
    
    _selectedCategoryId = widget.product.categoryId;
    _selectedLocationId = widget.product.locationId;
    _selectedCondition = widget.product.condition;

    _loadData();
  }

  Future<void> _loadData() async {
    // In a real app, these would come from an API
    setState(() {
      _categories = [
        {'id': 1, 'name': 'Electronics'},
        {'id': 2, 'name': 'Computers'},
        {'id': 3, 'name': 'Furniture'},
        {'id': 4, 'name': 'Sports'},
        {'id': 5, 'name': 'Fashion'},
      ];
      _locations = [
        {'id': 1, 'name': 'New York'},
        {'id': 2, 'name': 'Los Angeles'},
        {'id': 3, 'name': 'Chicago'},
        {'id': 4, 'name': 'Houston'},
        {'id': 5, 'name': 'Phoenix'},
      ];
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ToastUtils.showError(context, 'Please select a category');
      return;
    }

    if (_selectedLocationId == null) {
      ToastUtils.showError(context, 'Please select a location');
      return;
    }

    if (_selectedCondition == null) {
      ToastUtils.showError(context, 'Please select a condition');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _productService.updateProduct(
        id: widget.product.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        originalPrice: _originalPriceController.text.isNotEmpty
            ? double.parse(_originalPriceController.text)
            : null,
        categoryId: _selectedCategoryId!,
        locationId: _selectedLocationId!,
        condition: _selectedCondition!,
      );

      if (mounted) {
        ToastUtils.showSuccess(context, 'Product updated successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddProductImagesScreen(
                    productId: widget.product.id,
                    productTitle: widget.product.title,
                  ),
                ),
              );
            },
            tooltip: 'Manage Images',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Product Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a product title';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category['id'] as int,
                  child: Text(category['name'] as String),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategoryId = value);
                }
              },
            ),

            const SizedBox(height: 16),

            // Location
            DropdownButtonFormField<int>(
              value: _selectedLocationId,
              decoration: const InputDecoration(
                labelText: 'Location *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              items: _locations.map((location) {
                return DropdownMenuItem<int>(
                  value: location['id'] as int,
                  child: Text(location['name'] as String),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLocationId = value);
                }
              },
            ),

            const SizedBox(height: 16),

            // Condition
            DropdownButtonFormField<String>(
              value: _selectedCondition,
              decoration: const InputDecoration(
                labelText: 'Condition *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.check_circle),
              ),
              items: _conditions.map((condition) {
                return DropdownMenuItem<String>(
                  value: condition['value'],
                  child: Text(condition['label']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCondition = value);
                }
              },
            ),

            const SizedBox(height: 16),

            // Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                prefixText: '\$',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Original Price
            TextFormField(
              controller: _originalPriceController,
              decoration: const InputDecoration(
                labelText: 'Original Price (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money_off),
                prefixText: '\$',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final originalPrice = double.tryParse(value);
                  if (originalPrice == null || originalPrice <= 0) {
                    return 'Please enter a valid price';
                  }
                  final price = double.tryParse(_priceController.text);
                  if (price != null && originalPrice <= price) {
                    return 'Original price must be greater than sale price';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Update Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Update Product',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
