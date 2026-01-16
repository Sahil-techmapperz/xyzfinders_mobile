import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../core/theme/app_theme.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: "Edit Product".text.color(Colors.black).xl2.bold.make(),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.collections, color: AppTheme.primaryColor),
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
          padding: const EdgeInsets.all(24),
          children: [
            // Title
            _buildLabel('Product Title'),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'e.g., iPhone 13 Pro Max',
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
            const SizedBox(height: 20),

            // Description
            _buildLabel('Description'),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Describe your product in detail',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
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
            const SizedBox(height: 20),

            // Category & Location Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Category'),
                      DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.category),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                        isExpanded: true,
                        hint: const Text('Select'),
                        items: _categories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category['id'] as int,
                            child: Text(
                                category['name'] as String,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedCategoryId = value),
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Location'),
                      DropdownButtonFormField<int>(
                        value: _selectedLocationId,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_on),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                        isExpanded: true,
                        hint: const Text('Select'),
                        items: _locations.map((location) {
                          return DropdownMenuItem<int>(
                            value: location['id'] as int,
                            child: Text(
                                location['name'] as String,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedLocationId = value),
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Price & Condition Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       _buildLabel('Price'),
                       TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                             if (value == null || value.isEmpty) return 'Required';
                             if (double.tryParse(value) == null) return 'Invalid';
                             return null;
                          },
                       ),
                     ],
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       _buildLabel('Condition'),
                       DropdownButtonFormField<String>(
                         value: _selectedCondition,
                         decoration: const InputDecoration(
                           prefixIcon: Icon(Icons.check_circle),
                           contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                         ),
                         isExpanded: true,
                         hint: const Text('Select'),
                         items: _conditions.map((condition) {
                           return DropdownMenuItem<String>(
                             value: condition['value'],
                             child: Text(
                                 condition['label']!,
                                 style: const TextStyle(fontSize: 14),
                             ),
                           );
                         }).toList(),
                         onChanged: (value) => setState(() => _selectedCondition = value),
                         validator: (value) => value == null ? 'Required' : null,
                       ),
                     ],
                   ),
                 ),
              ],
            ),
            
            const SizedBox(height: 20),

            // Original Price (Optional)
            _buildLabel('Original Price (Optional)'),
            TextFormField(
              controller: _originalPriceController,
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixIcon: Icon(Icons.money_off),
                helperText: 'Enter if item is on sale',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final originalPrice = double.tryParse(value);
                  final price = double.tryParse(_priceController.text);
                  if (originalPrice == null) return 'Invalid price';
                  if (price != null && originalPrice <= price) {
                    return 'Must be > sale price';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 40),

            // Update Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Sleek black for update
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontSize: 14,
        ),
      ),
    );
  }
}
