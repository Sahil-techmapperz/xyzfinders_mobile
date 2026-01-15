class AppConstants {
  // App Info
  static const String appName = 'XYZ Finders';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey = 'user_role';
  static const String isLoggedInKey = 'is_logged_in';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Image
  static const int maxImageSizeBytes = 1073741824; // 1GB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const int imageQuality = 85;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Cache
  static const Duration imageCacheDuration = Duration(days: 7);
  
  // User Roles
  static const String roleBuyer = 'buyer';
  static const String roleSeller = 'seller';
  static const String roleAdmin = 'admin';
  
  // Product Conditions
  static const List<String> productConditions = [
    'new',
    'like_new',
    'good',
    'fair',
    'poor'
  ];
  
  static const Map<String, String> productConditionLabels = {
    'new': 'New',
    'like_new': 'Like New',
    'good': 'Good',
    'fair': 'Fair',
    'poor': 'Poor'
  };
  
  // Product Status
  static const String statusActive = 'active';
  static const String statusSold = 'sold';
  static const String statusInactive = 'inactive';
}
