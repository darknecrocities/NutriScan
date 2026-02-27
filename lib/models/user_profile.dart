class UserProfile {
  final String id;
  final String name;
  final double weight;
  final double height;
  final int age;
  final double bmi;

  UserProfile({
    required this.id,
    required this.name,
    required this.weight,
    required this.height,
    required this.age,
    required this.bmi,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      age: json['age'],
      bmi: (json['bmi'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'height': height,
      'age': age,
      'bmi': bmi,
    };
  }
}
