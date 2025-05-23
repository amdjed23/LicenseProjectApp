import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        await _firestore.collection("users").doc(userCredential.user!.uid).set({
          "username": usernameController.text,
          "email": emailController.text,
        });
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Inscription successful !")),
        );

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error : ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,title: Text("Inscription",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),backgroundColor: Colors.blue,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            //mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset("images/logo.png", fit: BoxFit.fill , height: 350,alignment: Alignment.center,),
              Container(
                height: 80,
                margin: EdgeInsets.only(top:15,bottom: 10) ,
                child: Text(" Create Account ",style: TextStyle(
                    fontFamily: "serif",
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.blue.shade900
                ), textAlign: TextAlign.center, ),
              ),

              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.person,color: Colors.blue,),
                  labelText: "Full name",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter the username";
                  if (value.length < 5 ) return "Min 5 characters";
                  return null;
                },
              ),
              SizedBox(height: 15),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.email,color: Colors.blue,),
                  labelText: "Email",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter your email";
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Email invalid";
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),


              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.lock,color: Colors.blue,),
                  labelText: "Password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return "Min 8 characters";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),


              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(400, 50) ,
                  backgroundColor: Colors.blue.shade500,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5, // Ombre du bouton
                ),
                onPressed: _registerUser,
                child: Text("Sign-up",style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),),
              ),


              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text("Are you already here ? Login ",style: TextStyle(
                  color: Colors.blue.shade900,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
