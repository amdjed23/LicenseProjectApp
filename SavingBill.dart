import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsCalculatorPage extends StatefulWidget {
  const SavingsCalculatorPage({Key? key}) : super(key: key);

  @override
  _SavingsCalculatorPageState createState() => _SavingsCalculatorPageState();
}

class _SavingsCalculatorPageState extends State<SavingsCalculatorPage> {
  String? get uid => FirebaseAuth.instance.currentUser?.uid;
  double _savingsPercentage = 15;
  double _calculatedSavings = 0;
  double _currentBill = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateSavings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saving Bills Calculator',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white,size: 30 ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('energyconsumption')
            .orderBy('timestemp',descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No energy data available'));
          }

          final latestDoc = snapshot.data!.docs.first;
          final latestData = latestDoc.data() as Map<String, dynamic>;
          _currentBill = (latestData['cost'] ?? latestData['totalestimatedCost'] ?? 0.0).toDouble();
          _isLoading = false;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Your Current Monthly Cost',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${_currentBill.toStringAsFixed(2)} DA',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30),

                Text(
                  'Adjust Savings Percentage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Slider(
                  value: _savingsPercentage,
                  min: 5,
                  max: 40,
                  divisions: 7,
                  label: '${_savingsPercentage.round()}%',
                  onChanged: (value) {
                    setState(() {
                      _savingsPercentage = value;
                      _calculateSavings();
                    });
                  },
                ),

                SizedBox(height: 30),

                Container(
                  padding: EdgeInsets.all(20),
                  height: 200,
                  width: 315,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade800,width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Potential Monthly Savings',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${_calculatedSavings.toStringAsFixed(2)} DA',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'New Estimated Bill: ${(_currentBill - _calculatedSavings).toStringAsFixed(2)} DA',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Annual Savings: ${(_calculatedSavings * 12).toStringAsFixed(2)} DA',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  'Tips to achieve these savings:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ..._buildSavingsTips(_savingsPercentage.round()),
              ],
            ),
          );
        },
      ),
    );
  }

  void _calculateSavings() {
    setState(() {
      _calculatedSavings = _currentBill * (_savingsPercentage / 100);
    });
  }

  List<Widget> _buildSavingsTips(int percentage) {
    if (percentage <= 15) {
      return [
        _buildTipItem('Adjust thermostat by 1-2 degrees'),
        _buildTipItem('Switch 5 lights to LED bulbs'),
        _buildTipItem('Unplug unused electronics'),
      ];
    } else if (percentage <= 25) {
      return [
        _buildTipItem('Install smart thermostat'),
        _buildTipItem('Seal windows and doors'),
        _buildTipItem('Use appliances during off-peak hours'),
      ];
    } else {
      return [
        _buildTipItem('Upgrade to energy-efficient appliances'),
        _buildTipItem('Consider solar water heating'),
        _buildTipItem('Improve home insulation'),
      ];
    }
  }

  Widget _buildTipItem(String text) {
    return Card(
      margin: EdgeInsets.only(left: 30,right: 30,top: 10),
      color: Colors.blueGrey.shade100,
      child: ListTile(
           title: Text(text),
           leading: Icon(Icons.check_circle_rounded,color: Colors.green,size: 23,),
        ),
      );
  }
}