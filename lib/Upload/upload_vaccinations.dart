import 'package:cloud_firestore/cloud_firestore.dart';

class VaccinationUploader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> vaccinations = [
    {
      "name": "BCG (Bacillus Calmette–Guérin)",
      "name_ar": "بي سي جي (التدرن)",
      "age": "At birth",
      "age_ar": "عند الولادة",
      "mandatory": true,
      "status": "upcoming",
      "admin_type": "injection",
      "conditions": ["Not given if severe immunodeficiency"],
      "conditions_ar": ["لا يعطى إذا كان هناك نقص مناعة شديد"],
      "description": "Protects against tuberculosis, especially severe forms in children.",
      "description_ar": "يحمي من مرض السل، خاصة الأشكال الحادة عند الأطفال.",
      "notificationScheduled": false, // Added for FCM integration
    },
    {
      "name": "Hexavalent Vaccine (DTP-HepB-Hib-IPV) - 1st dose",
      "name_ar": "المطعوم السداسي (الدفتيريا، الكزاز، السعال الديكي، التهاب الكبد ب، المستدمية النزلية، شلل الأطفال) - الجرعة الأولى",
      "age": "2 months",
      "age_ar": "عمر شهرين",
      "mandatory": true,
      "status": "upcoming",
      "admin_type": "injection",
      "conditions": [],
      "conditions_ar": [],
      "description": "Combination vaccine protecting against six diseases.",
      "description_ar": "مطعوم مركب يحمي من ستة أمراض.",
      "notificationScheduled": false, // Added for FCM integration
    },
    {
      "name": "Hexavalent Vaccine (DTP-HepB-Hib-IPV) - 2nd dose",
      "name_ar": "المطعوم السداسي - الجرعة الثانية",
      "age": "3 months",
      "age_ar": "عمر 3 شهور",
      "mandatory": true,
      "status": "upcoming",
      "admin_type": "injection",
      "conditions": [],
      "conditions_ar": [],
      "description": "Second dose of the hexavalent vaccine.",
      "description_ar": "الجرعة الثانية من المطعوم السداسي.",
      "notificationScheduled": false, // Added for FCM integration
    },
    {
      "name": "Hexavalent Vaccine (DTP-HepB-Hib-IPV) - 3rd dose",
      "name_ar": "المطعوم السداسي - الجرعة الثالثة",
      "age": "4 months",
      "age_ar": "عمر 4 شهور",
      "mandatory": true,
      "status": "upcoming",
      "admin_type": "injection",
      "conditions": [],
      "conditions_ar": [],
      "description": "Third and final dose of the hexavalent vaccine.",
      "description_ar": "الجرعة الثالثة والأخيرة من المطعوم السداسي.",
      "notificationScheduled": false, // Added for FCM integration
    },
    {
      "name": "Measles Vaccine - 1st dose",
      "name_ar": "مطعوم الحصبة - الجرعة الأولى",
      "age": "9 months",
      "age_ar": "عمر 9 شهور",
      "mandatory": true,
      "status": "upcoming",
      "admin_type": "injection",
      "conditions": [],
      "conditions_ar": [],
      "description": "Protects against measles infection.",
      "description_ar": "يحمي من الإصابة بالحصبة.",
      "notificationScheduled": false, // Added for FCM integration
    },
    {
      "name": "MMR (Measles, Mumps, Rubella) - 1st dose",
      "name_ar": "المطعوم الثلاثي الفيروسي (الحصبة، النكاف، الحصبة الألمانية) - الجرعة الأولى",
      "age": "12 months",
      "age_ar": "عمر 12 شهر",
      "mandatory": true,
      "status": "upcoming",
      "admin_type": "injection",
      "conditions": ["Delayed 3 months if plasma/immunoglobulin was given"],
      "conditions_ar": ["يؤجل 3 أشهر إذا تم إعطاء بلازما أو أجسام مناعية"],
      "description": "Protects against measles, mumps, and rubella.",
      "description_ar": "يحمي من الحصبة والنكاف والحصبة الألمانية.",
      "notificationScheduled": false, // Added for FCM integration
    },
    {
      "name": "DPT Booster - 1st booster",
      "name_ar": "الجرعة المعززة الأولى من المطعوم الثلاثي (الدفتيريا، الكزاز، السعال الديكي)",
      "age": "18 months",
      "age_ar": "عمر 18 شهر",
      "mandatory": true,
      "status": "upcoming",
      "admin_type": "injection",
      "conditions": ["Use DT instead if child had severe reaction to DPT"],
      "conditions_ar": ["يستخدم المطعوم الثنائي الصغير بدلاً من الثلاثي في حال حدوث تفاعل شديد"],
      "description": "First booster dose of the DPT vaccine.",
      "description_ar": "الجرعة المعززة الأولى من مطعوم الثلاثي.",
      "notificationScheduled": false, // Added for FCM integration
    },
    {
      "name": "Oral Polio Vaccine (OPV) - 1st dose",
      "name_ar": "مطعوم شلل الأطفال الفموي - الجرعة الأولى",
      "age": "3 months",
      "age_ar": "عمر 3 شهور",
      "mandatory": true,
      "status": "upcoming",
      "admin_type": "oral",
      "conditions": ["Not given if household member has immunodeficiency"],
      "conditions_ar": ["لا يعطى إذا كان أحد أفراد الأسرة يعاني من نقص المناعة"],
      "description": "Oral vaccine to protect against polio virus infection.",
      "description_ar": "مطعوم فموي لحماية الطفل من عدوى فيروس شلل الأطفال.",
      "notificationScheduled": false, // Added for FCM integration
    },
    {
      "name": "Oral Polio Vaccine (OPV) - Booster dose",
      "name_ar": "مطعوم شلل الأطفال الفموي - الجرعة المعززة",
      "age": "18 months",
      "age_ar": "عمر 18 شهر",
      "mandatory": true,
      "status": "upcoming",
      "admin_type": "oral",
      "conditions": ["Not given if household member has immunodeficiency"],
      "conditions_ar": ["لا يعطى إذا كان أحد أفراد الأسرة يعاني من نقص المناعة"],
      "description": "Booster dose of Oral Polio Vaccine.",
      "description_ar": "الجرعة المعززة من مطعوم شلل الأطفال الفموي.",
      "notificationScheduled": false, // Added for FCM integration
    },
  ];

  /// Uploads data to Firebase Firestore using a WriteBatch
  Future<void> uploadData() async {
    try {
      CollectionReference vaccinesRef = _firestore.collection("vaccinations");
      WriteBatch batch = _firestore.batch();

      for (var vaccine in vaccinations) {
        final docRef = vaccinesRef.doc(vaccine["name"]);
        batch.set(docRef, vaccine);
        print("✅ Prepared: ${vaccine["name"]}");
      }

      await batch.commit();
      print("🎉 Vaccination data successfully uploaded!");
    } catch (e) {
      print("❌ Error uploading data: $e");
    }
  }
}