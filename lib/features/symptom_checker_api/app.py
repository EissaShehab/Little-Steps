# from flask import Flask, request, jsonify
# import pickle
# import numpy as np
# import traceback
# from flask_cors import CORS
# print("📦 Starting Flask Symptom Checker API...")

# # تحميل الملفات المحفوظة
# with open("mlp_final_model.pkl", "rb") as f:
#     model = pickle.load(f)

# with open("scaler.pkl", "rb") as f:
#     scaler = pickle.load(f)

# with open("selector.pkl", "rb") as f:
#     selector = pickle.load(f)

# # إعداد التطبيق
# app = Flask(__name__)
# CORS(app)  # للسماح بالوصول من تطبيق Flutter

# @app.route("/")
# def home():
#     return "✅ Symptom Checker API is running."

# @app.route("/predict", methods=["POST"])
# def predict():
#     try:
#         data = request.get_json()

#         if not data or "features" not in data:
#             return jsonify({"error": "Missing 'features' key"}), 400

#         features = np.array(data["features"]).reshape(1, -1)
#         scaled = scaler.transform(features)
#         selected = selector.transform(scaled)
#         prediction = model.predict(selected)[0]

#         recommendation = classify_recommendation(prediction)

#         return jsonify({
#             "prediction": prediction,
#             "recommendation": recommendation
#         })

#     except Exception as e:
#         traceback.print_exc()
#         return jsonify({"error": str(e)}), 500

# def classify_recommendation(disease):
#     emergency = ["Meningitis", "Sepsis"]
#     consult = ["Otitis Media", "Pneumonia"]

#     if disease in emergency:
#         return "Emergency"
#     elif disease in consult:
#         return "Call Doctor"
#     else:
#         return "Monitor at Home"

# if __name__ == "__main__":
#     app.run(host="0.0.0.0", port=5000, debug=True)
