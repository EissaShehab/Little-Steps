// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<void> uploadHealthTips() async {
//   final firestore = FirebaseFirestore.instance;
//   final CollectionReference tipsCollection = firestore.collection('health_tips');

//   List<Map<String, dynamic>> healthTips = [
//     {
//       "title": "Exclusive Breastfeeding",
//       "content": "Breastfeeding is the best source of nutrition for infants up to 6 months. It strengthens immunity and protects against infections.",
//       "category": "Nutrition",
//       "age_range": "0-6 months",
//       "source": "Jordanian Ministry of Health",
//       "createdAt": FieldValue.serverTimestamp(),
//     },
//     {
//       "title": "Safe Sleep Practices",
//       "content": "Always place the baby on their back for sleep to reduce the risk of Sudden Infant Death Syndrome (SIDS).",
//       "category": "Sleep",
//       "age_range": "0-6 months",
//       "source": "Jordanian Ministry of Health",
//       "createdAt": FieldValue.serverTimestamp(),
//     },
//     {
//       "title": "Introducing Solid Foods",
//       "content": "Start introducing iron-rich foods like mashed vegetables, fruits, and rice cereal at six months.",
//       "category": "Nutrition",
//       "age_range": "6-12 months",
//       "source": "Jordanian Ministry of Health",
//       "createdAt": FieldValue.serverTimestamp(),
//     },
//     {
//       "title": "Early Childhood Vaccinations",
//       "content": "Follow the national vaccination schedule to ensure strong immunity against preventable diseases.",
//       "category": "Vaccination",
//       "age_range": "0-12 months",
//       "source": "Jordanian Ministry of Health",
//       "createdAt": FieldValue.serverTimestamp(),
//     },
//     {
//       "title": "Daily Physical Activity",
//       "content": "Encourage at least 60 minutes of active playtime daily to promote healthy physical development.",
//       "category": "Physical Activity",
//       "age_range": "3-5 years",
//       "source": "Jordanian Ministry of Health",
//       "createdAt": FieldValue.serverTimestamp(),
//     },
//     {
//       "title": "Oral Hygiene for Toddlers",
//       "content": "Start brushing with a soft toothbrush and fluoride toothpaste as soon as the first tooth appears.",
//       "category": "Oral Health",
//       "age_range": "1-2 years",
//       "source": "Jordanian Ministry of Health",
//       "createdAt": FieldValue.serverTimestamp(),
//     },
//     {
//       "title": "Screen Time Limitation",
//       "content": "Limit screen exposure to less than 1 hour per day for children under 5.",
//       "category": "Child Development",
//       "age_range": "3-5 years",
//       "source": "Jordanian Ministry of Health",
//       "createdAt": FieldValue.serverTimestamp(),
//     }
//   ];

//   try {
//     // ✅ Check if any tips already exist
//     final snapshot = await tipsCollection.limit(1).get();
//     if (snapshot.docs.isNotEmpty) {
//       print("⚠️ Health tips already exist. Skipping upload.");
//       return;
//     }

//     // ✅ Uploading Health Tips
//     for (var tip in healthTips) {
//       await tipsCollection.add(tip);
//     }

//     print("✅ Health tips uploaded successfully to Firestore!");
//   } catch (e) {
//     print("❌ Error uploading health tips: $e");
//   }
// }
