import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadHealthTips() async {
  final firestore = FirebaseFirestore.instance;
  final CollectionReference tipsCollection = firestore.collection('health_tips');

  List<Map<String, dynamic>> healthTips = [
    // نصائح لعمر 0-6 أشهر (8 نصائح × 2 لغة = 16 نصيحة)
    {
      "title": "الرضاعة الطبيعية الحصرية",
      "content": "الرضاعة الطبيعية هي أفضل مصدر لتغذية الرضع حتى 6 أشهر. تقوي المناعة وتحمي من الالتهابات.",
      "category": "Nutrition",
      "age_range": "0-6 months",
      "language": "ar",
      "source": "منظمة الصحة العالمية",
      "priority": 5,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "Exclusive Breastfeeding",
      "content": "Breastfeeding is the best source of nutrition for infants up to 6 months. It strengthens immunity and protects against infections.",
      "category": "Nutrition",
      "age_range": "0-6 months",
      "language": "en",
      "source": "World Health Organization",
      "priority": 5,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "ممارسات النوم الآمن",
      "content": "ضعي الطفل دائمًا على ظهره أثناء النوم لتقليل مخاطر متلازمة موت الرضع المفاجئ (SIDS).",
      "category": "Sleep",
      "age_range": "0-6 months",
      "language": "ar",
      "source": "وزارة الصحة الأردنية",
      "priority": 7, // أولوية أعلى لأنها مهمة جدًا
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "Safe Sleep Practices",
      "content": "Always place the baby on their back for sleep to reduce the risk of Sudden Infant Death Syndrome (SIDS).",
      "category": "Sleep",
      "age_range": "0-6 months",
      "language": "en",
      "source": "Jordanian Ministry of Health",
      "priority": 7, // أولوية أعلى
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "التطعيمات المبكرة",
      "content": "اتبعي جدول التطعيمات الوطني لضمان مناعة قوية ضد الأمراض القابلة للوقاية.",
      "category": "Vaccination",
      "age_range": "0-6 months",
      "language": "ar",
      "source": "وزارة الصحة الأردنية",
      "priority": 7, // أولوية أعلى
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "Early Vaccinations",
      "content": "Follow the national vaccination schedule to ensure strong immunity against preventable diseases.",
      "category": "Vaccination",
      "age_range": "0-6 months",
      "language": "en",
      "source": "Jordanian Ministry of Health",
      "priority": 7, // أولوية أعلى
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "التدليك اللطيف للرضع",
      "content": "استخدمي زيوت طبيعية مثل زيت الزيتون لتدليك الطفل لتحسين الدورة الدموية وتهدئته.",
      "category": "Child Development",
      "age_range": "0-6 months",
      "language": "ar",
      "source": "منظمة الصحة العالمية",
      "priority": 5,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "Gentle Infant Massage",
      "content": "Use natural oils like olive oil to massage the baby to improve circulation and soothe them.",
      "category": "Child Development",
      "age_range": "0-6 months",
      "language": "en",
      "source": "World Health Organization",
      "priority": 5,
      "createdAt": FieldValue.serverTimestamp(),
    },

    // نصائح لعمر 6-12 أشهر (7 نصائح × 2 لغة = 14 نصيحة)
    {
      "title": "إدخال الأطعمة الصلبة",
      "content": "ابدئي بإدخال الأطعمة الغنية بالحديد مثل الخضروات المهروسة والفواكه والحبوب عند 6 أشهر.",
      "category": "Nutrition",
      "age_range": "6-12 months",
      "language": "ar",
      "source": "منظمة الصحة العالمية",
      "priority": 6,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "Introducing Solid Foods",
      "content": "Start introducing iron-rich foods like mashed vegetables, fruits, and rice cereal at six months.",
      "category": "Nutrition",
      "age_range": "6-12 months",
      "language": "en",
      "source": "World Health Organization",
      "priority": 6,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "تجنب الأطعمة المسببة للحساسية",
      "content": "ابتعدي عن إدخال أطعمة مثل الفول السوداني أو البيض قبل استشارة طبيب الأطفال.",
      "category": "Nutrition",
      "age_range": "6-12 months",
      "language": "ar",
      "source": "الأكاديمية الأمريكية لطب الأطفال",
      "priority": 6,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "Avoid Allergenic Foods",
      "content": "Avoid introducing foods like peanuts or eggs before consulting a pediatrician.",
      "category": "Nutrition",
      "age_range": "6-12 months",
      "language": "en",
      "source": "American Academy of Pediatrics",
      "priority": 6,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "روتين نوم منتظم",
      "content": "حاولي وضع روتين نوم يومي للطفل لتحسين جودة نومه.",
      "category": "Sleep",
      "age_range": "6-12 months",
      "language": "ar",
      "source": "وزارة الصحة الأردنية",
      "priority": 5,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "Regular Sleep Routine",
      "content": "Try to establish a daily sleep routine to improve the baby’s sleep quality.",
      "category": "Sleep",
      "age_range": "6-12 months",
      "language": "en",
      "source": "Jordanian Ministry of Health",
      "priority": 5,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "تحفيز الحركة",
      "content": "شجعي الطفل على الزحف والحركة لتعزيز نموه البدني.",
      "category": "Physical Activity",
      "age_range": "6-12 months",
      "language": "ar",
      "source": "منظمة الصحة العالمية",
      "priority": 5,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "Encourage Movement",
      "content": "Encourage the baby to crawl and move to promote physical development.",
      "category": "Physical Activity",
      "age_range": "6-12 months",
      "language": "en",
      "source": "World Health Organization",
      "priority": 5,
      "createdAt": FieldValue.serverTimestamp(),
    },

    // نصائح لعمر 12-24 أشهر (5 نصائح × 2 لغة = 10 نصائح)
    {
      "title": "نظافة الفم للأطفال الصغار",
      "content": "ابدئي بفرشاة أسنان ناعمة ومعجون أسنان يحتوي على الفلورايد بمجرد ظهور السن الأولى.",
      "category": "Oral Health",
      "age_range": "12-24 months",
      "language": "ar",
      "source": "وزارة الصحة الأردنية",
      "priority": 6,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "Oral Hygiene for Toddlers",
      "content": "Start brushing with a soft toothbrush and fluoride toothpaste as soon as the first tooth appears.",
      "category": "Oral Health",
      "age_range": "12-24 months",
      "language": "en",
      "source": "Jordanian Ministry of Health",
      "priority": 6,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "تناول وجبات متوازنة",
      "content": "قدمي وجبات متوازنة تشمل الخضروات والفواكه والبروتينات لدعم نمو الطفل.",
      "category": "Nutrition",
      "age_range": "12-24 months",
      "language": "ar",
      "source": "منظمة الصحة العالمية",
      "priority": 5,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "Balanced Meals",
      "content": "Offer balanced meals including vegetables, fruits, and proteins to support your child’s growth.",
      "category": "Nutrition",
      "age_range": "12-24 months",
      "language": "en",
      "source": "World Health Organization",
      "priority": 5,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "اللعب التفاعلي",
      "content": "العبي مع طفلك ألعابًا تعليمية لتحفيز مهاراته الاجتماعية والمعرفية.",
      "category": "Child Development",
      "age_range": "12-24 months",
      "language": "ar",
      "source": "الأكاديمية الأمريكية لطب الأطفال",
      "priority": 5,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "Interactive Play",
      "content": "Play educational games with your child to stimulate social and cognitive skills.",
      "category": "Child Development",
      "age_range": "12-24 months",
      "language": "en",
      "source": "American Academy of Pediatrics",
      "priority": 5,
      "createdAt": FieldValue.serverTimestamp(),
    },

    // نصائح لعمر 24-60 أشهر (5 نصائح × 2 لغة = 10 نصائح)
    {
      "title": "النشاط البدني اليومي",
      "content": "شجعي الطفل على ممارسة اللعب النشط لمدة 60 دقيقة يوميًا لتعزيز نموه البدني.",
      "category": "Physical Activity",
      "age_range": "24-60 months",
      "language": "ar",
      "source": "وزارة الصحة الأردنية",
      "priority": 6,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "Daily Physical Activity",
      "content": "Encourage at least 60 minutes of active playtime daily to promote healthy physical development.",
      "category": "Physical Activity",
      "age_range": "24-60 months",
      "language": "en",
      "source": "Jordanian Ministry of Health",
      "priority": 6,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "تقليل وقت الشاشة",
      "content": "قللي وقت الشاشة لأقل من ساعة يوميًا للأطفال دون 5 سنوات.",
      "category": "Child Development",
      "age_range": "24-60 months",
      "language": "ar",
      "source": "منظمة الصحة العالمية",
      "priority": 6,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "Screen Time Limitation",
      "content": "Limit screen exposure to less than 1 hour per day for children under 5.",
      "category": "Child Development",
      "age_range": "24-60 months",
      "language": "en",
      "source": "World Health Organization",
      "priority": 6,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "التوازن في التغذية",
      "content": "تأكدي من تقديم وجبات تحتوي على الحبوب الكاملة والخضروات لدعم صحة الطفل.",
      "category": "Nutrition",
      "age_range": "24-60 months",
      "language": "ar",
      "source": "الأكاديمية الأمريكية لطب الأطفال",
      "priority": 5,
      "createdAt": FieldValue.serverTimestamp(),
    },
    {
      "title": "Balanced Nutrition",
      "content": "Ensure meals include whole grains and vegetables to support your child’s health.",
      "category": "Nutrition",
      "age_range": "24-60 months",
      "language": "en",
      "source": "American Academy of Pediatrics",
      "priority": 5,
      "createdAt": FieldValue.serverTimestamp(),
    },
  ];

  try {
    // ✅ التحقق إذا كان فيه نصائح موجودة مسبقًا
    final snapshot = await tipsCollection.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      print("⚠️ Health tips already exist. Skipping upload.");
      return;
    }

    // ✅ رفع النصائح
    for (var tip in healthTips) {
      await tipsCollection.add(tip);
    }

    print("✅ Health tips uploaded successfully to Firestore!");
  } catch (e) {
    print("❌ Error uploading health tips: $e");
  }
}