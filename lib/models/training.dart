class Training {
  final String id;
  final String name;
  final String description;
  final String trainerName;
  final String imageUrl;
  final int maxParticipants;
  final int currentParticipants;
  final double price;
  final DateTime startTime;
  final DateTime endTime;
  final String roomId;
  final List<String> equipment;
  final double rating;
  final int reviewCount;

  Training({
    required this.id,
    required this.name,
    required this.description,
    required this.trainerName,
    required this.imageUrl,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.price,
    required this.startTime,
    required this.endTime,
    required this.roomId,
    required this.equipment,
    this.rating = 0.0,
    this.reviewCount = 0,
  });
}
