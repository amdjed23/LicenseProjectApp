import 'package:app1/SavingBill.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EnergyEfficiencyTipsPage extends StatefulWidget {
  const EnergyEfficiencyTipsPage({Key? key}) : super(key: key);

  @override
  State<EnergyEfficiencyTipsPage> createState() => _EnergyEfficiencyTipsPageState();
}

class _EnergyEfficiencyTipsPageState extends State<EnergyEfficiencyTipsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white,size: 30 ),
          title: Text('Energy-Saving Tips',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          backgroundColor: Colors.blue
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Heating & Cooling (40% of energy use)'),

            Container(
              height: 360,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: BorderRadius.circular(8)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTipCard(
                    'Optimal Temperatures',
                    '20°C in winter, 26°C in summer\nReduce by 1°C to save 7% on heating',
                    Icons.thermostat,
                  ),
                  _buildTipCard(
                    'Maintenance',
                    'Clean HVAC filters monthly\nSeal windows/doors to prevent drafts',
                    Icons.home_repair_service,
                  ),
                  _buildTipCard(
                    'Smart Habits',
                    'Use curtains to retain heat/block sun\nClose doors to unused rooms',
                    Icons.lightbulb_outline,
                  ),
                ],
              ),
            ),




            _buildSectionHeader('Lighting (15% of energy use)'),

            Container(
              height: 210 ,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTipCard(
                    'LED Bulbs',
                    'Use 75% less energy than incandescent',
                    Icons.lightbulb,
                  ),
                  _buildTipCard(
                    'Smart Lighting',
                    'Install motion sensors\nMaximize natural daylight',
                    Icons.motion_photos_on,
                  ),
                ],
              ),
            ),



            _buildSectionHeader('Appliances & Electronics'),

            Container(
              height: 240,
              decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTipCard(
                    'Refrigerator',
                    'Keep at 4°C (fridge), -18°C (freezer)\nDefrost regularly',
                    Icons.kitchen,
                  ),
                  _buildTipCard(
                    'Washing Machine',
                    'Wash full loads at 30°C\nAir-dry clothes when possible',
                    Icons.local_laundry_service,
                  ),
                ],
              ),
            ),

            _buildSectionHeader('Water Heating (12% of energy use)'),

            Container(
              height: 240,
              decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTipCard(
                    'Temperature Setting',
                    'Set water heater to 60°C for optimal efficiency',
                    Icons.water_damage,
                  ),
                  _buildTipCard(
                    'Water Saving',
                    'Install low-flow showerheads\nFix leaks promptly',
                    Icons.shower,
                  ),
                ],
              ),
            ),



            _buildSectionHeader('Behavioral Changes'),

            Container(
              height: 240,
              decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTipCard(
                    'Peak Hours',
                    'Avoid heavy appliance use during high-rate periods',
                    Icons.access_time,
                  ),
                  _buildTipCard(
                    'Seasonal Adjustments',
                    'Winter: Use rugs and layered clothing\nSummer: Use fans before AC',
                    Icons.sunny,
                  ),
                ],
              ),
            ),



            _buildSavingsCalculator(),

            SizedBox(height: 20),
            Text(
              'Implementing these tips could save you 15-25% on your energy bills!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String content, IconData icon) {
    return Card(
      margin: EdgeInsets.only(left: 10,right: 10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.blue[900]),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsCalculator() {
    return Card(
      color: Colors.blueGrey[100],
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Potential Savings Calculator',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'See how much you could save by implementing these tips:',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SavingsCalculatorPage() ));

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Calculate My Savings',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}