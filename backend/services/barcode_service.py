import httpx

async def get_nutrition_data(upc: str):
    url = f"https://world.openfoodfacts.org/api/v0/product/{upc}.json"
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        if response.status_code == 200:
            data = response.json()
            if data.get("status") == 1:
                product = data["product"]
                return {
                    "name": product.get("product_name", "Unknown Product"),
                    "calories": product.get("nutriments", {}).get("energy-kcal_100g", 0),
                    "protein": product.get("nutriments", {}).get("proteins_100g", 0),
                    "fat": product.get("nutriments", {}).get("fat_100g", 0),
                    "carbs": product.get("nutriments", {}).get("carbohydrates_100g", 0),
                    "brand": product.get("brands", "Unknown Brand"),
                    "image": product.get("image_url"),
                    "serving_size": product.get("serving_size", "100g")
                }
        return None
