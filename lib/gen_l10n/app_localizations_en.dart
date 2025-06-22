// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get continueJourney => 'Continue your child\'s health journey';

  @override
  String get email => 'Email';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get passwordUppercase => 'Password must contain at least one uppercase letter';

  @override
  String get passwordLowercase => 'Password must contain at least one lowercase letter';

  @override
  String get passwordNumber => 'Password must contain at least one number';

  @override
  String get passwordSpecial => 'Password must contain at least one special character';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get newUser => 'New user?';

  @override
  String get createAccount => 'Create account';

  @override
  String get login => 'Login';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get startTracking => 'Start tracking your child\'s health journey';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameRequired => 'Full Name is required';

  @override
  String get fullNameMinLength => 'Name must be at least 2 characters';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get loginHere => 'Login here';

  @override
  String get register => 'Register';

  @override
  String get splashTagline => 'Track your child\'s health journey';

  @override
  String get hello => 'Hello';

  @override
  String get guest => 'Guest';

  @override
  String get selectChild => 'Select a Child';

  @override
  String get manageChildren => 'Manage Children';

  @override
  String get noChildrenRegistered => '⚠️ No children registered. Please add a child.';

  @override
  String get monitorGrowth => 'Monitor Growth';

  @override
  String get trackGrowthDescription => 'Track your child’s growth milestones with precision and care.';

  @override
  String get ensureHealth => 'Ensure Health';

  @override
  String get ensureHealthDescription => 'Keep your child healthy with vaccinations and health tips.';

  @override
  String get home => 'Home';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get growth => 'Growth';

  @override
  String get vaccines => 'Vaccines';

  @override
  String get healthTips => 'Health Tips';

  @override
  String get nearestHospital => 'Nearest Hospital';

  @override
  String healthTipsFor(Object name) {
    return 'Health Tips for $name';
  }

  @override
  String get healthRecords => 'Health Records';

  @override
  String healthRecordsFor(Object name) {
    return 'Health Records for $name';
  }

  @override
  String get contact => 'Contact';

  @override
  String get noChildSelected => 'No Child Selected';

  @override
  String get selectChildBeforeFeature => 'Please select a child before accessing this feature.';

  @override
  String get ok => 'OK';

  @override
  String get enterGrowthMeasurements => 'Enter Growth Measurements';

  @override
  String errorLoadingWHOData(Object error) {
    return 'Error loading WHO data: $error';
  }

  @override
  String get measurementSavedSuccessfully => 'Measurement saved successfully';

  @override
  String errorSavingMeasurement(Object error) {
    return 'Error saving measurement: $error';
  }

  @override
  String get enterAgeManually => 'Enter Age Manually';

  @override
  String get ageMonths => 'Age (months)';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get latestMeasurement => 'Latest Measurement';

  @override
  String get justNow => 'Just now';

  @override
  String get date => 'Date';

  @override
  String get aDayAgo => '1 day ago';

  @override
  String daysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String get aWeekAgo => '1 week ago';

  @override
  String weeksAgo(Object count) {
    return '$count weeks ago';
  }

  @override
  String get aMonthAgo => '1 month ago';

  @override
  String monthsAgo(Object count) {
    return '$count months ago';
  }

  @override
  String get anHourAgo => '1 hour ago';

  @override
  String hoursAgo(Object count) {
    return '$count hours ago';
  }

  @override
  String get headCircumferenceCm => 'Head Circumference (cm)';

  @override
  String get saveMeasurement => 'Save Measurement';

  @override
  String get pleaseEnterAge => 'Please enter age';

  @override
  String get ageRangeError => 'Age must be between 0 and 60 months';

  @override
  String pleaseEnterField(Object field) {
    return '$field is required';
  }

  @override
  String fieldRangeError(Object field, Object min, Object max) {
    return '$field must be between $min and $max';
  }

  @override
  String get months => 'months';

  @override
  String get kg => 'kg';

  @override
  String get cm => 'cm';

  @override
  String get weight => 'Weight';

  @override
  String get height => 'Height';

  @override
  String get headCircumference => 'Head Circumference';

  @override
  String get growthOverview => 'Growth Overview';

  @override
  String get noMeasurements => 'No measurements yet. Add one to begin.';

  @override
  String get addMeasurement => 'Add Measurement';

  @override
  String get heightVsAge => 'Height vs Age (cm)';

  @override
  String get weightVsAge => 'Weight vs Age (kg)';

  @override
  String get headVsAge => 'Head Circumference vs Age (cm)';

  @override
  String get status => 'Status';

  @override
  String get moreDetails => 'More Details';

  @override
  String get lessDetails => 'Less Details';

  @override
  String get mandatoryLabel => 'Mandatory';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get conditions => 'Conditions';

  @override
  String get dailyTip => 'Daily Tip';

  @override
  String get source => 'Source';

  @override
  String get noRelevantTips => 'No relevant tips available.';

  @override
  String get noChildSelectedTips => 'No child selected. Please select a child from the home screen.';

  @override
  String get noTipsInCategory => 'No tips available for this category.';

  @override
  String get allCategories => 'All Categories';

  @override
  String get nutrition => 'Nutrition';

  @override
  String get vaccination => 'Vaccination';

  @override
  String get sleep => 'Sleep';

  @override
  String get physicalActivity => 'Physical Activity';

  @override
  String get oralHealth => 'Oral Health';

  @override
  String get childDevelopment => 'Child Development';

  @override
  String get contactAuthorities => 'Contact Authorities';

  @override
  String get callNow => 'Call Now';

  @override
  String get emailNow => 'Email Now';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get emailLabel => 'Email';

  @override
  String emailLaunchFailed(Object email) {
    return 'Unable to open email app. The email address ($email) has been copied to your clipboard.';
  }

  @override
  String get noHealthRecords => 'No health records yet.\nTap + to add one!';

  @override
  String get attachment => 'Attachment';

  @override
  String get download => 'Download';

  @override
  String get delete => 'Delete';

  @override
  String get addHealthRecord => 'Add Health Record';

  @override
  String get titleExample => 'Title (e.g., Vaccination)';

  @override
  String get description => 'Description';

  @override
  String get noFileSelected => 'No file selected';

  @override
  String fileSelected(Object fileName) {
    return 'File: $fileName';
  }

  @override
  String get uploadFile => 'Upload File';

  @override
  String get selectDate => 'Select Date';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get pleaseFillAllFields => 'Please fill in all fields';

  @override
  String get fileSizeExceedsLimit => 'File size exceeds 10MB limit';

  @override
  String get deleteRecord => 'Delete Record';

  @override
  String get confirmDeleteRecord => 'Are you sure you want to delete this record?';

  @override
  String get downloadComplete => 'Download complete';

  @override
  String get open => 'Open';

  @override
  String errorDownloadingFile(Object error) {
    return 'Error downloading file: $error';
  }

  @override
  String get editChildProfile => 'Edit Child Profile';

  @override
  String get childProfiles => 'Child Profiles';

  @override
  String get noChildrenRegisteredYet => 'No children registered yet.';

  @override
  String get registeredChildren => 'Registered Children';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get deleteChild => 'Delete Child';

  @override
  String confirmDeleteChild(Object name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get removeChild => 'Remove Child';

  @override
  String get confirmRemoveChild => 'Are you sure you want to remove this child?';

  @override
  String get remove => 'Remove';

  @override
  String childIndex(Object index) {
    return 'Child $index';
  }

  @override
  String get imageSelectionFailed => 'Image selection failed';

  @override
  String get takePhoto => 'Take a Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get enterChildName => 'Enter child\'s name';

  @override
  String get nationalID => 'National ID';

  @override
  String get enterChildNationalID => 'Enter child\'s national ID';

  @override
  String get nationalIDRequired => 'National ID is required';

  @override
  String get nationalIDLengthError => 'National ID must be exactly 10 digits';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get selectChildBirthDate => 'Select child\'s birth date';

  @override
  String get gender => 'Gender';

  @override
  String get relationship => 'Relationship';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get parent => 'Parent';

  @override
  String get guardian => 'Guardian';

  @override
  String fieldRequired(Object field) {
    return '$field is required';
  }

  @override
  String get update => 'Update';

  @override
  String get saveAllProfiles => 'Save All Profiles';

  @override
  String get childProfileDeletedSuccessfully => 'Child profile deleted successfully!';

  @override
  String failedToDeleteChild(Object error) {
    return 'Failed to delete child: $error';
  }

  @override
  String get childProfileUpdatedSuccessfully => 'Child profile updated successfully!';

  @override
  String failedToUpdateProfile(Object error) {
    return 'Failed to update profile: $error';
  }

  @override
  String get pleaseLoginToSaveProfiles => 'Please log in to save profiles.';

  @override
  String get childProfileSavedSuccessfully => 'Child profile saved successfully!';

  @override
  String failedToSaveProfiles(Object error) {
    return 'Failed to save profiles: $error';
  }

  @override
  String get authenticationRequired => 'Authentication required';

  @override
  String get pleaseFillAllRequiredFields => 'Please fill all required fields';

  @override
  String get pleaseSelectChild => 'Please select a child to view their profile.';

  @override
  String get noChildrenAddProfile => 'No children registered. Add a child profile.';

  @override
  String get notAvailable => 'N/A';

  @override
  String get childID => 'ID';

  @override
  String get idCopiedToClipboard => 'ID copied to clipboard';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get changePassword => 'Change Password';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get about => 'About';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Log Out';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get loggingOut => 'Logging out...';

  @override
  String errorLoggingOut(Object error) {
    return 'Error logging out: $error';
  }

  @override
  String get aboutLittleSteps => 'About LittleSteps';

  @override
  String get aboutContent => 'LittleSteps aims to digitize and simplify the management of your child\'s health journey, including growth tracking, vaccinations, and health tips. It transforms user inputs into organized health records based on predefined templates for each health category.';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get websiteLabel => 'Website: github/EissaShehab';

  @override
  String get updateCredentials => 'Update Your Credentials';

  @override
  String get secureAccountMessage => 'Secure your account by changing your password regularly.';

  @override
  String get currentPasswordLabel => 'Current Password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get pleaseEnterCurrentPassword => 'Please enter your current password';

  @override
  String get pleaseEnterNewPassword => 'Please enter a new password';

  @override
  String get passwordMinLength6 => 'Password must be at least 6 characters';

  @override
  String get pleaseConfirmPassword => 'Please confirm your new password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String errorChangingPassword(Object error) {
    return 'Error changing password: $error';
  }

  @override
  String get privacyPolicyAgreement => 'By changing your password, you agree to our Privacy Policy and Terms of Use';

  @override
  String get privacyPolicyDetails => 'Privacy Policy Details';

  @override
  String get privacyPolicyContent => 'This is the body of the privacy policy. Here you can outline the purpose, rules, and regulations regarding data collection, storage, and usage in your app. Ensure the text is clear, concise, and informative for users to understand their rights and obligations.';

  @override
  String get additionalInformation => 'Additional Information';

  @override
  String get additionalInfoContent => 'Here you can add additional information, such as third-party services used, user rights, or steps users can take to manage their data within the app.';

  @override
  String get acceptAndContinue => 'Accept and Continue';

  @override
  String get statusUpcoming => 'UPCOMING';

  @override
  String get statusCompleted => 'COMPLETED';

  @override
  String get statusMissed => 'MISSED';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet.';

  @override
  String get notificationDeleted => 'Notification deleted';

  @override
  String get error => 'Error';

  @override
  String get markAsTaken => 'Mark as Taken';

  @override
  String get age => 'Age';

  @override
  String get vaccinationSchedule => 'Vaccination Schedule';

  @override
  String get noVaccinationsFound => 'No vaccinations found';

  @override
  String get emergencySection => 'Emergency Cases';

  @override
  String get nearestPharmacy => 'Nearest Pharmacy';

  @override
  String get contactNurse => 'Contact Nurse';

  @override
  String get noPharmaciesFound => '🚫 No nearby pharmacies found.';

  @override
  String pharmacyDistance(Object distance) {
    return 'Distance: $distance km';
  }

  @override
  String get childWeather => 'SmartWeatherAlerts';

  @override
  String get refresh => 'Refresh';

  @override
  String get temperatureNow => 'Temperature Now';

  @override
  String get weatherCondition => 'Weather Condition';

  @override
  String get weatherClear => 'Clear';

  @override
  String get weatherPartlyCloudy => 'Partly Cloudy';

  @override
  String get weatherFog => 'Foggy';

  @override
  String get weatherDrizzle => 'Drizzle';

  @override
  String get weatherRain => 'Rain';

  @override
  String get weatherSnow => 'Snow';

  @override
  String get weatherThunder => 'Thunderstorm';

  @override
  String get weatherUnknown => 'Unknown';

  @override
  String get weatherAlertColdInfant => 'Severe cold  keep infants indoors.';

  @override
  String get weatherAlertColdGeneral => 'Very cold  dress your child warmly.';

  @override
  String get weatherAlertHotToddler => 'Hot weather  keep toddlers hydrated and avoid sun.';

  @override
  String get weatherAlertHotGeneral => 'High heat make sure your child is comfortable.';

  @override
  String get weatherAlertWarmForInfant => 'Warm weather might be unsuitable for infants.';

  @override
  String get weatherFetchError => 'Failed to fetch weather data.';

  @override
  String get weatherNotification => 'Weather Alert';

  @override
  String get vaccineNotification => 'Vaccination Reminder';

  @override
  String get symptomsScreenTitle => '🩺 Select Symptoms';

  @override
  String get searchHint => 'Search for a symptom...';

  @override
  String get symptomNotFoundPrompt => '✨ Symptom not found? Add it here:';

  @override
  String get addSymptomHint => 'Enter a new symptom...';

  @override
  String get analyzeSymptomsButton => 'Analyze Symptoms';

  @override
  String get selectSeverityTooltip => 'Select Severity';

  @override
  String get selectChildFirstMessage => 'Please select a child first.';

  @override
  String analysisFailedMessage(Object error) {
    return 'Failed to analyze: $error';
  }

  @override
  String get severityLow => 'Mild';

  @override
  String get severityMedium => 'Moderate';

  @override
  String get severityHigh => 'Severe';

  @override
  String get symptomCategoryGeneral => 'General';

  @override
  String get symptomCategoryRespiratory => 'Respiratory';

  @override
  String get symptomCategoryENT => 'ENT';

  @override
  String get symptomCategoryDigestive => 'Digestive';

  @override
  String get symptomCategorySkin => 'Skin';

  @override
  String get symptomCategoryOther => 'Other';

  @override
  String get symptomFever => 'Fever';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get symptomHeadache => 'Headache';

  @override
  String get symptomMildFever => 'Mild Fever';

  @override
  String get symptomCough => 'Cough';

  @override
  String get symptomDryCough => 'Dry Cough';

  @override
  String get symptomWheezing => 'Wheezing';

  @override
  String get symptomShortnessOfBreath => 'Shortness of Breath';

  @override
  String get symptomSoreThroat => 'Sore Throat';

  @override
  String get symptomRunnyNose => 'Runny Nose';

  @override
  String get symptomSneezing => 'Sneezing';

  @override
  String get symptomEarPain => 'Ear Pain';

  @override
  String get symptomEarTugging => 'Ear Tugging';

  @override
  String get symptomNasalCongestion => 'Nasal Congestion';

  @override
  String get symptomRedThroat => 'Red Throat';

  @override
  String get symptomVomiting => 'Vomiting';

  @override
  String get symptomDiarrhea => 'Diarrhea';

  @override
  String get symptomLossOfAppetite => 'Loss of Appetite';

  @override
  String get symptomAbdominalCramps => 'Abdominal Cramps';

  @override
  String get symptomRedRash => 'Red Rash';

  @override
  String get symptomItchySkin => 'Itchy Skin';

  @override
  String get symptomCrackedSkin => 'Cracked Skin';

  @override
  String get symptomMouthSores => 'Mouth Sores';

  @override
  String get symptomChestPain => 'Chest Pain';

  @override
  String get symptomBodyAches => 'Body Aches';

  @override
  String get severityVeryHigh => 'Very Severe';

  @override
  String get predictionResultTitle => 'Prediction Result';

  @override
  String get mostLikelyDisease => 'Most likely disease:';

  @override
  String get detailsTitle => 'Result Details:';

  @override
  String get disclaimerNote => '⚠ These results are for assistance only and do not replace a professional medical consultation.';

  @override
  String get newAnalysis => 'New Analysis';

  @override
  String get diseaseAsthma => 'Asthma';

  @override
  String get diseaseBronchiolitis => 'Bronchiolitis';

  @override
  String get diseaseBronchitis => 'Bronchitis';

  @override
  String get diseaseChickenpox => 'Chickenpox';

  @override
  String get diseaseCommonCold => 'Common Cold';

  @override
  String get diseaseEczema => 'Eczema';

  @override
  String get diseaseFebrileSeizures => 'Febrile Seizures';

  @override
  String get diseaseFlu => 'Flu';

  @override
  String get diseaseHeatStroke => 'Heat Stroke';

  @override
  String get diseaseOtitisMedia => 'Ear Infection';

  @override
  String get diseasePneumonia => 'Pneumonia';

  @override
  String get diseaseRSV => 'RSV (Respiratory Syncytial Virus)';

  @override
  String get diseaseScarletFever => 'Scarlet Fever';

  @override
  String get diseaseSinusInfection => 'Sinus Infection';

  @override
  String get diseaseStomachFlu => 'Stomach Flu';

  @override
  String get diseaseTonsillitis => 'Tonsillitis';

  @override
  String get diseaseViralSoreThroat => 'Viral Sore Throat';

  @override
  String get diseaseViralSummerFever => 'Viral Summer Fever';

  @override
  String get resultDetails => 'Result Details';

  @override
  String get resultDisclaimer => '⚠ These results are for informational purposes only and do not replace a professional medical diagnosis.';

  @override
  String get symptomChills => 'Chills';

  @override
  String get symptomConfusion => 'Confusion';

  @override
  String get symptomDizziness => 'Dizziness';

  @override
  String get symptomFainting => 'Fainting';

  @override
  String get symptomSweating => 'Sweating';

  @override
  String get symptomSuddenOnset => 'Sudden Onset';

  @override
  String get symptomIrritability => 'Irritability';

  @override
  String get symptomChestTightness => 'Chest Tightness';

  @override
  String get symptomChestDiscomfort => 'Chest Discomfort';

  @override
  String get symptomDryRespiratoryPattern => 'Dry Respiratory Pattern';

  @override
  String get symptomFacialPain => 'Facial Pain';

  @override
  String get symptomSinusPressure => 'Sinus Pressure';

  @override
  String get symptomStomachPain => 'Stomach Pain';

  @override
  String get symptomNausea => 'Nausea';

  @override
  String get symptomRedPatches => 'Red Patches';

  @override
  String get symptomSkinPeeling => 'Skin Peeling';

  @override
  String get symptomConvulsions => 'Convulsions';

  @override
  String get symptomStiffNeck => 'Stiff Neck';

  @override
  String get symptomFebrilePattern => 'Febrile Pattern';

  @override
  String get symptomBluishSkin => 'Bluish Skin';

  @override
  String get symptomBulgingFontanelle => 'Bulging Fontanelle';

  @override
  String get symptomAgeUnderTwo => 'Age under 2 years';

  @override
  String get symptomAllergyTrigger => 'Allergy Trigger';

  @override
  String get symptomHighFever => 'High Fever';

  @override
  String get symptomHighBodyTemperature => 'High Body Temperature';

  @override
  String get symptomHeatStrokePattern => 'Heat Stroke Pattern';

  @override
  String get symptomRSVPattern => 'RSV Pattern';

  @override
  String get symptomScarletFever => 'Scarlet Fever';

  @override
  String get symptomThroatCluster => 'Throat Cluster';

  @override
  String get symptomStomachFlu => 'Stomach Flu';

  @override
  String get symptomCategoryNeurological => 'Neurological';

  @override
  String get symptomCategoryCardiac => 'Cardiac';

  @override
  String get zScoreSeverelyUnderweight => 'Severely underweight';

  @override
  String get zScoreUnderweight => 'Underweight';

  @override
  String get zScoreNormalWeight => 'Normal weight';

  @override
  String get zScoreOverweight => 'Overweight';

  @override
  String get zScoreObese => 'Obese';

  @override
  String get zScoreSeverelyStunted => 'Severely stunted';

  @override
  String get zScoreStunted => 'Stunted';

  @override
  String get zScoreNormalHeight => 'Normal height';

  @override
  String get zScoreMicrocephaly => 'Microcephaly';

  @override
  String get zScoreNormalHead => 'Normal head size';

  @override
  String get zScoreMacrocephaly => 'Macrocephaly';

  @override
  String get zScoreNormalKeyword => 'Normal';

  @override
  String get zScoreMildKeyword => 'Mild';

  @override
  String get chartLabelValue => 'Value';

  @override
  String get chartLabelAge => 'Age';

  @override
  String get chartLabelStatus => 'Status';

  @override
  String percentileWeight(Object percentile) {
    return 'Weight is in the top $percentile% of peers';
  }

  @override
  String percentileHeight(Object percentile) {
    return 'Height is in the top $percentile% of peers';
  }

  @override
  String percentileHead(Object percentile) {
    return 'Head size is in the top $percentile% of peers';
  }

  @override
  String get helpful => 'Helpful';

  @override
  String get notHelpful => 'Not Helpful';

  @override
  String get searchTips => 'Search tips...';

  @override
  String get within => 'within';

  @override
  String get tryAnotherSearch => 'Try another search';

  @override
  String get reset => 'Reset';

  @override
  String get noDailyTip => 'No health tip available for today.';

  @override
  String get thankYouFeedback => 'Thank you for your feedback!';

  @override
  String get errorOccurred => 'An error occurred. Please try again later.';

  @override
  String get unhelpful => 'Not Helpful';

  @override
  String get retry => 'Retry';

  @override
  String get authorityRenadName => 'Ranad Ajarmeh';

  @override
  String get authorityRenadSpecialty => 'Pediatric Specialist';

  @override
  String get authorityRenadHospital => 'Istiklal Hospital';

  @override
  String get authorityRahafName => 'Rahaf Jaditawi';

  @override
  String get authorityRahafSpecialty => 'Pediatric Nurse (RN2)';

  @override
  String get authorityRahafHospital => 'Istiklal Hospital';

  @override
  String get authorityReefName => 'Reef Al Majali';

  @override
  String get authorityReefSpecialty => 'Pediatric Nurse (RN3)';

  @override
  String get authorityReefHospital => 'Istiklal Hospital';

  @override
  String get authorityLeenName => 'Leen Hendawy';

  @override
  String get authorityLeenSpecialty => 'Pediatric Nurse (RN3)';

  @override
  String get authorityLeenHospital => 'Istiklal Hospital';

  @override
  String get authoritySajoudName => 'Sajoud Zawaneh';

  @override
  String get authoritySajoudSpecialty => 'Pediatric Nurse (RN2)';

  @override
  String get authoritySajoudHospital => 'Istiklal Hospital';

  @override
  String get birthDateCannotBeFuture => 'Birth date cannot be in the future';

  @override
  String get dateOfBirthRequired => 'Date of birth is required';

  @override
  String get birthDateMustBeWithinFiveYears => 'Birth date must be within the last 5 years';

  @override
  String get nearestHospitalsTitle => 'Nearest Hospital';

  @override
  String get locationRefreshTooltip => 'Refresh Location';

  @override
  String get locationErrorMessage => '⚠️ Failed to get location. Make sure GPS is enabled.';

  @override
  String get locationLoading => 'Getting current location...';

  @override
  String currentLocationLabel(Object address) {
    return '📍 You are currently in: $address';
  }

  @override
  String get noHospitalsFound => '🚫 No nearby hospitals found.';

  @override
  String hospitalDistance(Object distance) {
    return 'Distance: $distance km';
  }

  @override
  String get openInMaps => 'Open in Maps';

  @override
  String get startNavigation => 'Start Navigation';

  @override
  String get openMapError => '❌ Unable to open Maps application.';

  @override
  String get startNavError => '❌ Unable to start navigation.';

  @override
  String get nearestPharmaciesTitle => 'Nearest Pharmacy';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get confirmDeleteAll => 'Confirm Delete All';

  @override
  String get deleteAllNotificationsMessage => 'Are you sure you want to delete all notifications?';

  @override
  String get allNotificationsDeleted => 'All notifications have been deleted.';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleteNotificationMessage => 'Are you sure you want to delete this notification?';

  @override
  String get pleaseLogin => 'Please log in to view notifications.';

  @override
  String get noTitle => 'No Title';

  @override
  String get unknownChild => 'Unknown Child';

  @override
  String get noContent => 'No Content';

  @override
  String get symptoms => 'Digital Doctor';

  @override
  String get duplicateNationalIdError => 'This national ID is already used by another child.';

  @override
  String get deleteMeasurement => 'Delete Measurement';

  @override
  String get confirmDeleteMeasurement => 'Are you sure you want to delete this measurement?';

  @override
  String get measurementDeleted => 'Measurement deleted successfully.';

  @override
  String errorDeletingMeasurement(Object error) {
    return 'Error deleting measurement: $error';
  }

  @override
  String get undo => 'Undo';

  @override
  String get pleaseLoginToExport => 'Please log in to export the report';

  @override
  String get growthReportExportedToHealthRecords => 'Growth report exported to health records successfully';

  @override
  String errorExportingToHealthRecords(Object error) {
    return 'Error exporting to health records: $error';
  }

  @override
  String get errorExportingToHealthRecords_error => 'The error message';

  @override
  String get exportToHealthRecords => 'Export to Health Records';

  @override
  String get symptom_analysis_report => 'Symptom Analysis Report';

  @override
  String get child_name => 'Child Name';

  @override
  String get likely_disease => 'Likely Disease';

  @override
  String get symptom_details => 'Symptom Details';

  @override
  String get symptom => 'Symptom';

  @override
  String get severity => 'Severity';

  @override
  String get disease_probabilities => 'Disease Probabilities';

  @override
  String get disease => 'Disease';

  @override
  String get probability => 'Probability';

  @override
  String get health_record_title => 'Symptom Analysis';

  @override
  String get health_record_description => 'Analysis results based on symptoms saved as PDF';

  @override
  String get file_name => 'symptom_report.pdf';

  @override
  String get severity_mild => 'Mild';

  @override
  String get severity_moderate => 'Moderate';

  @override
  String get severity_severe => 'Severe';

  @override
  String get severity_very_severe => 'Very Severe';

  @override
  String get severity_unknown => 'Unknown';

  @override
  String get child => 'child';

  @override
  String get recordDeleted => 'Record deleted';

  @override
  String get recordAdded => 'Record added';

  @override
  String get locationPermissionDenied => 'Location permission denied. Please enable it to view the weather.';

  @override
  String get weightTooLow => 'Weight is unusually low for age.';

  @override
  String get weightTooHigh => 'Weight is unusually high for age.';

  @override
  String get weightNormalRange => 'Weight is within normal range.';

  @override
  String get heightTooLow => 'Height is unusually short for age.';

  @override
  String get heightNormalRange => 'Height is within normal range.';

  @override
  String get headTooSmall => 'Head size is unusually small.';

  @override
  String get headTooLarge => 'Head size is unusually large.';

  @override
  String get headNormalRange => 'Head size is within normal range.';

  @override
  String get valueNormalRange => 'Measurement is within normal range.';

  @override
  String get invalidMeasurementOutlier => 'The value entered is too extreme and may be incorrect. Please verify the child\'s measurements.';

  @override
  String get symptomSevereFatigue => 'Severe Fatigue';

  @override
  String get symptomDifficultySwallowing => 'Difficulty Swallowing';

  @override
  String get symptomSwollenTongue => 'Swollen Tongue';

  @override
  String get symptomSwollenTonsils => 'Swollen Tonsils';

  @override
  String get symptomDrySkin => 'Dry Skin';

  @override
  String get loading => 'Loading...';

  @override
  String get selectChildFirst => 'selectChildFirst';

  @override
  String get minSymptomsWarning => 'Please select at least 4 symptoms.';

  @override
  String get maxSymptomsWarning => 'You can select up to 10 symptoms only.';

  @override
  String get nameTooShort => 'Name must be at least 4 characters long';

  @override
  String get nameTooLong => 'Name cannot exceed 30 characters';

  @override
  String get invalidNameCharacters => 'Name can only contain Arabic or English letters, spaces, or hyphens';

  @override
  String get residenceID => 'Residence ID';

  @override
  String get identifierType => 'Identifier Type';

  @override
  String get enterChildResidenceID => 'Enter child\'s Residence ID';

  @override
  String get identifierLengthError => 'Identifier must be exactly 10 digits';
}
