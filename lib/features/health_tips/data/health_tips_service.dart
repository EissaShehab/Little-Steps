import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class HealthTipsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getDailyTipForChild(String userId, String childId, String language) async {
    try {
      final childDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .get();

      if (!childDoc.exists) {
        logger.w("⚠️ Child not found: $childId");
        return null;
      }

      final data = childDoc.data()!;
      final birthDate = (data['birthDate'] as Timestamp).toDate();
      final ageInMonths = _calculateAgeInMonths(birthDate);
      final ageRange = _mapAgeToRange(ageInMonths);

      final today = DateTime.now().toUtc().toIso8601String().split('T')[0];
      final tipsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .collection('tips');

      final existingTip = await tipsRef.doc(today).get();
      if (existingTip.exists) {
        // التحقق من اللغة المخزنة
        final storedLanguage = existingTip.data()?['language'] ?? 'en';
        if (storedLanguage == language) {
          logger.i("📦 Using cached tip for $childId on $today with language: $language");
          return {
            'id': existingTip.id,
            'title': existingTip.data()?['title'] ?? (language == 'ar' ? 'غير متاح' : 'Not Available'),
            'content': existingTip.data()?['content'] ?? '',
            'category': existingTip.data()?['category'] ?? '',
            'date': existingTip.data()?['date'] ?? today,
            'source': existingTip.data()?['source'] ?? '',
            'feedbackGiven': existingTip.data()?['feedbackGiven'] ?? false,
            'helpful_count': existingTip.data()?['helpful_count'] ?? 0,
            'unhelpful_count': existingTip.data()?['unhelpful_count'] ?? 0,
          };
        } else {
          logger.i("🌐 Language changed (stored: $storedLanguage, current: $language). Fetching new tip...");
        }
      }

      final allTipsSnapshot = await _firestore
          .collection('health_tips')
          .where('age_range', isEqualTo: ageRange)
          .where('language', isEqualTo: language)
          .get();

      final allTips = allTipsSnapshot.docs;
      if (allTips.isEmpty) {
        logger.w("⚠️ No tips found for age range: $ageRange and language: $language");
        return {
          'title': language == 'ar' ? 'غير متاح' : 'Not Available',
          'content': language == 'ar' ? 'لم يتم العثور على نصائح لهذا العمر حاليًا.' : 'No tips found for this age range currently.',
          'source': language == 'ar' ? 'التطبيق' : 'App',
          'date': today,
          'feedbackGiven': true,
          'helpful_count': 0,
          'unhelpful_count': 0,
        };
      }

      final takenSnapshot = await tipsRef.get();
      final takenTitles = takenSnapshot.docs.map((doc) => doc.data()['title'] as String).toSet();
      final unusedTips = allTips.where((doc) => !takenTitles.contains(doc['title'])).toList();

      Map<String, dynamic>? selectedTip;

      if (unusedTips.isNotEmpty) {
        selectedTip = unusedTips.first.data();
        logger.i("✅ Selected NEW unused tip for $childId: ${selectedTip['title']}");
      } else {
        selectedTip = takenSnapshot.docs.isNotEmpty
            ? takenSnapshot.docs.reduce((a, b) =>
                (a.data()['helpful_count'] ?? 0) > (b.data()['helpful_count'] ?? 0) ? a : b).data()
            : allTips.first.data();
        logger.w("⚠️ No unused tip found. Using highest-rated tip: ${selectedTip['title']}");
      }

      await tipsRef.doc(today).set({
        'title': selectedTip['title'] ?? (language == 'ar' ? 'غير متاح' : 'Not Available'),
        'content': selectedTip['content'] ?? '',
        'category': selectedTip['category'] ?? '',
        'date': today,
        'source': selectedTip['source'] ?? '',
        'language': language, // إضافة اللغة عند التخزين
        'feedbackGiven': false,
        'helpful_count': selectedTip['helpful_count'] ?? 0,
        'unhelpful_count': selectedTip['unhelpful_count'] ?? 0,
      });

      logger.i("💾 Tip stored under /users/$userId/children/$childId/tips/$today with language: $language");
      return {
        'title': selectedTip['title'] ?? (language == 'ar' ? 'غير متاح' : 'Not Available'),
        'content': selectedTip['content'] ?? '',
        'category': selectedTip['category'] ?? '',
        'date': today,
        'source': selectedTip['source'] ?? '',
        'feedbackGiven': false,
        'helpful_count': selectedTip['helpful_count'] ?? 0,
        'unhelpful_count': selectedTip['unhelpful_count'] ?? 0,
      };
    } catch (e) {
      logger.e("❌ Error in getDailyTipForChild: $e");
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> getTipsForChild(String userId, String childId, String language) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('children')
        .doc(childId)
        .snapshots()
        .asyncMap((childDoc) async {
      if (!childDoc.exists) {
        logger.w("⚠️ Child not found: $childId");
        return [];
      }

      final data = childDoc.data()!;
      final birthDate = (data['birthDate'] as Timestamp).toDate();
      final ageInMonths = _calculateAgeInMonths(birthDate);
      final ageRange = _mapAgeToRange(ageInMonths);

      final tipsSnapshot = await _firestore
          .collection('health_tips')
          .where('age_range', isEqualTo: ageRange)
          .where('language', isEqualTo: language)
          .get();

      final today = DateTime.now().toUtc().toIso8601String().split('T')[0];
      return tipsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? (language == 'ar' ? 'غير متاح' : 'Not Available'),
          'content': data['content'] ?? '',
          'category': data['category'] ?? '',
          'date': data['createdAt'] ?? today,
          'source': data['source'] ?? '',
          'feedbackGiven': false,
          'helpful_count': data['helpful_count'] ?? 0,
          'unhelpful_count': data['unhelpful_count'] ?? 0,
        };
      }).toList();
    });
  }

  Future<void> addFeedbackForTip(String userId, String childId, String tipDate, bool isHelpful) async {
    try {
      final tipRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .collection('tips')
          .doc(tipDate);

      final tipDoc = await tipRef.get();
      if (!tipDoc.exists) {
        logger.w("⚠️ Tip not found for $childId on $tipDate");
        return;
      }

      await tipRef.update({
        'feedbackGiven': true,
        'helpful_count': FieldValue.increment(isHelpful ? 1 : 0),
        'unhelpful_count': FieldValue.increment(isHelpful ? 0 : 1),
      });

      logger.i("👍 Feedback saved for $childId on $tipDate: helpful=$isHelpful");
    } catch (e) {
      logger.e("❌ Error saving feedback: $e");
    }
  }

  String _mapAgeToRange(int ageInMonths) {
    if (ageInMonths <= 6) return "0-6 months";
    if (ageInMonths <= 12) return "6-12 months";
    if (ageInMonths <= 24) return "12-24 months";
    return "24-60 months";
  }

  int _calculateAgeInMonths(DateTime birthDate) {
    final now = DateTime.now();
    return ((now.difference(birthDate).inDays) / 30).floor();
  }
}