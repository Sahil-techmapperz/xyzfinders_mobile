import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, we only implement the empty state since we don't have wishlist data logic
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 100), // padding for bottom nav
          itemCount: _getMockWishlistItems().length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75, // Adjust for image + text height
          ),
          itemBuilder: (context, index) {
            final item = _getMockWishlistItems()[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with heart icon overlay
                  Expanded(
                    flex: 6,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            image: DecorationImage(
                              image: NetworkImage(item['image'] as String),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Heart Icon
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.favorite, color: Colors.red, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Details
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "₹ ${item['price']}/-",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              item['title'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item['location'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
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
            );
          },
        ),
      ),
    );
  }

  // Mock Data Generator
  List<Map<String, dynamic>> _getMockWishlistItems() {
    return [
      {
        'title': 'BMW M5 Competition',
        'price': '2,29,000',
        'location': 'Sector 62 Dwarka, New Delhi',
        'image': 'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=300&q=60'
      },
      {
        'title': 'Intel i9 14gen -High-end Processor',
        'price': '45,000',
        'location': 'Greater Kailash, New Delhi',
        'image': 'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?auto=format&fit=crop&w=300&q=60'
      },
      {
        'title': '3 BHK Luxury Apartment',
        'price': '45,000',
        'location': 'Greater Kailash, New Delhi',
        'image': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=300&q=60'
      },
      {
        'title': 'iPhone 16 Pro Max 12GB 256GB',
        'price': '56,000',
        'location': 'Sector 62 Duarka, New Delhi',
        'image': 'https://images.unsplash.com/photo-1616348436168-de43ad0db179?auto=format&fit=crop&w=300&q=60'
      },
    ];
  }
}
