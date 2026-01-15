import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import '../../../data/services/image_upload_service.dart';
import '../../../core/utils/toast_utils.dart';

class AddProductImagesScreen extends StatefulWidget {
  final int productId;
  final String productTitle;

  const AddProductImagesScreen({
    super.key,
    required this.productId,
    required this.productTitle,
  });

  @override
  State<AddProductImagesScreen> createState() => _AddProductImagesScreenState();
}

class _AddProductImagesScreenState extends State<AddProductImagesScreen> {
  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _uploadService = ImageUploadService();
  final List<File> _selectedImages = [];
  bool _isUploading = false;
  bool _isDragging = false;

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Error picking images: $e');
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      
      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Error taking photo: $e');
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) {
      ToastUtils.showError(context, 'Please select at least one image');
      return;
    }

    setState(() => _isUploading = true);

    try {
      await _uploadService.uploadMultipleProductImages(
        productId: widget.productId,
        imageFiles: _selectedImages,
      );

      if (mounted) {
        ToastUtils.showSuccess(context, 'Images uploaded successfully!');
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Upload failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data for: ${widget.productTitle}'),
      ),
      body: Column(
        children: [
          // Drag and Drop Area
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropTarget(
              onDragDone: (detail) async {
                // Handle dropped files
                for (final file in detail.files) {
                  try {
                    final imageFile = File(file.path);
                    setState(() {
                      _selectedImages.add(imageFile);
                    });
                  } catch (e) {
                    if (mounted) {
                      ToastUtils.showError(context, 'Error loading file: $e');
                    }
                  }
                }
              },
              onDragEntered: (detail) {
                setState(() {
                  _isDragging = true;
                });
              },
              onDragExited: (detail) {
                setState(() {
                  _isDragging = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isDragging ? Colors.blue : Colors.grey[300]!,
                    width: _isDragging ? 3 : 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _isDragging ? Colors.blue[50] : Colors.grey[50],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isDragging ? Icons.file_upload : Icons.add_photo_alternate,
                      size: 48,
                      color: _isDragging ? Colors.blue : Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isDragging
                          ? 'Drop images here'
                          : 'Drag & drop images here',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _isDragging ? Colors.blue : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'or',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isUploading ? null : _pickImages,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _isUploading ? null : _takePhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Selected images grid with drag and drop
          Expanded(
            child: _selectedImages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No images selected',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap Gallery or Camera to add images',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.drag_indicator, size: 20, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Long press and drag to reorder',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ReorderableGridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _selectedImages.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final item = _selectedImages.removeAt(oldIndex);
                              _selectedImages.insert(newIndex, item);
                            });
                          },
                          itemBuilder: (context, index) {
                            return Stack(
                              key: ValueKey(_selectedImages[index].path),
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImages[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // First image badge
                                if (index == 0)
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Cover',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                // Remove button
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),

          // Upload button
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isUploading || _selectedImages.isEmpty
                  ? null
                  : _uploadImages,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Upload ${_selectedImages.length} Image${_selectedImages.length != 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
