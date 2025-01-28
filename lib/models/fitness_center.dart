class FitnessCenter {
  final String id;
  final String name;
  final String location;
  final String amenities;
  final double pricePerHour;
  final double rating;

  FitnessCenter({
    required this.id,
    required this.name,
    required this.location,
    required this.amenities,
    required this.pricePerHour,
    required this.rating,
  });

  factory FitnessCenter.fromJson(Map<String, dynamic> json) {
    return FitnessCenter(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      amenities: json['amenities'],
      pricePerHour: json['price_per_hour'].toDouble(),
      rating: json['rating'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'amenities': amenities,
      'price_per_hour': pricePerHour,
      'rating': rating,
    };
  }
}
