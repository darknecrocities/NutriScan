class FoodItem {
  final String name;
  final String? description;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;
  final String? brand;
  final String? imageUrl;
  final String? explanation;

  FoodItem({
    required this.name,
    this.description,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.brand,
    this.imageUrl,
    this.explanation,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] ?? 'Unknown Food',
      description: json['description'],
      calories: (json['calories'] as num).toInt(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      brand: json['brand'],
      imageUrl: json['image'],
      explanation: json['explanation'],
    );
  }
}
