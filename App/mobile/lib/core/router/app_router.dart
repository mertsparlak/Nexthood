import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/main_layout.dart';
import '../../screens/discovery_feed_screen.dart';
import '../../screens/map_view_screen.dart';
import '../../screens/ai_picks_screen.dart';
import '../../screens/interest_profile_screen.dart';
import '../../screens/event_detail_screen.dart';
import '../../screens/create_event_screen.dart';
import '../../screens/not_found_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
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
