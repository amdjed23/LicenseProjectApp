import 'package:flutter/material.dart';

class DataSharingPage extends StatefulWidget {
  @override
  _DataSharingPageState createState() => _DataSharingPageState();
}

class _DataSharingPageState extends State<DataSharingPage> {
  bool _shareAnonymized = false;
  bool _shareForResearch = false;
  bool _shareWithUtility = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Data sharing',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold ),),
        iconTheme: IconThemeData(color: Colors.white,size: 30 ),
      ),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'Control how your anonymized energy data is shared to help improve energy services and research.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            _buildSharingOption(
              'Share anonymized data',
              'Help improve energy algorithms (no personal info)',
              _shareAnonymized,
                  (v) => setState(() => _shareAnonymized = v),
            ),
            _buildSharingOption(
              'Share for research',
              'Contribute to energy efficiency studies',
              _shareForResearch,
                  (v) => setState(() => _shareForResearch = v),
            ),
            _buildSharingOption(
              'Share with utility provider',
              'Get personalized recommendations',
              _shareWithUtility,
                  (v) => setState(() => _shareWithUtility = v),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _savePreferences,
              child: Text('Save Preferences',style: TextStyle(color: Colors.white,fontSize: 18),),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 60),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharingOption(String title, String description, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            activeColor: Colors.blue,
            value: value,
            onChanged: (v) => onChanged(v!),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _savePreferences() {
    // Sauvegarder les préférences
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data sharing preferences updated',style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),backgroundColor: Colors.green,),
    );
    Navigator.pop(context);
  }
}