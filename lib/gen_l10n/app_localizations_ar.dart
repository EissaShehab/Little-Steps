// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get continueJourney => 'واصل متابعة صحة طفلك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get passwordMinLength => 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get passwordUppercase => 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';

  @override
  String get passwordLowercase => 'يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل';

  @override
  String get passwordNumber => 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';

  @override
  String get passwordSpecial => 'يجب أن تحتوي كلمة المرور على رمز خاص واحد على الأقل';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get newUser => 'مستخدم جديد؟';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get createAccountTitle => 'إنشاء حساب';

  @override
  String get startTracking => 'ابدأ في تتبع رحلة صحة طفلك';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get fullNameRequired => 'الاسم الكامل مطلوب';

  @override
  String get fullNameMinLength => 'يجب أن يكون الاسم مكونًا من حرفين على الأقل';

  @override
  String get alreadyHaveAccount => 'هل لديك حساب بالفعل؟';

  @override
  String get loginHere => 'تسجيل الدخول من هنا';

  @override
  String get register => 'تسجيل';

  @override
  String get splashTagline => 'تابع رحلة صحة طفلك';

  @override
  String get hello => 'مرحبًا';

  @override
  String get guest => 'ضيف';

  @override
  String get selectChild => 'اختر طفلًا';

  @override
  String get manageChildren => 'إدارة الأطفال';

  @override
  String get noChildrenRegistered => '⚠️ لا يوجد أطفال مسجلين. يرجى إضافة طفل.';

  @override
  String get monitorGrowth => 'راقب النمو';

  @override
  String get trackGrowthDescription => 'تابع معالم نمو طفلك بدقة وعناية.';

  @override
  String get ensureHealth => 'حافظ على الصحة';

  @override
  String get ensureHealthDescription => 'حافظ على صحة طفلك بالتطعيمات ونصائح صحية.';

  @override
  String get home => 'الرئيسية';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get growth => 'النمو';

  @override
  String get vaccines => 'التطعيمات';

  @override
  String get healthTips => 'نصائح صحية';

  @override
  String get nearestHospital => 'أقرب مستشفى';

  @override
  String healthTipsFor(Object name) {
    return 'نصائح صحية لـ $name';
  }

  @override
  String get healthRecords => 'السجلات الصحية';

  @override
  String healthRecordsFor(Object name) {
    return 'السجلات الصحية لـ $name';
  }

  @override
  String get contact => 'تواصل';

  @override
  String get noChildSelected => 'لم يتم اختيار طفل';

  @override
  String get selectChildBeforeFeature => 'يرجى اختيار طفل قبل الوصول إلى هذه الميزة.';

  @override
  String get ok => 'موافق';

  @override
  String get enterGrowthMeasurements => 'أدخل قياسات النمو';

  @override
  String errorLoadingWHOData(Object error) {
    return 'خطأ في تحميل بيانات WHO: $error';
  }

  @override
  String get measurementSavedSuccessfully => 'تم حفظ القياس بنجاح';

  @override
  String errorSavingMeasurement(Object error) {
    return 'خطأ في حفظ القياس: $error';
  }

  @override
  String get enterAgeManually => 'أدخل العمر يدويًا';

  @override
  String get ageMonths => 'العمر (بالأشهر)';

  @override
  String get weightKg => 'الوزن (كجم)';

  @override
  String get heightCm => 'الطول (سم)';

  @override
  String get latestMeasurement => 'أحدث قياس';

  @override
  String get justNow => 'الآن';

  @override
  String get date => 'التاريخ';

  @override
  String get aDayAgo => 'قبل يوم';

  @override
  String daysAgo(Object count) {
    return 'قبل $count أيام';
  }

  @override
  String get aWeekAgo => 'قبل أسبوع';

  @override
  String weeksAgo(Object count) {
    return 'قبل $count أسابيع';
  }

  @override
  String get aMonthAgo => 'قبل شهر';

  @override
  String monthsAgo(Object count) {
    return 'قبل $count شهور';
  }

  @override
  String get anHourAgo => 'قبل ساعة';

  @override
  String hoursAgo(Object count) {
    return 'قبل $count ساعات';
  }

  @override
  String get headCircumferenceCm => 'محيط الرأس (سم)';

  @override
  String get saveMeasurement => 'حفظ القياس';

  @override
  String get pleaseEnterAge => 'يرجى إدخال العمر';

  @override
  String get ageRangeError => 'يجب أن يكون العمر بين 0 و60 شهرًا';

  @override
  String pleaseEnterField(Object field) {
    return 'يرجى إدخال $field';
  }

  @override
  String fieldRangeError(Object field, Object min, Object max) {
    return 'يجب أن يكون $field بين $min و$max';
  }

  @override
  String get months => 'أشهر';

  @override
  String get kg => 'كجم';

  @override
  String get cm => 'سم';

  @override
  String get weight => 'الوزن';

  @override
  String get height => 'الطول';

  @override
  String get headCircumference => 'محيط الرأس';

  @override
  String get growthOverview => 'نظرة عامة على النمو';

  @override
  String get noMeasurements => 'لا توجد قياسات بعد. أضف واحدة للبدء.';

  @override
  String get addMeasurement => 'إضافة قياس';

  @override
  String get heightVsAge => 'الطول مقابل العمر (سم)';

  @override
  String get weightVsAge => 'الوزن مقابل العمر (كجم)';

  @override
  String get headVsAge => 'محيط الرأس مقابل العمر (سم)';

  @override
  String get status => 'الحالة';

  @override
  String get moreDetails => 'عرض المزيد';

  @override
  String get lessDetails => 'إخفاء التفاصيل';

  @override
  String get mandatoryLabel => 'إلزامي';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get conditions => 'الشروط';

  @override
  String get dailyTip => 'نصيحة يومية';

  @override
  String get source => 'المصدر';

  @override
  String get noRelevantTips => 'لا توجد نصائح ذات صلة حالياً.';

  @override
  String get noChildSelectedTips => 'لم يتم اختيار طفل. يرجى اختيار طفل من الشاشة الرئيسية.';

  @override
  String get noTipsInCategory => 'لا توجد نصائح متاحة لهذه الفئة.';

  @override
  String get allCategories => 'كل الفئات';

  @override
  String get nutrition => 'التغذية';

  @override
  String get vaccination => 'التطعيم';

  @override
  String get sleep => 'النوم';

  @override
  String get physicalActivity => 'النشاط البدني';

  @override
  String get oralHealth => 'صحة الفم';

  @override
  String get childDevelopment => 'نمو الطفل';

  @override
  String get contactAuthorities => 'تواصل مع الجهات المختصة';

  @override
  String get callNow => 'اتصل الآن';

  @override
  String get emailNow => 'أرسل بريدًا';

  @override
  String get phoneLabel => 'الهاتف';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String emailLaunchFailed(Object email) {
    return 'تعذر فتح تطبيق البريد. تم نسخ البريد الإلكتروني ($email) إلى الحافظة.';
  }

  @override
  String get noHealthRecords => 'لا توجد سجلات صحية بعد.\nاضغط على + لإضافة واحد!';

  @override
  String get attachment => 'مرفق';

  @override
  String get download => 'تحميل';

  @override
  String get delete => 'حذف';

  @override
  String get addHealthRecord => 'إضافة سجل صحي';

  @override
  String get titleExample => 'العنوان (مثال: تطعيم)';

  @override
  String get description => 'الوصف';

  @override
  String get noFileSelected => 'لم يتم اختيار ملف';

  @override
  String fileSelected(Object fileName) {
    return 'الملف: $fileName';
  }

  @override
  String get uploadFile => 'رفع ملف';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get pleaseFillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get fileSizeExceedsLimit => 'حجم الملف يتجاوز الحد الأقصى 10 ميجابايت';

  @override
  String get deleteRecord => 'حذف السجل';

  @override
  String get confirmDeleteRecord => 'هل أنت متأكد من حذف هذا السجل؟';

  @override
  String get downloadComplete => 'اكتمل التحميل';

  @override
  String get open => 'فتح';

  @override
  String errorDownloadingFile(Object error) {
    return 'خطأ أثناء التحميل: $error';
  }

  @override
  String get editChildProfile => 'تعديل ملف الطفل';

  @override
  String get childProfiles => 'ملفات الأطفال';

  @override
  String get noChildrenRegisteredYet => 'لا يوجد أطفال مسجلين بعد.';

  @override
  String get registeredChildren => 'الأطفال المسجلين';

  @override
  String get dismiss => 'إغلاق';

  @override
  String get deleteChild => 'حذف الطفل';

  @override
  String confirmDeleteChild(Object name) {
    return 'هل أنت متأكد من حذف $name؟';
  }

  @override
  String get removeChild => 'إزالة الطفل';

  @override
  String get confirmRemoveChild => 'هل أنت متأكد من إزالة هذا الطفل؟';

  @override
  String get remove => 'إزالة';

  @override
  String childIndex(Object index) {
    return 'الطفل $index';
  }

  @override
  String get imageSelectionFailed => 'فشل اختيار الصورة';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختيار من المعرض';

  @override
  String get addPhoto => 'إضافة صورة';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get enterChildName => 'أدخل اسم الطفل';

  @override
  String get nationalID => 'الرقم الوطني';

  @override
  String get enterChildNationalID => 'أدخل الرقم الوطني  للطفل';

  @override
  String get nationalIDRequired => 'الرقم القومي مطلوب';

  @override
  String get nationalIDLengthError => 'يجب أن يكون الرقم القومي مكونًا من 10 أرقام بالضبط';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get selectChildBirthDate => 'اختر تاريخ ميلاد الطفل';

  @override
  String get gender => 'الجنس';

  @override
  String get relationship => 'العلاقة';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get other => 'آخر';

  @override
  String get parent => 'والد';

  @override
  String get guardian => 'وصي';

  @override
  String fieldRequired(Object field) {
    return '$field مطلوب';
  }

  @override
  String get update => 'تحديث';

  @override
  String get saveAllProfiles => 'حفظ جميع الملفات';

  @override
  String get childProfileDeletedSuccessfully => 'تم حذف ملف الطفل بنجاح!';

  @override
  String failedToDeleteChild(Object error) {
    return 'فشل في حذف الطفل: $error';
  }

  @override
  String get childProfileUpdatedSuccessfully => 'تم تحديث ملف الطفل بنجاح!';

  @override
  String failedToUpdateProfile(Object error) {
    return 'فشل في تحديث الملف: $error';
  }

  @override
  String get pleaseLoginToSaveProfiles => 'يرجى تسجيل الدخول لحفظ الملفات.';

  @override
  String get childProfileSavedSuccessfully => 'تم حفظ ملف الطفل بنجاح!';

  @override
  String failedToSaveProfiles(Object error) {
    return 'فشل في حفظ الملفات: $error';
  }

  @override
  String get authenticationRequired => 'التسجيل مطلوب';

  @override
  String get pleaseFillAllRequiredFields => 'يرجى ملء جميع الحقول المطلوبة';

  @override
  String get pleaseSelectChild => 'يرجى اختيار طفل لعرض ملفه الشخصي.';

  @override
  String get noChildrenAddProfile => 'لا يوجد أطفال مسجلين. أضف ملف طفل.';

  @override
  String get notAvailable => 'غير متوفر';

  @override
  String get childID => 'المعرف';

  @override
  String get idCopiedToClipboard => 'تم نسخ المعرف إلى الحافظة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get language => 'اللغة';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get about => 'حول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirmMessage => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get loggingOut => 'جارٍ تسجيل الخروج...';

  @override
  String errorLoggingOut(Object error) {
    return 'خطأ أثناء تسجيل الخروج: $error';
  }

  @override
  String get aboutLittleSteps => 'حول LittleSteps';

  @override
  String get aboutContent => 'يهدف LittleSteps إلى رقمنة وتبسيط إدارة رحلة صحة طفلك، بما في ذلك تتبع النمو، التطعيمات، والنصائح الصحية. يحول إدخالات المستخدم إلى سجلات صحية منظمة بناءً على قوالب محددة مسبقًا لكل فئة صحية.';

  @override
  String get contactInformation => 'معلومات التواصل';

  @override
  String get websiteLabel => 'الموقع: github/EissaShehab';

  @override
  String get updateCredentials => 'تحديث بياناتك';

  @override
  String get secureAccountMessage => 'أمّن حسابك عن طريق تغيير كلمة المرور بانتظام.';

  @override
  String get currentPasswordLabel => 'كلمة المرور الحالية';

  @override
  String get newPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get pleaseEnterCurrentPassword => 'يرجى إدخال كلمة المرور الحالية';

  @override
  String get pleaseEnterNewPassword => 'يرجى إدخال كلمة المرور الجديدة';

  @override
  String get passwordMinLength6 => 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';

  @override
  String get pleaseConfirmPassword => 'يرجى تأكيد كلمة المرور الجديدة';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get passwordChangedSuccessfully => 'تم تغيير كلمة المرور بنجاح';

  @override
  String errorChangingPassword(Object error) {
    return 'خطأ أثناء تغيير كلمة المرور: $error';
  }

  @override
  String get privacyPolicyAgreement => 'بتغيير كلمة المرور، فإنك توافق على سياسة الخصوصية وشروط الاستخدام الخاصة بنا';

  @override
  String get privacyPolicyDetails => 'تفاصيل سياسة الخصوصية';

  @override
  String get privacyPolicyContent => 'هذا هو نص سياسة الخصوصية. هنا يمكنك توضيح الغرض، القواعد، واللوائح المتعلقة بجمع البيانات، تخزينها، واستخدامها في تطبيقك. تأكد أن النص واضح، موجز، ومفيد للمستخدمين لفهم حقوقهم وواجباتهم.';

  @override
  String get additionalInformation => 'معلومات إضافية';

  @override
  String get additionalInfoContent => 'هنا يمكنك إضافة معلومات إضافية، مثل الخدمات الخارجية المستخدمة، حقوق المستخدم، أو الخطوات التي يمكن للمستخدمين اتخاذها لإدارة بياناتهم داخل التطبيق.';

  @override
  String get acceptAndContinue => 'قبول ومتابعة';

  @override
  String get statusUpcoming => 'قادم';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusMissed => 'فائت';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get noNotifications => 'لا توجد إشعارات بعد.';

  @override
  String get notificationDeleted => 'تم حذف الإشعار';

  @override
  String get error => 'خطأ';

  @override
  String get markAsTaken => 'تم إعطاؤه';

  @override
  String get age => 'العمر';

  @override
  String get vaccinationSchedule => 'جدول المطاعيم';

  @override
  String get noVaccinationsFound => 'لا توجد مطاعيم متوفرة';

  @override
  String get emergencySection => 'حالات الطوارئ';

  @override
  String get nearestPharmacy => 'أقرب صيدلية';

  @override
  String get contactNurse => 'تواصل مع ممرضة';

  @override
  String get noPharmaciesFound => '🚫 لم يتم العثور على صيدليات قريبة حاليًا.';

  @override
  String pharmacyDistance(Object distance) {
    return 'المسافة: $distance كم';
  }

  @override
  String get childWeather => 'تنبيهات الطقس الذكية';

  @override
  String get refresh => 'تحديث';

  @override
  String get temperatureNow => 'درجة الحرارة الآن';

  @override
  String get weatherCondition => 'حالة الطقس';

  @override
  String get weatherClear => 'صحو';

  @override
  String get weatherPartlyCloudy => 'غائم جزئيًا';

  @override
  String get weatherFog => 'ضباب';

  @override
  String get weatherDrizzle => 'رذاذ';

  @override
  String get weatherRain => 'أمطار';

  @override
  String get weatherSnow => 'ثلوج';

  @override
  String get weatherThunder => 'عاصفة رعدية';

  @override
  String get weatherUnknown => 'طقس غير معروف';

  @override
  String get weatherAlertColdInfant => '❄️ الجو شديد البرودة، يُنصح بعدم إخراج الأطفال الرضع.';

  @override
  String get weatherAlertColdGeneral => '⚠️ الطقس بارد جدًا، تأكد من تدفئة طفلك جيدًا.';

  @override
  String get weatherAlertHotToddler => '🌡️ حرارة مرتفعة! تجنب تعريض طفلك الصغير للشمس المباشرة.';

  @override
  String get weatherAlertHotGeneral => '☀️ الطقس حار جدًا، تأكد من أن طفلك مرتاح ومرطّب.';

  @override
  String get weatherAlertWarmForInfant => '🔥 الجو دافئ جدًا وقد لا يُناسب الأطفال دون 6 شهور.';

  @override
  String get weatherFetchError => 'فشل في تحميل بيانات الطقس.';

  @override
  String get weatherNotification => 'تنبيه طقس';

  @override
  String get vaccineNotification => 'تذكير مطعوم';

  @override
  String get symptomsScreenTitle => '🩺 اختيار الأعراض';

  @override
  String get searchHint => 'ابحث عن عرض...';

  @override
  String get symptomNotFoundPrompt => '✨ عرض غير موجود؟ أضفه هنا:';

  @override
  String get addSymptomHint => 'اكتب عرض جديد...';

  @override
  String get analyzeSymptomsButton => 'تحليل الأعراض';

  @override
  String get selectSeverityTooltip => 'تحديد الشدة';

  @override
  String get selectChildFirstMessage => 'يرجى اختيار الطفل أولاً.';

  @override
  String analysisFailedMessage(Object error) {
    return 'فشل التحليل: $error';
  }

  @override
  String get severityLow => 'خفيف';

  @override
  String get severityMedium => 'متوسط';

  @override
  String get severityHigh => 'شديد';

  @override
  String get symptomCategoryGeneral => 'عام';

  @override
  String get symptomCategoryRespiratory => 'تنفسي';

  @override
  String get symptomCategoryENT => 'أنف وأذن وحنجرة';

  @override
  String get symptomCategoryDigestive => 'الجهاز الهضمي';

  @override
  String get symptomCategorySkin => 'الجلد';

  @override
  String get symptomCategoryOther => 'أخرى';

  @override
  String get symptomFever => 'حمى';

  @override
  String get symptomFatigue => 'تعب';

  @override
  String get symptomHeadache => 'صداع';

  @override
  String get symptomMildFever => 'حمى خفيفة';

  @override
  String get symptomCough => 'سعال';

  @override
  String get symptomDryCough => 'سعال جاف';

  @override
  String get symptomWheezing => 'صفير';

  @override
  String get symptomShortnessOfBreath => 'ضيق تنفس';

  @override
  String get symptomSoreThroat => 'التهاب حلق';

  @override
  String get symptomRunnyNose => 'سيلان أنف';

  @override
  String get symptomSneezing => 'عطاس';

  @override
  String get symptomEarPain => 'ألم أذن';

  @override
  String get symptomEarTugging => '';

  @override
  String get symptomNasalCongestion => 'احتقان الأنف';

  @override
  String get symptomRedThroat => 'احمرار الحلق';

  @override
  String get symptomVomiting => 'تقيؤ';

  @override
  String get symptomDiarrhea => 'إسهال';

  @override
  String get symptomLossOfAppetite => 'فقدان الشهية';

  @override
  String get symptomAbdominalCramps => 'تقلصات في البطن';

  @override
  String get symptomRedRash => 'طفح جلدي أحمر';

  @override
  String get symptomItchySkin => 'حكة في الجلد';

  @override
  String get symptomCrackedSkin => 'تشققات جلدية';

  @override
  String get symptomMouthSores => 'تقرحات الفم';

  @override
  String get symptomChestPain => 'ألم في الصدر';

  @override
  String get symptomBodyAches => 'آلام بالجسم';

  @override
  String get severityVeryHigh => 'شديد جدًا';

  @override
  String get predictionResultTitle => 'نتيجة التحليل';

  @override
  String get mostLikelyDisease => 'المرض الأكثر احتمالًا:';

  @override
  String get detailsTitle => 'تفاصيل النتائج:';

  @override
  String get disclaimerNote => '⚠ هذه النتائج مقدمة كمساعدة ولا تغني عن استشارة الطبيب المختص.';

  @override
  String get newAnalysis => 'تحليل جديد';

  @override
  String get diseaseAsthma => 'الربو';

  @override
  String get diseaseBronchiolitis => 'التهاب القصيبات الهوائية';

  @override
  String get diseaseBronchitis => 'التهاب الشعب الهوائية';

  @override
  String get diseaseChickenpox => 'الجدري المائي';

  @override
  String get diseaseCommonCold => 'نزلة برد';

  @override
  String get diseaseEczema => 'الأكزيما';

  @override
  String get diseaseFebrileSeizures => 'نوبات الحمى';

  @override
  String get diseaseFlu => 'الإنفلونزا';

  @override
  String get diseaseHeatStroke => 'ضربة شمس';

  @override
  String get diseaseOtitisMedia => 'التهاب الأذن الوسطى';

  @override
  String get diseasePneumonia => 'الالتهاب الرئوي';

  @override
  String get diseaseRSV => 'فيروس RSV';

  @override
  String get diseaseScarletFever => 'الحمى القرمزية';

  @override
  String get diseaseSinusInfection => 'التهاب الجيوب الأنفية';

  @override
  String get diseaseStomachFlu => 'أنفلونزا المعدة';

  @override
  String get diseaseTonsillitis => 'التهاب اللوزتين';

  @override
  String get diseaseViralSoreThroat => 'التهاب الحلق الفيروسي';

  @override
  String get diseaseViralSummerFever => 'حمى صيفية فيروسية';

  @override
  String get resultDetails => 'تفاصيل النتائج';

  @override
  String get resultDisclaimer => '⚠ هذه النتائج مقدمة كمساعدة ولا تغني عن استشارة الطبيب المختص.';

  @override
  String get symptomChills => 'قشعريرة';

  @override
  String get symptomConfusion => 'ارتباك';

  @override
  String get symptomDizziness => 'دوخة';

  @override
  String get symptomFainting => 'إغماء';

  @override
  String get symptomSweating => 'تعرق';

  @override
  String get symptomSuddenOnset => 'ظهور مفاجئ';

  @override
  String get symptomIrritability => 'سهولة التهيج';

  @override
  String get symptomChestTightness => 'ضيق في الصدر';

  @override
  String get symptomChestDiscomfort => 'انزعاج صدري';

  @override
  String get symptomDryRespiratoryPattern => 'نمط تنفسي جاف';

  @override
  String get symptomFacialPain => 'ألم في الوجه';

  @override
  String get symptomSinusPressure => 'ضغط الجيوب الأنفية';

  @override
  String get symptomStomachPain => 'ألم المعدة';

  @override
  String get symptomNausea => 'غثيان';

  @override
  String get symptomRedPatches => 'بقع حمراء';

  @override
  String get symptomSkinPeeling => 'تقشر الجلد';

  @override
  String get symptomConvulsions => 'تشنجات';

  @override
  String get symptomStiffNeck => 'تيبس الرقبة';

  @override
  String get symptomFebrilePattern => 'نمط حمى';

  @override
  String get symptomBluishSkin => 'ازرقاق الجلد';

  @override
  String get symptomBulgingFontanelle => 'انتفاخ اليافوخ';

  @override
  String get symptomAgeUnderTwo => 'العمر أقل من سنتين';

  @override
  String get symptomAllergyTrigger => 'مسبب تحسس';

  @override
  String get symptomHighFever => 'حمى شديدة';

  @override
  String get symptomHighBodyTemperature => 'ارتفاع درجة حرارة الجسم';

  @override
  String get symptomHeatStrokePattern => 'Heat Stroke Pattern';

  @override
  String get symptomRSVPattern => 'نمط عدوى RSV';

  @override
  String get symptomScarletFever => 'الحمى القرمزية';

  @override
  String get symptomThroatCluster => 'مجموعة أعراض الحلق';

  @override
  String get symptomStomachFlu => 'أنفلونزا المعدة';

  @override
  String get symptomCategoryNeurological => 'الأعصاب';

  @override
  String get symptomCategoryCardiac => 'القلب';

  @override
  String get zScoreSeverelyUnderweight => 'نقص حاد في الوزن';

  @override
  String get zScoreUnderweight => 'نقص في الوزن';

  @override
  String get zScoreNormalWeight => 'وزن طبيعي';

  @override
  String get zScoreOverweight => 'زيادة في الوزن';

  @override
  String get zScoreObese => 'سُمنة';

  @override
  String get zScoreSeverelyStunted => 'تأخر حاد في النمو';

  @override
  String get zScoreStunted => 'تأخر في النمو';

  @override
  String get zScoreNormalHeight => 'طول طبيعي';

  @override
  String get zScoreMicrocephaly => 'صغر الرأس';

  @override
  String get zScoreNormalHead => 'محيط رأس طبيعي';

  @override
  String get zScoreMacrocephaly => 'تضخم الرأس';

  @override
  String get zScoreNormalKeyword => 'طبيعي';

  @override
  String get zScoreMildKeyword => 'بسيط';

  @override
  String get chartLabelValue => 'القيمة';

  @override
  String get chartLabelAge => 'العمر';

  @override
  String get chartLabelStatus => 'الحالة';

  @override
  String percentileWeight(Object percentile) {
    return 'الوزن ضمن أعلى $percentile% من أقرانه';
  }

  @override
  String percentileHeight(Object percentile) {
    return 'الطول ضمن أعلى $percentile% من أقرانه';
  }

  @override
  String percentileHead(Object percentile) {
    return 'محيط الرأس ضمن أعلى $percentile% من أقرانه';
  }

  @override
  String get helpful => 'مفيد';

  @override
  String get notHelpful => 'غير مفيد';

  @override
  String get searchTips => 'ابحث في النصائح...';

  @override
  String get within => 'ضمن';

  @override
  String get tryAnotherSearch => 'جرب بحثًا آخر';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get noDailyTip => 'لا توجد نصيحة صحية متاحة لليوم.';

  @override
  String get thankYouFeedback => 'شكرًا لملاحظتك!';

  @override
  String get errorOccurred => 'حدث خطأ. الرجاء المحاولة لاحقًا.';

  @override
  String get unhelpful => 'غير مفيد';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get authorityRenadName => 'رناد العجارمة';

  @override
  String get authorityRenadSpecialty => 'أخصائية أطفال';

  @override
  String get authorityRenadHospital => 'مستشفى الاستقلال';

  @override
  String get authorityRahafName => 'رهف جديتاوي';

  @override
  String get authorityRahafSpecialty => 'ممرضة أطفال (المستوى الثاني)';

  @override
  String get authorityRahafHospital => 'مستشفى الاستقلال';

  @override
  String get authorityReefName => 'ريف المجالي';

  @override
  String get authorityReefSpecialty => 'ممرضة أطفال (المستوى الثالث)';

  @override
  String get authorityReefHospital => 'مستشفى الاستقلال';

  @override
  String get authorityLeenName => 'لين هندواي';

  @override
  String get authorityLeenSpecialty => 'ممرضة أطفال (المستوى الثالث)';

  @override
  String get authorityLeenHospital => 'مستشفى الاستقلال';

  @override
  String get authoritySajoudName => 'سجود الزعانة';

  @override
  String get authoritySajoudSpecialty => 'ممرضة أطفال (المستوى الثاني)';

  @override
  String get authoritySajoudHospital => 'مستشفى الاستقلال';

  @override
  String get birthDateCannotBeFuture => 'تاريخ الميلاد لا يمكن أن يكون في المستقبل';

  @override
  String get dateOfBirthRequired => 'تاريخ الميلاد مطلوب';

  @override
  String get birthDateMustBeWithinFiveYears => 'تاريخ الميلاد يجب أن يكون ضمن الخمس سنوات الأخيرة';

  @override
  String get nearestHospitalsTitle => 'أقرب مستشفى';

  @override
  String get locationRefreshTooltip => 'تحديث الموقع';

  @override
  String get locationErrorMessage => '⚠️ تعذر الحصول على الموقع. تأكد من تفعيل GPS.';

  @override
  String get locationLoading => 'جارٍ تحديد الموقع الحالي...';

  @override
  String currentLocationLabel(Object address) {
    return '📍 أنت الآن في: $address';
  }

  @override
  String get noHospitalsFound => '🚫 لم يتم العثور على مستشفيات قريبة حاليًا.';

  @override
  String hospitalDistance(Object distance) {
    return 'المسافة: $distance كم';
  }

  @override
  String get openInMaps => 'افتح في الخرائط';

  @override
  String get startNavigation => 'ابدأ التوجيه';

  @override
  String get openMapError => '❌ لا يمكن فتح تطبيق الخرائط.';

  @override
  String get startNavError => '❌ لا يمكن بدء التوجيه.';

  @override
  String get nearestPharmaciesTitle => 'أقرب صيدلية';

  @override
  String get deleteAll => 'حذف الكل';

  @override
  String get confirmDeleteAll => 'تأكيد الحذف الكلي';

  @override
  String get deleteAllNotificationsMessage => 'هل أنت متأكد من حذف جميع الإشعارات؟';

  @override
  String get allNotificationsDeleted => 'تم حذف جميع الإشعارات.';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String get deleteNotificationMessage => 'هل أنت متأكد من حذف هذا الإشعار؟';

  @override
  String get pleaseLogin => 'يرجى تسجيل الدخول لعرض الإشعارات.';

  @override
  String get noTitle => 'لا يوجد عنوان';

  @override
  String get unknownChild => 'طفل غير معروف';

  @override
  String get noContent => 'لا يوجد محتوى';

  @override
  String get symptoms => 'الطبيب الرقمي';

  @override
  String get duplicateNationalIdError => 'الرقم الوطني مستخدم لطفل آخر بالفعل.';

  @override
  String get deleteMeasurement => 'حذف القياس';

  @override
  String get confirmDeleteMeasurement => 'هل أنت متأكد أنك تريد حذف هذا القياس؟';

  @override
  String get measurementDeleted => 'تم حذف القياس بنجاح.';

  @override
  String errorDeletingMeasurement(Object error) {
    return 'حدث خطأ أثناء حذف القياس: $error';
  }

  @override
  String get undo => 'تراجع';

  @override
  String get pleaseLoginToExport => 'يرجى تسجيل الدخول لتصدير التقرير';

  @override
  String get growthReportExportedToHealthRecords => 'تم تصدير تقرير النمو إلى السجلات الصحية بنجاح';

  @override
  String errorExportingToHealthRecords(Object error) {
    return 'خطأ أثناء التصدير إلى السجلات الصحية: $error';
  }

  @override
  String get errorExportingToHealthRecords_error => 'رسالة الخطأ';

  @override
  String get exportToHealthRecords => 'تصدير إلى السجلات الصحية';

  @override
  String get symptom_analysis_report => 'تقرير تحليل الأعراض';

  @override
  String get child_name => 'اسم الطفل';

  @override
  String get likely_disease => 'المرض المحتمل';

  @override
  String get symptom_details => 'تفاصيل الأعراض';

  @override
  String get symptom => 'العرض';

  @override
  String get severity => 'الشدة';

  @override
  String get disease_probabilities => 'احتمالات الأمراض';

  @override
  String get disease => 'المرض';

  @override
  String get probability => 'الاحتمال';

  @override
  String get health_record_title => 'تحليل الأعراض';

  @override
  String get health_record_description => 'نتيجة التحليل بناءً على الأعراض محفوظة بصيغة PDF';

  @override
  String get file_name => 'symptom_report.pdf';

  @override
  String get severity_mild => 'خفيفة';

  @override
  String get severity_moderate => 'متوسطة';

  @override
  String get severity_severe => 'مرتفعة';

  @override
  String get severity_very_severe => 'مرتفعة جداً';

  @override
  String get severity_unknown => 'غير معروف';

  @override
  String get child => 'الطفل';

  @override
  String get recordDeleted => 'تم حذف السجل';

  @override
  String get recordAdded => 'تم إضافة السجل';

  @override
  String get locationPermissionDenied => 'تم رفض إذن الموقع. يرجى تفعيله لعرض حالة الطقس.';

  @override
  String get weightTooLow => 'الوزن منخفض بشكل غير طبيعي للعمر.';

  @override
  String get weightTooHigh => 'الوزن مرتفع بشكل غير طبيعي للعمر.';

  @override
  String get weightNormalRange => 'الوزن ضمن النطاق الطبيعي.';

  @override
  String get heightTooLow => 'الطول أقل من الطبيعي للعمر.';

  @override
  String get heightNormalRange => 'الطول ضمن النطاق الطبيعي.';

  @override
  String get headTooSmall => 'محيط الرأس صغير بشكل غير طبيعي.';

  @override
  String get headTooLarge => 'محيط الرأس كبير بشكل غير طبيعي.';

  @override
  String get headNormalRange => 'محيط الرأس ضمن النطاق الطبيعي.';

  @override
  String get valueNormalRange => 'القيمة ضمن النطاق الطبيعي.';

  @override
  String get invalidMeasurementOutlier => 'القيمة المدخلة غير منطقية وقد تكون خاطئة. يرجى التأكد من قياسات الطفل.';

  @override
  String get symptomSevereFatigue => 'تعب شديد';

  @override
  String get symptomDifficultySwallowing => 'صعوبة في البلع';

  @override
  String get symptomSwollenTongue => 'تورم اللسان';

  @override
  String get symptomSwollenTonsils => 'تورم اللوزتين';

  @override
  String get symptomDrySkin => 'جفاف الجلد';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get selectChildFirst => 'اختر الطفل أولاً';

  @override
  String get minSymptomsWarning => 'الرجاء اختيار 4 أعراض على الأقل.';

  @override
  String get maxSymptomsWarning => 'يمكنك اختيار 10 أعراض كحد أقصى فقط.';

  @override
  String get nameTooShort => 'الاسم يجب أن يتكون من 4 أحرف على الأقل';

  @override
  String get nameTooLong => 'الاسم لا يمكن أن يتجاوز 30 حرفًا';

  @override
  String get invalidNameCharacters => 'الاسم يمكن أن يحتوي فقط على أحرف عربية أو إنجليزية، مسافات، أو واصلة';

  @override
  String get residenceID => 'رقم الإقامة';

  @override
  String get identifierType => 'نوع المعرّف';

  @override
  String get enterChildResidenceID => 'أدخل رقم إقامة الطفل';

  @override
  String get identifierLengthError => 'يجب أن يكون المعرّف مكونًا من 10 أرقام';
}
