import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:littlesteps/routes/app_routes.dart';
import 'package:littlesteps/features/child_profile/data/child_profile_service.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/features/vaccinations/data/vaccination_service.dart';
import 'package:littlesteps/providers/providers.dart' as child_provider;
import 'package:logger/logger.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/date_picker_field.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';

final logger = Logger();

final childrenProvider = StateProvider<List<ChildEntry>>((ref) => []);

class ChildProfileData {
  final String name;
  final String identifier;
  final String identifierType;
  final DateTime? birthDate;
  final String gender;
  final String relationship;
  final String? imagePath;

  ChildProfileData({
    required this.name,
    required this.identifier,
    required this.identifierType,
    this.birthDate,
    required this.gender,
    required this.relationship,
    this.imagePath,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'identifier': identifier,
        'identifierType': identifierType,
        'birthDate': birthDate?.toIso8601String(),
        'gender': gender,
        'relationship': relationship,
        'imagePath': imagePath,
      };

  static ChildProfileData fromChildEntry(ChildEntry entry) => ChildProfileData(
        name: entry.nameController.text.trim(),
        identifier: entry.nationalIDController.text.trim(),
        identifierType: entry.identifierType,
        birthDate: entry.birthDate,
        gender: entry.gender,
        relationship: entry.relationship,
        imagePath: entry.profileImage?.path,
      );
}

Future<List<Map<String, dynamic>>> validateProfilesInIsolate(
    List<Map<String, dynamic>> profiles) async {
  final results = <Map<String, dynamic>>[];
  for (var profile in profiles) {
    final name = profile['name'] as String;
    final identifier = profile['identifier'] as String;
    final identifierType = profile['identifierType'] as String;
    final birthDateStr = profile['birthDate'] as String?;
    final gender = profile['gender'] as String;
    final relationship = profile['relationship'] as String;
    final imagePath = profile['imagePath'] as String?;

    if (name.isEmpty) {
      results.add({'success': false, 'error': 'Name is required'});
      continue;
    }
    if (name.trim().length < 4) {
      results.add(
          {'success': false, 'error': 'Name must be at least 4 characters long'});
      continue;
    }
    if (name.trim().length > 30) {
      results.add(
          {'success': false, 'error': 'Name cannot exceed 30 characters'});
      continue;
    }
    if (!RegExp(r'^[ء-يa-zA-Z\s-]+$').hasMatch(name)) {
      results.add({
        'success': false,
        'error': 'Name can only contain Arabic or English letters, spaces, or hyphens'
      });
      continue;
    }

    if (identifier.isEmpty) {
      results.add({'success': false, 'error': 'Identifier is required'});
      continue;
    }
    if (identifier.length != 10 || !RegExp(r'^\d{10}$').hasMatch(identifier)) {
      results.add(
          {'success': false, 'error': 'Identifier must be exactly 10 digits'});
      continue;
    }
    if (!['national_id', 'residence_id'].contains(identifierType)) {
      results.add(
          {'success': false, 'error': 'Invalid identifier type'});
      continue;
    }

    if (birthDateStr == null) {
      results.add({'success': false, 'error': 'Date of birth is required'});
      continue;
    }

    results.add({
      'success': true,
      'data': {
        'name': name.trim(),
        'identifier': identifier,
        'identifierType': identifierType,
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
  bool _isLoading = false;
  late AnimationController _animationController;
  bool _isEditing = false;
  String? _editingChildId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addChild();
      _checkAuthentication();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    final children = ref.read(childrenProvider);
    for (var entry in children) {
      entry.dispose();
    }
    super.dispose();
  }

  void _addChild() {
    final children = ref.read(childrenProvider.notifier);
    children.state = [...children.state, ChildEntry()];
    _animationController.forward(from: 0);
    _isEditing = false;
    _editingChildId = null;
  }

  void _removeChild(int index) {
    final children = ref.read(childrenProvider.notifier);
    final updatedChildren = [...children.state];
    updatedChildren[index].dispose();
    updatedChildren.removeAt(index);
    children.state = updatedChildren;
    _animationController.reverse();
  }

  Future<void> _deleteChild(String childId) async {
    if (!mounted) return;

    final service = ref.read(child_provider.childProfileServiceProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError(AppLocalizations.of(context)!.pleaseLoginToSaveProfiles);
      context.go(AppRoutes.login);
      return;
    }

    try {
      await service.deleteChildProfile(user.uid, childId);
      ref.invalidate(child_provider.childProfilesProvider);
      logger.i("✅ Child profile deleted: $childId");
      if (mounted) {
        _showSuccess(
            AppLocalizations.of(context)!.childProfileDeletedSuccessfully);
      }
    } catch (e) {
      logger.e("❌ Error deleting child profile: $e");
      if (mounted) {
        _showError(
            AppLocalizations.of(context)!.failedToDeleteChild(e.toString()));
      }
    }
  }

  void _editChild(ChildProfile child) {
    final entry = ChildEntry();
    entry.nameController.text = child.name;
    entry.nationalIDController.text = child.identifier;
    entry.identifierType = child.identifierType;
    entry.birthDate = child.birthDate;
    entry.gender = (child.gender == 'other') ? 'male' : child.gender;
    entry.relationship = child.relationship;
    entry.photoUrl = child.photoUrl;
    final children = ref.read(childrenProvider.notifier);
    children.state = [...children.state, entry];
    _isEditing = true;
    _editingChildId = child.id;
    _animationController.forward(from: 0);
  }

  Future<void> _updateChild() async {
    if (_isLoading || _editingChildId == null) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(AppLocalizations.of(context)!.authenticationRequired);
      }

      final children = ref.read(childrenProvider);
      final entry = children.last;
      if (!entry.formKey.currentState!.validate()) {
        throw Exception(
            AppLocalizations.of(context)!.pleaseFillAllRequiredFields);
      }

      final profileData = ChildProfileData.fromChildEntry(entry).toMap();
      final validationResult =
          (await compute(validateProfilesInIsolate, [profileData])).first;

      if (!validationResult['success']) {
        throw Exception(validationResult['error']);
      }

      final data = validationResult['data'] as Map<String, dynamic>;

      final service = ref.read(child_provider.childProfileServiceProvider);
      final updatedProfile = ChildProfile(
        id: _editingChildId!,
        name: data['name'] as String,
        identifier: data['identifier'] as String,
        identifierType: data['identifierType'] as String,
        birthDate: data['birthDate'] as DateTime,
        gender: data['gender'] as String,
        relationship: data['relationship'] as String,
        photoUrl: entry.profileImage != null ? '' : entry.photoUrl,
        updatedAt: DateTime.now(),
      );

      await service.updateChildProfile(
        userId: user.uid,
        childId: _editingChildId!,
        profile: updatedProfile,
        imageFile: entry.profileImage,
      );

      ref.invalidate(child_provider.childProfilesProvider);
      if (mounted) {
        final childrenNotifier = ref.read(childrenProvider.notifier);
        final updatedChildren = [...children];
        updatedChildren.removeLast();
        childrenNotifier.state = updatedChildren;
        setState(() {
          _isEditing = false;
          _editingChildId = null;
        });
        _showSuccess(
            AppLocalizations.of(context)!.childProfileUpdatedSuccessfully);
      }
    } catch (e) {
      _showError(
          AppLocalizations.of(context)!.failedToUpdateProfile(e.toString()));
      if (e
          .toString()
          .contains(AppLocalizations.of(context)!.authenticationRequired)) {
        context.go(AppRoutes.login);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _checkAuthentication() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      logger.w("User not authenticated, redirecting to login.");
      if (mounted) {
        _showError(AppLocalizations.of(context)!.pleaseLoginToSaveProfiles);
        context.go(AppRoutes.login);
      }
    } else {
      logger.d("User authenticated: ${user.uid}");
      ref.invalidate(child_provider.childProfilesProvider);
    }
  }

  Future<void> _saveAllProfiles() async {
    if (_isLoading) return;

    final children = ref.read(childrenProvider);
    if (children.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(AppLocalizations.of(context)!.authenticationRequired);
      }

      for (var entry in children) {
        if (!entry.formKey.currentState!.validate()) {
          throw Exception(
              AppLocalizations.of(context)!.pleaseFillAllRequiredFields);
        }
      }

      final profileDataList = children
          .map((entry) => ChildProfileData.fromChildEntry(entry).toMap())
          .toList();
      final validationResults =
          await compute(validateProfilesInIsolate, profileDataList);

      final service = ref.read(child_provider.childProfileServiceProvider);
      final vaccinationService = VaccinationService();

      final isFirstChild =
          (ref.read(child_provider.childProfilesProvider).value ?? []).isEmpty;

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
          identifier: data['identifier'] as String,
          identifierType: data['identifierType'] as String,
          birthDate: data['birthDate'] as DateTime,
          gender: data['gender'] as String,
          relationship: data['relationship'] as String,
          photoUrl: '',
          updatedAt: DateTime.now(),
        );

        await service.saveChildProfile(
          userId: user.uid,
          profile: profile,
          imageFile: children[i].profileImage,
          childId: childId,
        );

        await vaccinationService.initializeVaccinationsForChild(
            childId, data['birthDate'] as DateTime);
      }

      ref.invalidate(child_provider.childProfilesProvider);
      if (mounted) {
        final childrenNotifier = ref.read(childrenProvider.notifier);
        for (var entry in children) {
          entry.dispose();
        }
        childrenNotifier.state = [];
        _showSuccess(
            AppLocalizations.of(context)!.childProfileSavedSuccessfully);
        if (isFirstChild) {
          context.go(AppRoutes.home);
        } else {
          _addChild();
        }
      }
    } catch (e) {
      _showError(
          AppLocalizations.of(context)!.failedToSaveProfiles(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorOccurred),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.retry,
            onPressed: () => _saveAllProfiles(),
          ),
        ),
      );
      if (e
          .toString()
          .contains(AppLocalizations.of(context)!.authenticationRequired)) {
        context.go(AppRoutes.login);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _cancelEdit() {
    final children = ref.read(childrenProvider.notifier);
    final updatedChildren = [...children.state];
    updatedChildren.removeLast();
    children.state = updatedChildren;
    setState(() {
      _isEditing = false;
      _editingChildId = null;
    });
  }

  void _showError(String message) {
    if (!mounted) return;

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
          label: AppLocalizations.of(context)!.dismiss,
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.dismiss,
          textColor: Theme.of(context).colorScheme.onPrimary,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(
        title: _isEditing
            ? AppLocalizations.of(context)!.editChildProfile
            : AppLocalizations.of(context)!.childProfiles,
        trailingIcon: Icons.add_circle,
        onTrailingPressed: _addChild,
        onBackPressed: () => context.pop(),
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
              Consumer(
                builder: (context, ref, child) {
                  final childProfilesAsync =
                      ref.watch(child_provider.childProfilesProvider);
                  return childProfilesAsync.when(
                    data: (children) {
                      if (children.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            AppLocalizations.of(context)!
                                .noChildrenRegisteredYet,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.registeredChildren,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 170,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: children.length,
                              itemBuilder: (context, index) {
                                final child = children[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: _buildChildCard(child),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text(
                        "${AppLocalizations.of(context)!.error}: ${e.toString()}",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  );
                },
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final children = ref.watch(childrenProvider);
                    return SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                        ),
                        child: AnimatedList(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          key: ValueKey(children.length),
                          initialItemCount: children.length,
                          itemBuilder: (context, index, animation) {
                            return SizeTransition(
                              sizeFactor: animation,
                              child: _ChildCard(
                                entry: children[index],
                                index: index,
                                onRemove: children.length > 1
                                    ? () => _removeChild(index)
                                    : null,
                                scrollController: _scrollController,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              _SaveButton(
                isLoading: _isLoading,
                isEditing: _isEditing,
                onSave: _saveAllProfiles,
                onUpdate: _updateChild,
                onCancel: _cancelEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildCard(ChildProfile child) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: (child.photoUrl != null && child.photoUrl!.isNotEmpty)
                  ? FadeInImage(
                      placeholder: const AssetImage('assets/placeholder.png'),
                      image: NetworkImage(child.photoUrl!),
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      imageErrorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    )
                  : Icon(Icons.child_care,
                      size: 30, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              child.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.edit,
                      size: 20, color: Theme.of(context).colorScheme.primary),
                  onPressed: () => _editChild(child),
                ),
                IconButton(
                  icon: Icon(Icons.delete,
                      size: 20, color: Theme.of(context).colorScheme.error),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.deleteChild),
                        content: Text(AppLocalizations.of(context)!
                            .confirmDeleteChild(child.name)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              AppLocalizations.of(context)!.cancel,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteChild(child.id);
                            },
                            child: Text(
                              AppLocalizations.of(context)!.delete,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildEntry entry;
  final int index;
  final VoidCallback? onRemove;
  final ScrollController scrollController;

  const _ChildCard({
    required this.entry,
    required this.index,
    this.onRemove,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: entry.formKey,
          child: Column(
            children: [
              _CardHeader(
                index: index + 1,
                onRemove: onRemove,
              ),
              const SizedBox(height: 16),
              _ImagePickerSection(
                entry: entry,
              ),
              const SizedBox(height: 24),
              _PersonalInfoSection(
                entry: entry,
                context: context,
                scrollController: scrollController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final int index;
  final VoidCallback? onRemove;

  const _CardHeader({
    required this.index,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.childIndex(index),
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
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.removeChild),
                  content:
                      Text(AppLocalizations.of(context)!.confirmRemoveChild),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onRemove!();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.remove,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
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

class _ImagePickerSection extends StatefulWidget {
  final ChildEntry entry;

  const _ImagePickerSection({
    required this.entry,
  });

  @override
  State<_ImagePickerSection> createState() => _ImagePickerSectionState();
}

class _ImagePickerSectionState extends State<_ImagePickerSection> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 300,
        maxHeight: 300,
      );
      if (image != null) {
        setState(() => widget.entry.profileImage = File(image.path));
      }
    } catch (e) {
      logger.e("❌ Image pick error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.imageSelectionFailed,
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)!.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: widget.entry.profileImage != null
                  ? Image.file(
                      widget.entry.profileImage!,
                      fit: BoxFit.cover,
                      width: 180,
                      height: 180,
                    )
                  : (widget.entry.photoUrl != null &&
                          widget.entry.photoUrl!.isNotEmpty)
                      ? FadeInImage(
                          placeholder:
                              const AssetImage('assets/placeholder.png'),
                          image: NetworkImage(widget.entry.photoUrl!),
                          fit: BoxFit.cover,
                          width: 180,
                          height: 180,
                          imageErrorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        )
                      : Icon(
                          Icons.child_care,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.entry.profileImage != null ||
                        (widget.entry.photoUrl != null &&
                            widget.entry.photoUrl!.isNotEmpty)
                    ? AppLocalizations.of(context)!.changePhoto
                    : AppLocalizations.of(context)!.addPhoto,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
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
  final ChildEntry entry;
  final BuildContext context;
  final ScrollController scrollController;

  const _PersonalInfoSection({
    required this.entry,
    required this.context,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final genderOptions = [
      {'key': 'male', 'label': AppLocalizations.of(context)!.male},
      {'key': 'female', 'label': AppLocalizations.of(context)!.female},
    ];

    final relationshipOptions = [
      {'key': 'parent', 'label': AppLocalizations.of(context)!.parent},
      {'key': 'guardian', 'label': AppLocalizations.of(context)!.guardian},
    ];

    final identifierTypeOptions = [
      {'key': 'national_id', 'label': AppLocalizations.of(context)!.nationalID},
      {'key': 'residence_id', 'label': AppLocalizations.of(context)!.residenceID},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: entry.nameController,
          label: AppLocalizations.of(context)!.fullName,
          icon: Icons.person_rounded,
          placeholder: AppLocalizations.of(context)!.enterChildName,
          focusNode: entry.nameFocusNode,
          nextFocusNode: entry.nationalIDFocusNode,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'[ء-يa-zA-Z\s-]')),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppLocalizations.of(context)!.fieldRequired(
                  AppLocalizations.of(context)!.fullName);
            }
            if (value.trim().length < 4) {
              return AppLocalizations.of(context)!.nameTooShort;
            }
            if (value.trim().length > 30) {
              return AppLocalizations.of(context)!.nameTooLong;
            }
            if (!RegExp(r'^[ء-يa-zA-Z\s-]+$').hasMatch(value)) {
              return AppLocalizations.of(context)!.invalidNameCharacters;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: AppLocalizations.of(context)!.identifierType,
          value: entry.identifierType,
          items: identifierTypeOptions,
          onChanged: (value) => entry.identifierType = value,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: entry.nationalIDController,
          label: entry.identifierType == 'national_id'
              ? AppLocalizations.of(context)!.nationalID
              : AppLocalizations.of(context)!.residenceID,
          icon: Icons.badge_rounded,
          placeholder: entry.identifierType == 'national_id'
              ? AppLocalizations.of(context)!.enterChildNationalID
              : AppLocalizations.of(context)!.enterChildResidenceID,
          focusNode: entry.nationalIDFocusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.fieldRequired(
                  entry.identifierType == 'national_id'
                      ? AppLocalizations.of(context)!.nationalID
                      : AppLocalizations.of(context)!.residenceID);
            }
            if (value.length != 10) {
              return AppLocalizations.of(context)!.identifierLengthError;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DatePickerField(
          context: context,
          selectedDate: entry.birthDate,
          onDateSelected: (date) => entry.birthDate = date,
          labelText: AppLocalizations.of(context)!.dateOfBirth,
          placeholder: AppLocalizations.of(context)!.selectChildBirthDate,
          validator: (date) {
            if (date == null) {
              return AppLocalizations.of(context)!.dateOfBirthRequired;
            }
            final now = DateTime.now();
            final fiveYearsAgo = now.subtract(const Duration(days: 365 * 5));
            if (date.isAfter(now)) {
              return AppLocalizations.of(context)!.birthDateCannotBeFuture;
            }
            if (date.isBefore(fiveYearsAgo)) {
              return AppLocalizations.of(context)!
                  .birthDateMustBeWithinFiveYears;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: AppLocalizations.of(context)!.gender,
          value: entry.gender,
          items: genderOptions,
          onChanged: (value) => entry.gender = value,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: AppLocalizations.of(context)!.relationship,
          value: entry.relationship,
          items: relationshipOptions,
          onChanged: (value) => entry.relationship = value,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String placeholder,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
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
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
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
          validator: validator,
          onFieldSubmitted: (value) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<Map<String, String>> items,
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
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item['key'],
                    child: Text(item['label']!),
                  ))
              .toList(),
          onChanged: (newValue) => onChanged(newValue ?? value),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
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
          dropdownColor: Theme.of(context).colorScheme.surface,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isLoading;
  final bool isEditing;
  final VoidCallback onSave;
  final VoidCallback onUpdate;
  final VoidCallback onCancel;

  const _SaveButton({
    required this.isLoading,
    required this.isEditing,
    required this.onSave,
    required this.onUpdate,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isEditing)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: OutlinedButton(
                onPressed: isLoading ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : (isEditing ? onUpdate : onSave),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    isEditing
                        ? AppLocalizations.of(context)!.update
                        : AppLocalizations.of(context)!.saveAllProfiles,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class ChildEntry {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nationalIDController = TextEditingController();
  final nameFocusNode = FocusNode();
  final nationalIDFocusNode = FocusNode();
  DateTime? birthDate;
  String gender = 'male';
  String relationship = 'parent';
  String identifierType = 'national_id';
  File? profileImage;
  String? photoUrl;

  ChildEntry({this.photoUrl});

  void dispose() {
    nameController.dispose();
    nationalIDController.dispose();
    nameFocusNode.dispose();
    nationalIDFocusNode.dispose();
  }
}