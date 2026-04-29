import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'services/browsing_log_service.dart';

void main() {
  // Gezinme log servisini başlat (periyodik flush timer)
  BrowsingLogService().init();
  runApp(const MahalleConnectApp());
}

class MahalleConnectApp extends StatelessWidget {
  const MahalleConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mahalle-Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
