import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SetConsumptionGoalsPage extends StatefulWidget {
  const SetConsumptionGoalsPage({Key? key}) : super(key: key);

  @override
  _SetConsumptionGoalsPageState createState() => _SetConsumptionGoalsPageState();
}

class _SetConsumptionGoalsPageState extends State<SetConsumptionGoalsPage> {
  // Variables to store user goals
  double _electricityGoal = 0.0;
  double _gasGoal = 0.0;
  double _currentElectricity = 0.0;
  double _currentGas = 0.0;

  // Controllers for text fields
  final TextEditingController _electricityController = TextEditingController();
  final TextEditingController _gasController = TextEditingController();

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _fetchLatestConsumption();
  }

  @override
  void dispose() {
    _electricityController.dispose();
    _gasController.dispose();
    super.dispose();
  }

  Future<void> _fetchLatestConsumption() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('energyconsumption')
          .orderBy('timestemp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          _currentElectricity = (data['electricityusage'] ?? 0.0).toDouble();
          _currentGas = (data['gazusage'] ?? 0.0).toDouble();
        });
      }
    } catch (e) {
      debugPrint('Error fetching consumption data: $e');
    }
  }

  void _saveGoals() {
    setState(() async {
      _electricityGoal = double.tryParse(_electricityController.text) ?? 0.0;
      _gasGoal = double.tryParse(_gasController.text) ?? 0.0;

      // Save to Firestore
        FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('energyconsumption').add({
          'energyGoals': {
             'electricity': _electricityGoal,
             'gas': _gasGoal,
             'lastUpdated': FieldValue.serverTimestamp(),
          }
     });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Goals saved successfully!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white,size: 30 ),
        title: const Text('Set Consumption Goals',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Electricity Goal Section
                _buildGoalSection(
                  title: "Electricity (kWh)",
                  goal: _electricityGoal,
                  current: _currentElectricity,
                  controller: _electricityController,
                ),

                const SizedBox(height: 20),

                // Gas Goal Section
                _buildGoalSection(
                  title: "Gas (Th )",
                  goal: _gasGoal,
                  current: _currentGas,
                  controller: _gasController,
                ),

                const SizedBox(height: 20),

                // Save Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                        ),
                        minimumSize: Size(double.infinity, 60),
                        backgroundColor: Colors.blue
                    ),
                    onPressed: _saveGoals,
                    child: const Text('Save Goals',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )

    );
  }

  Widget _buildGoalSection({
    required String title,
    required double goal,
    required double current,
    required TextEditingController controller,
  }) {
    double progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Set $title Goal',
                suffixText: title.contains('Electricity') ? 'kWh' : 'Th',
                border: OutlineInputBorder(),
                hintText: 'Enter your target',
              ),
            ),
            const SizedBox(height: 10),
            if (goal > 0) ...[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                color: progress > 0.8 ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 5),
              Text(
                'Current: ${current.toStringAsFixed(1)} ${title.contains('Electricity') ? 'kWh' : 'Th'}',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                'Progress: ${(progress * 100).toStringAsFixed(1)} % of goal',
                style: TextStyle(
                  color: progress > 0.8 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
     );
    }
  }
