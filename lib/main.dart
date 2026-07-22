import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/favorite_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/security_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/address_provider.dart';
import 'presentation/providers/job_application_provider.dart';
import 'presentation/providers/language_provider.dart';
import 'presentation/providers/agency_provider.dart';
import 'core/localization/app_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'core/config/api_service.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => JobApplicationProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AgencyProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, _) {
          return MaterialApp(
            title: 'XYZ Finders',
            scaffoldMessengerKey: scaffoldMessengerKey,
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: child,
              );
            },
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            locale: langProvider.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('hi'),
              Locale('ar'),
              Locale('fr'),
              Locale('es'),
            ],
            localizationsDelegates: const [
              AppLocalizationDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    print('[Startup] Starting _checkAuth...');
    final authProvider = context.read<AuthProvider>();
    final agencyProvider = context.read<AgencyProvider>();

    // Run auth checks in parallel — navigate immediately when done
    print('[Startup] Awaiting auth status check...');
    await Future.wait([
      authProvider.checkAuthStatus(),
      agencyProvider.checkAuthStatus(),
    ]);
    print('[Startup] Auth status check complete. User Auth: ${authProvider.isAuthenticated}, Agency Auth: ${agencyProvider.isAuthenticated}');

    // If agency is authenticated, clear any regular user session to avoid conflicts
    if (agencyProvider.isAuthenticated && authProvider.isAuthenticated) {
      print('[Startup] Both regular and agency sessions active. Clearing regular user session.');
      await authProvider.logout();
    }

    if (agencyProvider.isAuthenticated || authProvider.isAuthenticated) {
      final token = await ApiService().getAuthToken();
      print('[Startup] Found stored token: ${token != null ? "YES" : "NO"}');
      if (token != null) {
        final userId = authProvider.isAuthenticated ? authProvider.user?.id?.toString() : null;
        final agencyId = agencyProvider.isAuthenticated ? agencyProvider.agencyUser?.id?.toString() : null;
        print('[Startup] Initializing socket with userId: $userId, agencyId: $agencyId');
        context.read<ChatProvider>().initializeSocket(token, userId: userId, agencyId: agencyId);
        context.read<ChatProvider>().loadConversations();
      }
    } else {
      print('[Startup] User is not authenticated. Skipping socket initialization.');
    }

    if (mounted) {
      print('[Startup] Navigating to HomeScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.60;
    return Scaffold(
      backgroundColor: const Color(0xFFE76713),
      body: Center(
        child: Image.asset(
          'assets/images/app_logo_white.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
