import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @continueJourney.
  ///
  /// In en, this message translates to:
  /// **'Continue your child\'s health journey'**
  String get continueJourney;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get passwordUppercase;

  /// No description provided for @passwordLowercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one lowercase letter'**
  String get passwordLowercase;

  /// No description provided for @passwordNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get passwordNumber;

  /// No description provided for @passwordSpecial.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one special character'**
  String get passwordSpecial;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @newUser.
  ///
  /// In en, this message translates to:
  /// **'New user?'**
  String get newUser;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @startTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your child\'s health journey'**
  String get startTracking;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full Name is required'**
  String get fullNameRequired;

  /// No description provided for @fullNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get fullNameMinLength;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginHere.
  ///
  /// In en, this message translates to:
  /// **'Login here'**
  String get loginHere;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Track your child\'s health journey'**
  String get splashTagline;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @selectChild.
  ///
  /// In en, this message translates to:
  /// **'Select a Child'**
  String get selectChild;

  /// No description provided for @manageChildren.
  ///
  /// In en, this message translates to:
  /// **'Manage Children'**
  String get manageChildren;

  /// No description provided for @noChildrenRegistered.
  ///
  /// In en, this message translates to:
  /// **'⚠️ No children registered. Please add a child.'**
  String get noChildrenRegistered;

  /// No description provided for @monitorGrowth.
  ///
  /// In en, this message translates to:
  /// **'Monitor Growth'**
  String get monitorGrowth;

  /// No description provided for @trackGrowthDescription.
  ///
  /// In en, this message translates to:
  /// **'Track your child’s growth milestones with precision and care.'**
  String get trackGrowthDescription;

  /// No description provided for @ensureHealth.
  ///
  /// In en, this message translates to:
  /// **'Ensure Health'**
  String get ensureHealth;

  /// No description provided for @ensureHealthDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep your child healthy with vaccinations and health tips.'**
  String get ensureHealthDescription;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @vaccines.
  ///
  /// In en, this message translates to:
  /// **'Vaccines'**
  String get vaccines;

  /// No description provided for @healthTips.
  ///
  /// In en, this message translates to:
  /// **'Health Tips'**
  String get healthTips;

  /// No description provided for @nearestHospital.
  ///
  /// In en, this message translates to:
  /// **'Nearest Hospital'**
  String get nearestHospital;

  /// No description provided for @healthTipsFor.
  ///
  /// In en, this message translates to:
  /// **'Health Tips for {name}'**
  String healthTipsFor(Object name);

  /// No description provided for @healthRecords.
  ///
  /// In en, this message translates to:
  /// **'Health Records'**
  String get healthRecords;

  /// No description provided for @healthRecordsFor.
  ///
  /// In en, this message translates to:
  /// **'Health Records for {name}'**
  String healthRecordsFor(Object name);

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @noChildSelected.
  ///
  /// In en, this message translates to:
  /// **'No Child Selected'**
  String get noChildSelected;

  /// No description provided for @selectChildBeforeFeature.
  ///
  /// In en, this message translates to:
  /// **'Please select a child before accessing this feature.'**
  String get selectChildBeforeFeature;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @enterGrowthMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Enter Growth Measurements'**
  String get enterGrowthMeasurements;

  /// No description provided for @errorLoadingWHOData.
  ///
  /// In en, this message translates to:
  /// **'Error loading WHO data: {error}'**
  String errorLoadingWHOData(Object error);

  /// No description provided for @measurementSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Measurement saved successfully'**
  String get measurementSavedSuccessfully;

  /// No description provided for @errorSavingMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Error saving measurement: {error}'**
  String errorSavingMeasurement(Object error);

  /// No description provided for @enterAgeManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Age Manually'**
  String get enterAgeManually;

  /// No description provided for @ageMonths.
  ///
  /// In en, this message translates to:
  /// **'Age (months)'**
  String get ageMonths;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @latestMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Latest Measurement'**
  String get latestMeasurement;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @aDayAgo.
  ///
  /// In en, this message translates to:
  /// **'1 day ago'**
  String get aDayAgo;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(Object count);

  /// No description provided for @aWeekAgo.
  ///
  /// In en, this message translates to:
  /// **'1 week ago'**
  String get aWeekAgo;

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String weeksAgo(Object count);

  /// No description provided for @aMonthAgo.
  ///
  /// In en, this message translates to:
  /// **'1 month ago'**
  String get aMonthAgo;

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} months ago'**
  String monthsAgo(Object count);

  /// No description provided for @anHourAgo.
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get anHourAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(Object count);

  /// No description provided for @headCircumferenceCm.
  ///
  /// In en, this message translates to:
  /// **'Head Circumference (cm)'**
  String get headCircumferenceCm;

  /// No description provided for @saveMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Save Measurement'**
  String get saveMeasurement;

  /// No description provided for @pleaseEnterAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter age'**
  String get pleaseEnterAge;

  /// No description provided for @ageRangeError.
  ///
  /// In en, this message translates to:
  /// **'Age must be between 0 and 60 months'**
  String get ageRangeError;

  /// No description provided for @pleaseEnterField.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String pleaseEnterField(Object field);

  /// No description provided for @fieldRangeError.
  ///
  /// In en, this message translates to:
  /// **'{field} must be between {min} and {max}'**
  String fieldRangeError(Object field, Object min, Object max);

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @headCircumference.
  ///
  /// In en, this message translates to:
  /// **'Head Circumference'**
  String get headCircumference;

  /// No description provided for @growthOverview.
  ///
  /// In en, this message translates to:
  /// **'Growth Overview'**
  String get growthOverview;

  /// No description provided for @noMeasurements.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet. Add one to begin.'**
  String get noMeasurements;

  /// No description provided for @addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add Measurement'**
  String get addMeasurement;

  /// No description provided for @heightVsAge.
  ///
  /// In en, this message translates to:
  /// **'Height vs Age (cm)'**
  String get heightVsAge;

  /// No description provided for @weightVsAge.
  ///
  /// In en, this message translates to:
  /// **'Weight vs Age (kg)'**
  String get weightVsAge;

  /// No description provided for @headVsAge.
  ///
  /// In en, this message translates to:
  /// **'Head Circumference vs Age (cm)'**
  String get headVsAge;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @moreDetails.
  ///
  /// In en, this message translates to:
  /// **'More Details'**
  String get moreDetails;

  /// No description provided for @lessDetails.
  ///
  /// In en, this message translates to:
  /// **'Less Details'**
  String get lessDetails;

  /// No description provided for @mandatoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Mandatory'**
  String get mandatoryLabel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @conditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get conditions;

  /// No description provided for @dailyTip.
  ///
  /// In en, this message translates to:
  /// **'Daily Tip'**
  String get dailyTip;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @noRelevantTips.
  ///
  /// In en, this message translates to:
  /// **'No relevant tips available.'**
  String get noRelevantTips;

  /// No description provided for @noChildSelectedTips.
  ///
  /// In en, this message translates to:
  /// **'No child selected. Please select a child from the home screen.'**
  String get noChildSelectedTips;

  /// No description provided for @noTipsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No tips available for this category.'**
  String get noTipsInCategory;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @vaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get vaccination;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @physicalActivity.
  ///
  /// In en, this message translates to:
  /// **'Physical Activity'**
  String get physicalActivity;

  /// No description provided for @oralHealth.
  ///
  /// In en, this message translates to:
  /// **'Oral Health'**
  String get oralHealth;

  /// No description provided for @childDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Child Development'**
  String get childDevelopment;

  /// No description provided for @contactAuthorities.
  ///
  /// In en, this message translates to:
  /// **'Contact Authorities'**
  String get contactAuthorities;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get callNow;

  /// No description provided for @emailNow.
  ///
  /// In en, this message translates to:
  /// **'Email Now'**
  String get emailNow;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailLaunchFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open email app. The email address ({email}) has been copied to your clipboard.'**
  String emailLaunchFailed(Object email);

  /// No description provided for @noHealthRecords.
  ///
  /// In en, this message translates to:
  /// **'No health records yet.\nTap + to add one!'**
  String get noHealthRecords;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @addHealthRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Health Record'**
  String get addHealthRecord;

  /// No description provided for @titleExample.
  ///
  /// In en, this message translates to:
  /// **'Title (e.g., Vaccination)'**
  String get titleExample;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// No description provided for @fileSelected.
  ///
  /// In en, this message translates to:
  /// **'File: {fileName}'**
  String fileSelected(Object fileName);

  /// No description provided for @uploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get uploadFile;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @fileSizeExceedsLimit.
  ///
  /// In en, this message translates to:
  /// **'File size exceeds 10MB limit'**
  String get fileSizeExceedsLimit;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get deleteRecord;

  /// No description provided for @confirmDeleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get confirmDeleteRecord;

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download complete'**
  String get downloadComplete;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @errorDownloadingFile.
  ///
  /// In en, this message translates to:
  /// **'Error downloading file: {error}'**
  String errorDownloadingFile(Object error);

  /// No description provided for @editChildProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Child Profile'**
  String get editChildProfile;

  /// No description provided for @childProfiles.
  ///
  /// In en, this message translates to:
  /// **'Child Profiles'**
  String get childProfiles;

  /// No description provided for @noChildrenRegisteredYet.
  ///
  /// In en, this message translates to:
  /// **'No children registered yet.'**
  String get noChildrenRegisteredYet;

  /// No description provided for @registeredChildren.
  ///
  /// In en, this message translates to:
  /// **'Registered Children'**
  String get registeredChildren;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @deleteChild.
  ///
  /// In en, this message translates to:
  /// **'Delete Child'**
  String get deleteChild;

  /// No description provided for @confirmDeleteChild.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String confirmDeleteChild(Object name);

  /// No description provided for @removeChild.
  ///
  /// In en, this message translates to:
  /// **'Remove Child'**
  String get removeChild;

  /// No description provided for @confirmRemoveChild.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this child?'**
  String get confirmRemoveChild;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @childIndex.
  ///
  /// In en, this message translates to:
  /// **'Child {index}'**
  String childIndex(Object index);

  /// No description provided for @imageSelectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Image selection failed'**
  String get imageSelectionFailed;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @enterChildName.
  ///
  /// In en, this message translates to:
  /// **'Enter child\'s name'**
  String get enterChildName;

  /// No description provided for @nationalID.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalID;

  /// No description provided for @enterChildNationalID.
  ///
  /// In en, this message translates to:
  /// **'Enter child\'s national ID'**
  String get enterChildNationalID;

  /// No description provided for @nationalIDRequired.
  ///
  /// In en, this message translates to:
  /// **'National ID is required'**
  String get nationalIDRequired;

  /// No description provided for @nationalIDLengthError.
  ///
  /// In en, this message translates to:
  /// **'National ID must be exactly 10 digits'**
  String get nationalIDLengthError;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @selectChildBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Select child\'s birth date'**
  String get selectChildBirthDate;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @parent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parent;

  /// No description provided for @guardian.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get guardian;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String fieldRequired(Object field);

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @saveAllProfiles.
  ///
  /// In en, this message translates to:
  /// **'Save All Profiles'**
  String get saveAllProfiles;

  /// No description provided for @childProfileDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Child profile deleted successfully!'**
  String get childProfileDeletedSuccessfully;

  /// No description provided for @failedToDeleteChild.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete child: {error}'**
  String failedToDeleteChild(Object error);

  /// No description provided for @childProfileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Child profile updated successfully!'**
  String get childProfileUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String failedToUpdateProfile(Object error);

  /// No description provided for @pleaseLoginToSaveProfiles.
  ///
  /// In en, this message translates to:
  /// **'Please log in to save profiles.'**
  String get pleaseLoginToSaveProfiles;

  /// No description provided for @childProfileSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Child profile saved successfully!'**
  String get childProfileSavedSuccessfully;

  /// No description provided for @failedToSaveProfiles.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profiles: {error}'**
  String failedToSaveProfiles(Object error);

  /// No description provided for @authenticationRequired.
  ///
  /// In en, this message translates to:
  /// **'Authentication required'**
  String get authenticationRequired;

  /// No description provided for @pleaseFillAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get pleaseFillAllRequiredFields;

  /// No description provided for @pleaseSelectChild.
  ///
  /// In en, this message translates to:
  /// **'Please select a child to view their profile.'**
  String get pleaseSelectChild;

  /// No description provided for @noChildrenAddProfile.
  ///
  /// In en, this message translates to:
  /// **'No children registered. Add a child profile.'**
  String get noChildrenAddProfile;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @childID.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get childID;

  /// No description provided for @idCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'ID copied to clipboard'**
  String get idCopiedToClipboard;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMessage;

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get loggingOut;

  /// No description provided for @errorLoggingOut.
  ///
  /// In en, this message translates to:
  /// **'Error logging out: {error}'**
  String errorLoggingOut(Object error);

  /// No description provided for @aboutLittleSteps.
  ///
  /// In en, this message translates to:
  /// **'About LittleSteps'**
  String get aboutLittleSteps;

  /// No description provided for @aboutContent.
  ///
  /// In en, this message translates to:
  /// **'LittleSteps aims to digitize and simplify the management of your child\'s health journey, including growth tracking, vaccinations, and health tips. It transforms user inputs into organized health records based on predefined templates for each health category.'**
  String get aboutContent;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @websiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Website: github/EissaShehab'**
  String get websiteLabel;

  /// No description provided for @updateCredentials.
  ///
  /// In en, this message translates to:
  /// **'Update Your Credentials'**
  String get updateCredentials;

  /// No description provided for @secureAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Secure your account by changing your password regularly.'**
  String get secureAccountMessage;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @passwordMinLength6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength6;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @errorChangingPassword.
  ///
  /// In en, this message translates to:
  /// **'Error changing password: {error}'**
  String errorChangingPassword(Object error);

  /// No description provided for @privacyPolicyAgreement.
  ///
  /// In en, this message translates to:
  /// **'By changing your password, you agree to our Privacy Policy and Terms of Use'**
  String get privacyPolicyAgreement;

  /// No description provided for @privacyPolicyDetails.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy Details'**
  String get privacyPolicyDetails;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'This is the body of the privacy policy. Here you can outline the purpose, rules, and regulations regarding data collection, storage, and usage in your app. Ensure the text is clear, concise, and informative for users to understand their rights and obligations.'**
  String get privacyPolicyContent;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @additionalInfoContent.
  ///
  /// In en, this message translates to:
  /// **'Here you can add additional information, such as third-party services used, user rights, or steps users can take to manage their data within the app.'**
  String get additionalInfoContent;

  /// No description provided for @acceptAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Accept and Continue'**
  String get acceptAndContinue;

  /// No description provided for @statusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get statusUpcoming;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get statusCompleted;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'MISSED'**
  String get statusMissed;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotifications;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @markAsTaken.
  ///
  /// In en, this message translates to:
  /// **'Mark as Taken'**
  String get markAsTaken;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @vaccinationSchedule.
  ///
  /// In en, this message translates to:
  /// **'Vaccination Schedule'**
  String get vaccinationSchedule;

  /// No description provided for @noVaccinationsFound.
  ///
  /// In en, this message translates to:
  /// **'No vaccinations found'**
  String get noVaccinationsFound;

  /// No description provided for @emergencySection.
  ///
  /// In en, this message translates to:
  /// **'Emergency Cases'**
  String get emergencySection;

  /// No description provided for @nearestPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Nearest Pharmacy'**
  String get nearestPharmacy;

  /// No description provided for @contactNurse.
  ///
  /// In en, this message translates to:
  /// **'Contact Nurse'**
  String get contactNurse;

  /// No description provided for @noPharmaciesFound.
  ///
  /// In en, this message translates to:
  /// **'🚫 No nearby pharmacies found.'**
  String get noPharmaciesFound;

  /// No description provided for @pharmacyDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance: {distance} km'**
  String pharmacyDistance(Object distance);

  /// No description provided for @childWeather.
  ///
  /// In en, this message translates to:
  /// **'SmartWeatherAlerts'**
  String get childWeather;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @temperatureNow.
  ///
  /// In en, this message translates to:
  /// **'Temperature Now'**
  String get temperatureNow;

  /// No description provided for @weatherCondition.
  ///
  /// In en, this message translates to:
  /// **'Weather Condition'**
  String get weatherCondition;

  /// No description provided for @weatherClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get weatherClear;

  /// No description provided for @weatherPartlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly Cloudy'**
  String get weatherPartlyCloudy;

  /// No description provided for @weatherFog.
  ///
  /// In en, this message translates to:
  /// **'Foggy'**
  String get weatherFog;

  /// No description provided for @weatherDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get weatherDrizzle;

  /// No description provided for @weatherRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get weatherRain;

  /// No description provided for @weatherSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get weatherSnow;

  /// No description provided for @weatherThunder.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get weatherThunder;

  /// No description provided for @weatherUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get weatherUnknown;

  /// No description provided for @weatherAlertColdInfant.
  ///
  /// In en, this message translates to:
  /// **'Severe cold  keep infants indoors.'**
  String get weatherAlertColdInfant;

  /// No description provided for @weatherAlertColdGeneral.
  ///
  /// In en, this message translates to:
  /// **'Very cold  dress your child warmly.'**
  String get weatherAlertColdGeneral;

  /// No description provided for @weatherAlertHotToddler.
  ///
  /// In en, this message translates to:
  /// **'Hot weather  keep toddlers hydrated and avoid sun.'**
  String get weatherAlertHotToddler;

  /// No description provided for @weatherAlertHotGeneral.
  ///
  /// In en, this message translates to:
  /// **'High heat make sure your child is comfortable.'**
  String get weatherAlertHotGeneral;

  /// No description provided for @weatherAlertWarmForInfant.
  ///
  /// In en, this message translates to:
  /// **'Warm weather might be unsuitable for infants.'**
  String get weatherAlertWarmForInfant;

  /// No description provided for @weatherFetchError.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch weather data.'**
  String get weatherFetchError;

  /// No description provided for @weatherNotification.
  ///
  /// In en, this message translates to:
  /// **'Weather Alert'**
  String get weatherNotification;

  /// No description provided for @vaccineNotification.
  ///
  /// In en, this message translates to:
  /// **'Vaccination Reminder'**
  String get vaccineNotification;

  /// No description provided for @symptomsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'🩺 Select Symptoms'**
  String get symptomsScreenTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a symptom...'**
  String get searchHint;

  /// No description provided for @symptomNotFoundPrompt.
  ///
  /// In en, this message translates to:
  /// **'✨ Symptom not found? Add it here:'**
  String get symptomNotFoundPrompt;

  /// No description provided for @addSymptomHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a new symptom...'**
  String get addSymptomHint;

  /// No description provided for @analyzeSymptomsButton.
  ///
  /// In en, this message translates to:
  /// **'Analyze Symptoms'**
  String get analyzeSymptomsButton;

  /// No description provided for @selectSeverityTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select Severity'**
  String get selectSeverityTooltip;

  /// No description provided for @selectChildFirstMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select a child first.'**
  String get selectChildFirstMessage;

  /// No description provided for @analysisFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze: {error}'**
  String analysisFailedMessage(Object error);

  /// No description provided for @severityLow.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get severityLow;

  /// No description provided for @severityMedium.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get severityMedium;

  /// No description provided for @severityHigh.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severityHigh;

  /// No description provided for @symptomCategoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get symptomCategoryGeneral;

  /// No description provided for @symptomCategoryRespiratory.
  ///
  /// In en, this message translates to:
  /// **'Respiratory'**
  String get symptomCategoryRespiratory;

  /// No description provided for @symptomCategoryENT.
  ///
  /// In en, this message translates to:
  /// **'ENT'**
  String get symptomCategoryENT;

  /// No description provided for @symptomCategoryDigestive.
  ///
  /// In en, this message translates to:
  /// **'Digestive'**
  String get symptomCategoryDigestive;

  /// No description provided for @symptomCategorySkin.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get symptomCategorySkin;

  /// No description provided for @symptomCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get symptomCategoryOther;

  /// No description provided for @symptomFever.
  ///
  /// In en, this message translates to:
  /// **'Fever'**
  String get symptomFever;

  /// No description provided for @symptomFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get symptomFatigue;

  /// No description provided for @symptomHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get symptomHeadache;

  /// No description provided for @symptomMildFever.
  ///
  /// In en, this message translates to:
  /// **'Mild Fever'**
  String get symptomMildFever;

  /// No description provided for @symptomCough.
  ///
  /// In en, this message translates to:
  /// **'Cough'**
  String get symptomCough;

  /// No description provided for @symptomDryCough.
  ///
  /// In en, this message translates to:
  /// **'Dry Cough'**
  String get symptomDryCough;

  /// No description provided for @symptomWheezing.
  ///
  /// In en, this message translates to:
  /// **'Wheezing'**
  String get symptomWheezing;

  /// No description provided for @symptomShortnessOfBreath.
  ///
  /// In en, this message translates to:
  /// **'Shortness of Breath'**
  String get symptomShortnessOfBreath;

  /// No description provided for @symptomSoreThroat.
  ///
  /// In en, this message translates to:
  /// **'Sore Throat'**
  String get symptomSoreThroat;

  /// No description provided for @symptomRunnyNose.
  ///
  /// In en, this message translates to:
  /// **'Runny Nose'**
  String get symptomRunnyNose;

  /// No description provided for @symptomSneezing.
  ///
  /// In en, this message translates to:
  /// **'Sneezing'**
  String get symptomSneezing;

  /// No description provided for @symptomEarPain.
  ///
  /// In en, this message translates to:
  /// **'Ear Pain'**
  String get symptomEarPain;

  /// No description provided for @symptomEarTugging.
  ///
  /// In en, this message translates to:
  /// **'Ear Tugging'**
  String get symptomEarTugging;

  /// No description provided for @symptomNasalCongestion.
  ///
  /// In en, this message translates to:
  /// **'Nasal Congestion'**
  String get symptomNasalCongestion;

  /// No description provided for @symptomRedThroat.
  ///
  /// In en, this message translates to:
  /// **'Red Throat'**
  String get symptomRedThroat;

  /// No description provided for @symptomVomiting.
  ///
  /// In en, this message translates to:
  /// **'Vomiting'**
  String get symptomVomiting;

  /// No description provided for @symptomDiarrhea.
  ///
  /// In en, this message translates to:
  /// **'Diarrhea'**
  String get symptomDiarrhea;

  /// No description provided for @symptomLossOfAppetite.
  ///
  /// In en, this message translates to:
  /// **'Loss of Appetite'**
  String get symptomLossOfAppetite;

  /// No description provided for @symptomAbdominalCramps.
  ///
  /// In en, this message translates to:
  /// **'Abdominal Cramps'**
  String get symptomAbdominalCramps;

  /// No description provided for @symptomRedRash.
  ///
  /// In en, this message translates to:
  /// **'Red Rash'**
  String get symptomRedRash;

  /// No description provided for @symptomItchySkin.
  ///
  /// In en, this message translates to:
  /// **'Itchy Skin'**
  String get symptomItchySkin;

  /// No description provided for @symptomCrackedSkin.
  ///
  /// In en, this message translates to:
  /// **'Cracked Skin'**
  String get symptomCrackedSkin;

  /// No description provided for @symptomMouthSores.
  ///
  /// In en, this message translates to:
  /// **'Mouth Sores'**
  String get symptomMouthSores;

  /// No description provided for @symptomChestPain.
  ///
  /// In en, this message translates to:
  /// **'Chest Pain'**
  String get symptomChestPain;

  /// No description provided for @symptomBodyAches.
  ///
  /// In en, this message translates to:
  /// **'Body Aches'**
  String get symptomBodyAches;

  /// No description provided for @severityVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very Severe'**
  String get severityVeryHigh;

  /// No description provided for @predictionResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Prediction Result'**
  String get predictionResultTitle;

  /// No description provided for @mostLikelyDisease.
  ///
  /// In en, this message translates to:
  /// **'Most likely disease:'**
  String get mostLikelyDisease;

  /// No description provided for @detailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Result Details:'**
  String get detailsTitle;

  /// No description provided for @disclaimerNote.
  ///
  /// In en, this message translates to:
  /// **'⚠ These results are for assistance only and do not replace a professional medical consultation.'**
  String get disclaimerNote;

  /// No description provided for @newAnalysis.
  ///
  /// In en, this message translates to:
  /// **'New Analysis'**
  String get newAnalysis;

  /// No description provided for @diseaseAsthma.
  ///
  /// In en, this message translates to:
  /// **'Asthma'**
  String get diseaseAsthma;

  /// No description provided for @diseaseBronchiolitis.
  ///
  /// In en, this message translates to:
  /// **'Bronchiolitis'**
  String get diseaseBronchiolitis;

  /// No description provided for @diseaseBronchitis.
  ///
  /// In en, this message translates to:
  /// **'Bronchitis'**
  String get diseaseBronchitis;

  /// No description provided for @diseaseChickenpox.
  ///
  /// In en, this message translates to:
  /// **'Chickenpox'**
  String get diseaseChickenpox;

  /// No description provided for @diseaseCommonCold.
  ///
  /// In en, this message translates to:
  /// **'Common Cold'**
  String get diseaseCommonCold;

  /// No description provided for @diseaseEczema.
  ///
  /// In en, this message translates to:
  /// **'Eczema'**
  String get diseaseEczema;

  /// No description provided for @diseaseFebrileSeizures.
  ///
  /// In en, this message translates to:
  /// **'Febrile Seizures'**
  String get diseaseFebrileSeizures;

  /// No description provided for @diseaseFlu.
  ///
  /// In en, this message translates to:
  /// **'Flu'**
  String get diseaseFlu;

  /// No description provided for @diseaseHeatStroke.
  ///
  /// In en, this message translates to:
  /// **'Heat Stroke'**
  String get diseaseHeatStroke;

  /// No description provided for @diseaseOtitisMedia.
  ///
  /// In en, this message translates to:
  /// **'Ear Infection'**
  String get diseaseOtitisMedia;

  /// No description provided for @diseasePneumonia.
  ///
  /// In en, this message translates to:
  /// **'Pneumonia'**
  String get diseasePneumonia;

  /// No description provided for @diseaseRSV.
  ///
  /// In en, this message translates to:
  /// **'RSV (Respiratory Syncytial Virus)'**
  String get diseaseRSV;

  /// No description provided for @diseaseScarletFever.
  ///
  /// In en, this message translates to:
  /// **'Scarlet Fever'**
  String get diseaseScarletFever;

  /// No description provided for @diseaseSinusInfection.
  ///
  /// In en, this message translates to:
  /// **'Sinus Infection'**
  String get diseaseSinusInfection;

  /// No description provided for @diseaseStomachFlu.
  ///
  /// In en, this message translates to:
  /// **'Stomach Flu'**
  String get diseaseStomachFlu;

  /// No description provided for @diseaseTonsillitis.
  ///
  /// In en, this message translates to:
  /// **'Tonsillitis'**
  String get diseaseTonsillitis;

  /// No description provided for @diseaseViralSoreThroat.
  ///
  /// In en, this message translates to:
  /// **'Viral Sore Throat'**
  String get diseaseViralSoreThroat;

  /// No description provided for @diseaseViralSummerFever.
  ///
  /// In en, this message translates to:
  /// **'Viral Summer Fever'**
  String get diseaseViralSummerFever;

  /// No description provided for @resultDetails.
  ///
  /// In en, this message translates to:
  /// **'Result Details'**
  String get resultDetails;

  /// No description provided for @resultDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'⚠ These results are for informational purposes only and do not replace a professional medical diagnosis.'**
  String get resultDisclaimer;

  /// No description provided for @symptomChills.
  ///
  /// In en, this message translates to:
  /// **'Chills'**
  String get symptomChills;

  /// No description provided for @symptomConfusion.
  ///
  /// In en, this message translates to:
  /// **'Confusion'**
  String get symptomConfusion;

  /// No description provided for @symptomDizziness.
  ///
  /// In en, this message translates to:
  /// **'Dizziness'**
  String get symptomDizziness;

  /// No description provided for @symptomFainting.
  ///
  /// In en, this message translates to:
  /// **'Fainting'**
  String get symptomFainting;

  /// No description provided for @symptomSweating.
  ///
  /// In en, this message translates to:
  /// **'Sweating'**
  String get symptomSweating;

  /// No description provided for @symptomSuddenOnset.
  ///
  /// In en, this message translates to:
  /// **'Sudden Onset'**
  String get symptomSuddenOnset;

  /// No description provided for @symptomIrritability.
  ///
  /// In en, this message translates to:
  /// **'Irritability'**
  String get symptomIrritability;

  /// No description provided for @symptomChestTightness.
  ///
  /// In en, this message translates to:
  /// **'Chest Tightness'**
  String get symptomChestTightness;

  /// No description provided for @symptomChestDiscomfort.
  ///
  /// In en, this message translates to:
  /// **'Chest Discomfort'**
  String get symptomChestDiscomfort;

  /// No description provided for @symptomDryRespiratoryPattern.
  ///
  /// In en, this message translates to:
  /// **'Dry Respiratory Pattern'**
  String get symptomDryRespiratoryPattern;

  /// No description provided for @symptomFacialPain.
  ///
  /// In en, this message translates to:
  /// **'Facial Pain'**
  String get symptomFacialPain;

  /// No description provided for @symptomSinusPressure.
  ///
  /// In en, this message translates to:
  /// **'Sinus Pressure'**
  String get symptomSinusPressure;

  /// No description provided for @symptomStomachPain.
  ///
  /// In en, this message translates to:
  /// **'Stomach Pain'**
  String get symptomStomachPain;

  /// No description provided for @symptomNausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get symptomNausea;

  /// No description provided for @symptomRedPatches.
  ///
  /// In en, this message translates to:
  /// **'Red Patches'**
  String get symptomRedPatches;

  /// No description provided for @symptomSkinPeeling.
  ///
  /// In en, this message translates to:
  /// **'Skin Peeling'**
  String get symptomSkinPeeling;

  /// No description provided for @symptomConvulsions.
  ///
  /// In en, this message translates to:
  /// **'Convulsions'**
  String get symptomConvulsions;

  /// No description provided for @symptomStiffNeck.
  ///
  /// In en, this message translates to:
  /// **'Stiff Neck'**
  String get symptomStiffNeck;

  /// No description provided for @symptomFebrilePattern.
  ///
  /// In en, this message translates to:
  /// **'Febrile Pattern'**
  String get symptomFebrilePattern;

  /// No description provided for @symptomBluishSkin.
  ///
  /// In en, this message translates to:
  /// **'Bluish Skin'**
  String get symptomBluishSkin;

  /// No description provided for @symptomBulgingFontanelle.
  ///
  /// In en, this message translates to:
  /// **'Bulging Fontanelle'**
  String get symptomBulgingFontanelle;

  /// No description provided for @symptomAgeUnderTwo.
  ///
  /// In en, this message translates to:
  /// **'Age under 2 years'**
  String get symptomAgeUnderTwo;

  /// No description provided for @symptomAllergyTrigger.
  ///
  /// In en, this message translates to:
  /// **'Allergy Trigger'**
  String get symptomAllergyTrigger;

  /// No description provided for @symptomHighFever.
  ///
  /// In en, this message translates to:
  /// **'High Fever'**
  String get symptomHighFever;

  /// No description provided for @symptomHighBodyTemperature.
  ///
  /// In en, this message translates to:
  /// **'High Body Temperature'**
  String get symptomHighBodyTemperature;

  /// No description provided for @symptomHeatStrokePattern.
  ///
  /// In en, this message translates to:
  /// **'Heat Stroke Pattern'**
  String get symptomHeatStrokePattern;

  /// No description provided for @symptomRSVPattern.
  ///
  /// In en, this message translates to:
  /// **'RSV Pattern'**
  String get symptomRSVPattern;

  /// No description provided for @symptomScarletFever.
  ///
  /// In en, this message translates to:
  /// **'Scarlet Fever'**
  String get symptomScarletFever;

  /// No description provided for @symptomThroatCluster.
  ///
  /// In en, this message translates to:
  /// **'Throat Cluster'**
  String get symptomThroatCluster;

  /// No description provided for @symptomStomachFlu.
  ///
  /// In en, this message translates to:
  /// **'Stomach Flu'**
  String get symptomStomachFlu;

  /// No description provided for @symptomCategoryNeurological.
  ///
  /// In en, this message translates to:
  /// **'Neurological'**
  String get symptomCategoryNeurological;

  /// No description provided for @symptomCategoryCardiac.
  ///
  /// In en, this message translates to:
  /// **'Cardiac'**
  String get symptomCategoryCardiac;

  /// No description provided for @zScoreSeverelyUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Severely underweight'**
  String get zScoreSeverelyUnderweight;

  /// No description provided for @zScoreUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get zScoreUnderweight;

  /// No description provided for @zScoreNormalWeight.
  ///
  /// In en, this message translates to:
  /// **'Normal weight'**
  String get zScoreNormalWeight;

  /// No description provided for @zScoreOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get zScoreOverweight;

  /// No description provided for @zScoreObese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get zScoreObese;

  /// No description provided for @zScoreSeverelyStunted.
  ///
  /// In en, this message translates to:
  /// **'Severely stunted'**
  String get zScoreSeverelyStunted;

  /// No description provided for @zScoreStunted.
  ///
  /// In en, this message translates to:
  /// **'Stunted'**
  String get zScoreStunted;

  /// No description provided for @zScoreNormalHeight.
  ///
  /// In en, this message translates to:
  /// **'Normal height'**
  String get zScoreNormalHeight;

  /// No description provided for @zScoreMicrocephaly.
  ///
  /// In en, this message translates to:
  /// **'Microcephaly'**
  String get zScoreMicrocephaly;

  /// No description provided for @zScoreNormalHead.
  ///
  /// In en, this message translates to:
  /// **'Normal head size'**
  String get zScoreNormalHead;

  /// No description provided for @zScoreMacrocephaly.
  ///
  /// In en, this message translates to:
  /// **'Macrocephaly'**
  String get zScoreMacrocephaly;

  /// No description provided for @zScoreNormalKeyword.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get zScoreNormalKeyword;

  /// No description provided for @zScoreMildKeyword.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get zScoreMildKeyword;

  /// No description provided for @chartLabelValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get chartLabelValue;

  /// No description provided for @chartLabelAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get chartLabelAge;

  /// No description provided for @chartLabelStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get chartLabelStatus;

  /// No description provided for @percentileWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight is in the top {percentile}% of peers'**
  String percentileWeight(Object percentile);

  /// No description provided for @percentileHeight.
  ///
  /// In en, this message translates to:
  /// **'Height is in the top {percentile}% of peers'**
  String percentileHeight(Object percentile);

  /// No description provided for @percentileHead.
  ///
  /// In en, this message translates to:
  /// **'Head size is in the top {percentile}% of peers'**
  String percentileHead(Object percentile);

  /// No description provided for @helpful.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get helpful;

  /// No description provided for @notHelpful.
  ///
  /// In en, this message translates to:
  /// **'Not Helpful'**
  String get notHelpful;

  /// No description provided for @searchTips.
  ///
  /// In en, this message translates to:
  /// **'Search tips...'**
  String get searchTips;

  /// No description provided for @within.
  ///
  /// In en, this message translates to:
  /// **'within'**
  String get within;

  /// No description provided for @tryAnotherSearch.
  ///
  /// In en, this message translates to:
  /// **'Try another search'**
  String get tryAnotherSearch;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @noDailyTip.
  ///
  /// In en, this message translates to:
  /// **'No health tip available for today.'**
  String get noDailyTip;

  /// No description provided for @thankYouFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouFeedback;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get errorOccurred;

  /// No description provided for @unhelpful.
  ///
  /// In en, this message translates to:
  /// **'Not Helpful'**
  String get unhelpful;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @authorityRenadName.
  ///
  /// In en, this message translates to:
  /// **'Ranad Ajarmeh'**
  String get authorityRenadName;

  /// No description provided for @authorityRenadSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Pediatric Specialist'**
  String get authorityRenadSpecialty;

  /// No description provided for @authorityRenadHospital.
  ///
  /// In en, this message translates to:
  /// **'Istiklal Hospital'**
  String get authorityRenadHospital;

  /// No description provided for @authorityRahafName.
  ///
  /// In en, this message translates to:
  /// **'Rahaf Jaditawi'**
  String get authorityRahafName;

  /// No description provided for @authorityRahafSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Pediatric Nurse (RN2)'**
  String get authorityRahafSpecialty;

  /// No description provided for @authorityRahafHospital.
  ///
  /// In en, this message translates to:
  /// **'Istiklal Hospital'**
  String get authorityRahafHospital;

  /// No description provided for @authorityReefName.
  ///
  /// In en, this message translates to:
  /// **'Reef Al Majali'**
  String get authorityReefName;

  /// No description provided for @authorityReefSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Pediatric Nurse (RN3)'**
  String get authorityReefSpecialty;

  /// No description provided for @authorityReefHospital.
  ///
  /// In en, this message translates to:
  /// **'Istiklal Hospital'**
  String get authorityReefHospital;

  /// No description provided for @authorityLeenName.
  ///
  /// In en, this message translates to:
  /// **'Leen Hendawy'**
  String get authorityLeenName;

  /// No description provided for @authorityLeenSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Pediatric Nurse (RN3)'**
  String get authorityLeenSpecialty;

  /// No description provided for @authorityLeenHospital.
  ///
  /// In en, this message translates to:
  /// **'Istiklal Hospital'**
  String get authorityLeenHospital;

  /// No description provided for @authoritySajoudName.
  ///
  /// In en, this message translates to:
  /// **'Sajoud Zawaneh'**
  String get authoritySajoudName;

  /// No description provided for @authoritySajoudSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Pediatric Nurse (RN2)'**
  String get authoritySajoudSpecialty;

  /// No description provided for @authoritySajoudHospital.
  ///
  /// In en, this message translates to:
  /// **'Istiklal Hospital'**
  String get authoritySajoudHospital;

  /// No description provided for @birthDateCannotBeFuture.
  ///
  /// In en, this message translates to:
  /// **'Birth date cannot be in the future'**
  String get birthDateCannotBeFuture;

  /// No description provided for @dateOfBirthRequired.
  ///
  /// In en, this message translates to:
  /// **'Date of birth is required'**
  String get dateOfBirthRequired;

  /// No description provided for @birthDateMustBeWithinFiveYears.
  ///
  /// In en, this message translates to:
  /// **'Birth date must be within the last 5 years'**
  String get birthDateMustBeWithinFiveYears;

  /// Title for the Nearest Hospitals screen
  ///
  /// In en, this message translates to:
  /// **'Nearest Hospital'**
  String get nearestHospitalsTitle;

  /// Tooltip for refresh location button
  ///
  /// In en, this message translates to:
  /// **'Refresh Location'**
  String get locationRefreshTooltip;

  /// Error message when location can't be retrieved
  ///
  /// In en, this message translates to:
  /// **'⚠️ Failed to get location. Make sure GPS is enabled.'**
  String get locationErrorMessage;

  /// Shown while fetching user location
  ///
  /// In en, this message translates to:
  /// **'Getting current location...'**
  String get locationLoading;

  /// Label showing user’s current location
  ///
  /// In en, this message translates to:
  /// **'📍 You are currently in: {address}'**
  String currentLocationLabel(Object address);

  /// Message shown when no hospitals are found
  ///
  /// In en, this message translates to:
  /// **'🚫 No nearby hospitals found.'**
  String get noHospitalsFound;

  /// Shows distance to hospital
  ///
  /// In en, this message translates to:
  /// **'Distance: {distance} km'**
  String hospitalDistance(Object distance);

  /// Button label to open hospital in map
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// Button label to launch navigation to hospital
  ///
  /// In en, this message translates to:
  /// **'Start Navigation'**
  String get startNavigation;

  /// Shown when the map app cannot be opened
  ///
  /// In en, this message translates to:
  /// **'❌ Unable to open Maps application.'**
  String get openMapError;

  /// Shown when navigation intent fails
  ///
  /// In en, this message translates to:
  /// **'❌ Unable to start navigation.'**
  String get startNavError;

  /// Title for the Nearest Pharmacies screen
  ///
  /// In en, this message translates to:
  /// **'Nearest Pharmacy'**
  String get nearestPharmaciesTitle;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @confirmDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete All'**
  String get confirmDeleteAll;

  /// No description provided for @deleteAllNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all notifications?'**
  String get deleteAllNotificationsMessage;

  /// No description provided for @allNotificationsDeleted.
  ///
  /// In en, this message translates to:
  /// **'All notifications have been deleted.'**
  String get allNotificationsDeleted;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteNotificationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this notification?'**
  String get deleteNotificationMessage;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view notifications.'**
  String get pleaseLogin;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No Title'**
  String get noTitle;

  /// No description provided for @unknownChild.
  ///
  /// In en, this message translates to:
  /// **'Unknown Child'**
  String get unknownChild;

  /// No description provided for @noContent.
  ///
  /// In en, this message translates to:
  /// **'No Content'**
  String get noContent;

  /// Label for the digital doctor feature
  ///
  /// In en, this message translates to:
  /// **'Digital Doctor'**
  String get symptoms;

  /// No description provided for @duplicateNationalIdError.
  ///
  /// In en, this message translates to:
  /// **'This national ID is already used by another child.'**
  String get duplicateNationalIdError;

  /// No description provided for @deleteMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Delete Measurement'**
  String get deleteMeasurement;

  /// No description provided for @confirmDeleteMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this measurement?'**
  String get confirmDeleteMeasurement;

  /// No description provided for @measurementDeleted.
  ///
  /// In en, this message translates to:
  /// **'Measurement deleted successfully.'**
  String get measurementDeleted;

  /// No description provided for @errorDeletingMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Error deleting measurement: {error}'**
  String errorDeletingMeasurement(Object error);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @pleaseLoginToExport.
  ///
  /// In en, this message translates to:
  /// **'Please log in to export the report'**
  String get pleaseLoginToExport;

  /// No description provided for @growthReportExportedToHealthRecords.
  ///
  /// In en, this message translates to:
  /// **'Growth report exported to health records successfully'**
  String get growthReportExportedToHealthRecords;

  /// No description provided for @errorExportingToHealthRecords.
  ///
  /// In en, this message translates to:
  /// **'Error exporting to health records: {error}'**
  String errorExportingToHealthRecords(Object error);

  /// No description provided for @errorExportingToHealthRecords_error.
  ///
  /// In en, this message translates to:
  /// **'The error message'**
  String get errorExportingToHealthRecords_error;

  /// No description provided for @exportToHealthRecords.
  ///
  /// In en, this message translates to:
  /// **'Export to Health Records'**
  String get exportToHealthRecords;

  /// No description provided for @symptom_analysis_report.
  ///
  /// In en, this message translates to:
  /// **'Symptom Analysis Report'**
  String get symptom_analysis_report;

  /// No description provided for @child_name.
  ///
  /// In en, this message translates to:
  /// **'Child Name'**
  String get child_name;

  /// No description provided for @likely_disease.
  ///
  /// In en, this message translates to:
  /// **'Likely Disease'**
  String get likely_disease;

  /// No description provided for @symptom_details.
  ///
  /// In en, this message translates to:
  /// **'Symptom Details'**
  String get symptom_details;

  /// No description provided for @symptom.
  ///
  /// In en, this message translates to:
  /// **'Symptom'**
  String get symptom;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @disease_probabilities.
  ///
  /// In en, this message translates to:
  /// **'Disease Probabilities'**
  String get disease_probabilities;

  /// No description provided for @disease.
  ///
  /// In en, this message translates to:
  /// **'Disease'**
  String get disease;

  /// No description provided for @probability.
  ///
  /// In en, this message translates to:
  /// **'Probability'**
  String get probability;

  /// No description provided for @health_record_title.
  ///
  /// In en, this message translates to:
  /// **'Symptom Analysis'**
  String get health_record_title;

  /// No description provided for @health_record_description.
  ///
  /// In en, this message translates to:
  /// **'Analysis results based on symptoms saved as PDF'**
  String get health_record_description;

  /// No description provided for @file_name.
  ///
  /// In en, this message translates to:
  /// **'symptom_report.pdf'**
  String get file_name;

  /// No description provided for @severity_mild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get severity_mild;

  /// No description provided for @severity_moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get severity_moderate;

  /// No description provided for @severity_severe.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severity_severe;

  /// No description provided for @severity_very_severe.
  ///
  /// In en, this message translates to:
  /// **'Very Severe'**
  String get severity_very_severe;

  /// No description provided for @severity_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get severity_unknown;

  /// No description provided for @child.
  ///
  /// In en, this message translates to:
  /// **'child'**
  String get child;

  /// No description provided for @recordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Record deleted'**
  String get recordDeleted;

  /// No description provided for @recordAdded.
  ///
  /// In en, this message translates to:
  /// **'Record added'**
  String get recordAdded;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Please enable it to view the weather.'**
  String get locationPermissionDenied;

  /// No description provided for @weightTooLow.
  ///
  /// In en, this message translates to:
  /// **'Weight is unusually low for age.'**
  String get weightTooLow;

  /// No description provided for @weightTooHigh.
  ///
  /// In en, this message translates to:
  /// **'Weight is unusually high for age.'**
  String get weightTooHigh;

  /// No description provided for @weightNormalRange.
  ///
  /// In en, this message translates to:
  /// **'Weight is within normal range.'**
  String get weightNormalRange;

  /// No description provided for @heightTooLow.
  ///
  /// In en, this message translates to:
  /// **'Height is unusually short for age.'**
  String get heightTooLow;

  /// No description provided for @heightNormalRange.
  ///
  /// In en, this message translates to:
  /// **'Height is within normal range.'**
  String get heightNormalRange;

  /// No description provided for @headTooSmall.
  ///
  /// In en, this message translates to:
  /// **'Head size is unusually small.'**
  String get headTooSmall;

  /// No description provided for @headTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Head size is unusually large.'**
  String get headTooLarge;

  /// No description provided for @headNormalRange.
  ///
  /// In en, this message translates to:
  /// **'Head size is within normal range.'**
  String get headNormalRange;

  /// No description provided for @valueNormalRange.
  ///
  /// In en, this message translates to:
  /// **'Measurement is within normal range.'**
  String get valueNormalRange;

  /// No description provided for @invalidMeasurementOutlier.
  ///
  /// In en, this message translates to:
  /// **'The value entered is too extreme and may be incorrect. Please verify the child\'s measurements.'**
  String get invalidMeasurementOutlier;

  /// No description provided for @symptomSevereFatigue.
  ///
  /// In en, this message translates to:
  /// **'Severe Fatigue'**
  String get symptomSevereFatigue;

  /// No description provided for @symptomDifficultySwallowing.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Swallowing'**
  String get symptomDifficultySwallowing;

  /// No description provided for @symptomSwollenTongue.
  ///
  /// In en, this message translates to:
  /// **'Swollen Tongue'**
  String get symptomSwollenTongue;

  /// No description provided for @symptomSwollenTonsils.
  ///
  /// In en, this message translates to:
  /// **'Swollen Tonsils'**
  String get symptomSwollenTonsils;

  /// No description provided for @symptomDrySkin.
  ///
  /// In en, this message translates to:
  /// **'Dry Skin'**
  String get symptomDrySkin;

  /// The loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @selectChildFirst.
  ///
  /// In en, this message translates to:
  /// **'selectChildFirst'**
  String get selectChildFirst;

  /// No description provided for @minSymptomsWarning.
  ///
  /// In en, this message translates to:
  /// **'Please select at least 4 symptoms.'**
  String get minSymptomsWarning;

  /// No description provided for @maxSymptomsWarning.
  ///
  /// In en, this message translates to:
  /// **'You can select up to 10 symptoms only.'**
  String get maxSymptomsWarning;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 4 characters long'**
  String get nameTooShort;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name cannot exceed 30 characters'**
  String get nameTooLong;

  /// No description provided for @invalidNameCharacters.
  ///
  /// In en, this message translates to:
  /// **'Name can only contain Arabic or English letters, spaces, or hyphens'**
  String get invalidNameCharacters;

  /// Label for residence ID field
  ///
  /// In en, this message translates to:
  /// **'Residence ID'**
  String get residenceID;

  /// Label for identifier type dropdown
  ///
  /// In en, this message translates to:
  /// **'Identifier Type'**
  String get identifierType;

  /// Placeholder for residence ID input
  ///
  /// In en, this message translates to:
  /// **'Enter child\'s Residence ID'**
  String get enterChildResidenceID;

  /// Error message for invalid identifier length
  ///
  /// In en, this message translates to:
  /// **'Identifier must be exactly 10 digits'**
  String get identifierLengthError;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
