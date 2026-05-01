import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:dio/dio.dart' as dio;
import 'package:provider/provider.dart';
import '../../providers/agency_provider.dart';
import '../../../core/theme/app_theme.dart';

class AgencyAddPostImagesScreen extends StatefulWidget {
  final Map<String, dynamic> postData;
  final int? editAdId;

  const AgencyAddPostImagesScreen({
    super.key,
    required this.postData,
    this.editAdId,
  });

  @override
  State<AgencyAddPostImagesScreen> createState() => _AgencyAddPostImagesScreenState();
}

class _AgencyAddPostImagesScreenState extends State<AgencyAddPostImagesScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  bool _isPublishing = false;

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _handlePublish() async {
    if (_selectedImages.isEmpty && widget.editAdId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one image')));
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final provider = context.read<AgencyProvider>();
      final Map<String, dynamic> finalData = Map.from(widget.postData);
      
      final List<dio.MultipartFile> multipartImages = [];
      for (var image in _selectedImages) {
        multipartImages.add(await dio.MultipartFile.fromFile(image.path));
      }
      
      if (multipartImages.isNotEmpty) {
        finalData['images'] = multipartImages;
      }

      final success = widget.editAdId != null 
        ? await provider.updateAd(widget.editAdId!, finalData)
        : await provider.postAd(finalData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.editAdId != null ? "Ad updated successfully!" : "Ad posted successfully!"), backgroundColor: Colors.green),
        );
        // Pop back to My Ads screen
        Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/agency_my_ads');
        // Actually since we push several screens, better to pop to dashboard and then let user navigate or just pop twice
        Navigator.of(context).pop(); // Pop images screen
        Navigator.of(context).pop(); // Pop post ad screen
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: (provider.error ?? "Failed to save ad").text.make(), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Publish failed: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: "Add Photos".text.color(Colors.black).xl2.bold.make(),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Info Box
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.secondaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: "The first image will be your ad's cover photo. You can drag and drop to reorder."
                      .text.color(AppTheme.secondaryColor).medium.sm.make(),
                ),
              ],
            ),
          ),

          // Upload Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200, width: 2),
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFF8FAFC),
              ),
              child: Column(
                children: [
                  const Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  "Add high quality images to get more leads".text.gray600.make(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isPublishing ? null : _pickImages,
                        icon: const Icon(Icons.photo_library),
                        label: "Gallery".text.make(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _isPublishing ? null : _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: "Camera".text.make(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Selected Images Grid
          Expanded(
            child: _selectedImages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined, size: 64, color: Colors.grey.shade200),
                        const SizedBox(height: 16),
                        "No images selected".text.gray400.make(),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Row(
                          children: [
                            "Selected Images".text.bold.lg.make(),
                            const Spacer(),
                            "${_selectedImages.length} images".text.gray500.make(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ReorderableGridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _selectedImages.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
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
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(_selectedImages[index], fit: BoxFit.cover),
                                ),
                                if (index == 0)
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.secondaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: "Cover".text.white.xs.bold.make(),
                                    ),
                                  ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                      child: const Icon(Icons.close, color: Colors.white, size: 14),
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

          // Bottom Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isPublishing ? null : _handlePublish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isPublishing
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : "Publish Ad Now".text.bold.lg.make(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
