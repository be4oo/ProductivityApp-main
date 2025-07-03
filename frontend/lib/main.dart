import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/models.dart';
import 'providers/auth_provider.dart';
import 'providers/persistent_task_provider.dart';
import 'providers/persistent_project_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/focus_mode_widget.dart';
import 'services/api_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  runApp(const BlitzitApp());
}

class BlitzitApp extends StatelessWidget {
  const BlitzitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PersistentTaskProvider()),
        ChangeNotifierProvider(create: (_) => PersistentProjectProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return FutureBuilder(
            future: _initializeProviders(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return MaterialApp(
                  title: 'Blitzit - Modern Productivity Hub',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme(null),
                  darkTheme: AppTheme.darkTheme(null),
                  themeMode: themeProvider.themeMode,
                  home: const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
              
              return MaterialApp.router(
                title: 'Blitzit - Modern Productivity Hub',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme(null),
                darkTheme: AppTheme.darkTheme(null),
                themeMode: themeProvider.themeMode,
                routerConfig: _router,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _initializeProviders(BuildContext context) async {
    final taskProvider = Provider.of<PersistentTaskProvider>(context, listen: false);
    final projectProvider = Provider.of<PersistentProjectProvider>(context, listen: false);
    
    await Future.wait([
      taskProvider.initialize(),
      projectProvider.initialize(),
    ]);
  }
}

// Router configuration
final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/analytics',
      name: 'analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/focus/:taskId',
      name: 'focus',
      builder: (context, state) {
        final taskId = int.tryParse(state.pathParameters['taskId'] ?? '0') ?? 0;
        // Create a dummy task for focus mode
        final task = Task(
          id: taskId,
          title: 'Focus Session',
          description: 'Focus mode session',
          column: 'focus',
          estimatedTime: 25,
          actualTime: 0,
          priority: TaskPriority.high,
          status: TaskStatus.inProgress,
          reminderEnabled: false,
          reminderOffset: 0,
          isUrgent: false,
          isImportant: true,
          projectId: 1,
          ownerId: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(hours: 1)),
        );
        return FocusModeWidget(task: task);
      },
    ),
  ],
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isAuthenticated;
    final isOnAuthPage = state.matchedLocation == '/auth';
    final isOnSplashPage = state.matchedLocation == '/splash';

    // Always allow splash screen
    if (isOnSplashPage) return null;

    // If not logged in and not on auth page, redirect to auth
    if (!isLoggedIn && !isOnAuthPage) {
      return '/auth';
    }

    // If logged in and on auth page, redirect to home
    if (isLoggedIn && isOnAuthPage) {
      return '/home';
    }

    return null;
  },
);