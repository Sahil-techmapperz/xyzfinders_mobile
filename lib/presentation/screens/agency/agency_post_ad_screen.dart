import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../data/models/agency_models.dart';
import '../../../data/models/category_model.dart';
import '../../../data/services/category_service.dart';
import '../../../core/theme/app_theme.dart';
import 'agency_add_post_images_screen.dart';

class AgencyPostAdScreen extends StatefulWidget {
  final AgencyAd? ad;
  final CategoryModel? selectedCategory;
  
  const AgencyPostAdScreen({super.key, this.ad, this.selectedCategory});

  @override
  State<AgencyPostAdScreen> createState() => _AgencyPostAdScreenState();
}

class _AgencyPostAdScreenState extends State<AgencyPostAdScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  
  int? _selectedCategoryId;
  int? _selectedLocationId;
  String? _selectedCondition;

  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = true;

  final List<Map<String, dynamic>> _locations = [
    {'id': 1, 'name': 'Mumbai, Maharashtra'},
    {'id': 2, 'name': 'Delhi, NCR'},
    {'id': 3, 'name': 'Bangalore, Karnataka'},
    {'id': 4, 'name': 'Hyderabad, Telangana'},
    {'id': 5, 'name': 'Chennai, Tamil Nadu'},
    {'id': 6, 'name': 'Kolkata, West Bengal'},
  ];

  final List<Map<String, String>> _conditions = [
    {'value': 'new', 'label': 'New'},
    {'value': 'like_new', 'label': 'Like New'},
    {'value': 'good', 'label': 'Good'},
    {'value': 'fair', 'label': 'Fair'},
    {'value': 'poor', 'label': 'Poor'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.ad?.title);
    _descriptionController = TextEditingController(); // AgencyAd doesn't have it, but we'll try to fetch if editing
    _priceController = TextEditingController(text: widget.ad?.price);
    _originalPriceController = TextEditingController();
    
    if (widget.selectedCategory != null) {
      _selectedCategoryId = widget.selectedCategory!.id;
    }
    
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await CategoryService().getCategories();
      setState(() {
        _categories = cats;
        _isLoadingCategories = false;
        
        // If we have a selected category from previous screen, ensure it's in the list
        if (_selectedCategoryId != null && !_categories.any((c) => c.id == _selectedCategoryId)) {
          // If not in list, maybe it's not a root category, but for now we'll keep it
        }
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a category")));
      return;
    }
    
    if (_selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a location")));
      return;
    }

    final Map<String, dynamic> postData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': _priceController.text.trim(),
      'original_price': _originalPriceController.text.trim(),
      'category_id': _selectedCategoryId,
      'location_id': _selectedLocationId,
      'condition': _selectedCondition,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgencyAddPostImagesScreen(
          postData: postData,
          editAdId: widget.ad?.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.ad != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: (isEditing ? "Edit Ad" : "Ad Details").text.color(Colors.black).xl2.bold.make(),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: isEditing ? [
          IconButton(
            icon: const Icon(Icons.collections, color: AppTheme.secondaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AgencyAddPostImagesScreen(
                    postData: {}, // When just managing images, data can be empty or handled separately
                    editAdId: widget.ad!.id,
                  ),
                ),
              );
            },
            tooltip: 'Manage Images',
          ),
        ] : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Title
            _buildLabel('Post Title'),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'e.g., Luxury 3BHK Apartment',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 20),

            // Description
            _buildLabel('Description'),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe what you are offering...',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              validator: (v) => v!.isEmpty ? 'Please enter a description' : null,
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
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.category),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                        hint: "Select".text.sm.make(),
                        items: _categories.map((c) => DropdownMenuItem(value: c.id, child: c.name.text.sm.make())).toList(),
                        onChanged: (v) => setState(() => _selectedCategoryId = v),
                        validator: (v) => v == null ? 'Required' : null,
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
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_on),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                        hint: "Select".text.sm.make(),
                        items: _locations.map((l) => DropdownMenuItem(value: l['id'] as int, child: (l['name'] as String).text.sm.make())).toList(),
                        onChanged: (v) => setState(() => _selectedLocationId = v),
                        validator: (v) => v == null ? 'Required' : null,
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
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
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
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.check_circle_outline),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                        hint: "Select".text.sm.make(),
                        items: _conditions.map((c) => DropdownMenuItem(value: c['value'], child: c['label']!.text.sm.make())).toList(),
                        onChanged: (v) => setState(() => _selectedCondition = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Original Price
            _buildLabel('Original Price (Optional)'),
            TextFormField(
              controller: _originalPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixIcon: Icon(Icons.money_off_outlined),
                helperText: 'Show a discount if applicable',
              ),
            ),

            const SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 4,
                  shadowColor: AppTheme.secondaryColor.withOpacity(0.3),
                ),
                child: (isEditing ? "Save And Continue" : "Post And Continue")
                    .text.bold.lg.make(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Info Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'You will be able to upload images in the next step.',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: text.text.bold.gray700.make(),
    );
  }
}
