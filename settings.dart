import 'package:app1/changepassword.dart';
import 'package:app1/settingsPages/DatasharingRef.dart';
import 'package:app1/settingsPages/DeleteAccount.dart';
import 'package:app1/settingsPages/ExportData.dart';
import 'package:app1/settingsPages/Help&FaQ.dart';
import 'package:app1/settingsPages/AlertsPage.dart';
import 'package:app1/settingsPages/SetConsumptionGoels.dart';
import 'package:flutter/material.dart';
import 'package:app1/profil_page.dart';
import 'package:app1/calculate_consumption.dart';



class SettingsPage extends StatefulWidget {
  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage>  {
  bool change = false ;





  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Settings',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold ),),
          iconTheme: IconThemeData(color: Colors.white,size: 30 ),
        ),

        body: ListView(
          padding: EdgeInsets.only(top:7,bottom: 14 ) ,
          children: [

            const SectionHeader(title: "Energy Settings : "),

            Card(
              margin: EdgeInsets.only(top: 10,left: 14,right: 14),
              child: ListTile(
                minTileHeight: 70,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                leading: const Icon(Icons.trending_up, color: Colors.deepOrangeAccent ,size: 30,),
                tileColor: Colors.blueGrey.shade100,
                title: const Text("Set Consumption Goals",style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SetConsumptionGoalsPage() ));

                },
              ),
            ),

            Card(
              margin: EdgeInsets.only(top: 10,left: 14,right: 14),
              child: ListTile(
                minTileHeight: 70,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                leading: const Icon(Icons.warning, color: Colors.red ,size: 30,),
                tileColor: Colors.blueGrey.shade100,
                title: const Text("Alert Thresholds",style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SimpleAlertPage() ));

                },
              ),
            ),


            const SectionHeader(title: "Account : " ),
            Card(
              margin: EdgeInsets.only(top: 10,left: 14,right: 14),
              child: ListTile(
                minTileHeight: 70,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                leading: const Icon(Icons.person, color: Colors.blueAccent ,size: 30,),
                tileColor: Colors.blueGrey.shade100,
                title: const Text("Profile",style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                },
              ),
            ),

            Card(
              margin: EdgeInsets.only(top: 10,left: 14,right: 14),
              child: ListTile(
                minTileHeight: 70,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                leading: const Icon(Icons.lock, color: Colors.black38 ,size: 30,),
                tileColor: Colors.blueGrey.shade100,
                title: const Text("Change Password",style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordPage()));

                },
              ),
            ),


            const SectionHeader(title: "Privacy & Data : "),
            Card(
              margin: EdgeInsets.only(top: 7,left: 14,right: 14),
              child: ListTile(
                minTileHeight: 70,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                leading: const Icon(Icons.shield, color: Colors.blue ,size: 30,),
                tileColor: Colors.blueGrey.shade100,
                title: const Text("Data Sharing Preferences",style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DataSharingPage() ));

                },
              ),
            ),

            Card(
              margin: EdgeInsets.only(top: 10,left: 14,right: 14),
              child: ListTile(
                minTileHeight: 70,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                leading: const Icon(Icons.file_download, color: Colors.deepOrangeAccent ,size: 30,),
                tileColor: Colors.blueGrey.shade100,
                title: const Text("Export Data",style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ExportDataPage()));

                },
              ),
            ),

            Card(
              margin: EdgeInsets.only(top: 10,left: 14,right: 14),
              child: ListTile(
                minTileHeight: 70,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                leading: const Icon(Icons.delete_forever, color: Colors.red ,size: 30,),
                tileColor: Colors.blueGrey.shade100,
                title: const Text("Delete Account",style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DeleteAccountPage()));

                },
              ),
            ),


            const SectionHeader(title: "About : "),

            Card(
              margin: EdgeInsets.only(top: 7,left: 14,right: 14),
              child: ListTile(
                minTileHeight: 70,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                leading: const Icon(Icons.info, color: Colors.blueAccent ,size: 30,),
                tileColor: Colors.blueGrey.shade100,
                title: const Text("App Version",style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: const Text("1.0.0"),
              ),
            ),

            Card(
              margin: EdgeInsets.only(top: 10,left: 14,right: 14),
              child: ListTile(
                minTileHeight: 70,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                leading: const Icon(Icons.help, color: Colors.teal ,size: 30,),
                tileColor: Colors.blueGrey.shade100,
                title: const Text("Help & FAQ",style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HelpCenterPage()));

                },
              ),
            ),


          ],
        ),
      ) ;

  }
}


class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.green[900],
          fontWeight: FontWeight.bold,
          fontSize: 20
        ),
      ),
    );
  }
}




