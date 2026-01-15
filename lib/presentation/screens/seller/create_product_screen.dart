import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../core/utils/toast_utils.dart';
import 'add_product_images_screen.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();

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
    _loadData();
  }

  Future<void> _loadData() async {
    // In a real app, these would come from an API
    // Using mock data for now that matches the backend seeds
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
      final product = await _productService.createProduct(
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
        ToastUtils.showSuccess(context, 'Product created successfully!');
        
        // Ask if user wants to add images
        final addImages = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Add Images?'),
            content: const Text('Would you like to add images to your product now?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Add Images'),
              ),
            ],
          ),
        );

        if (addImages == true && mounted) {
          // Navigate to image upload screen
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddProductImagesScreen(
                productId: product.id,
                productTitle: product.title,
              ),
            ),
          );
        }
        
        if (mounted) {
          Navigator.pop(context, true); // Return to My Products
        }
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
        title: const Text('Add New Product'),
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
                hintText: 'e.g., iPhone 13 Pro Max',
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
                hintText: 'Describe your product in detail',
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
                setState(() => _selectedCategoryId = value);
              },
              validator: (value) {
                if (value == null) return 'Please select a category';
                return null;
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
                setState(() => _selectedLocationId = value);
              },
              validator: (value) {
                if (value == null) return 'Please select a location';
                return null;
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
                hintText: '0.00',
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

            // Original Price (optional)
            TextFormField(
              controller: _originalPriceController,
              decoration: const InputDecoration(
                labelText: 'Original Price (optional)',
                hintText: '0.00',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money_off),
                prefixText: '\$',
                helperText: 'If product is on sale',
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

            // Submit Button
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
                      'Create Product',
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            const SizedBox(height: 16),

            // Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can add images after creating the product',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
