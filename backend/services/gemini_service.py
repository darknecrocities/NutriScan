import os
import google.generativeai as genai
from PIL import Image
import io
from dotenv import load_dotenv

load_dotenv()

# Load API Key (should be in .env)
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)

async def analyze_food_image(image_bytes: bytes):
    if not GEMINI_API_KEY:
        return {"error": "Gemini API Key not configured"}

    model = genai.GenerativeModel('gemini-1.5-flash')
    
    # Load image from bytes
    image = Image.open(io.BytesIO(image_bytes))
    
    prompt = """
    Analyze this food image. Provide:
    1. A short description of the food.
    2. Estimated calories (total).
    3. Estimated macronutrients (Protein, Fat, Carbs in grams).
    4. An explanation of how you derived these estimates.
    
    Format the response as JSON:
    {
      "name": "Food Name",
      "description": "Short description",
      "calories": 123,
      "protein": 10,
      "fat": 5,
      "carbs": 20,
      "explanation": "Reasoning..."
    }
    """
    
    response = model.generate_content([prompt, image])
    # Note: In a real app, you'd want to parse the JSON response properly.
    # For now, we return the text and let the main handler deal with it.
    return response.text
