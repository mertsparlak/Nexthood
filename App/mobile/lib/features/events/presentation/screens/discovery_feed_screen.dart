import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mahalle_connect/core/theme/app_colors.dart';
import 'package:mahalle_connect/core/theme/app_theme.dart';
import 'package:mahalle_connect/features/events/presentation/providers/event_provider.dart';
import 'package:mahalle_connect/features/events/presentation/widgets/event_card.dart';

class DiscoveryFeedScreen extends ConsumerWidget {
  const DiscoveryFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventListProvider);

    return RefreshIndicator(
      color: AppColors.primaryOrange,
      onRefresh: () => ref.read(eventListProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          // Sticky Header
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(),
          ),
          // Create Event Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: GestureDetector(
                onTap: () => context.push('/create-event'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.orangeGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOrange.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(LucideIcons.plus, size: 20, color: AppColors.white),
                      SizedBox(width: 12),
                      Text(
                        'Create Event',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            ),
          ),

          // Loading state
          if (eventState.isLoading && eventState.events.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryOrange),
              ),
            ),

          // Error state
          if (eventState.error != null && eventState.events.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.wifiOff, size: 48, color: AppColors.gray400),
                    const SizedBox(height: 16),
                    Text(eventState.error!, style: const TextStyle(color: AppColors.gray600)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.read(eventListProvider.notifier).refresh(),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange),
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),

          // Empty state
          if (!eventState.isLoading && eventState.error == null && eventState.events.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.calendar, size: 48, color: AppColors.gray300),
                    const SizedBox(height: 16),
                    const Text('No events yet', style: TextStyle(color: AppColors.gray500, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text('Be the first to create one!', style: TextStyle(color: AppColors.gray400, fontSize: 14)),
                  ],
                ),
              ),
            ),

          // Event Cards
          if (eventState.events.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = eventState.events[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: EventCard(
                        event: event,
                        onTap: () => context.push('/event/${event.id}'),
                      ).animate(delay: (index * 100).ms).fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0),
                    );
                  },
                  childCount: eventState.events.length,
                ),
              ),
            ),
          // Bottom padding for nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get maxExtent => 160;

  @override
  double get minExtent => 160;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) => false;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteGlass,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              ShaderMask(
                shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                child: const Text(
                  'Nexthood',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
              const Text(
                'Discover local events',
                style: TextStyle(fontSize: 13, color: AppColors.gray600),
              ),
              const SizedBox(height: 12),
              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.gray100.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: const [
                          SizedBox(width: 12),
                          Icon(LucideIcons.search, size: 16, color: AppColors.gray400),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search events, locations...',
                                hintStyle: TextStyle(fontSize: 14, color: AppColors.gray400),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(LucideIcons.slidersHorizontal, size: 20, color: AppColors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
