from flask import Flask, request, jsonify
import joblib
import numpy as np
import os

# تحميل النموذج والمعالجات
model_path = r"C:\Users\issas\Downloads\ilovepdf_converted (1)"
mlp = joblib.load(os.path.join(model_path, "mlp_final_model.pkl"))
scaler = joblib.load(os.path.join(model_path, "scaler.pkl"))
selector = joblib.load(os.path.join(model_path, "selector.pkl"))

# ترتيب الأعراض
feature_order = [
    "Abdominal Cramps", "Body Aches", "Chest Discomfort", "Chest Pain", "Chest Tightness",
    "Chills", "Confusion", "Convulsions", "Cough", "Cracked Skin",
    "Diarrhea", "Dizziness", "Dry Skin", "Ear Pain", "Facial Pain",
    "Fainting", "Fatigue", "Fever", "Headache", "High Body Temperature",
    "Irritability", "Itchy Skin", "Loss of Appetite", "Mild Fever", "Nasal Congestion",
    "Nausea", "Red Patches", "Red Rash", "Red Throat", "Runny Nose",
    "Shortness of Breath", "Sneezing", "Sore Throat", "Stiff Neck", "Sweating",
    "Swollen Tongue", "Vomiting", "Wheezing", "Allergy Trigger", "Age < 2 years",
    "Bluish Skin", "Dry Cough", "High Fever", "Sudden Onset", "Severe Fatigue",
    "Bulging Fontanelle", "Ear Tugging", "Mouth Sores", "Skin Peeling", "Difficulty Swallowing",
    "Swollen Tonsils", "RSV Pattern", "Febrile Pattern", "DryRespiratory Pattern", "Throat Cluster", "Heat Stroke Pattern"
]

app = Flask(__name__)

@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json()
        print("Received data:", data)  # للمراقبة
        input_data = [data.get(symptom, 0) for symptom in feature_order]
        input_array = np.array([input_data])
        scaled = scaler.transform(input_array)
        selected = selector.transform(scaled)
        prediction = mlp.predict(selected)[0]
        proba = mlp.predict_proba(selected)[0]
        result = {
            "predicted_disease": prediction,
            "probabilities": {
                cls: round(float(prob), 4)
                for cls, prob in zip(mlp.classes_, proba)
                if prob > 0.01
            }
        }
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(port=5000)
