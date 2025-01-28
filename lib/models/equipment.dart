class Equipment {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String category;
  final Map<String, int> rentalPrices;

  Equipment({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.rentalPrices,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      images: List<String>.from(json['images']),
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      category: json['category'],
      rentalPrices: Map<String, int>.from(json['rentalPrices']),
    );
  }
}
