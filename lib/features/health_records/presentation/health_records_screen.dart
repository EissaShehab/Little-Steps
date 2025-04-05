import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/features/health_records/models/health_record_model.dart';
import 'package:littlesteps/features/health_records/providers/health_records_provider.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:logger/logger.dart';
import 'package:littlesteps/shared/widgets/typography.dart';

final logger = Logger();

class HealthRecordsScreen extends ConsumerStatefulWidget {
  final ChildProfile child;

  const HealthRecordsScreen({super.key, required this.child});

  @override
  ConsumerState<HealthRecordsScreen> createState() =>
      _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends ConsumerState<HealthRecordsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recordsAsync = ref.watch(healthRecordsProvider(widget.child.id));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Health Records - ${widget.child.name}',
        trailingIcon: Icons.add,
        onTrailingPressed: () => _showAddRecordDialog(context),
      ),
      body: GradientBackground(
        showPattern: false,
        child: recordsAsync.when(
          data: (records) => records.isEmpty
              ? Center(
                  child: Text(
                    'No health records yet.\nTap + to add one!',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyStyle.copyWith(
                      color: isDark
                          ? Colors.white70
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) => Opacity(
                        opacity: _fadeAnimation.value,
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey[600]!
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          color:
                              isDark ? Colors.grey[800] : colorScheme.surface,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(
                              Icons.medical_services,
                              color: colorScheme
                                  .error, // Health records accent color
                              size: 32,
                            ),
                            title: Text(
                              record.title,
                              style: AppTypography.subheadingStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat.yMMMd().format(record.date),
                                  style: AppTypography.bodyStyle.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : colorScheme.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  record.description,
                                  style: AppTypography.bodyStyle.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : colorScheme.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                                if (record.attachmentUrl != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_file,
                                        size: 16,
                                        color: isDark
                                            ? Colors.white70
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          record.fileName ?? 'Attachment',
                                          style:
                                              AppTypography.bodyStyle.copyWith(
                                            color: colorScheme.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      AnimatedScaleButton(
                                        onPressed: () async {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) => Center(
                                              child: CircularProgressIndicator(
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          );
                                          try {
                                            await _downloadFile(
                                              context,
                                              record.attachmentUrl!,
                                              record.fileName ?? 'attachment',
                                            );
                                          } finally {
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: colorScheme.primary
                                                    .withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.download,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Download',
                                                style: AppTypography.buttonStyle
                                                    .copyWith(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: colorScheme.error,
                              ),
                              onPressed: () => _confirmDelete(context, record),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          loading: () => Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          ),
          error: (error, _) => Center(
            child: Text(
              'Error: $error',
              style: AppTypography.bodyStyle.copyWith(
                color: isDark ? Colors.redAccent : colorScheme.error,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    File? selectedFile;
    String? fileName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Health Record',
          style: AppTypography.subheadingStyle.copyWith(
            color: isDark ? Colors.white : colorScheme.primary,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title (e.g., Vaccination)',
                    border: const OutlineInputBorder(),
                    labelStyle: AppTypography.bodyStyle.copyWith(
                      color: isDark ? Colors.white70 : colorScheme.onSurface,
                    ),
                  ),
                  style: AppTypography.bodyStyle.copyWith(
                    color: isDark ? Colors.white : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: const OutlineInputBorder(),
                    labelStyle: AppTypography.bodyStyle.copyWith(
                      color: isDark ? Colors.white70 : colorScheme.onSurface,
                    ),
                  ),
                  maxLines: 2,
                  style: AppTypography.bodyStyle.copyWith(
                    color: isDark ? Colors.white : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedFile == null
                            ? 'No file selected'
                            : 'File: ${fileName ?? ''}',
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyStyle.copyWith(
                          color:
                              isDark ? Colors.white70 : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    AnimatedScaleButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'png', 'pdf', 'xlsx'],
                        );
                        if (result != null) {
                          final file = File(result.files.single.path!);
                          final size = await file.length();
                          if (size > 10 * 1024 * 1024) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('File size exceeds 10MB limit'),
                                backgroundColor: colorScheme.error,
                              ),
                            );
                            return;
                          }
                          setState(() {
                            selectedFile = file;
                            fileName = result.files.single.name;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Upload File',
                          style: AppTypography.buttonStyle.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedScaleButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Select Date: ${DateFormat.yMMMd().format(selectedDate)}',
                      style: AppTypography.bodyStyle.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: isDark ? Colors.grey[800] : colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          AnimatedScaleButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.buttonStyle.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
          AnimatedScaleButton(
            onPressed: () {
              if (titleController.text.isEmpty || descController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: colorScheme.error,
                  ),
                );
                return;
              }
              ref
                  .read(healthRecordsProvider(widget.child.id).notifier)
                  .addRecord(
                    titleController.text,
                    selectedDate,
                    descController.text,
                    file: selectedFile,
                  );
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: AppTypography.buttonStyle.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, HealthRecord record) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Record',
          style: AppTypography.subheadingStyle.copyWith(
            color: isDark ? Colors.white : colorScheme.error,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this record?',
          style: AppTypography.bodyStyle.copyWith(
            color: isDark ? Colors.white70 : colorScheme.onSurface,
          ),
        ),
        backgroundColor: isDark ? Colors.grey[800] : colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          AnimatedScaleButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.buttonStyle.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
          AnimatedScaleButton(
            onPressed: () {
              ref
                  .read(healthRecordsProvider(widget.child.id).notifier)
                  .deleteRecord(record.id, record.attachmentUrl);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: AppTypography.buttonStyle.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadFile(
      BuildContext context, String url, String fileName) async {
    final colorScheme = Theme.of(context).colorScheme;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw 'Failed to download file: ${response.statusCode}';
      }

      final tempDir = await getTemporaryDirectory();
      final sanitizedFileName = fileName.replaceAll(RegExp(r'[^\w\s-]'), '_');
      final filePath = '${tempDir.path}/$sanitizedFileName';
      final file = File(filePath);

      await file.writeAsBytes(response.bodyBytes);

      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        throw 'Could not open file: ${result.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download complete'),
          backgroundColor: colorScheme.primary,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () => OpenFile.open(filePath),
          ),
        ),
      );
    } catch (e) {
      logger.e('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading file: $e'),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }
}

class AnimatedScaleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const AnimatedScaleButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  _AnimatedScaleButtonState createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
