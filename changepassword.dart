import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      final currentPassword = _currentPasswordController.text.trim();
      final newPassword = _newPasswordController.text.trim();

      try {
        // Re-authenticate user
        final cred = EmailAuthProvider.credential(
          email: user!.email!,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(cred);

        // Update password
        await user.updatePassword(newPassword);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Password has changed successfully",textAlign: TextAlign.center,),
          backgroundColor: Colors.green,
        ));

        _formKey.currentState!.reset();
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

      } on FirebaseAuthException catch (e) {
        String message = "Erreur : ${e.message}";
        if (e.code == 'wrong-password') {
          message = "Mot de passe actuel incorrect.";
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ));
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change password ',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500)),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white,size: 30 ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPasswordField(" actual password ", _currentPasswordController),
              SizedBox(height: 16),
              _buildPasswordField("New password ", _newPasswordController),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm the new password ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords does not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              _isLoading ? CircularProgressIndicator() : ElevatedButton(
                onPressed: _changePassword,
                child: Text("Change the password",style: TextStyle(color: Colors.white,fontSize: 16),),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)
                  ),
                  minimumSize: Size(double.infinity, 60),
                  backgroundColor: Colors.blue.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return ' try enter $label';
        } else if (value.length < 8) {
          return 'Password must contain at least 8 characters';
        }
        return null;
      },
    );
  }
}
