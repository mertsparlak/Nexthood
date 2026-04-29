import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notifService = NotificationService();
  List<AppNotification> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final notifs = await _notifService.getNotifications();
    setState(() {
      _notifications = notifs;
      _loading = false;
    });
  }

  Future<void> _markAsRead(String id) async {
    await _notifService.markAsRead(id);
    await _loadNotifications();
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'event_suggestion':
        return LucideIcons.sparkles;
      case 'create_event_prompt':
        return LucideIcons.plusCircle;
      case 'trend_alert':
        return LucideIcons.trendingUp;
      default:
        return LucideIcons.bell;
    }
  }

  Color _colorForCategory(String? category) {
    switch (category) {
      case 'sports':
        return AppColors.sportsAmber;
      case 'music':
        return AppColors.musicPurple;
      case 'technology':
        return AppColors.techBlue;
      case 'community':
        return AppColors.communityGreen;
      case 'workshop':
        return AppColors.workshopPink;
      default:
        return AppColors.electricBlue;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: AppColors.whiteGlass,
              border: Border(
                bottom: BorderSide(color: AppColors.gray200.withValues(alpha: 0.5)),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.gray900),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Bildirimler',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                          ),
                          Text(
                            'AI destekli kişisel öneriler',
                            style: TextStyle(fontSize: 12, color: AppColors.gray600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.sparkles, size: 20, color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notif = _notifications[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildNotificationCard(notif)
                                .animate(delay: (index * 80).ms)
                                .fadeIn(duration: 400.ms)
                                .slideX(begin: -0.1, end: 0),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.bellOff, size: 36, color: AppColors.gray400),
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz bildirim yok',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Etkinlikleri keşfettikçe kişiselleştirilmiş\nöneriler burada görünecek.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.gray500),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildNotificationCard(AppNotification notif) {
    final accentColor = _colorForCategory(notif.relatedCategory);

    return GestureDetector(
      onTap: () {
        if (!notif.isRead) _markAsRead(notif.id);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead
              ? AppColors.white.withValues(alpha: 0.6)
              : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: notif.isRead
                ? AppColors.gray200.withValues(alpha: 0.3)
                : accentColor.withValues(alpha: 0.3),
            width: notif.isRead ? 1 : 1.5,
          ),
          boxShadow: notif.isRead
              ? []
              : [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İkon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _iconForType(notif.notificationType),
                size: 22,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 12),
            // İçerik
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.gray900,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: notif.isRead ? AppColors.gray500 : AppColors.gray700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (notif.relatedDistrict != null) ...[
                        Icon(LucideIcons.mapPin, size: 12, color: AppColors.gray400),
                        const SizedBox(width: 4),
                        Text(
                          notif.relatedDistrict!,
                          style: const TextStyle(fontSize: 11, color: AppColors.gray500),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Icon(LucideIcons.clock, size: 12, color: AppColors.gray400),
                      const SizedBox(width: 4),
                      Text(
                        _timeAgo(notif.createdAt),
                        style: const TextStyle(fontSize: 11, color: AppColors.gray500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
