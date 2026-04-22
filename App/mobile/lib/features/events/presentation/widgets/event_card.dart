import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mahalle_connect/core/theme/app_colors.dart';
import 'package:mahalle_connect/data/models/event.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  String get _formattedDate {
    final df = DateFormat('MMM d, yyyy');
    return df.format(event.startDate.toLocal());
  }

  String get _formattedTime {
    final tf = DateFormat('HH:mm');
    return tf.format(event.startDate.toLocal());
  }

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
                  if (event.imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: event.imageUrl!,
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
                      errorWidget: (_, __, ___) => _placeholderImage(),
                    )
                  else
                    _placeholderImage(),
                  // Free/Paid Badge
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
                          Icon(
                            event.isFree ? LucideIcons.heart : LucideIcons.ticket,
                            size: 12,
                            color: event.isFree ? AppColors.neighborhoodGreen : AppColors.electricBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.isFree ? 'Free' : 'Paid',
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
                        '$_formattedDate • $_formattedTime',
                        style: const TextStyle(fontSize: 13, color: AppColors.gray600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location
                  if (event.locationName != null) ...[
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 16, color: AppColors.neighborhoodGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.locationName!,
                            style: const TextStyle(fontSize: 13, color: AppColors.gray600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Description snippet
                  if (event.description != null)
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
                        event.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: 192,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange.withValues(alpha: 0.15),
            AppColors.electricBlue.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: const Center(
        child: Icon(LucideIcons.calendar, size: 48, color: AppColors.gray400),
      ),
    );
  }
}
