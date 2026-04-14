import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

class _EventType {
  final String id;
  final String label;
  final String icon;
  final List<Color> gradientColors;

  const _EventType({
    required this.id,
    required this.label,
    required this.icon,
    required this.gradientColors,
  });
}

const _eventTypes = [
  _EventType(
    id: 'tournament',
    label: 'Tournament',
    icon: '🏆',
    gradientColors: [Color(0xFFFB923C), Color(0xFFEF4444)],
  ),
  _EventType(
    id: 'charity',
    label: 'Charity',
    icon: '❤️',
    gradientColors: [Color(0xFFF472B6), Color(0xFFF43F5E)],
  ),
  _EventType(
    id: 'adoption',
    label: 'Pet Adoption',
    icon: '🐾',
    gradientColors: [Color(0xFFC084FC), Color(0xFF6366F1)],
  ),
  _EventType(
    id: 'community',
    label: 'Community',
    icon: '👥',
    gradientColors: [Color(0xFF4ADE80), Color(0xFF10B981)],
  ),
  _EventType(
    id: 'workshop',
    label: 'Workshop',
    icon: '🎨',
    gradientColors: [Color(0xFF60A5FA), Color(0xFF06B6D4)],
  ),
  _EventType(
    id: 'other',
    label: 'Other',
    icon: '✨',
    gradientColors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
  ),
];

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  String? selectedType;
  bool isFree = true;

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxAttendeesController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _maxAttendeesController.dispose();
    super.dispose();
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Create Event',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray900)),
                        Text('Share with your neighborhood',
                            style: TextStyle(fontSize: 12, color: AppColors.gray600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: selectedType == null ? _buildTypeSelection() : _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What type of event?',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _eventTypes.length,
          itemBuilder: (context, index) {
            final type = _eventTypes[index];
            return GestureDetector(
              onTap: () => setState(() => selectedType = type.id),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: type.gradientColors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: type.gradientColors.first.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(type.icon, style: const TextStyle(fontSize: 36)),
                    const SizedBox(height: 8),
                    Text(type.label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                            fontSize: 15)),
                  ],
                ),
              ),
            ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms);
          },
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildForm() {
    final selected = _eventTypes.firstWhere((t) => t.id == selectedType);

    return Column(
      children: [
        // Selected Type Badge
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Text(selected.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Event Type',
                        style: TextStyle(fontSize: 12, color: AppColors.gray600)),
                    Text(selected.label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: AppColors.gray900)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => selectedType = null),
                child: const Text('Change',
                    style: TextStyle(
                        color: AppColors.electricBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Upload Image
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Event Photo',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray300, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: const [
                    Icon(LucideIcons.upload, size: 32, color: AppColors.gray400),
                    SizedBox(height: 8),
                    Text('Click to upload image',
                        style: TextStyle(fontSize: 13, color: AppColors.gray600)),
                    SizedBox(height: 4),
                    Text('PNG, JPG up to 10MB',
                        style: TextStyle(fontSize: 11, color: AppColors.gray500)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Form Fields
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              _fieldLabel('Event Title*'),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Neighborhood Basketball Tournament',
                ),
              ),
              const SizedBox(height: 16),

              // Category
              _fieldLabel('Category*'),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gray200),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(LucideIcons.tag, size: 20, color: AppColors.gray400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: const Text('Select category',
                              style: TextStyle(color: AppColors.gray400)),
                          value: _selectedCategory,
                          isExpanded: true,
                          items: ['Sports', 'Charity', 'Community', 'Workshop', 'Music', 'Other']
                              .map((c) => DropdownMenuItem(
                                  value: c.toLowerCase(), child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Date*'),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2027),
                            );
                            if (picked != null) setState(() => _selectedDate = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.gray50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.gray200),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.calendar, size: 20, color: AppColors.gray400),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedDate != null
                                      ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                                      : 'Select',
                                  style: TextStyle(
                                      color: _selectedDate != null
                                          ? AppColors.gray900
                                          : AppColors.gray400),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Time*'),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) setState(() => _selectedTime = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.gray50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.gray200),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.clock, size: 20, color: AppColors.gray400),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTime != null
                                      ? _selectedTime!.format(context)
                                      : 'Select',
                                  style: TextStyle(
                                      color: _selectedTime != null
                                          ? AppColors.gray900
                                          : AppColors.gray400),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Location
              _fieldLabel('Location*'),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'Enter address or place name',
                  prefixIcon: Icon(LucideIcons.mapPin, size: 20, color: AppColors.gray400),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              _fieldLabel('Description*'),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe your event...',
                ),
              ),
              const SizedBox(height: 16),

              // Max Attendees
              _fieldLabel('Max Attendees'),
              TextField(
                controller: _maxAttendeesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Leave empty for unlimited',
                  prefixIcon: Icon(LucideIcons.users, size: 20, color: AppColors.gray400),
                ),
              ),
              const SizedBox(height: 16),

              // Free toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Free Event',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: AppColors.gray900)),
                      Text('Is this event free to attend?',
                          style: TextStyle(fontSize: 12, color: AppColors.gray600)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => setState(() => isFree = !isFree),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: isFree ? AppColors.neighborhoodGreen : AppColors.gray300,
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: isFree ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Submit
        GestureDetector(
          onTap: () {
            // Handle submit
            print('Submitting event...');
            context.go('/');
          },
          child: Container(
            width: double.infinity,
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
              child: Text('Publish Event',
                  style: TextStyle(
                      color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900)),
    );
  }
}
