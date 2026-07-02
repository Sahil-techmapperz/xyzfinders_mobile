import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../presentation/screens/categories/automobiles/automobile_detail_screen.dart';
import '../../presentation/screens/categories/beauty/beauty_detail_screen.dart';
import '../../presentation/screens/categories/education/education_detail_screen.dart';
import '../../presentation/screens/categories/electronics/electronics_detail_screen.dart';
import '../../presentation/screens/categories/fashion/fashion_detail_screen.dart';
import '../../presentation/screens/categories/furniture/furniture_detail_screen.dart';
import '../../presentation/screens/categories/jobs/jobs_detail_screen.dart';
import '../../presentation/screens/categories/local_events/local_events_detail_screen.dart';
import '../../presentation/screens/categories/mobiles/mobiles_detail_screen.dart';
import '../../presentation/screens/categories/pets/pets_accessories_detail_screen.dart'
    as pets;
import '../../presentation/screens/categories/pets_accessories/pets_accessories_detail_screen.dart'
    as pets_acc;
import '../../presentation/screens/categories/real_estate/real_estate_detail_screen.dart';
import '../../presentation/screens/categories/services/services_detail_screen.dart';

/// Centralised routing helper.
///
/// Resolves a [ProductModel] to the correct category detail screen using
/// [ProductModel.categoryName] (preferred) or [ProductModel.category] map.
///
/// Usage:
///   ProductNavigationUtils.navigateTo(context, product);
///   // or
///   final screen = ProductNavigationUtils.detailScreenFor(product);
class ProductNavigationUtils {
  ProductNavigationUtils._();

  /// Returns the correct detail [Widget] for [product] based on its category.
  static Widget detailScreenFor(ProductModel product) {
    final catRaw = _resolveCategoryString(product);

    if (_matches(catRaw, ['real estate', 'property', 'realestate', 'real_estate', 'apartment', 'house', 'villa', 'land'])) {
      return RealEstateDetailScreen(productId: product.id, title: product.title);
    }
    if (_matches(catRaw, ['automobile', 'car', 'vehicle', 'bike', 'truck', 'scooter', 'suv', 'sedan'])) {
      return AutomobileDetailScreen(productId: product.id, title: product.title);
    }
    if (_matches(catRaw, ['electronic', 'gadget', 'electronics', 'gadgets', 'appliance', 'camera', 'laptop', 'computer'])) {
      return ElectronicsDetailScreen(productId: product.id, title: product.title);
    }
    if (_matches(catRaw, ['mobile', 'phone', 'tablet', 'smartphone', 'iphone', 'android'])) {
      return MobilesDetailScreen(productId: product.id, title: product.title);
    }
    if (_matches(catRaw, ['fashion', 'clothing', 'apparel', 'dress', 'wear', 'shirt', 'shoe'])) {
      return FashionDetailScreen(productId: product.id, title: product.title);
    }
    if (_matches(catRaw, ['furniture', 'hardware', 'home decor', 'interior', 'sofa', 'table', 'chair'])) {
      return FurnitureDetailScreen(productId: product.id, title: product.title);
    }
    if (_matches(catRaw, ['beauty', 'wellness', 'cosmetic', 'skincare', 'health', 'salon', 'spa'])) {
      return BeautyDetailScreen(productId: product.id, title: product.title);
    }
    if (_matches(catRaw, ['education', 'course', 'tutor', 'learning', 'school', 'coaching', 'training'])) {
      return EducationDetailScreen(productId: product.id, title: product.title);
    }
    if (_matches(catRaw, ['job', 'career', 'vacancy', 'hiring', 'recruitment', 'employment', 'internship'])) {
      return JobsDetailScreen(productId: product.id, title: product.title);
    }
    if (_matches(catRaw, ['local event', 'event', 'concert', 'festival', 'show', 'exhibition', 'fair'])) {
      return LocalEventsDetailScreen(productId: product.id, title: product.title);
    }
    if (_matches(catRaw, ['service', 'repair', 'cleaning', 'plumbing', 'electrical', 'freelance', 'contractor'])) {
      return ServicesDetailScreen(productId: product.id, title: product.title);
    }
    if (_matches(catRaw, ['pet accessory', 'pet accessories', 'pet supply', 'pet supplies'])) {
      return pets_acc.PetsAccessoriesDetailScreen(productId: product.id, title: product.title);
    }
    if (_matches(catRaw, ['pet', 'animal', 'dog', 'cat', 'bird', 'fish', 'rabbit'])) {
      return pets.PetsAccessoriesDetailScreen(productId: product.id, title: product.title);
    }

    // Default fallback — automobile detail is generic enough
    return AutomobileDetailScreen(productId: product.id, title: product.title);
  }

  /// Pushes the correct detail screen onto the navigator for [product].
  static Future<void> navigateTo(BuildContext context, ProductModel product) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => detailScreenFor(product)),
    );
  }

  /// Navigates when you only have an [productId], [title], and a category name string or category ID.
  /// Use this from screens that don't have a full [ProductModel] (e.g. chat screen).
  static Future<void> navigateByCategory(
    BuildContext context, {
    required int productId,
    String? title,
    String? categoryName,
    int? categoryId,
  }) {
    // Build a minimal synthetic category string
    String catRaw = (categoryName ?? '').toLowerCase().trim();

    // If catRaw is empty, try to resolve via numeric categoryId
    if (catRaw.isEmpty && categoryId != null) {
      catRaw = _categoryIdToName(categoryId);
    }

    final Widget screen;
    if (_matches(catRaw, ['real estate', 'property', 'realestate', 'real_estate', 'apartment', 'house', 'villa', 'land'])) {
      screen = RealEstateDetailScreen(productId: productId, title: title);
    } else if (_matches(catRaw, ['automobile', 'car', 'vehicle', 'bike', 'truck', 'scooter', 'suv', 'sedan'])) {
      screen = AutomobileDetailScreen(productId: productId, title: title);
    } else if (_matches(catRaw, ['electronic', 'gadget', 'electronics', 'gadgets', 'appliance', 'camera', 'laptop', 'computer'])) {
      screen = ElectronicsDetailScreen(productId: productId, title: title);
    } else if (_matches(catRaw, ['mobile', 'phone', 'tablet', 'smartphone', 'iphone', 'android'])) {
      screen = MobilesDetailScreen(productId: productId, title: title);
    } else if (_matches(catRaw, ['fashion', 'clothing', 'apparel', 'dress', 'wear', 'shirt', 'shoe'])) {
      screen = FashionDetailScreen(productId: productId, title: title);
    } else if (_matches(catRaw, ['furniture', 'hardware', 'home decor', 'interior', 'sofa', 'table', 'chair'])) {
      screen = FurnitureDetailScreen(productId: productId, title: title);
    } else if (_matches(catRaw, ['beauty', 'wellness', 'cosmetic', 'skincare', 'health', 'salon', 'spa'])) {
      screen = BeautyDetailScreen(productId: productId, title: title);
    } else if (_matches(catRaw, ['education', 'course', 'tutor', 'learning', 'school', 'coaching', 'training'])) {
      screen = EducationDetailScreen(productId: productId, title: title);
    } else if (_matches(catRaw, ['job', 'career', 'vacancy', 'hiring', 'recruitment', 'employment', 'internship'])) {
      screen = JobsDetailScreen(productId: productId, title: title);
    } else if (_matches(catRaw, ['local event', 'event', 'concert', 'festival', 'show', 'exhibition', 'fair'])) {
      screen = LocalEventsDetailScreen(productId: productId, title: title);
    } else if (_matches(catRaw, ['service', 'repair', 'cleaning', 'plumbing', 'electrical', 'freelance', 'contractor'])) {
      screen = ServicesDetailScreen(productId: productId, title: title);
    } else if (_matches(catRaw, ['pet accessory', 'pet accessories', 'pet supply', 'pet supplies'])) {
      screen = pets_acc.PetsAccessoriesDetailScreen(productId: productId, title: title);
    } else if (_matches(catRaw, ['pet', 'animal', 'dog', 'cat', 'bird', 'fish', 'rabbit'])) {
      screen = pets.PetsAccessoriesDetailScreen(productId: productId, title: title);
    } else {
      screen = AutomobileDetailScreen(productId: productId, title: title);
    }

    return Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ---------------------------------------------------------------------------

  static String _resolveCategoryString(ProductModel product) {
    // 1. Use categoryName from flat API response
    if (product.categoryName != null && product.categoryName!.isNotEmpty) {
      return product.categoryName!.toLowerCase().trim();
    }
    // 2. Fall back to category map (relationship)
    if (product.category != null) {
      final val = product.category!['name'] ?? product.category!['slug'] ?? '';
      return val.toString().toLowerCase().trim();
    }
    return '';
  }

  static bool _matches(String catRaw, List<String> keywords) {
    return keywords.any((kw) => catRaw.contains(kw));
  }

  /// Converts a backend category ID into a category name keyword for routing.
  /// Update these IDs to match your actual backend category IDs.
  static String _categoryIdToName(int id) {
    const Map<int, String> idMap = {
      1: 'real estate',
      2: 'automobile',
      3: 'mobiles',
      4: 'fashion',
      5: 'electronics',
      6: 'furniture',
      7: 'beauty',
      8: 'education',
      9: 'jobs',
      10: 'local events',
      11: 'services',
      12: 'pets',
      13: 'pet accessories',
    };
    return idMap[id] ?? '';
  }
}
