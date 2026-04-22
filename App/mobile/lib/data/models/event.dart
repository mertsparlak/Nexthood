import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  final String id;
  @JsonKey(name: 'creator_id')
  final String? creatorId;
  final String title;
  final String? description;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'is_free')
  final bool isFree;
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @JsonKey(name: 'location_name')
  final String? locationName;
  final String category;
  @JsonKey(name: 'event_url')
  final String? eventUrl;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Event({
    required this.id,
    this.creatorId,
    required this.title,
    this.description,
    this.imageUrl,
    required this.isFree,
    required this.startDate,
    this.endDate,
    this.locationName,
    required this.category,
    this.eventUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);
}

@JsonSerializable()
class EventListResponse {
  final List<Event> events;
  final int total;
  final int offset;
  final int limit;

  const EventListResponse({
    required this.events,
    required this.total,
    required this.offset,
    required this.limit,
  });

  factory EventListResponse.fromJson(Map<String, dynamic> json) =>
      _$EventListResponseFromJson(json);
}
