from fastapi import FastAPI, UploadFile, File, Form
from .services import barcode_service, gemini_service
import json

app = FastAPI(title="NutriScan API")

@app.get("/")
async def root():
    return {"message": "NutriScan API is running"}

@app.post("/scan/barcode")
async def scan_barcode(upc: str = Form(...)):
    data = await barcode_service.get_nutrition_data(upc)
    if data:
        return {"status": "success", "data": data}
    return {"status": "error", "message": "Product not found"}

@app.post("/scan/image")
async def scan_image(image: UploadFile = File(...)):
    image_bytes = await image.read()
    result_text = await gemini_service.analyze_food_image(image_bytes)
    
    try:
        # Attempt to clean and parse JSON from Gemini's response
        # Gemini often wraps JSON in markdown blocks
        clean_json = result_text.strip()
        if clean_json.startswith("```json"):
            clean_json = clean_json.replace("```json", "").replace("```", "").strip()
        
        data = json.loads(clean_json)
        return {"status": "success", "data": data}
    except Exception as e:
        return {"status": "error", "message": "Failed to parse AI response", "raw": result_text}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
