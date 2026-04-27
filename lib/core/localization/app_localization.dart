import 'package:flutter/material.dart';

class AppLocalization {
  final Locale locale;
  AppLocalization(this.locale);

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization)!;
  }

  static const _localizedValues = {
    'en': {
      'profile': 'Profile',
      'account_settings': 'Account Setting',
      'notification_settings': 'Notification Setting',
      'security_settings': 'Security Setting',
      'job_applications': 'My Job Applications',
      'wishlist': 'Wishlist',
      'languages': 'Languages',
      'support': 'Support',
      'logout': 'Logout',
      'switch_to_seller': 'Switch to Seller Mode',
      'switch_to_buyer': 'Switch to Buyer Mode',
      'manage_ads': 'Manage your ads and store',
      'manage_orders': 'Manage your orders and activity',
      'edit_profile': 'Edit Profile',
      'full_name': 'Full Name',
      'email': 'Email Address',
      'phone': 'Phone Number',
      'save_changes': 'Save Changes',
      'home': 'Home',
      'chats': 'Chats',
      'menu': 'Menu',
      'verified_buyer': 'Verified Buyer',
      'professional_seller': 'Professional Seller',
      'joined_on': 'Joined on',
    },
    'hi': {
      'profile': 'प्रोफ़ाइल',
      'account_settings': 'खाता सेटिंग',
      'notification_settings': 'नोटिफिकेशन सेटिंग',
      'security_settings': 'सुरक्षा सेटिंग',
      'job_applications': 'मेरे जॉब आवेदन',
      'wishlist': 'विशलिस्ट',
      'languages': 'भाषाएं',
      'support': 'सहायता',
      'logout': 'लॉगआउट',
      'switch_to_seller': 'सेलर मोड पर स्विच करें',
      'switch_to_buyer': 'बायर मोड पर स्विच करें',
      'manage_ads': 'अपने विज्ञापनों और स्टोर को प्रबंधित करें',
      'manage_orders': 'अपने ऑर्डर और गतिविधि को प्रबंधित करें',
      'edit_profile': 'प्रोफ़ाइल संपादित करें',
      'full_name': 'पूरा नाम',
      'email': 'ईमेल पता',
      'phone': 'फ़ोन नंबर',
      'save_changes': 'बदलाव सहेजें',
      'home': 'होम',
      'chats': 'चैट',
      'menu': 'मेन्यू',
      'verified_buyer': 'सत्यापित खरीदार',
      'professional_seller': 'पेशेवर विक्रेता',
      'joined_on': 'शामिल हुए',
    },
    'ar': {
      'profile': 'الملف الشخصي',
      'account_settings': 'إعدادات الحساب',
      'notification_settings': 'إعدادات التنبيهات',
      'security_settings': 'إعدادات الأمان',
      'job_applications': 'طلبات الوظائف الخاصة بي',
      'wishlist': 'قائمة الأمنيات',
      'languages': 'اللغات',
      'support': 'الدعم',
      'logout': 'تسجيل الخروج',
      'switch_to_seller': 'التبديل إلى وضع البائع',
      'switch_to_buyer': 'التبديل إلى وضع المشتري',
      'manage_ads': 'إدارة إعلاناتك ومتجرك',
      'manage_orders': 'إدارة طلباتك ونشاطك',
      'edit_profile': 'تعديل الملف الشخصي',
      'full_name': 'الاسم الكامل',
      'email': 'عنوان البريد الإلكتروني',
      'phone': 'رقم الهاتف',
      'save_changes': 'حفظ التغييرات',
      'home': 'الرئيسية',
      'chats': 'المحادثات',
      'menu': 'القائمة',
      'verified_buyer': 'مشتري موثق',
      'professional_seller': 'بائع محترف',
      'joined_on': 'انضم في',
    },
    'fr': {
      'profile': 'Profil',
      'account_settings': 'Paramètres du compte',
      'notification_settings': 'Paramètres de notification',
      'security_settings': 'Paramètres de sécurité',
      'job_applications': 'Mes candidatures',
      'wishlist': 'Liste de souhaits',
      'languages': 'Langues',
      'support': 'Support',
      'logout': 'Déconnexion',
      'switch_to_seller': 'Passer en mode vendeur',
      'switch_to_buyer': 'Passer en mode acheteur',
      'manage_ads': 'Gérez vos annonces et votre boutique',
      'manage_orders': 'Gérez vos commandes et votre activité',
      'edit_profile': 'Modifier le profil',
      'full_name': 'Nom complet',
      'email': 'Adresse e-mail',
      'phone': 'Numéro de téléphone',
      'save_changes': 'Enregistrer les modifications',
      'home': 'Accueil',
      'chats': 'Chats',
      'menu': 'Menu',
      'verified_buyer': 'Acheteur vérifié',
      'professional_seller': 'Vendeur professionnel',
      'joined_on': 'Inscrit le',
    },
    'es': {
      'profile': 'Perfil',
      'account_settings': 'Configuración de cuenta',
      'notification_settings': 'Configuración de notificaciones',
      'security_settings': 'Configuración de seguridad',
      'job_applications': 'Mis solicitudes de empleo',
      'wishlist': 'Lista de deseos',
      'languages': 'Idiomas',
      'support': 'Soporte',
      'logout': 'Cerrar sesión',
      'switch_to_seller': 'Cambiar a modo vendedor',
      'switch_to_buyer': 'Cambiar a modo comprador',
      'manage_ads': 'Gestiona tus anuncios y tienda',
      'manage_orders': 'Gestiona tus pedidos y actividad',
      'edit_profile': 'Editar perfil',
      'full_name': 'Nombre completo',
      'email': 'Correo electrónico',
      'phone': 'Número de teléfono',
      'save_changes': 'Guardar cambios',
      'home': 'Inicio',
      'chats': 'Chats',
      'menu': 'Menú',
      'verified_buyer': 'Comprador verificado',
      'professional_seller': 'Vendedor profesional',
      'joined_on': 'Se unió el',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi', 'ar', 'fr', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalization> load(Locale locale) {
    return Future.value(AppLocalization(locale));
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}
