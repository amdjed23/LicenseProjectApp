import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class EnergyData {
  final String period;
  final double realconsumption;
  final double estimation;
  EnergyData({required this.period, required this.realconsumption, required this.estimation});
}

class EstimationData {
  final String period;
  final double estimation;

  EstimationData({required this.period, required this.estimation});
}

class EstimationDataScreen extends StatelessWidget {

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  double calculerCoutGaz(double consommationM3) { // calculate cost estimation for gaz
    double cout = 0.0;

    if (consommationM3 <= 25) {
      cout = consommationM3 * 0.326;
    } else if (consommationM3 <= 60) {
      cout = (25 * 0.326) + ((consommationM3 - 25) * 1.348);
    } else {
      cout = (25 * 0.326) + (35 * 1.348) + ((consommationM3 - 60) * 2.025);
    }

    return cout;
  }

  double calculerCoutElectricite(double consommationKWh) { // calculate estimation cost for electricity
    double cout = 0.0;

    if (consommationKWh <= 125) {
      cout = consommationKWh * 0.416;
    } else if (consommationKWh <= 250) {
      cout = (125 * 0.416) + ((consommationKWh - 125) * 0.621);
    } else if (consommationKWh <= 1000) {
      cout = (125 * 0.416) + (125 * 0.621) + ((consommationKWh - 250) * 3.967);
    } else {
      cout = (125 * 0.416) + (125 * 0.621) + (750 * 3.967) + ((consommationKWh - 1000) * 4.175);
    }

    return cout;
  }

  Map<String, dynamic> getEnergyEfficiencyLabel(double energyKwh) {
    if (energyKwh < 350) {
      return {"label": "Excellent ", "color": Colors.green.shade700,};
    } else if (energyKwh < 550) {
      return {"label": "Good ", "color": Colors.lightGreen.shade700,};
    } else if (energyKwh < 700) {
      return {"label": "Average ", "color": Colors.orange,};
    } else {
      return {"label": "Risk ", "color": Colors.red,};
    }
  }

  Map<String, Map<String, EnergyData>> yearlyData = {};
  String currentYear = DateTime.now().year.toString();
  String currentTrimester = 'T1';
  String? selectedYear;
  String? selectedTrimester;

  List<EnergyData> getChartData() {

    if (selectedYear == null && selectedTrimester == null) {
      // Show current year's data by default
      final currentYear = DateTime.now().year.toString();
      return yearlyData[currentYear]?.values.toList() ?? [];
    } else if (selectedYear != null && selectedTrimester == null) {
      // Show selected year's data
      return yearlyData[selectedYear!]?.values.toList() ?? [];
    } else if (selectedYear != null && selectedTrimester != null) {
      // Show specific trimester of selected year
      final data = yearlyData[selectedYear!]?[selectedTrimester!];
      return data != null ? [data] : [];
    }
    return [];


   // if (yearlyData.containsKey(currentYear) ){
   //   return [yearlyData[currentYear]![currentTrimester] ??
   //       EnergyData(period: currentTrimester, realconsumption: 0,estimation: 0)];
   // }
   // return [];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text("Views Estimations ",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white,size: 30 ),
      ),
      body:
      StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('energyconsumption').orderBy('timestemp',descending: true).snapshots(),
        builder: (context, snapshot) {
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
          final data = latestDoc.data() as Map<String, dynamic>;

          final year = data['year'] ?? '' ;
          final trimester = data['trimester'] ?? '' ;

          final estimationtotal = data['estimationmtotal']; // energy for one month
          final estiamtioncost = data['totalestimatedCost']; // ,cost for one month
          final estimatedelect = data['estimatedElect'];
          final estimatedgaz = data['estimatedgas'];
          final convertedGas = data['estimatedGazConverted'];



          return ListView(
            padding: EdgeInsets.only(bottom: 14),
            children: [

              Container(
                margin: EdgeInsets.only(top: 14,left: 14,right: 14),
                child: Text("Trend Analysis :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.green.shade800)),
              ),

              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('energyconsumption').orderBy('date', descending: true).snapshots(),

                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No data available',textAlign: TextAlign.center,),);

                    }

                    yearlyData = {};
                    bool hasValidData = false;


                    for (final doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;


                      final year = data['year']?.toString() ?? DateTime.now().year.toString();
                      final trimester = data['trimester']?.toString() ?? 'T1';

                      final estimation = data['estimationmtotal'] ;
                      final realconsumption = data['totalconsumption'] ?? 0.0;

                      if (realconsumption > 0 || estimation > 0) hasValidData = true;

                      // Update current trimester from the latest document
                      if (year == currentYear) {
                        currentTrimester = trimester;
                      }

                      // Initialize year if not exists
                      yearlyData.putIfAbsent(year, () =>
                      {
                        'T1': EnergyData(period: 'T1', realconsumption: 0, estimation: 0),
                        'T2': EnergyData(period: 'T2', realconsumption: 0, estimation: 0),
                        'T3': EnergyData(period: 'T3', realconsumption: 0, estimation: 0),
                        'T4': EnergyData(period: 'T4', realconsumption: 0, estimation: 0),
                      });

                      yearlyData[year]![trimester] = EnergyData(
                        period: trimester,
                        realconsumption: realconsumption,
                        estimation: yearlyData[year]![trimester]!.estimation + estimation,
                      );
                    }

                    // final chartData = getChartData();

                    List<EnergyData> chartData = [];
                    if (yearlyData.containsKey(currentYear)) {
                      chartData = yearlyData[currentYear]!.values.toList();
                    }


                  return Container(
                    padding: EdgeInsets.all(14),
                    margin: EdgeInsets.all(14),
                    height: 300,
                    decoration: BoxDecoration(
                        color: Colors.blueGrey.shade100,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: chartData.isEmpty
                        ? Center(child: Text('No data to display'))
                        : SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        title: AxisTitle(text: '$year - $trimester'),
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: "Analyse Energy "),
                        interval: 250,
                      ),
                      legend: Legend(
                        isVisible: true,
                        position: LegendPosition.top,
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries>[
                        ColumnSeries<EnergyData, String>(
                          name: 'Real Consumption',
                          dataSource: chartData,
                          xValueMapper: (EnergyData data, _) => data.period,
                          yValueMapper: (EnergyData data, _) => data.realconsumption,
                          color: Colors.red.shade400,
                        ),
                        ColumnSeries<EnergyData, String>(
                          name: 'Estimation ',
                          dataSource: chartData,
                          xValueMapper: (EnergyData data, _) => data.period,
                          yValueMapper: (EnergyData data, _) => data.estimation,
                          color: Colors.green.shade400,
                        ),
                      ],
                    ),
                  );
                }
              ),

              Container(
                margin: EdgeInsets.only(left: 14,right: 14),
                child: Text(" Current Month Estimated Consumption  : ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.green.shade800)),
              ),

              Container(
                padding: EdgeInsets.all(14),
                margin: EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard(
                      icon: Icons.data_usage,
                      title: " Energy : ",
                      value: "${estimationtotal.toStringAsFixed(1)} kWh",
                      color: Colors.blue,
                    ),

                    _buildSummaryCard(
                      icon: Icons.electric_bolt,
                      title: "Electricity :",
                      value: "${estimatedelect.toStringAsFixed(1)} kWh",
                      color: Colors.green,
                    ),

                    _buildSummaryCard(
                      icon: Icons.gas_meter,
                      title: "Gas :",
                      value: "${estimatedgaz.toStringAsFixed(1)} Th / ${convertedGas.toStringAsFixed(1)} Kwh ",
                      color: Colors.orange,
                    ),

                    _buildSummaryCard(
                      icon: Icons.monetization_on,
                      title: " Cost",
                      value: "${estiamtioncost.toStringAsFixed(0)} DA",
                      color: Colors.green,
                    ),

                  ],
                ),
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
        minTileHeight: 65,
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13)),
        trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color,fontSize: 14)),
      ),
    );
  }

}