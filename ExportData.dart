import 'package:flutter/material.dart';

class ExportDataPage extends StatefulWidget {
  @override
  _ExportDataPageState createState() => _ExportDataPageState();

}

class _ExportDataPageState extends State<ExportDataPage> {

  final List<String> _exportOptions = [
    'CSV (Excel compatible)',
    'JSON (Developer friendly)',
    'PDF Report',
    'Google Sheets'
  ];

  bool _energy = false;
  bool _estimations = false;
  bool _effinciencytips = false;
  bool _comparecons = false ;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // Mettre à jour la date sélectionnée
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white,size: 30 ),
        backgroundColor: Colors.blue,
        title: const Text('Export Data',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold ),),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select data range to export:',
              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey.shade600,fontSize: 16),
            ),

            SizedBox(height: 10),

            _buildDateRangeSelector(),

            SizedBox(height: 20),

            Text(
              'Export format:',
              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey.shade600,fontSize: 16),
            ),
            SizedBox(height: 10),

            DropdownButtonFormField<String>(
              items: _exportOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {},
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),

            SizedBox(height: 20),

            Text(
              'Data to include:',
              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey.shade600),
            ),

            _buildDataCheckbox(
                'Energy consumption',
                _energy,
                 (v) => setState(() => _energy = v)
            ),

            _buildDataCheckbox(
                'Views estimation',
                _estimations,
               (v) => setState(() => _estimations = v)
            ),

            _buildDataCheckbox(
                'Efficiency tips',
                _effinciencytips,
                (v) => setState(() => _effinciencytips = v)
            ),

            _buildDataCheckbox(
                'Compare consumption',
                _comparecons,
                (v) => setState(() => _comparecons = v)
            ),




            Spacer(),


            ElevatedButton.icon(

              onPressed: () => _exportData(context),
              icon: Icon(Icons.download,color: Colors.white,),
              label: Text('Export Data',style: TextStyle(color: Colors.white,fontSize: 16),),
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

  Widget _buildDateRangeSelector() {
    return Row(
      children: [

        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'From',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('to'),
        ),

        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'To',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
        ),

      ],
    );
  }

  Widget _buildDataCheckbox(String label, bool value,ValueChanged<bool> onChanged) {
    return CheckboxListTile(
      activeColor: Colors.blue,
      title: Text(label),
      value: value,
      onChanged: (v) => onChanged(v!) ,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }


  void _exportData(BuildContext context) {
    // Simuler l'exportation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Started'),
        content: Text('Your data export is being prepared. You will receive a notification when it\'s ready.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}