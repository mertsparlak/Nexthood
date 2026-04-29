import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../data/models/event.dart';
import '../services/browsing_log_service.dart';

const _categoryIcons = <String, IconData>{
  'music': LucideIcons.music,
  'technology': LucideIcons.cpu,
  'community': LucideIcons.users,
  'sports': LucideIcons.dumbbell,
  'workshop': LucideIcons.palette,
  'concert': LucideIcons.music,
};

const _categoryColors = <String, Color>{
  'music': AppColors.musicPurple,
  'technology': AppColors.techBlue,
  'community': AppColors.communityGreen,
  'sports': AppColors.sportsAmber,
  'workshop': AppColors.workshopPink,
  'concert': AppColors.musicPurple,
};

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  String? selectedCategory;

  List<Event> get filteredEvents => selectedCategory != null
      ? mockEvents.where((e) => e.category == selectedCategory).toList()
      : mockEvents;

  @override
  Widget build(BuildContext context) {
    final categories = mockEvents.map((e) => e.category).toSet().toList();

    return Column(
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nearby Events',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.navigation, size: 20, color: AppColors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search
                  Container(
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
                              hintText: 'Search location...',
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
                  const SizedBox(height: 12),
                  // Category Filters
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip('All', selectedCategory == null, () {
                          setState(() => selectedCategory = null);
                        }),
                        const SizedBox(width: 8),
                        ...categories.map((cat) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildFilterChip(
                                cat[0].toUpperCase() + cat.substring(1),
                                selectedCategory == cat,
                                () => setState(() => selectedCategory = cat),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Map Area + Event List
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mock Map
                _buildMockMap(),
                // Event List
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Events on Map (${filteredEvents.length})',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
                      ),
                      const SizedBox(height: 12),
                      ...filteredEvents.map((event) => _buildEventListItem(event)),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: isActive ? AppTheme.primaryGradient : null,
          color: isActive ? null : AppColors.gray100,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isActive ? AppColors.white : AppColors.gray700,
          ),
        ),
      ),
    );
  }

  Widget _buildMockMap() {
    const positions = [
      Offset(0.30, 0.20),
      Offset(0.60, 0.40),
      Offset(0.25, 0.60),
      Offset(0.70, 0.30),
      Offset(0.50, 0.70),
      Offset(0.40, 0.50),
    ];

    return Container(
      height: 400,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDBEAFE), Color(0xFFDCFCE7)],
        ),
      ),
      child: Stack(
        children: [
          // Grid
          Opacity(
            opacity: 0.2,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemCount: 64,
              itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(border: Border.all(color: AppColors.gray400, width: 0.5)),
              ),
            ),
          ),
          // Markers
          ...List.generate(filteredEvents.length, (index) {
            final event = filteredEvents[index];
            final pos = positions[index % positions.length];
            final icon = _categoryIcons[event.category] ?? LucideIcons.users;
            final color = _categoryColors[event.category] ?? AppColors.gray500;

            return Positioned(
              left: pos.dx * MediaQuery.of(context).size.width - 24,
              top: pos.dy * 400 - 24,
              child: GestureDetector(
                onTap: () {
                  BrowsingLogService().logMapMarkerClick(
                    eventId: event.id,
                    category: event.category,
                    locationName: event.location,
                  );
                  context.push('/event/${event.id}');
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Icon(icon, size: 24, color: AppColors.white),
                ).animate(delay: (index * 100).ms).scale(begin: const Offset(0, 0), end: const Offset(1, 1)),
              ),
            );
          }),
          // User location
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.electricBlue.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (c) => c.repeat()).scaleXY(
                      begin: 1,
                      end: 3,
                      duration: 1500.ms,
                    ).fadeOut(duration: 1500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventListItem(Event event) {
    final icon = _categoryIcons[event.category] ?? LucideIcons.users;
    final color = _categoryColors[event.category] ?? AppColors.gray500;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          BrowsingLogService().logCardClick(
            eventId: event.id,
            category: event.category,
            locationName: event.location,
            sourceScreen: 'map_view',
          );
          context.push('/event/${event.id}');
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          event.distance,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.neighborhoodGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          event.time,
                          style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
