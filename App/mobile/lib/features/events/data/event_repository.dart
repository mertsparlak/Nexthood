import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mahalle_connect/core/network/api_client.dart';
import 'package:mahalle_connect/data/models/event.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(dio: ref.watch(dioProvider));
});

class EventRepository {
  final Dio _dio;

  EventRepository({required Dio dio}) : _dio = dio;

  Future<EventListResponse> fetchEvents({
    String? category,
    String? search,
    double? lat,
    double? lng,
    double radiusKm = 10.0,
    int offset = 0,
    int limit = 20,
  }) async {
    final response = await _dio.get('/events', queryParameters: {
      if (category != null) 'category': category,
      if (search != null) 'search': search,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'radius_km': radiusKm,
      'offset': offset,
      'limit': limit,
    });
    return EventListResponse.fromJson(response.data);
  }

  Future<Map<String, dynamic>> fetchEventById(String eventId) async {
    final response = await _dio.get('/events/$eventId');
    return response.data;
  }

  Future<Event> createEvent({
    required String title,
    required String category,
    required DateTime startDate,
    String? description,
    DateTime? endDate,
    String? locationName,
    double? lat,
    double? lng,
    String? imageUrl,
    bool isFree = true,
  }) async {
    final response = await _dio.post('/events', data: {
      'title': title,
      'category': category,
      'start_date': startDate.toIso8601String(),
      if (description != null) 'description': description,
      if (endDate != null) 'end_date': endDate.toIso8601String(),
      if (locationName != null) 'location_name': locationName,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (imageUrl != null) 'image_url': imageUrl,
      'is_free': isFree,
    });
    return Event.fromJson(response.data);
  }

  Future<void> rsvp(String eventId, String status) async {
    await _dio.post('/events/$eventId/rsvp', data: {'status': status});
  }

  Future<void> logInteraction(String eventId, String action) async {
    await _dio.post('/events/$eventId/log', data: {'action': action});
  }
}
