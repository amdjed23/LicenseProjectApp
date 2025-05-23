import 'package:app1/CompareConsumption.dart';
import 'package:app1/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotifications{
  final _firebaseMessaging = FirebaseMessaging.instance ;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    String? token = await _firebaseMessaging.getToken();
    print("Token : $token");
    handleBackgroundNotification();
  }
  
  void handleMessege(RemoteMessage? message ){
    if(message == null ) return ;
    navigatorkey.currentState!.pushNamed(NotificationScreen().routeName,arguments: message);
  }

  Future handleBackgroundNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessege);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessege);

  }


}

class NotificationScreen {
  String get routeName => "notif" ;


}