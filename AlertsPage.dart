import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';




class SimpleAlertPage extends StatefulWidget {
  @override
  _SimpleAlertPageState createState() => _SimpleAlertPageState();
}

class _SimpleAlertPageState extends State<SimpleAlertPage> {
  // Electricity Threshold
  double _electricityThreshold = 100.0; // Default: 50 kWh
  bool _notificationsEnabled = true;
  double _gasThreshold = 50.0; // Default: 30 m³
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  double _currentElectricity = 0.0;
  double _currentGas = 0.0;

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _checkInitialNotificationStatus();
    _loadCurrentConsumption();
  }

  Future<void> _loadCurrentConsumption() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('energyconsumption')
        .orderBy('timestemp',descending: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        _currentElectricity = data['electricityusage'] ?? 0.0;
        _currentGas = data['gazusage'] ?? 0.0;
      });
    }
  }

  Future<void> _checkInitialNotificationStatus() async {
    // Check current permission status
    final settings = await _messaging.getNotificationSettings();
    setState(() {
      _notificationsEnabled =
          settings.authorizationStatus == AuthorizationStatus.authorized;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // Request permission if enabling
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      setState(() {
        _notificationsEnabled =
            settings.authorizationStatus == AuthorizationStatus.authorized;
      });

      if (_notificationsEnabled) {
        _showTestNotification();
      }
    } else {
      setState(() => _notificationsEnabled = false);
    }
  }

  Future<void> _showTestNotification() async {
    if (_notificationsEnabled) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Notifications are now active"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showNotification(String title, String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(message),
          ],
        ),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(16),
      ),
    );
  }

  void _checkThresholds() {
    if (_notificationsEnabled) {
      if (_currentElectricity > _electricityThreshold) {
        _showNotification(
          "High Electricity Use! ⚡ ",
          "Your usage (${_currentElectricity.toStringAsFixed(2)}kWh) exceeded ${_electricityThreshold.round()}kWh",
        );
      }
      if (_currentGas > _gasThreshold) {
        _showNotification(
          "High Gas Use! 🔥 ",
          "Your usage (${_currentGas.toStringAsFixed(2)}m³) exceeded ${_gasThreshold.round()}m³",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child:Scaffold(
            appBar: AppBar(
              title: Text("Alerts Thresholds", style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.blue,
              iconTheme: IconThemeData(color: Colors.white,size: 30 ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(

                  children: [

                    SwitchListTile(
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.grey.shade300,
                      inactiveTrackColor: Colors.grey.shade700,
                      title: Text("Enable Alerts"),
                      subtitle: Text(_notificationsEnabled
                          ? "Alerts are active"
                          : "Turn on to receive alerts"),
                      value: _notificationsEnabled,
                      onChanged: _toggleNotifications,
                    ),

                    Divider(height: 30),

                    Card(
                      color: Colors.blue.shade50,

                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text("Current Consumption", style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Electricity : ", style: TextStyle(
                                    fontSize: 18),),
                                Text("${_currentElectricity.toStringAsFixed(
                                    2)} kWh", style: TextStyle(fontSize: 18),),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Gas : ", style: TextStyle(fontSize: 18),),
                                Text("${_currentGas.toStringAsFixed(2)} Th ",
                                  style: TextStyle(fontSize: 18),),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Electricity Threshold
                    Text("Electricity Alert (kWh) ⚡ ",
                        style: TextStyle(fontSize: 18)),
                    Slider(
                      activeColor: Colors.black87,
                      value: _electricityThreshold,
                      min: 10,
                      max: 500,
                      divisions: 9,
                      label: "${_electricityThreshold.round()} kWh",
                      onChanged: (value) =>
                          setState(() => _electricityThreshold = value),
                    ),
                    Text("Alert when > ${_electricityThreshold.round()} kWh"),

                    Divider(height: 30),

                    // Gas Threshold
                    Text("Gas Alert (Th) 🔥 ", style: TextStyle(fontSize: 18)),
                    Slider(
                      activeColor: Colors.black87,
                      value: _gasThreshold,
                      min: 10,
                      max: 100,
                      divisions: 4,
                      label: "${_gasThreshold.round()} Th ",
                      onChanged: (value) => setState(() => _gasThreshold = value),
                    ),

                    Text("Alert when > ${_gasThreshold.round()} Th"),

                    SizedBox(height: 30),

                    // Test Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _notificationsEnabled ? _checkThresholds : null,
                      child: Text("Test Alerts Now",
                          style: TextStyle(color: Colors.white)),
                    ),


                  ]

              ),
            )
        ) );


  }
}

