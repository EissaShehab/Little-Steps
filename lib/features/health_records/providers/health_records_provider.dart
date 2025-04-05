import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:littlesteps/features/health_records/models/health_record_model.dart';
import 'package:littlesteps/features/health_records/data/HealthRecords_Service .dart';
import 'package:uuid/uuid.dart';

final healthRecordsServiceProvider = Provider<HealthRecordsService>((ref) => HealthRecordsService());

final healthRecordsProvider = StateNotifierProvider.family<HealthRecordsNotifier, AsyncValue<List<HealthRecord>>, String>(
  (ref, childId) => HealthRecordsNotifier(ref.read(healthRecordsServiceProvider), childId),
);

class HealthRecordsNotifier extends StateNotifier<AsyncValue<List<HealthRecord>>> {
  final HealthRecordsService _service;
  final String _childId;

  HealthRecordsNotifier(this._service, this._childId) : super(const AsyncValue.loading()) {
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      state = const AsyncValue.loading();
      final records = await _service.getRecordsForChild(_childId);
      state = AsyncValue.data(records);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addRecord(String title, DateTime date, String description, {File? file}) async {
    final newRecord = HealthRecord(
      id: const Uuid().v4(),
      childId: _childId,
      title: title,
      date: date,
      description: description,
    );
    await _service.addRecord(newRecord, file: file);
    await _loadRecords();
  }

  Future<void> updateRecord(HealthRecord record) async {
    await _service.updateRecord(record);
    await _loadRecords();
  }

  Future<void> deleteRecord(String recordId, String? attachmentUrl) async {
    await _service.deleteRecord(recordId, attachmentUrl);
    await _loadRecords();
  }
}