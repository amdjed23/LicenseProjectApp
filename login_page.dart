import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sign_up_page.dart';
import 'calculate_consumption.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CalculateConsumptionPage()),
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
      appBar: AppBar(
          title: Text("Connexion",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
          centerTitle: true,
          backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white,size: 30 ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
           // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              
              Image.asset("images/logo.png", fit: BoxFit.fill , height: 350,alignment: Alignment.center,),

              Container(
                height: 80,
                margin: EdgeInsets.only(top:20,bottom: 10) ,
                child: Text("Welcome here",style: TextStyle(
                  fontFamily: "serif",
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.blue.shade900
                ),
                 textAlign: TextAlign.center,
                ),
              ),

              TextFormField(
                
                controller: emailController,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.email,color: Colors.blue,) ,
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                validator: (value) => value!.isEmpty ? "Entrez un email" : null,
              ),
              SizedBox(height: 15),
              
              
              TextFormField(
                
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.lock,color: Colors.blue ,) ,
                  labelText: "Mot de passe",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                validator: (value) =>
                value!.isEmpty ? "Entrez un mot de passe" : null,
              ),
              SizedBox(height: 20),
              
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(400, 50) ,
                  backgroundColor: Colors.blue.shade400, // Couleur du bouton
                  foregroundColor: Colors.white, // Couleur du texte
                  padding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5, // Ombre du bouton
                ),
                onPressed: _loginUser,
                child: Text("Login",style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                ),),
              ),


              TextButton(

                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Text("Create account ",style: TextStyle(
                  color: Colors.blue.shade900,
                  fontSize: 18,
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

