class Event {
  final String id;
  final String title;
  final String category;
  final String date;
  final String time;
  final String location;
  final String address;
  final String description;
  final String aiSummary;
  final int attendees;
  final String imageUrl;
  final double lat;
  final double lng;
  final int aiScore;
  final String distance;

  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.address,
    required this.description,
    required this.aiSummary,
    required this.attendees,
    required this.imageUrl,
    required this.lat,
    required this.lng,
    required this.aiScore,
    required this.distance,
  });
}
