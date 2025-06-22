import 'package:littlesteps/gen_l10n/app_localizations.dart';

const Map<String, List<String>> symptomCategories = {
  'symptomCategoryGeneral': [
    "Fever",
    "Fatigue",
    "Headache",
    "Mild Fever",
    "Body Aches",
    "Chills",
    "Confusion",
    "Dizziness",
    "Fainting",
    "Sweating",
    "Sudden Onset",
    "Irritability",
    "Loss of Appetite",
    "Severe Fatigue",
    "Dry Skin",
    "Difficulty Swallowing",
    "Swollen Tongue",
    "Swollen Tonsils",
  ],
  'symptomCategoryRespiratory': [
    "Cough",
    "Dry Cough",
    "Wheezing",
    "Shortness of Breath",
    "Chest Tightness",
    "Chest Discomfort",
    "Chest Pain",
    "DryRespiratory Pattern",
  ],
  'symptomCategoryENT': [
    "Sore Throat",
    "Runny Nose",
    "Sneezing",
    "Ear Pain",
    "Ear Tugging",
    "Nasal Congestion",
    "Red Throat",
    "Facial Pain",
  ],
  'symptomCategoryDigestive': [
    "Vomiting",
    "Diarrhea",
    "Loss of Appetite",
    "Abdominal Cramps",
    "Nausea",
  ],
  'symptomCategorySkin': [
    "Red Rash",
    "Itchy Skin",
    "Cracked Skin",
    "Mouth Sores",
    "Red Patches",
    "Skin Peeling",
    "Dry Skin",
  ],
  'symptomCategoryNeurological': [
    "Convulsions",
    "Stiff Neck",
    "Febrile Pattern",
  ],
  'symptomCategoryCardiac': [
    "Bluish Skin",
  ],
  'symptomCategoryOther': [
    "Bulging Fontanelle",
    "Allergy Trigger",
    "High Fever",
    "High Body Temperature",
    "RSV Pattern",
    "Throat Cluster",
  ],
};

extension SymptomLocalization on AppLocalizations {
  String translateSymptom(String key) {
    switch (key) {
      case "Fever":
        return symptomFever;
      case "Fatigue":
        return symptomFatigue;
      case "Headache":
        return symptomHeadache;
      case "Mild Fever":
        return symptomMildFever;
      case "Body Aches":
        return symptomBodyAches;
      case "Chills":
        return symptomChills;
      case "Confusion":
        return symptomConfusion;
      case "Dizziness":
        return symptomDizziness;
      case "Fainting":
        return symptomFainting;
      case "Sweating":
        return symptomSweating;
      case "Sudden Onset":
        return symptomSuddenOnset;
      case "Irritability":
        return symptomIrritability;
      case "Loss of Appetite":
        return symptomLossOfAppetite;
      case "Severe Fatigue":
        return symptomSevereFatigue;
      case "Dry Skin":
        return symptomDrySkin;
      case "Difficulty Swallowing":
        return symptomDifficultySwallowing;
      case "Swollen Tongue":
        return symptomSwollenTongue;
      case "Swollen Tonsils":
        return symptomSwollenTonsils;
      case "Age < 2 years":
        return symptomAgeUnderTwo;
      case "Cough":
        return symptomCough;
      case "Dry Cough":
        return symptomDryCough;
      case "Wheezing":
        return symptomWheezing;
      case "Shortness of Breath":
        return symptomShortnessOfBreath;
      case "Chest Tightness":
        return symptomChestTightness;
      case "Chest Discomfort":
        return symptomChestDiscomfort;
      case "Chest Pain":
        return symptomChestPain;
      case "Sore Throat":
        return symptomSoreThroat;
      case "Runny Nose":
        return symptomRunnyNose;
      case "Sneezing":
        return symptomSneezing;
      case "Ear Pain":
        return symptomEarPain;
      case "Ear Tugging":
        return symptomEarTugging;
      case "Nasal Congestion":
        return symptomNasalCongestion;
      case "Red Throat":
        return symptomRedThroat;
      case "Facial Pain":
        return symptomFacialPain;
      case "Vomiting":
        return symptomVomiting;
      case "Diarrhea":
        return symptomDiarrhea;
      case "Abdominal Cramps":
        return symptomAbdominalCramps;
      case "Nausea":
        return symptomNausea;
      case "Red Rash":
        return symptomRedRash;
      case "Itchy Skin":
        return symptomItchySkin;
      case "Cracked Skin":
        return symptomCrackedSkin;
      case "Mouth Sores":
        return symptomMouthSores;
      case "Red Patches":
        return symptomRedPatches;
      case "Skin Peeling":
        return symptomSkinPeeling;
      case "Convulsions":
        return symptomConvulsions;
      case "Stiff Neck":
        return symptomStiffNeck;
      case "Febrile Pattern":
        return symptomFebrilePattern;
      case "Bluish Skin":
        return symptomBluishSkin;
      case "Bulging Fontanelle":
        return symptomBulgingFontanelle;
      case "Allergy Trigger":
        return symptomAllergyTrigger;
      case "High Fever":
        return symptomHighFever;
      case "High Body Temperature":
        return symptomHighBodyTemperature;
      case "RSV Pattern":
        return symptomRSVPattern;
      case "Throat Cluster":
        return symptomThroatCluster;
      case "DryRespiratory Pattern":
        return symptomDryRespiratoryPattern;
      default:
        return key;
    }
  }

  String translateDisease(String key) {
    switch (key) {
      case "Asthma":
        return diseaseAsthma;
      case "Bronchiolitis":
        return diseaseBronchiolitis;
      case "Bronchitis":
        return diseaseBronchitis;
      case "Chickenpox":
        return diseaseChickenpox;
      case "Common Cold":
        return diseaseCommonCold;
      case "Eczema":
        return diseaseEczema;
      case "Febrile Seizures":
        return diseaseFebrileSeizures;
      case "Flu":
        return diseaseFlu;
      case "Heat Stroke":
        return diseaseHeatStroke;
      case "Otitis Media":
        return diseaseOtitisMedia;
      case "Pneumonia":
        return diseasePneumonia;
      case "RSV (Respiratory Syncytial Virus)":
        return diseaseRSV;
      case "Scarlet Fever":
        return diseaseScarletFever;
      case "Sinus Infection":
        return diseaseSinusInfection;
      case "Stomach Flu":
        return diseaseStomachFlu;
      case "Tonsillitis":
        return diseaseTonsillitis;
      case "Viral Sore Throat":
        return diseaseViralSoreThroat;
      case "Viral Summer Fever":
        return diseaseViralSummerFever;
      default:
        return key;
    }
  }

  String translateCategory(String key) {
    switch (key) {
      case 'symptomCategoryGeneral':
        return symptomCategoryGeneral;
      case 'symptomCategoryRespiratory':
        return symptomCategoryRespiratory;
      case 'symptomCategoryENT':
        return symptomCategoryENT;
      case 'symptomCategoryDigestive':
        return symptomCategoryDigestive;
      case 'symptomCategorySkin':
        return symptomCategorySkin;
      case 'symptomCategoryNeurological':
        return symptomCategoryNeurological;
      case 'symptomCategoryCardiac':
        return symptomCategoryCardiac;
      case 'symptomCategoryOther':
        return symptomCategoryOther;
      default:
        return key;
    }
  }
}
