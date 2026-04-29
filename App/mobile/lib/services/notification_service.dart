/// Bildirim servisi — Backend'den AI tabanlı bildirimleri alır ve yönetir.
///
/// Uygulama açıldığında günlük bildirim üretimini tetikler (günde 1 kez).
/// Mock modda örnek bildirimler gösterir.
import 'api_client.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String notificationType;
  final String? relatedCategory;
  final String? relatedDistrict;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.notificationType,
    this.relatedCategory,
    this.relatedDistrict,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      notificationType: json['notification_type'],
      relatedCategory: json['related_category'],
      relatedDistrict: json['related_district'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiClient _api = ApiClient();

  /// Mock bildirimler — backend bağlantısı olmadan UI'ı test etmek için.
  static final List<AppNotification> _mockNotifications = [
    AppNotification(
      id: 'mock-1',
      title: '🏃 Spor etkinlikleri ilgini çekiyor!',
      body: 'Riverside Park bölgesinde spor etkinlikleri çok ilgi görüyor. Bir spor etkinliği planlamak ister misin?',
      notificationType: 'event_suggestion',
      relatedCategory: 'sports',
      relatedDistrict: 'Riverside Park',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      id: 'mock-2',
      title: '🎵 Müzik etkinlikleri seni bekliyor!',
      body: 'Downtown bölgesinde müzik etkinlikleri popüler. Yakınındaki konserleri keşfetmeye ne dersin?',
      notificationType: 'event_suggestion',
      relatedCategory: 'music',
      relatedDistrict: 'Downtown',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppNotification(
      id: 'mock-3',
      title: '💻 Teknoloji buluşmaları popüler!',
      body: 'Tech District bölgesinde teknoloji etkinlikleri trend. Bir tech meetup planlamak ister misin?',
      notificationType: 'create_event_prompt',
      relatedCategory: 'technology',
      relatedDistrict: 'Tech District',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  /// Bildirimleri getirir. Mock modda örnek bildirimler döner.
  Future<List<AppNotification>> getNotifications() async {
    if (_api.useMock) return _mockNotifications;

    final data = await _api.getList('/notifications');
    if (data == null) return [];
    return data.map((j) => AppNotification.fromJson(j)).toList();
  }

  /// Günlük bildirim üretimini tetikler (uygulama açılışında çağrılır).
  Future<AppNotification?> triggerDailyNotification() async {
    if (_api.useMock) return null; // Mock modda otomatik üretme

    final data = await _api.post('/notifications/generate', {});
    if (data == null || data['status'] == 'mock_ok') return null;
    return AppNotification.fromJson(data);
  }

  /// Bildirimi okundu olarak işaretler.
  Future<void> markAsRead(String notificationId) async {
    if (_api.useMock) {
      // Mock modda lokal olarak güncelle
      final idx = _mockNotifications.indexWhere((n) => n.id == notificationId);
      if (idx >= 0) {
        _mockNotifications[idx] = AppNotification(
          id: _mockNotifications[idx].id,
          title: _mockNotifications[idx].title,
          body: _mockNotifications[idx].body,
          notificationType: _mockNotifications[idx].notificationType,
          relatedCategory: _mockNotifications[idx].relatedCategory,
          relatedDistrict: _mockNotifications[idx].relatedDistrict,
          isRead: true,
          createdAt: _mockNotifications[idx].createdAt,
        );
      }
      return;
    }

    await _api.patch('/notifications/$notificationId');
  }

  /// Okunmamış bildirim sayısını döner.
  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }
}
