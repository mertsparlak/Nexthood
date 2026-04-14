import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../data/models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            SizedBox(
              height: 192,
              width: double.infinity,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: event.imageUrl,
                    width: double.infinity,
                    height: 192,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.gray100,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.gray100,
                      child: const Icon(LucideIcons.image, color: AppColors.gray400),
                    ),
                  ),
                  // AI Score Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.sparkles, size: 12, color: AppColors.electricBlue),
                          const SizedBox(width: 4),
                          Text(
                            '${event.aiScore}% Match',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Category Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.neighborhoodGreen,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        event.category[0].toUpperCase() + event.category.substring(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Event Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Date/Time
                  Row(
                    children: [
                      const Icon(LucideIcons.calendar, size: 16, color: AppColors.electricBlue),
                      const SizedBox(width: 8),
                      Text(
                        '${event.date} • ${event.time}',
                        style: const TextStyle(fontSize: 13, color: AppColors.gray600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 16, color: AppColors.neighborhoodGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${event.location} • ${event.distance}',
                          style: const TextStyle(fontSize: 13, color: AppColors.gray600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Attendees
                  Row(
                    children: [
                      const Icon(LucideIcons.users, size: 16, color: AppColors.gray400),
                      const SizedBox(width: 8),
                      Text(
                        '${event.attendees} attending',
                        style: const TextStyle(fontSize: 13, color: AppColors.gray600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // AI Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.electricBlue.withValues(alpha: 0.05),
                          AppColors.neighborhoodGreen.withValues(alpha: 0.05),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.electricBlue.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      event.aiSummary,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.gray700,
                      ),
                    ),
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
