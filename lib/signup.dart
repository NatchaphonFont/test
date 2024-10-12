import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import the Cloud Firestore package

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();

  Future<void> register() async {
    // Check if all fields are filled
    if (fullNameController.text.trim().isEmpty ||
        user.text.trim().isEmpty ||
        pass.text.trim().isEmpty) {
      Fluttertoast.showToast(
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        msg: 'Please fill out all fields',
        toastLength: Toast.LENGTH_SHORT,
      );
      return; // Exit the function if any field is empty
    }

    try {
      // Attempt to create a new user
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.text.trim(),
        password: pass.text.trim(),
      );

      // Capture full name if needed for further use
      String fullName = fullNameController.text.trim();

      // Set default profile image URL
      String defaultProfileImageUrl =
          'https://drive.google.com/uc?id=1ONnSB_riKEr_7XZuxY1WEfwtc7BU1fJZ';

      // Save the user's data in Firestore with createdAt and profileImageUrl
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'displayName': fullName,
        'email': userCredential.user!.email,
        'occupation': 'ผู้ใช้ทั่วไป', // Default occupation
        'createdAt': FieldValue
            .serverTimestamp(), // Set createdAt to the server timestamp
        'profileImageUrl': defaultProfileImageUrl, // Add profileImageUrl field
      });

      // If successful, show a success message
      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        textColor: Colors.white,
        msg: 'Registration Successful',
        toastLength: Toast.LENGTH_SHORT,
      );

      // Navigate to the dashboard
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MyApp(), // Navigate to the main screen
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';

      // Handle specific error cases
      if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email provided is not valid.';
      }

      // Show error message as a toast
      Fluttertoast.showToast(
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        msg: errorMessage,
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      // Handle any other error
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'An unknown error occurred',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          "Sign up with",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFF3D657),
            height: 2,
          ),
        ),
        const Text(
          "Signup",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF3D657),
            letterSpacing: 2,
            height: 1,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        TextField(
          style: const TextStyle(color: Colors.white),
          controller: fullNameController,
          decoration: InputDecoration(
            hintText: 'Enter Full Name',
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        TextField(
          style: const TextStyle(color: Colors.white),
          controller: user,
          decoration: InputDecoration(
            hintText: 'Enter Email / Username',
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        TextField(
          style: const TextStyle(color: Colors.white),
          obscureText: true,
          controller: pass,
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF3D657),
            borderRadius: const BorderRadius.all(
              Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF3D657).withOpacity(0.4),
                spreadRadius: 4,
                blurRadius: 8,
                offset: const Offset(0, 4), // เพิ่มเงาให้ดูเหมือนปุ่มลอย
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: register,
              borderRadius:
                  BorderRadius.circular(25), // เพิ่มความโค้งมนให้การคลิก
              splashColor: Colors.black26, // สีเอฟเฟกต์เมื่อกดปุ่ม
              highlightColor: Colors.black12, // สีเมื่อกดปุ่ม
              child: const Center(
                child: Text(
                  "SIGN UP",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1C),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        const Text(
          "Or Signup with",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFF3D657),
            height: 1,
          ),
        ),
      ],
    );
  }
}
