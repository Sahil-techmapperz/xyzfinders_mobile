class ApiConstants {
  // Base URL - Update this when deploying
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  static const String baseUrl = 'http://192.168.1.7:3000/api'; // Android emulator
  // For iOS simulator use: http://localhost:3000/api
  // For physical device use your computer's IP: http://192.168.x.x:3000/api
  
  // API Endpoints
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh-token';
  
  // Products
  static const String products = '/products';
  static String productById(int id) => '/products/$id';
  static String markProductSold(int id) => '/products/$id/mark-sold';
  static String productAnalytics(int id) => '/products/$id/analytics';
  
  // Categories
  static const String categories = '/categories';
  static String categoryById(int id) => '/categories/$id';
  
  // Locations
  static const String states = '/locations/states';
  static const String cities = '/locations/cities';
  static const String locations = '/locations';
  
  // Users
  static const String userProfile = '/users/profile';
  static const String myProducts = '/users/my-products';
  static String userById(int id) => '/users/$id';
  static String userReviews(int id) => '/users/$id/reviews';
  
  // Favorites
  static const String favorites = '/favorites';
  static String favoriteById(int id) => '/favorites/$id';
  
  // Messages
  static const String messages = '/messages';
  static const String conversations = '/messages/conversations';
  static String messageById(int id) => '/messages/$id';
  static String messagesBetween(int productId, int userId) => 
      '/messages/$productId/$userId';
  
  // Reviews
  static const String reviews = '/reviews';
  
  // Reports
  static const String reports = '/reports';
  
  // Subscriptions
  static const String subscriptionPlans = '/subscriptions/plans';
  static const String currentSubscription = '/subscriptions/current';
  static const String subscribe = '/subscriptions/subscribe';
  static const String cancelSubscription = '/subscriptions/cancel';
  static const String subscriptionHistory = '/subscriptions/history';
  
  // Boosts
  static const String purchaseBoost = '/boosts/purchase';
  static const String boostHistory = '/boosts/history';
  
  // Support
  static const String supportCategories = '/support/categories';
  static const String supportTickets = '/support/tickets';
  static const String contactSupport = '/support/contact';
  static const String supportStats = '/support/stats';
  
  // Notifications
  static const String notificationSettings = '/notifications/settings';
  
  // Image Upload
  static const String uploadProfileImage = '/upload/profile-image';
  static const String uploadProductImages = '/upload/product-images';
  
  // Image Retrieval
  static String userImage(int id) => '/images/user/$id';
  static String productImage(int id) => '/images/product/$id';
  static String categoryImage(int id, {required String type}) => 
      '/images/category/$id?type=$type';
      
  // Admin
  static const String adminStats = '/admin/stats';
  static const String adminProducts = '/admin/products';
  static const String adminUsers = '/admin/users';
  static const String adminReports = '/admin/reports';
}
