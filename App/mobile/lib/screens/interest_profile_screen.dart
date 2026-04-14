import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../data/models/interest.dart';

const _iconMap = <String, IconData>{
  'Cpu': LucideIcons.cpu,
  'Music': LucideIcons.music,
  'Dumbbell': LucideIcons.dumbbell,
  'Palette': LucideIcons.palette,
  'Coffee': LucideIcons.coffee,
  'Users': LucideIcons.users,
  'Leaf': LucideIcons.leaf,
  'GraduationCap': LucideIcons.graduationCap,
  'Heart': LucideIcons.heart,
  'Briefcase': LucideIcons.briefcase,
  'Gamepad': LucideIcons.gamepad2,
  'Camera': LucideIcons.camera,
};

class InterestProfileScreen extends StatefulWidget {
  const InterestProfileScreen({super.key});

  @override
  State<InterestProfileScreen> createState() => _InterestProfileScreenState();
}

class _InterestProfileScreenState extends State<InterestProfileScreen> {
  late List<Interest> interests;
  double radiusMeters = 100;

  @override
  void initState() {
    super.initState();
    interests = getMockInterests();
  }

  void _toggleInterest(String id) {
    setState(() {
      interests = interests.map((i) {
        if (i.id == id) return i.copyWith(selected: !i.selected);
        return i;
      }).toList();
    });
  }

  int get selectedCount => interests.where((i) => i.selected).length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.gray900),
                    ),
                    GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.settings, size: 20, color: AppColors.gray700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User Profile Card
                _buildProfileCard()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.15, end: 0),
                const SizedBox(height: 16),
                // Discovery Radius
                _buildRadiusCard()
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.15, end: 0),
                const SizedBox(height: 16),
                // Interests
                _buildInterestsCard()
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.15, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: const Center(
                      child: Text('JD',
                          style: TextStyle(
                              color: AppColors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gray200, width: 2),
                      ),
                      child: const Icon(LucideIcons.edit2, size: 12, color: AppColors.gray700),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('John Doe',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.gray900)),
                    const SizedBox(height: 4),
                    const Text('john.doe@email.com',
                        style: TextStyle(fontSize: 13, color: AppColors.gray600)),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(LucideIcons.mapPin, size: 16, color: AppColors.neighborhoodGreen),
                        SizedBox(width: 4),
                        Text('Manhattan, New York',
                            style: TextStyle(fontSize: 13, color: AppColors.gray600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('Edit Profile',
                        style: TextStyle(
                            color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('Share Profile',
                        style: TextStyle(
                            color: AppColors.gray700, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusCard() {
    final circleSize = (radiusMeters / 100 * 120).clamp(60.0, 220.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Discovery Radius',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900)),
                  Text('Events within ${radiusMeters.round()}m from you',
                      style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text('${radiusMeters.round()}m',
                    style: const TextStyle(
                        color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Map Visualization
          Container(
            height: 256,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDBEAFE), Color(0xFFDCFCE7)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Grid
                Opacity(
                  opacity: 0.1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
                    itemCount: 36,
                    itemBuilder: (_, __) => Container(
                      decoration:
                          BoxDecoration(border: Border.all(color: AppColors.gray400, width: 0.5)),
                    ),
                  ),
                ),
                // Radius Circle + User
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: circleSize,
                    height: circleSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer circle
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.electricBlue.withValues(alpha: 0.3),
                              width: 4,
                            ),
                            color: AppColors.electricBlue.withValues(alpha: 0.05),
                          ),
                        ),
                        // Middle ring
                        FractionallySizedBox(
                          widthFactor: 0.6,
                          heightFactor: 0.6,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.neighborhoodGreen.withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        // User avatar
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppTheme.primaryGradient,
                                border: Border.all(color: AppColors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.electricBlue.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('JD',
                                    style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                              ),
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.electricBlue.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                            ).animate(onPlay: (c) => c.repeat()).scaleXY(
                                  begin: 1,
                                  end: 2.5,
                                  duration: 1500.ms,
                                ).fadeOut(duration: 1500.ms),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Radius label
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4),
                        ],
                      ),
                      child: Text('${radiusMeters.round()}m radius',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray700)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('50m', style: TextStyle(fontSize: 12, color: AppColors.gray600)),
              Text('500m', style: TextStyle(fontSize: 12, color: AppColors.gray600)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primaryOrange,
              inactiveTrackColor: AppColors.gray200,
              thumbColor: AppColors.primaryOrange,
              overlayColor: AppColors.primaryOrange.withValues(alpha: 0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: radiusMeters,
              min: 50,
              max: 500,
              divisions: 9,
              onChanged: (v) => setState(() => radiusMeters = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Interests',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900)),
                  Text('$selectedCount selected',
                      style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
                ],
              ),
              const Icon(LucideIcons.sparkles, size: 20, color: AppColors.electricBlue),
            ],
          ),
          const SizedBox(height: 12),
          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.95,
            ),
            itemCount: interests.length,
            itemBuilder: (context, index) {
              final interest = interests[index];
              final icon = _iconMap[interest.icon] ?? LucideIcons.circle;
              return _buildInterestTile(interest, icon);
            },
          ),
          const SizedBox(height: 16),
          // Save Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Save Preferences',
                  style: TextStyle(
                      color: AppColors.gray700, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestTile(Interest interest, IconData icon) {
    return GestureDetector(
      onTap: () => _toggleInterest(interest.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: interest.selected ? AppTheme.primaryGradient : null,
          color: interest.selected ? null : AppColors.white,
          border: interest.selected
              ? null
              : Border.all(color: AppColors.gray200),
        ),
        transform: interest.selected
            ? (Matrix4.identity()..scale(1.05))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: interest.selected
                    ? AppColors.white.withValues(alpha: 0.2)
                    : AppColors.gray100,
              ),
              child: Icon(icon,
                  size: 16,
                  color: interest.selected ? AppColors.white : AppColors.gray700),
            ),
            const SizedBox(height: 6),
            Text(
              interest.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: interest.selected ? AppColors.white : AppColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
