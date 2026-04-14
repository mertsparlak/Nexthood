import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../data/models/event.dart';

class AIPicksScreen extends StatelessWidget {
  const AIPicksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPicks = List<Event>.from(mockEvents)
      ..sort((a, b) => b.aiScore.compareTo(a.aiScore));
    final top3 = topPicks.take(3).toList();
    final trending = mockEvents.where((e) => e.attendees > 50).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                        ),
                        child: const Icon(LucideIcons.sparkles, size: 32, color: AppColors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'AI-Powered Picks',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Events curated specifically for you',
                        style: TextStyle(fontSize: 13, color: AppColors.gray600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Matches Section
                Row(
                  children: const [
                    Icon(LucideIcons.sparkles, size: 20, color: AppColors.electricBlue),
                    SizedBox(width: 8),
                    Text(
                      'Top Matches For You',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...List.generate(top3.length, (index) {
                  final event = top3[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildTopPickCard(context, event, index)
                        .animate(delay: (index * 100).ms)
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: -0.15, end: 0),
                  );
                }),

                const SizedBox(height: 24),

                // Trending Section
                Row(
                  children: const [
                    Icon(LucideIcons.trendingUp, size: 20, color: AppColors.neighborhoodGreen),
                    SizedBox(width: 8),
                    Text(
                      'Trending in Your Area',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: trending.length,
                  itemBuilder: (context, index) {
                    return _buildTrendingCard(context, trending[index])
                        .animate(delay: (300 + index * 100).ms)
                        .fadeIn(duration: 400.ms)
                        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
                  },
                ),

                const SizedBox(height: 24),

                // AI Insights
                Container(
                  padding: const EdgeInsets.all(24),
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Your Activity Insights',
                              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
                            ),
                            SizedBox(height: 8),
                            Text('• Most active on weekends (7:00 PM - 10:00 PM)',
                                style: TextStyle(fontSize: 13, color: AppColors.gray700)),
                            SizedBox(height: 4),
                            Text('• Prefers events within 1 mile',
                                style: TextStyle(fontSize: 13, color: AppColors.gray700)),
                            SizedBox(height: 4),
                            Text('• High engagement with music & tech events',
                                style: TextStyle(fontSize: 13, color: AppColors.gray700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 800.ms).fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPickCard(BuildContext context, Event event, int index) {
    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: event.imageUrl,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${event.aiScore}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.electricBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.calendar, size: 12, color: AppColors.gray600),
                        const SizedBox(width: 4),
                        Text(event.date, style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 12, color: AppColors.neighborhoodGreen),
                        const SizedBox(width: 4),
                        Text(event.distance, style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
                      ],
                    ),
                  ],
                ),
              ),
              // Rank Badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: AppTheme.primaryGradient,
                ),
                child: Center(
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingCard(BuildContext context, Event event) {
    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: event.imageUrl,
              fit: BoxFit.cover,
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                ),
              ),
            ),
            // Title
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            // Attendees badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '🔥 ${event.attendees}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
