import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

import 'package:littlesteps/features/child_profile/models/child_model.dart';
import 'package:littlesteps/features/health_records/models/health_record_model.dart';
import 'package:littlesteps/features/health_records/providers/health_records_provider.dart';
import 'package:littlesteps/gen_l10n/app_localizations.dart';
import 'package:littlesteps/providers/providers.dart';
import 'package:littlesteps/shared/widgets/custom_app_bar.dart';
import 'package:littlesteps/shared/widgets/gradient_background.dart';
import 'package:littlesteps/shared/widgets/typography.dart';

final logger = Logger();

class HealthRecordsScreen extends ConsumerStatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  ConsumerState<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends ConsumerState<HealthRecordsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedChild = ref.watch(selectedChildProvider);
    final recordsAsync = ref.watch(healthRecordsProvider);

    if (selectedChild == null) {
      return Scaffold(
        appBar: CustomAppBar(title: tr.healthRecords),
        body: Center(
          child: Text(
            tr.selectChildFirstMessage,
            style: AppTypography.bodyStyle.copyWith(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: tr.healthRecordsFor(selectedChild.name),
        trailingIcon: Icons.add,
        onTrailingPressed: () => _showAddRecordDialog(context, selectedChild),
      ),
      body: GradientBackground(
        showPattern: false,
        child: recordsAsync.when(
          data: (records) => records.isEmpty
              ? Center(
                  child: Text(
                    tr.noHealthRecords,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyStyle.copyWith(
                      color: isDark
                          ? Colors.white70
                          : colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return _buildHealthRecordCard(context, record, index);
                  },
                ),
          loading: () => Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          ),
          error: (error, _) => Center(
            child: Text(
              '${tr.error}: $error',
              style: AppTypography.bodyStyle.copyWith(
                color: isDark ? Colors.redAccent : colorScheme.error,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthRecordCard(BuildContext context, HealthRecord record, int index) {
    final tr = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context, record),
      onDismissed: (_) async {
        await ref.read(healthRecordsProvider.notifier).deleteRecord(
              record.id,
              record.attachmentUrl,
            );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr.recordDeleted),
          backgroundColor: colorScheme.primary,
        ));
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Icon(Icons.description, color: colorScheme.primary),
          title: Text(record.title, style: AppTypography.subheadingStyle),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(DateFormat.yMMMd().format(record.date),
                  style: AppTypography.bodyStyle),
              const SizedBox(height: 4),
              Text(record.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStyle.copyWith(fontSize: 13)),
              if (record.attachmentUrl != null)
                TextButton.icon(
                  onPressed: () async {
                    await _downloadFile(
                      context,
                      record.attachmentUrl!,
                      record.fileName ?? 'attachment',
                    );
                  },
                  icon: const Icon(Icons.download, size: 18),
                  label: Text(tr.download),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context, ChildProfile child) {
    final tr = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    File? selectedFile;
    String? fileName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.addHealthRecord),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: tr.titleExample)),
              TextField(controller: descController, decoration: InputDecoration(labelText: tr.description)),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpg', 'png'],
                  );
                  if (result != null) {
                    final file = File(result.files.single.path!);
                    final size = await file.length();
                    if (size > 10 * 1024 * 1024) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(tr.fileSizeExceedsLimit),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ));
                      return;
                    }
                    setState(() {
                      selectedFile = file;
                      fileName = result.files.single.name;
                    });
                  }
                },
                icon: const Icon(Icons.attach_file),
                label: Text(selectedFile == null
                    ? tr.noFileSelected
                    : tr.fileSelected(fileName ?? '')),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
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
                child: Text('${tr.selectDate}: ${DateFormat.yMMMd().format(selectedDate)}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty || descController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(tr.pleaseFillAllFields),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ));
                return;
              }
              ref.read(healthRecordsProvider.notifier).addRecord(
                    titleController.text,
                    selectedDate,
                    descController.text,
                    file: selectedFile,
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(tr.recordAdded),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ));
            },
            child: Text(tr.save),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, HealthRecord record) {
    final tr = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.deleteRecord),
        content: Text(tr.confirmDeleteRecord),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadFile(BuildContext context, String url, String fileName) async {
    final tr = AppLocalizations.of(context)!;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) throw 'Failed to download file';

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/$fileName';
      final file = File(path);
      await file.writeAsBytes(response.bodyBytes);

      await OpenFile.open(path);
    } catch (e) {
      logger.e("Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr.errorDownloadingFile(e.toString())),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }
}
