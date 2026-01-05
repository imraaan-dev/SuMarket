import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/create_listing_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/listing_detail_screen.dart';
import 'screens/all_messages_screen.dart';
import 'screens/direct_message_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/my_listings_screen.dart';
import 'screens/splash_screen.dart';

// Providers / Services
import 'providers/auth_provider.dart';
import 'services/firestore_service.dart';
import 'providers/theme_provider.dart';
import 'providers/listing_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init required for Req 1 & 2
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SuMarketApp());
}

class SuMarketApp extends StatelessWidget {
  const SuMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ListingProvider>(
          create: (_) => ListingProvider(),
          update: (_, auth, listingProvider) =>
              listingProvider!..updateAuth(auth.user?.uid),
        ),

        // ✅ Firestore service provider (Req 2)
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SU Market',
            debugShowCheckedModeBanner: false,
            // Simple light/dark theme logic
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E88E5),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E88E5),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              textTheme:
                  GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            ),
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            // ✅ Use named routing (NO home:)
            // This avoids the "home + '/'" assertion entirely.
            initialRoute: SplashScreen.routeName,

            routes: {
              // ✅ Splash and Gate
              SplashScreen.routeName: (_) => const SplashScreen(),
              AuthGate.routeName: (_) => const AuthGate(),

              // Auth screens
              LoginScreen.routeName: (_) => const LoginScreen(),
              SignUpScreen.routeName: (_) => const SignUpScreen(),

              // Main app screens
              MainNavigation.routeName: (_) => const MainNavigation(),
              CreateListingScreen.routeName: (_) => const CreateListingScreen(),
              SettingsScreen.routeName: (_) => const SettingsScreen(),
              AllMessagesScreen.routeName: (_) => const AllMessagesScreen(),
              MyListingsScreen.routeName: (_) => const MyListingsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == ListingDetailScreen.routeName) {
                final args = settings.arguments as ListingDetailArguments;
                return MaterialPageRoute(
                  builder: (_) => ListingDetailScreen(arguments: args),
                );
              }

//               if (settings.name == DirectMessageScreen.routeName) {
//                 // Logic removed as we use direct MaterialPageRoute navigation now
//                 // and DirectMessageArguments class was removed.
//                 return null;
//               }

              return null;
            },
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static const routeName = '/gate';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.user != null) {
      return const MainNavigation();
    }

    // If we are not authenticated, show LoginScreen.
    // We do not block with a global loader here to allow LoginScreen
    // to handle its own loading state (e.g. spinner on button).
    return const LoginScreen();
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  static const routeName = '/main';

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
