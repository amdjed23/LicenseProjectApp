import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ConsumptionGraph extends StatefulWidget {
  @override
  _ConsumptionGraphState createState() => _ConsumptionGraphState();
}

class EnergyData {
  final String period;
  final double gas;
  final double electricity;

  EnergyData({
    required this.period,
    required this.gas,
    required this.electricity,
  });
}

class _ConsumptionGraphState extends State<ConsumptionGraph> {
  String? get uid => FirebaseAuth.instance.currentUser?.uid;
  String? selectedYear;
  String? selectedTrimester;
  Map<String, Map<String, EnergyData>> yearlyData = {};

  Map<String, dynamic> getEnergyEfficiencyLabel(double energyKwh) {
    if (energyKwh < 350) {
      return {"label": "Excellent", "color": Colors.green.shade700};
    } else if (energyKwh < 550) {
      return {"label": "Good", "color": Colors.lightGreen.shade700};
    } else if (energyKwh < 700) {
      return {"label": "Average", "color": Colors.orange};
    } else {
      return {"label": "Risk", "color": Colors.red};
    }
  }

  double convertM3toKwh(double gasUnit) {
    return gasUnit * 11.0;
  }


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

  }
  bool _autoSelectionDone = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Check Consumption",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white,size: 30 ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('energyconsumption')
            .orderBy('timestemp' , descending: true)
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

          yearlyData = {};
          bool hasValidData = false;


          for (final doc in snapshot.data!.docs) {

            final data = doc.data() as Map<String, dynamic>;

            final year = data['year']?.toString() ?? DateTime.now().year.toString();
            final trimester = data['trimester']?.toString() ?? 'T1';


            final electricity = (data['electricityusage'] ?? 0.0).toDouble();
            final gas = (data['gazusage'] ?? 0.0).toDouble();

            if (electricity > 0 || gas > 0) hasValidData = true;


            // Initialize year if not exists
            yearlyData.putIfAbsent(year, () => {
              'T1': EnergyData(period: 'T1', gas: 0, electricity: 0),
              'T2': EnergyData(period: 'T2', gas: 0, electricity: 0),
              'T3': EnergyData(period: 'T3', gas: 0, electricity: 0),
              'T4': EnergyData(period: 'T4', gas: 0, electricity: 0),
            });

            yearlyData[year]![trimester] = EnergyData(
              period: trimester,
              electricity: electricity, // yearlyData[year]![trimester]!.electricity ,
              gas: gas //yearlyData[year]![trimester]!.gas  ,
            );

          }


          // Get latest data for the summary cards
          final latestDoc = snapshot.data!.docs.first;
          final latestData = latestDoc.data() as Map<String, dynamic>;

          if (!_autoSelectionDone) {
            final latestYear = latestData['year']?.toString();
            final latestTrimester = latestData['trimester']?.toString();
            if (latestYear != null && latestTrimester != null) {
              selectedYear = latestYear;
              selectedTrimester = latestTrimester;
              _autoSelectionDone = true;
            }
          }


          final totalconso = latestData['totalconsumption'] ?? 0.0;
          final efficiency = getEnergyEfficiencyLabel(totalconso);
          final costActual = latestData['cost'] ?? 0.0;

          final electricity =   latestData['electricityusage'] ?? 0.0;
          final gas = latestData['gazusage'] ?? 0.0;

          final convertedGas = convertM3toKwh(gas);

          final chartData = getChartData();
          final _availableYears = yearlyData.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView(
            children: [

              Container(
                margin: EdgeInsets.all(14),
                child: Text("Consumption Trends :",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800)),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedYear,
                        hint: Text("Select Year"),
                        items: _availableYears.map((year) {
                          return DropdownMenuItem<String>(
                            value: year,
                            child: Text(year),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedYear = value;
                            selectedTrimester = null;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedTrimester,
                        hint: Text("Select Trimester"),
                        items: (selectedYear != null ? yearlyData[selectedYear]!.keys : yearlyData.values.first.keys)
                            .map((trimester) {
                          return DropdownMenuItem<String>(
                            value: trimester,
                            child: Text(trimester),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedTrimester = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),


                Container(
                    height: 300,
                    margin: EdgeInsets.all(14),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      color: Colors.blueGrey.shade100
                    ),
                    child:  chartData.isEmpty
                        ? Center(child: Text('No data to display'))
                    : SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        title: AxisTitle(text: selectedYear ?? 'Current Year'),
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: "Consumption"),
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
                    ),


              // Summary Cards
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 14,left: 14,right: 14),
                    child: Text(" Current Consumption Trends :",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800)),
                  ),


                  SizedBox(height: 8),

                  Container(
                    height: 430,
                    margin: EdgeInsets.all(14),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blueGrey.shade100
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryCard(
                          icon: Icons.gpp_good,
                          title: "Efficiency Score",
                          value: efficiency["label"],
                          color: efficiency["color"],
                        ),
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
                          icon: Icons.data_usage,
                          title: "Total Consumption",
                          value: "${totalconso.toStringAsFixed(1)} kWh",
                          color: Colors.blue,
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


                ],
              ),
            ],
          );
        },
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