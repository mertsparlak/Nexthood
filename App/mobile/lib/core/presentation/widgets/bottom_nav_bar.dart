import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mahalle_connect/core/theme/app_colors.dart';
import 'package:mahalle_connect/core/theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  static const _navItems = [
    _NavItem(icon: LucideIcons.home, label: 'Discover', path: '/'),
    _NavItem(icon: LucideIcons.map, label: 'Map', path: '/map'),
    _NavItem(icon: LucideIcons.sparkles, label: 'AI Picks', path: '/ai-picks'),
    _NavItem(icon: LucideIcons.user, label: 'Profile', path: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteGlass,
        border: Border(
          top: BorderSide(color: AppColors.gray200.withValues(alpha: 0.5)),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Colors.white.withValues(alpha: 0.7),
            BlendMode.srcOver,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _navItems.map((item) {
                  final isActive = currentPath == item.path;
                  return _buildNavItem(context, item, isActive);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, _NavItem item, bool isActive) {
    return GestureDetector(
      onTap: () => context.go(item.path),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isActive ? AppTheme.primaryGradient : null,
            ),
            transform: isActive
                ? (Matrix4.identity()..scale(1.1))
                : Matrix4.identity(),
            transformAlignment: Alignment.center,
            child: Icon(
              item.icon,
              size: 20,
              color: isActive ? AppColors.white : AppColors.gray500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              color: isActive ? AppColors.gray900 : AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
  });
}
