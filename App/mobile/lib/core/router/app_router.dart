import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mahalle_connect/core/presentation/main_layout.dart';
import 'package:mahalle_connect/features/events/presentation/screens/discovery_feed_screen.dart';
import 'package:mahalle_connect/features/map/presentation/map_view_screen.dart';
import 'package:mahalle_connect/features/events/presentation/screens/ai_picks_screen.dart';
import 'package:mahalle_connect/features/profile/presentation/interest_profile_screen.dart';
import 'package:mahalle_connect/features/events/presentation/screens/event_detail_screen.dart';
import 'package:mahalle_connect/features/events/presentation/screens/create_event_screen.dart';
import 'package:mahalle_connect/features/auth/presentation/screens/login_screen.dart';
import 'package:mahalle_connect/features/auth/presentation/screens/register_screen.dart';
import 'package:mahalle_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:mahalle_connect/core/router/not_found_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      // Still checking auth state
      if (authState.status == AuthStatus.unknown) return null;

      // Not logged in and not on auth pages -> redirect to login
      if (!isLoggedIn && !isLoggingIn) return '/login';

      // Logged in and on auth pages -> redirect to home
      if (isLoggedIn && isLoggingIn) return '/';

      return null;
    },
    routes: [
      // Auth screens (no bottom nav, no guard)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Screens WITHOUT bottom nav
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/event/:id',
        builder: (context, state) => EventDetailScreen(
          eventId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/create-event',
        builder: (context, state) => const CreateEventScreen(),
      ),
      // Shell with bottom nav
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DiscoveryFeedScreen(),
            ),
          ),
          GoRoute(
            path: '/map',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MapViewScreen(),
            ),
          ),
          GoRoute(
            path: '/ai-picks',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AIPicksScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InterestProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
