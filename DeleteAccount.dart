import 'package:app1/login_page.dart';
import 'package:flutter/material.dart';

class DeleteAccountPage extends StatefulWidget {
  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  bool _confirmDelete = false;
  final TextEditingController _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Delete Account',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold ),),
        iconTheme: IconThemeData(color: Colors.white,size: 30 ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Deletion Warning',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 10),
            Text(
              'Deleting your account will:',
              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey.shade500),
            ),
            SizedBox(height: 5),
            Text('• Permanently remove all your energy data'),
            Text('• Delete your profile information'),
            Text('• Cancel any active subscriptions'),
            SizedBox(height: 20),
            Text(
              'Reason for leaving (optional):',
              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey.shade500),
            ),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'Help us improve our service...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  activeColor: Colors.blue,
                  value: _confirmDelete,
                  onChanged: (v) => setState(() => _confirmDelete = v!),
                ),
                Expanded(
                  child: Text(
                    'I understand that this action cannot be undone and all my data will be permanently deleted.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.only(top: 300),
              child: ElevatedButton(
                onPressed: _confirmDelete ? _deleteAccount : null,
                child: Text('Permanently Delete Account',style: TextStyle(color: Colors.white,fontSize: 16),),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  ),
                  backgroundColor: Colors.red.shade400,
                  minimumSize: Size(double.infinity, 60),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you absolutely sure you want to delete your account and all associated data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDeletion();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _performDeletion() {
    // Simuler la suppression du compte
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account deletion in progress...')),
    );

    Future.delayed(Duration(seconds: 2), () {
      if(!mounted) return
      // Rediriger vers la page de connexion après suppression
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
      );

    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}