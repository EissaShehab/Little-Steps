import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Add this import
import 'package:image_picker/image_picker.dart';
import 'package:littlesteps/features/auth/providers/auth_provider.dart' as auth_provider;
import 'package:littlesteps/providers/providers.dart';
import 'package:littlesteps/routes/app_routes.dart'; // Add this import
import 'package:littlesteps/features/child_profile/data/child_profile_service.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/features/child_profile/providers/child_provider.dart';
import 'package:littlesteps/providers/providers.dart' as child_provider;
import 'package:logger/logger.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/date_picker_field.dart';
import 'package:uuid/uuid.dart';

final logger = Logger();

// Data class for serializable child profile data (for isolate validation)
class ChildProfileData {
  final String name;
  final String nationalID;
  final DateTime? birthDate;
  final String gender;
  final String relationship;
  final String? imagePath;

  ChildProfileData({
    required this.name,
    required this.nationalID,
    this.birthDate,
    required this.gender,
    required this.relationship,
    this.imagePath,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'nationalID': nationalID,
        'birthDate': birthDate?.toIso8601String(),
        'gender': gender,
        'relationship': relationship,
        'imagePath': imagePath,
      };

  static ChildProfileData fromChildEntry(ChildEntry entry) => ChildProfileData(
        name: entry.nameController.text.trim(),
        nationalID: entry.nationalIDController.text.trim(),
        birthDate: entry.birthDate,
        gender: entry.gender,
        relationship: entry.relationship,
        imagePath: entry.profileImage?.path,
      );
}

// Isolate function to validate profiles
Future<List<Map<String, dynamic>>> validateProfilesInIsolate(
    List<Map<String, dynamic>> profiles) async {
  final results = <Map<String, dynamic>>[];
  for (var profile in profiles) {
    final name = profile['name'] as String;
    final nationalID = profile['nationalID'] as String;
    final birthDateStr = profile['birthDate'] as String?;
    final gender = profile['gender'] as String;
    final relationship = profile['relationship'] as String;
    final imagePath = profile['imagePath'] as String?;

    if (name.isEmpty || nationalID.isEmpty) {
      results.add({'success': false, 'error': 'Name and National ID are required'});
      continue;
    }
    if (birthDateStr == null) {
      results.add({'success': false, 'error': 'Date of birth is required'});
      continue;
    }

    results.add({
      'success': true,
      'data': {
        'name': name,
        'nationalID': nationalID,
        'birthDate': DateTime.parse(birthDateStr),
        'gender': gender,
        'relationship': relationship,
        'imagePath': imagePath,
      },
    });
  }
  return results;
}

class ChildProfileScreen extends ConsumerStatefulWidget {
  const ChildProfileScreen({super.key});

  @override
  ConsumerState<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends ConsumerState<ChildProfileScreen>
    with SingleTickerProviderStateMixin {
  final List<ChildEntry> _children = [];
  final _picker = ImagePicker();
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _addChild();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuthentication());
  }

  @override
  void dispose() {
    for (var entry in _children) {
      entry.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _addChild() {
    setState(() {
      _children.add(ChildEntry());
      _animationController.forward(from: 0);
    });
  }

  void _removeChild(int index) {
    setState(() {
      _children[index].dispose();
      _children.removeAt(index);
      _animationController.reverse();
    });
  }

  Future<void> _checkAuthentication() async {
    final user = ref.read(auth_provider.authNotifierProvider).user;
    if (user == null) {
      logger.w("User not authenticated, redirecting to login.");
      if (mounted) {
        _showError(context, "Please log in to save profiles.");
        context.go(AppRoutes.login); // Use GoRouter to redirect
      }
    } else {
      logger.d("User authenticated: ${user.uid}");
    }
  }

  Future<void> _saveAllProfiles() async {
    if (_isLoading || _children.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(auth_provider.authNotifierProvider).user;
      if (user == null) {
        throw Exception('Authentication required');
      }

      // Step 1: Validate forms in the main isolate
      for (var entry in _children) {
        if (!entry.formKey.currentState!.validate()) {
          throw Exception('Please fill all required fields');
        }
      }

      // Step 2: Prepare serializable data for validation
      final profileDataList = _children.map((entry) => ChildProfileData.fromChildEntry(entry).toMap()).toList();

      // Step 3: Validate in isolate
      final validationResults = await compute(validateProfilesInIsolate, profileDataList);

      // Step 4: Process results and save in main isolate
      final service = ref.read(childProfileServiceProvider);
      for (int i = 0; i < validationResults.length; i++) {
        final result = validationResults[i];
        if (!result['success']) {
          throw Exception(result['error']);
        }

        final data = result['data'] as Map<String, dynamic>;
        final childId = const Uuid().v4();
        final profile = ChildProfile(
          id: childId,
          name: data['name'] as String,
          nationalID: data['nationalID'] as String,
          birthDate: data['birthDate'] as DateTime,
          gender: data['gender'] as String,
          relationship: data['relationship'] as String,
          photoUrl: '',
          updatedAt: DateTime.now(),
        );

        await service.saveChildProfile(
          userId: user.uid,
          profile: profile,
          imageFile: _children[i].profileImage,
          childId: childId,
        );
        logger.i("✅ Child profile saved for child $childId of user ${user.uid}");
      }

      // Invalidate provider to refresh child profiles
      ref.invalidate(childProfilesProvider);
      if (mounted) {
        logger.i("✅ All child profiles saved successfully for user ${user.uid}");
        context.go(AppRoutes.home); // Use GoRouter to navigate to home
      }
    } catch (e) {
      logger.e("❌ Error saving child profiles: $e");
      if (mounted) {
        _showError(context, 'Failed to save profiles: ${e.toString()}');
        if (e.toString().contains('Authentication required')) {
          context.go(AppRoutes.login); // Use GoRouter to redirect
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Theme.of(context).colorScheme.onError,
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Child Profiles',
        trailingIcon: Icons.add_circle,
        onTrailingPressed: _addChild,
        onBackPressed: () => context.pop(), // Use GoRouter to go back
      ),
      body: GradientBackground(
        colors: [
          Theme.of(context).colorScheme.primaryContainer,
          Theme.of(context).colorScheme.secondaryContainer,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: AnimatedList(
                  key: ValueKey(_children.length),
                  initialItemCount: _children.length,
                  itemBuilder: (context, index, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      child: _ChildCard(
                        context: context,
                        entry: _children[index],
                        index: index,
                        onRemove: _children.length > 1 ? () => _removeChild(index) : null,
                      ),
                    );
                  },
                ),
              ),
              _SaveButton(
                context: context,
                isLoading: _isLoading,
                onPressed: _saveAllProfiles,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final BuildContext context;
  final ChildEntry entry;
  final int index;
  final VoidCallback? onRemove;

  const _ChildCard({
    required this.context,
    required this.entry,
    required this.index,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: entry.formKey,
          child: Column(
            children: [
              _CardHeader(
                context: this.context,
                index: index + 1,
                onRemove: onRemove,
              ),
              const SizedBox(height: 16),
              _ImagePickerSection(
                context: this.context,
                entry: entry,
              ),
              const SizedBox(height: 24),
              _PersonalInfoSection(
                context: this.context,
                entry: entry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final BuildContext context;
  final int index;
  final VoidCallback? onRemove;

  const _CardHeader({
    required this.context,
    required this.index,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Child $index',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        if (onRemove != null)
          IconButton(
            icon: Icon(
              Icons.delete_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              showDialog(
                context: this.context,
                builder: (context) => AlertDialog(
                  title: const Text('Remove Child'),
                  content: const Text('Are you sure you want to remove this child?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(this.context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(this.context);
                        onRemove!();
                      },
                      child: Text(
                        'Remove',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _ImagePickerSection extends ConsumerStatefulWidget {
  final BuildContext context;
  final ChildEntry entry;

  const _ImagePickerSection({
    required this.context,
    required this.entry,
  });

  @override
  ConsumerState<_ImagePickerSection> createState() => _ImagePickerSectionState();
}

class _ImagePickerSectionState extends ConsumerState<_ImagePickerSection> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => widget.entry.profileImage = File(image.path));
      }
    } catch (e) {
      logger.e("❌ Image pick error: $e");
      _showError(widget.context, 'Image selection failed');
    }
  }

  void _showError(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(widget.context).cardColor,
              border: Border.all(
                color: Theme.of(widget.context).colorScheme.primary,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(widget.context).colorScheme.onSurface.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: widget.entry.profileImage != null
                  ? Image.file(widget.entry.profileImage!, fit: BoxFit.cover)
                  : Icon(
                      Icons.child_care,
                      size: 60,
                      color: Theme.of(widget.context).colorScheme.primary,
                    ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(widget.context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Add Photo',
                style: TextStyle(
                  color: Theme.of(widget.context).colorScheme.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoSection extends StatelessWidget {
  final BuildContext context;
  final ChildEntry entry;

  const _PersonalInfoSection({
    required this.context,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          context: this.context,
          controller: entry.nameController,
          label: 'Full Name',
          icon: Icons.person_rounded,
          placeholder: "Enter child's name",
        ),
        const SizedBox(height: 16),
        _buildTextField(
          context: this.context,
          controller: entry.nationalIDController,
          label: 'National ID',
          icon: Icons.badge_rounded,
          placeholder: "Enter child's national ID",
        ),
        const SizedBox(height: 16),
        DatePickerField(
          context: this.context,
          selectedDate: entry.birthDate,
          onDateSelected: (date) => entry.birthDate = date,
          labelText: 'Date of Birth',
          placeholder: "Select child's birth date",
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          context: this.context,
          label: 'Gender',
          value: entry.gender,
          items: ['Male', 'Female', 'Other'],
          onChanged: (value) => entry.gender = value!,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          context: this.context,
          label: 'Relationship',
          value: entry.relationship,
          items: ['Parent', 'Guardian'],
          onChanged: (value) => entry.relationship = value!,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          validator: (value) => _requiredValidator(value, label),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (newValue) => onChanged(newValue ?? value),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).colorScheme.primary,
          ),
          dropdownColor: Theme.of(context).cardColor,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value, String field) {
    return value?.isEmpty ?? true ? '$field is required' : null;
  }
}

class _SaveButton extends StatelessWidget {
  final BuildContext context;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.context,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Save All Profiles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }
}

class ChildEntry {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nationalIDController = TextEditingController();
  DateTime? birthDate;
  String gender = 'Male';
  String relationship = 'Parent';
  File? profileImage;

  void dispose() {
    nameController.dispose();
    nationalIDController.dispose();
  }
}