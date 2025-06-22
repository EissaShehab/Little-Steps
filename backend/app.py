{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": 7,
   "id": "06e73ba7-b782-485b-99f2-cf5d2495475b",
   "metadata": {},
   "outputs": [],
   "source": [
    "import nest_asyncio\n",
    "nest_asyncio.apply()\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 8,
   "id": "617a60c2-aaa0-43b1-be2f-01c45d5c2ad0",
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      " * Serving Flask app '__main__'\n",
      " * Debug mode: off\n"
     ]
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.\n",
      " * Running on http://127.0.0.1:5000\n",
      "Press CTRL+C to quit\n",
      "127.0.0.1 - - [08/May/2025 23:29:57] \"GET / HTTP/1.1\" 404 -\n",
      "127.0.0.1 - - [08/May/2025 23:29:57] \"GET / HTTP/1.1\" 404 -\n",
      "C:\\Users\\faris\\anaconda3\\Lib\\site-packages\\sklearn\\base.py:493: UserWarning: X does not have valid feature names, but StandardScaler was fitted with feature names\n",
      "  warnings.warn(\n",
      "127.0.0.1 - - [08/May/2025 23:30:56] \"POST /predict HTTP/1.1\" 200 -\n"
     ]
    }
   ],
   "source": [
    "from flask import Flask, request, jsonify\n",
    "import joblib\n",
    "import numpy as np\n",
    "import os\n",
    "\n",
    "# تحميل النموذج والمعالجات\n",
    "model_path = r\"C:\\Users\\faris\\Projects\\Python\\Gradutation\\models\"\n",
    "mlp = joblib.load(os.path.join(model_path, \"mlp_final_model.pkl\"))\n",
    "scaler = joblib.load(os.path.join(model_path, \"scaler.pkl\"))\n",
    "selector = joblib.load(os.path.join(model_path, \"selector.pkl\"))\n",
    "\n",
    "# ترتيب الأعراض\n",
    "feature_order = [\n",
    "    \"Abdominal Cramps\", \"Body Aches\", \"Chest Discomfort\", \"Chest Pain\", \"Chest Tightness\",\n",
    "    \"Chills\", \"Confusion\", \"Convulsions\", \"Cough\", \"Cracked Skin\",\n",
    "    \"Diarrhea\", \"Dizziness\", \"Dry Skin\", \"Ear Pain\", \"Facial Pain\",\n",
    "    \"Fainting\", \"Fatigue\", \"Fever\", \"Headache\", \"High Body Temperature\",\n",
    "    \"Irritability\", \"Itchy Skin\", \"Loss of Appetite\", \"Mild Fever\", \"Nasal Congestion\",\n",
    "    \"Nausea\", \"Red Patches\", \"Red Rash\", \"Red Throat\", \"Runny Nose\",\n",
    "    \"Shortness of Breath\", \"Sneezing\", \"Sore Throat\", \"Stiff Neck\", \"Sweating\",\n",
    "    \"Swollen Tongue\", \"Vomiting\", \"Wheezing\", \"Allergy Trigger\", \"Age < 2 years\",\n",
    "    \"Bluish Skin\", \"Dry Cough\", \"High Fever\", \"Sudden Onset\", \"Severe Fatigue\",\n",
    "    \"Bulging Fontanelle\", \"Ear Tugging\", \"Mouth Sores\", \"Skin Peeling\", \"Difficulty Swallowing\",\n",
    "    \"Swollen Tonsils\", \"RSV Pattern\", \"Febrile Pattern\", \"DryRespiratory Pattern\", \"Throat Cluster\", \"Heat Stroke Pattern\"\n",
    "]\n",
    "\n",
    "app = Flask(__name__)\n",
    "\n",
    "@app.route(\"/predict\", methods=[\"POST\"])\n",
    "def predict():\n",
    "    try:\n",
    "        data = request.get_json()\n",
    "        input_data = [data.get(symptom, 0) for symptom in feature_order]\n",
    "        input_array = np.array([input_data])\n",
    "        scaled = scaler.transform(input_array)\n",
    "        selected = selector.transform(scaled)\n",
    "        prediction = mlp.predict(selected)[0]\n",
    "        proba = mlp.predict_proba(selected)[0]\n",
    "        result = {\n",
    "            \"predicted_disease\": prediction,\n",
    "            \"probabilities\": {\n",
    "                cls: round(float(prob), 4)\n",
    "                for cls, prob in zip(mlp.classes_, proba)\n",
    "                if prob > 0.01\n",
    "            }\n",
    "        }\n",
    "        return jsonify(result)\n",
    "    except Exception as e:\n",
    "        return jsonify({\"error\": str(e)}), 500\n",
    "\n",
    "# تشغيل السيرفر\n",
    "app.run(port=5000)\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": '',
   "id": "78829532-aeaf-4017-a1c2-8d97d15e8514",
   "metadata": {},
   "outputs": [],
   "source": []
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3 (ipykernel)",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.12.7"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
