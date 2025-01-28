class GymRoom {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final int capacity;
  final Map<String, double> prices; // Почасовая, дневная стоимость
  final List<String> equipment;
  final double rating;
  final int reviewCount;
  final bool isAvailable;

  GymRoom({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.capacity,
    required this.prices,
    required this.equipment,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
  });
}
