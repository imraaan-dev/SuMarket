import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'screens/splash_screen.dart';

void main() {
  runApp(const SuMarketApp());
}

class SuMarketApp extends StatelessWidget {
  const SuMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SU Market',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignUpScreen.routeName: (_) => const SignUpScreen(),
        MainNavigation.routeName: (_) => const MainNavigation(),
        CreateListingScreen.routeName: (_) => const CreateListingScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        AllMessagesScreen.routeName: (_) => const AllMessagesScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == ListingDetailScreen.routeName) {
          final args = settings.arguments as ListingDetailArguments;
          return MaterialPageRoute(
            builder: (_) => ListingDetailScreen(arguments: args),
          );
        }
        if (settings.name == DirectMessageScreen.routeName) {
          if (settings.arguments is DirectMessageArguments) {
            final args = settings.arguments as DirectMessageArguments;
            return MaterialPageRoute(
              builder: (_) => DirectMessageScreen(arguments: args),
            );
          } else if (settings.arguments is Map) {
            final args = settings.arguments as Map;
            return MaterialPageRoute(
              builder: (_) => DirectMessageScreen(
                name: args['name'] as String?,
                surname: args['surname'] as String?,
              ),
            );
          }
        }
        return null;
      },
    );
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

  final List<Widget> _screens = [
    const HomeScreen(),
    const FavoritesScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
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


