# NutriScan

NutriScan is a hybrid AI-powered fitness and nutrition management app built with Flutter and a Python backend.

## Architecture

- **Frontend:** Flutter
- **Backend:** FastAPI (Python)
- **AI Integration:** Google Gemini (Image Analysis), MLKit (Barcode Scanning)
- **Data Source:** Open Food Facts API (Barcode Lookup)

## Getting Started

### Backend Setup

1. Navigate to the `backend` directory.
2. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # Or venv\Scripts\activate on Windows
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Create a `.env` file based on `.env.example` and add your `GEMINI_API_KEY`.
5. Start the server:
   ```bash
   python main.py
   ```

### Frontend Setup (Flutter)

1. Ensure you have Flutter installed.
2. Run `flutter pub get`.
3. Update `lib/providers/food_provider.dart` with your backend server's IP address if running on a physical device.
4. Run the app:
   ```bash
   flutter run
   ```

## Features

- [x] Barcode Scanning (MLKit + Open Food Facts)
- [x] Image Recognition (Gemini AI for prepared meals)
- [x] Daily Calorie Dashboard
- [x] Detailed Food Logging with AI explanations
