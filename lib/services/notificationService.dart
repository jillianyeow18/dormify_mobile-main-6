import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  // Variable to hold the token
  String? mtoken;
  Timer? _tokenRefreshTimer;

  Future<void> initialize() async {
    await _requestPermission();
    await setupFlutterNotifications();
    await _setupMessageHandlers();

    // Get the initial token and save it
    await getToken();

    // Listen for token changes
    listenToTokenRefresh();

    // Start periodic token refresh
    startTokenRefreshTimer();
  }

  // Request push notification permission
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Permission status: ${settings.authorizationStatus}');
  }

  // Get the FCM token and save it
  Future<void> getToken() async {
    final token = await _messaging.getToken();
    if (token != null && token != mtoken) {
      print('My token is $token');
      mtoken = token;
    }
  }

  // Listen for token changes
  void listenToTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      print('Token refreshed: $newToken');
      mtoken = newToken;
    });
  }

  // Start periodic token refresh
  void startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel(); // Cancel any existing timer
    _tokenRefreshTimer = Timer.periodic(Duration(hours: 12), (timer) async {
      final token = await _messaging.getToken();
      if (token != null && token != mtoken) {
        print('Periodic token refresh detected: $token');
        mtoken = token;
      }
    });
  }

  // Stop the periodic token refresh timer
  void stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
  }

  // Setup local notifications
  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) return;

    // Android Notification Channel Setup
    const channel = AndroidNotificationChannel(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel Name
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialization Settings for Android
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification clicked with payload: ${details.payload}');
      },
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  // Show notification when message is received
  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableLights: true,
            enableVibration: true,
            ticker: 'Notification ticker',
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  // Setup message handlers for foreground and background notifications
  Future<void> _setupMessageHandlers() async {
    // Foreground Messages
    FirebaseMessaging.onMessage.listen((message) {
      print('Foreground message received: ${message.notification?.title}');
      showNotification(message);
    });

    // Background Message when the app is in terminated state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Opened from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  // Handle background message when the app is opened from terminated state
  void _handleBackgroundMessage(RemoteMessage message) {
  navigatorKey.currentState?.pushNamed(
    '/notification_screen',
    arguments: message,
  );
}

}
