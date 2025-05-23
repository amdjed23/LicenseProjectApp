import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app1/TipsData.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';

class CompareConsumptionPage extends StatelessWidget {

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> showEnergyNotification(String level) async {
    String title = '';
    String message = '';

    switch (level) {
      case 'Excellent':
        message = 'Excellent✅! Keep up the good work🔋!';
        break;
      case 'Good':
        message = 'Good 🙂, but there\'s room to improve 💡. ';
        break;
      case 'Average':
        message = 'Warning ⚠️! You\'re using too much energy🚪.';
        break;
      case 'Risk':
        message = 'High risk!🔥 Your energy use is critical❗️. ';
        break;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'energy_channel', // channel ID
      'Energy Notifications', // channel name
      channelDescription: 'Notifications about energy usage',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,// ID de notification
      message,
      platformDetails,
    );
  }

  Map<String, dynamic> getTip(String level) {
    final efficiencyInfo = getEnergyEfficiencyLabel(0);
    switch (level) {
      case "Excellent":
        return {
          ...efficiencyInfo,
          "label": 'You\'re an energy-saving star! Maintain these habits.',
          "icon": Icons.check_circle_rounded,
          "specificTip": "Consider investing in solar panels to maximize savings",
        };
      case "Good":
        return {
          ...efficiencyInfo,
          "label": 'Try unplugging devices when not in use.',
          "icon": Icons.tips_and_updates_rounded,
          "specificTip": "Upgrade to smart power strips to eliminate phantom loads",
        };
      case "Average":
        return {
          ...efficiencyInfo,
          "label": 'Check for air leaks in home insulation.',
          "icon": Icons.warning,
          "specificTip": "Schedule an HVAC system checkup to improve efficiency",
        };
      case "Risk":
        return {
          ...efficiencyInfo,
          "label": 'Consider an energy audit or switching to LED lighting.',
          "icon": Icons.local_fire_department_rounded,
          "specificTip": "Immediate energy audit recommended",
        };
      default:
        return {
          ...efficiencyInfo,
          "label": 'Start tracking energy usage for tips.',
          "icon": Icons.help_outline,
          "specificTip": "Install energy monitoring devices",
        };
    }
  }

  Map<String, dynamic> getEnergyEfficiencyLabel(double energyKwh) {

    if (energyKwh < 350) {
      return {
        "level": "Excellent",
        "color": Colors.green.shade900,
        "description": "Your energy usage is very efficient!",
      };
    } else if (energyKwh < 550) {
      return {
        "level": "Good",
        "color": Colors.lightGreen.shade800,
        "description": "Your usage is better than average.",
      };
    } else if (energyKwh < 700) {
      return {
        "level": "Average",
        "color": Colors.orange.shade700,
        "description": "Your usage is typical but could improve.",
      };
    } else {
      return {
        "level": "Risk",
        "color": Colors.red,
        "description": "Your usage is higher than recommended.",
      };
    }
  }

  // Ideal apartment values (you can adjust them)
  final double idealElectricity = 150.0; // kWh
  final double idealGas = 80.0; // m³


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white,size: 30 ),
        backgroundColor: Colors.blue,
        title: Text("Compare Consumption",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),

        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('energyconsumption').orderBy('timestemp',descending: true).snapshots() ,

            builder: (context, snapshot)  {

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No data available',textAlign: TextAlign.center,),);

              }

              final latestDoc = snapshot.data!.docs.first;
              final latestData = latestDoc.data() as Map<String, dynamic>;

              final totalconso = latestData['totalconsumption'] ?? 0.0;

              final costimpact = latestData['cost'] ?? 0.0;
              final Userelectrecity =   latestData['electricityusage'] ?? 0.0;
              final Usergaz = latestData['gazusage'] ?? 0.0;
             // final efficiencyScore = getEnergyEfficiencyLabel(totalconso);

              final score = getEnergyEfficiencyLabel(totalconso);
              final efficiencyTips = getTip(score['level']);

               showEnergyNotification(score['level']);





            return ListView(
              children: [

                Container(
                  margin: EdgeInsets.only(top: 10,left: 14,right: 14),
                  child: Text("Comparison Overview :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.green.shade800)),
                ),

                // Date & Filters
                SizedBox(height: 10.0),

                // Summary Cards
                Container(
                  height: 260,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 5, left: 13, right: 13),
                  decoration: BoxDecoration(
                      color: Colors.blueGrey.shade100,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Column(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      _buildSummaryCard(
                        icon: Icons.data_usage,
                        title: "Total Consumption",
                        value: "${totalconso.toStringAsFixed(1)} kWh",
                        color: Colors.blue,
                      ),

                      _buildSummaryCard(
                        icon: Icons.monetization_on,
                        title: "Current Cost",
                        value: "${costimpact.toStringAsFixed(0)} DA",
                        color: Colors.green,
                      ),

                      _buildSummaryCard(
                        icon: Icons.gpp_good,
                        title: "Efficiency Score",
                        value: score["level"],
                        color: score["color"],
                      ),

                     // Divider(
                       // height: 8, thickness: 2, color: Colors.blueGrey.shade500,),

                     // Divider(height: 8,
                       // thickness: 2,
                       // color: Colors.blueGrey.shade500,),
                    ],
                  ),
                ),

                SizedBox(height: 10.0),

                Container(
                  margin: EdgeInsets.only(top: 10,left: 14,right: 14),
                  child: Text("Data visualisation :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.green.shade800)),
                ),
                // Charts
                Container(
                  height: 250,
                  margin: EdgeInsets.only(top: 5, left: 13, right: 13),
                  padding: EdgeInsets.only(top: 15, right: 15,bottom: 10),
                  decoration: BoxDecoration(
                      color: Colors.blueGrey.shade100,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.3,
                      child: BarChart(
                        BarChartData(
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return Text('Electricity');
                                    case 1:
                                      return Text('Gas');
                                    default:
                                      return Text('');
                                  }
                                },

                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true,reservedSize: 60),

                            ),
                          ),
                          barGroups: [
                            // Electricity comparison
                            BarChartGroupData(x: 0, barRods: [
                              BarChartRodData(toY: idealElectricity, width: 25, color: Colors.green,borderRadius: BorderRadius.circular(4)),
                              BarChartRodData(toY: Userelectrecity, width: 25, color: Colors.orange,borderRadius: BorderRadius.circular(4)),
                            ]),
                            // Gas comparison
                            BarChartGroupData(x: 1, barRods: [
                              BarChartRodData(toY: idealGas, width: 25, color: Colors.green,borderRadius: BorderRadius.circular(4)),
                              BarChartRodData(toY: Usergaz, width: 25, color: Colors.orange,borderRadius: BorderRadius.circular(4)),
                            ]),
                          ],
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          groupsSpace: 30,
                          barTouchData: BarTouchData(enabled: true),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegend("Optimized", Colors.green),
                    SizedBox(width: 20),
                    _buildLegend("My Apartment", Colors.orange),
                  ],
                ),

                SizedBox(height: 10.0),

                Container(
                  margin: EdgeInsets.only(top: 10,left: 14,right: 14),
                  child: Text("Insights & Recommendations :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.green.shade800)),
                ),

                // Recommendations
                _buildRecommendationCard(efficiencyTips,score),

                SizedBox(height: 10.0),

                Container(
                  margin: EdgeInsets.only(top: 10,left: 14,right: 14),
                  child: Text("Optimized Tips:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.green.shade800)),
                ),

                // Actions
                Container(
                  height: 65,
                  margin: EdgeInsets.only(top: 5, left: 13, right: 13,bottom: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.blueGrey.shade100,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        // icon: Icon(Icons.arrow_forward,color: Colors.green.shade900,),
                        label: Text("View Details", style: TextStyle(
                            color: Colors.green.shade900
                        ),),

                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey.shade700,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)
                            )
                        ),
                        icon: Icon(Icons.arrow_forward, color: Colors.white,),
                        onPressed: () {
                           Navigator.push(context, MaterialPageRoute(builder: (context)=> EnergyEfficiencyTipsPage() ) );
                        },
                        label: Text("Set Energy-Saving Tips", style: TextStyle(
                            color: Colors.white
                        ),),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );

  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        SizedBox(width: 5),
        Text(label),
      ],
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> tips, Map<String, dynamic> score) {
    return Card(
      color: score['color'].withOpacity(0.1),
      margin: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(tips['icon'], color: score['color']),
                const SizedBox(width: 10),
                Text(
                  'Energy Efficiency: ${score["level"]} ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: score['color'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(score['description'],style: TextStyle(fontSize: 14),textAlign: TextAlign.start,),
            const SizedBox(height: 8),
            Text(
              'Recommendation: ${tips['specificTip']}',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 8),
            Text(
              'Go to check :  ${tips['label']}',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        minTileHeight: 70,
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13)),
        trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color,fontSize: 14)),
      ),
    );
  }


}
