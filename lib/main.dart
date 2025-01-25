import 'package:dormify_mobile/notification_Page.dart';
import 'package:dormify_mobile/pages/chat/chat_detail_page.dart';
import 'package:dormify_mobile/pages/chat/chat_page.dart';
import 'package:dormify_mobile/pages/tenant/rental_page.dart';
import 'package:dormify_mobile/pages/tenant/tenant_home_page.dart';
import 'package:dormify_mobile/pages/tenant/rental_wishlist_page.dart';
import 'package:dormify_mobile/pages/auth_page.dart';
import 'package:dormify_mobile/services/firebase_options.dart';
import 'package:dormify_mobile/services/notificationService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      routes: {
        '/rental': (context) => const RentalPage(),
        '/tenant': (context) => const TenantHomePage(),
        '/wishlist': (context) => const RentalWishlistPage(),
        '/chat': (context) => ChatPage(),
        '/chat/detail': (context) => const ChatDetailPage(),
        '/notification_screen': (context) => const NotificationPage(),
      },
    );
  }
}
