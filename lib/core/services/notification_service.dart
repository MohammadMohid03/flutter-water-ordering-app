import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission from the user (the admin)
    await _firebaseMessaging.requestPermission();

    // You can handle notifications that are received while the app is in the foreground here
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  Future<void> subscribeToNewOrders() async {
    print("Subscribing admin to new_orders topic");
    await _firebaseMessaging.subscribeToTopic('new_orders');
  }

  Future<void> unsubscribeFromNewOrders() async {
    print("Unsubscribing admin from new_orders topic");
    await _firebaseMessaging.unsubscribeFromTopic('new_orders');
  }
}