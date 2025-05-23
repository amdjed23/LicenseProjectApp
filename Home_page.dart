import 'dart:io';
import 'package:app1/calculate_consumption.dart';
import 'package:app1/weather.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app1/CompareConsumption.dart';
import 'package:app1/EstimationData.dart';
import 'package:app1/Chatbot.dart';
import 'package:app1/consumptionGraphe.dart';
import 'package:app1/settings.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'profil_page.dart';
import 'login_page.dart';


void main(){
  runApp(
      MaterialApp(
        home: HomePage() ,
      )
  );
}



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();

 // final uid = FirebaseAuth.instance.currentUser!.uid;
}

class EnergyData {
  final String period;
  final double electricity;
  final double gas ;

  EnergyData({required this.period, required this.electricity, required this.gas  });
}




class _HomePageState extends State<HomePage> {


  final User? user = FirebaseAuth.instance.currentUser;

  String username = "Username";

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  String? selectedYear;
  String? selectedTrimester;
 // Map<String, Map<String, EnergyData>> yearlyData = {};


  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        setState(() {
          username = userDoc['username'] ?? "Name is empty";
        });
      } catch (e) {
        setState(() {
          username = "Username";
        });
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  double convertM3toKwh(double gazunit ){ // convert m3 of gaz to kwh
    return gazunit * 11.0 ;
  }

  String currentYear = DateTime.now().toString() ;
  String currentTrimester = "T1" ;
  bool _autoSelectionDone = false;


  String? latestYear;
  String? latestTrimester;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white,size: 30 ),
        actions: [
          // IconButton(onPressed: (){}, icon: Icon(Icons.search,color: Colors.white,size: 30,)),
          TextButton.icon(
            onPressed: (){  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));},
            icon:  Icon(Icons.person,color: Colors.white,size: 30,),
            label:Text("$username ",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 18)) ,

          ),

        ],
      ),
        drawer : Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue,),
                child: Text("Menu", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20)),
              ),
              ListTile(
                leading: Icon(Icons.home,color: Colors.indigo,size: 30,),
                title: Text("Home "),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage())),
              ),
              ListTile(
                leading: Icon(Icons.app_registration_rounded,color: Colors.blue.shade400,size: 30,),
                title: Text("Energy Registration "),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CalculateConsumptionPage())),
              ),
              ListTile(
                leading: Icon(Icons.analytics_rounded,color: Colors.red.shade400,size: 30,),
                title: Text("Check Consumption "),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ConsumptionGraph())),
              ),
              ListTile(
                leading: Icon(Icons.bar_chart_rounded,color: Colors.green,size: 30,),
                title: Text("View Estimations"),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EstimationDataScreen())),
              ),
          //    ListTile(
          //      leading: Icon(Icons.tips_and_updates_rounded,color: Colors.amber.shade600,size: 30,),
          //      title: Text("Energy Saving Tips"),
          //      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TipsPage())),
          //    ),
              ListTile(
                leading: Icon(Icons.stacked_line_chart_rounded,color: Colors.red.shade200,size: 30,),
                title: Text("Compare Consumption "),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CompareConsumptionPage())),
              ),
              ListTile(
                leading: Icon(Icons.smart_toy_rounded,color: Colors.blueAccent.shade200,size: 30,),
                title: Text("Smart Assistant "),
               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatBotApp())),
              ),

             // ListTile(
               // leading: Icon(Icons.sunny_snowing,color: Colors.yellow.shade800,size: 30,),
               // title: Text(" Check the weather "),
               // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WeatherPage(cityName: '',))),
             // ),

              Divider(height: 20,thickness: 2,color: Colors.blue.shade900,),
              
              ListTile(
                leading: Icon(Icons.settings,color: Colors.blueAccent.shade700,size: 30,),
                title: Text("Settings"),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage() ) ) ,
                
              ),

              ListTile(
                leading: Icon(Icons.exit_to_app_rounded,color: Colors.red.shade500,size: 30,),
                title: Text("Exit "),
                onTap: () => exit(0) ,
              )

            ],
          ),
        ),
      body:

      StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('energyconsumption').orderBy('timestemp',descending: true).snapshots() ,

          builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available',style: TextStyle(color: Colors.black87),textAlign: TextAlign.center,));
          }

          // Get latest data for the summary cards
          final latestDoc = snapshot.data!.docs.first;
          final latestData = latestDoc.data() as Map<String, dynamic>;

          final year = latestData['year'] ?? '' ;
          final trimester = latestData['trimester'] ?? '' ;


          final costActual = latestData['cost'] ?? 0.0;
          final electricity = latestData['electricityusage'] ?? 0.0;
          final gas = latestData['gazusage'] ?? 0.0;
          final convertedGas = convertM3toKwh(gas);

         // final chartData = getChartData();



          return ListView(

            children: [

              Container(
                margin: EdgeInsets.only(top: 14,left: 14,right: 14),
                child: Text("Summary of Energy Usage :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.green.shade800)),
              ),

             Container(
               padding: EdgeInsets.all(14),
               margin: EdgeInsets.all(14),
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(8),
                 color: Colors.blueGrey.shade100
               ),
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   _buildSummaryCard(
                     icon: Icons.electric_bolt,
                     title: "Electricity Usage",
                     value: "${electricity.toStringAsFixed(1)} kWh",
                     color: Colors.green,
                   ),
                   _buildSummaryCard(
                     icon: Icons.gas_meter,
                     title: "Gas Usage",
                     value: "${gas.toStringAsFixed(1)} Th (${convertedGas.toStringAsFixed(0)} kWh)",
                     color: Colors.orange,
                   ),
                   _buildSummaryCard(
                     icon: Icons.monetization_on,
                     title: "Current Cost",
                     value: "${costActual.toStringAsFixed(0)} DA",
                     color: Colors.green,
                   ),
                 ],
               ),
             ),


              Container(
                margin: EdgeInsets.all(14),
                child: Text("Consumption Trends :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.green.shade800)),
              ),



              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('energyconsumption').orderBy('timestemp',descending: true).snapshots() ,

                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No data available',style: TextStyle(color: Colors.black87),textAlign: TextAlign.center,));
                    }

                    final List<EnergyData> chartData = [
                      EnergyData(
                        period: "$year - $trimester",
                        electricity: electricity,
                        gas: gas,
                      )
                    ];



                   // final chartData = getChartData();

                  return Container(
                    height: 350,
                    margin: EdgeInsets.all(14),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.blueGrey.shade100
                    ),
                    child:  SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        title: AxisTitle(text: 'Consumption'),
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: ""),
                        interval: 250,
                      ),
                      legend: Legend(
                        isVisible: true,
                        position: LegendPosition.top,
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries>[
                        ColumnSeries<EnergyData, String>(
                          name: 'Gas (m³)',
                          dataSource: chartData,
                          xValueMapper: (EnergyData data, _) => data.period,
                          yValueMapper: (EnergyData data, _) => data.gas,
                          color: Colors.orange,
                        ),
                        ColumnSeries<EnergyData, String>(
                          name: 'Electricity (kWh)',
                          dataSource: chartData,
                          xValueMapper: (EnergyData data, _) => data.period,
                          yValueMapper: (EnergyData data, _) => data.electricity,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  );
                }
              ),



            ],
          );
        }
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




