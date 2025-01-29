class Equipment {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String category;
  final Map<String, double> rentalPrices;
  final double price;

  Equipment({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.rentalPrices,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'category': category,
      'rentalPrices': rentalPrices,
      'price': price,
    };
  }

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      images: List<String>.from(json['images']),
      rating: json['rating'],
      reviewCount: json['reviewCount'],
      category: json['category'],
rentalPrices: json['rentalPrices'] != null
  ? Map<String, double>.from(json['rentalPrices'])
  : {},
      price: json['price'],
    );
  }
}
