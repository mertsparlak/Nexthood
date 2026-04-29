/// Etkinlik gezinme log servisi — Kullanıcının etkinlik tıklamalarını takip eder.
///
/// Her tıklamada bir log kaydı oluşturur, buffer'da biriktirir ve
/// belirli aralıklarla (veya buffer dolunca) toplu olarak backend'e gönderir.
///
/// Backend bağlantısı yokken loglar yerel olarak tutulur ve
/// API client mock modunda sessizce çalışır.
import 'dart:async';
import 'api_client.dart';

class BrowsingLogEntry {
  final String eventId;
  final String action;
  final String eventCategory;
  final String? eventLocationName;
  final String? sourceScreen;
  final DateTime timestamp;

  BrowsingLogEntry({
    required this.eventId,
    required this.action,
    required this.eventCategory,
    this.eventLocationName,
    this.sourceScreen,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'action': action,
        'event_category': eventCategory,
        'event_location_name': eventLocationName,
        'source_screen': sourceScreen,
      };
}

/// Singleton log servisi — uygulama boyunca tek bir instance kullanılır.
class BrowsingLogService {
  static final BrowsingLogService _instance = BrowsingLogService._internal();
  factory BrowsingLogService() => _instance;
  BrowsingLogService._internal();

  final ApiClient _api = ApiClient();
  final List<BrowsingLogEntry> _buffer = [];
  Timer? _flushTimer;

  static const int _maxBufferSize = 10;
  static const Duration _flushInterval = Duration(seconds: 30);

  /// Servisi başlatır — periyodik flush timer'ı kurar.
  void init() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_flushInterval, (_) => flush());
  }

  /// Servisi durdurur — kalan logları gönderir.
  Future<void> dispose() async {
    _flushTimer?.cancel();
    await flush();
  }

  // ────────────────────────────────────────────
  // Log kayıt metotları
  // ────────────────────────────────────────────

  /// Etkinlik kartına tıklandığında (feed, ai picks gibi listelerde).
  void logCardClick({
    required String eventId,
    required String category,
    String? locationName,
    required String sourceScreen,
  }) {
    _addLog(BrowsingLogEntry(
      eventId: eventId,
      action: 'click_card',
      eventCategory: category,
      eventLocationName: locationName,
      sourceScreen: sourceScreen,
    ));
  }

  /// Etkinlik detay sayfası açıldığında.
  void logDetailView({
    required String eventId,
    required String category,
    String? locationName,
  }) {
    _addLog(BrowsingLogEntry(
      eventId: eventId,
      action: 'click_detail',
      eventCategory: category,
      eventLocationName: locationName,
      sourceScreen: 'event_detail',
    ));
  }

  /// Harita üzerinde marker'a tıklandığında.
  void logMapMarkerClick({
    required String eventId,
    required String category,
    String? locationName,
  }) {
    _addLog(BrowsingLogEntry(
      eventId: eventId,
      action: 'click_map_marker',
      eventCategory: category,
      eventLocationName: locationName,
      sourceScreen: 'map_view',
    ));
  }

  // ────────────────────────────────────────────
  // Buffer yönetimi
  // ────────────────────────────────────────────

  void _addLog(BrowsingLogEntry entry) {
    _buffer.add(entry);
    if (_buffer.length >= _maxBufferSize) {
      flush();
    }
  }

  /// Buffer'daki logları toplu olarak backend'e gönderir.
  Future<void> flush() async {
    if (_buffer.isEmpty) return;

    final logsToSend = List<BrowsingLogEntry>.from(_buffer);
    _buffer.clear();

    try {
      await _api.post('/logs/browse/batch', {
        'logs': logsToSend.map((l) => l.toJson()).toList(),
      });
    } catch (e) {
      // Gönderim başarısızsa logları geri ekle (veri kaybını önle)
      _buffer.insertAll(0, logsToSend);
    }
  }

  /// Mevcut buffer boyutunu döner (debug/test amaçlı).
  int get bufferSize => _buffer.length;
}
