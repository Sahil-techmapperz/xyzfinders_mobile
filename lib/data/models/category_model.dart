class CategoryModel {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final String? iconUrl;
  final String? imageUrl;
  final bool isFeatured;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.iconUrl,
    this.imageUrl,
    required this.isFeatured,
    required this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      imageUrl: json['image_url'] as String?,
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon_url': iconUrl,
      'image_url': imageUrl,
      'is_featured': isFeatured,
      'is_active': isActive,
    };
  }
}
