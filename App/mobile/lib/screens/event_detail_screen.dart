import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../services/browsing_log_service.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Etkinlik detayı açıldığında log kaydı oluştur
    final event = mockEvents.firstWhere(
      (e) => e.id == widget.eventId,
      orElse: () => mockEvents.first,
    );
    BrowsingLogService().logDetailView(
      eventId: event.id,
      category: event.category,
      locationName: event.location,
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = mockEvents.firstWhere(
      (e) => e.id == widget.eventId,
      orElse: () => mockEvents.first,
    );

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image
            SizedBox(
              height: 320,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: event.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.gray100),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                      ),
                    ),
                  ),
                  // Back Button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.gray900),
                      ),
                    ),
                  ),
                  // Action Buttons
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 16,
                    child: Row(
                      children: [
                        _circleButton(LucideIcons.share2),
                        const SizedBox(width: 8),
                        _circleButton(LucideIcons.bookmark),
                      ],
                    ),
                  ),
                  // AI Badge
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.sparkles, size: 16, color: AppColors.electricBlue),
                          const SizedBox(width: 8),
                          Text(
                            '${event.aiScore}% Match',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content – overlapping card effect
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Event Header Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tags
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.neighborhoodGreen,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  event.category[0].toUpperCase() + event.category.substring(1),
                                  style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.gray100,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(event.distance,
                                    style:
                                        const TextStyle(fontSize: 13, color: AppColors.gray700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Title
                          Text(event.title,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray900)),
                          const SizedBox(height: 16),
                          // Info rows
                          _infoRow(
                            LucideIcons.calendar,
                            AppColors.electricBlue,
                            'Date & Time',
                            event.date,
                            event.time,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _infoRow(
                                  LucideIcons.mapPin,
                                  AppColors.neighborhoodGreen,
                                  'Location',
                                  event.location,
                                  event.address,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.neighborhoodGreen,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(LucideIcons.navigation, size: 16, color: AppColors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _infoRow(
                            LucideIcons.users,
                            AppColors.purpleAttendees,
                            'Attendees',
                            '${event.attendees} people attending',
                            null,
                            iconBgColor: const Color(0xFFF3E8FF),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 16),

                    // AI Summary
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.electricBlue.withValues(alpha: 0.1),
                            AppColors.neighborhoodGreen.withValues(alpha: 0.1),
                          ],
                        ),
                        border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(LucideIcons.sparkles, size: 20, color: AppColors.electricBlue),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('AI Insights',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600, color: AppColors.gray900)),
                                  SizedBox(height: 2),
                                  Text("Why we think you'll love this",
                                      style: TextStyle(fontSize: 12, color: AppColors.gray600)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            event.aiSummary,
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: AppColors.gray700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 16),

                    // Description
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('About This Event',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, color: AppColors.gray900)),
                          const SizedBox(height: 12),
                          Text(event.description,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.gray700, height: 1.5)),
                        ],
                      ),
                    ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryOrange.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('Register for Event',
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.gray200, width: 2),
                            ),
                            child: const Center(
                              child: Text('Add to Calendar',
                                  style: TextStyle(
                                      color: AppColors.gray900,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                            ),
                          ),
                        ),
                      ],
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: AppColors.gray900),
    );
  }

  Widget _infoRow(
    IconData icon,
    Color iconColor,
    String title,
    String line1,
    String? line2, {
    Color? iconBgColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor ?? iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray900)),
              const SizedBox(height: 2),
              Text(line1, style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
              if (line2 != null) ...[
                const SizedBox(height: 2),
                Text(line2, style: const TextStyle(fontSize: 13, color: AppColors.gray500)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
