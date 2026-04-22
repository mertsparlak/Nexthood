import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mahalle_connect/data/models/event.dart';
import 'package:mahalle_connect/features/events/data/event_repository.dart';

class EventListState {
  final List<Event> events;
  final int total;
  final bool isLoading;
  final String? error;
  final String? categoryFilter;

  const EventListState({
    this.events = const [],
    this.total = 0,
    this.isLoading = false,
    this.error,
    this.categoryFilter,
  });

  EventListState copyWith({
    List<Event>? events,
    int? total,
    bool? isLoading,
    String? error,
    String? categoryFilter,
  }) {
    return EventListState(
      events: events ?? this.events,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      categoryFilter: categoryFilter ?? this.categoryFilter,
    );
  }
}

class EventListNotifier extends StateNotifier<EventListState> {
  final EventRepository _repo;

  EventListNotifier(this._repo) : super(const EventListState()) {
    fetchEvents();
  }

  Future<void> fetchEvents({String? category}) async {
    state = state.copyWith(isLoading: true, error: null, categoryFilter: category);
    try {
      final response = await _repo.fetchEvents(category: category);
      state = state.copyWith(
        events: response.events,
        total: response.total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load events');
    }
  }

  Future<void> refresh() async {
    await fetchEvents(category: state.categoryFilter);
  }
}

final eventListProvider = StateNotifierProvider<EventListNotifier, EventListState>((ref) {
  return EventListNotifier(ref.watch(eventRepositoryProvider));
});
