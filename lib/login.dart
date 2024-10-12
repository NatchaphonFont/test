import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screen/home_screen.dart'; // นำเข้า home_screen จากโฟลเดอร์ screen

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future login() async {
    try {
      // เข้าสู่ระบบด้วย Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: user.text,
        password: pass.text,
      );

      if (userCredential.user != null) {
        // Check if the user's data exists in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .get();

        if (!userDoc.exists) {
          // Create user data if it doesn't exist
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user?.uid)
              .set({
            'email': user.text.trim(),
            'lastLogin': FieldValue.serverTimestamp(),
          });
        } else {
          // Update last login time
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user?.uid)
              .update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }

        Fluttertoast.showToast(
          msg: 'Login Successful',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );
        // นำผู้ใช้ไปยังหน้า home_screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyApp1(), // เปลี่ยนเป็น HomeScreen
          ),
        );
      }
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          errorMessage = 'Username does not exist';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password';
        } else {
          errorMessage = 'Error: ${e.message}';
        }
      } else {
        errorMessage = 'An unexpected error occurred.';
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 239, 94),
              Colors.orangeAccent
            ], // ไล่สีจากเหลืองไปส้ม
            begin: Alignment.topLeft, // จุดเริ่มต้นของการไล่สี
            end: Alignment.bottomRight, // จุดสิ้นสุดของการไล่สี
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white, // สีพื้นหลังของ Container
              borderRadius:
                  BorderRadius.circular(25), // เพิ่มความโค้งมนให้กับกรอบสีขาว
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3), // เปลี่ยนการกระจายของเงา
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  "Welcome to",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1C1C1C),
                    height: 2,
                  ),
                ),
                const Text(
                  "Login Page",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1C),
                    letterSpacing: 2,
                    height: 1,
                  ),
                ),
                const Text(
                  "Please login to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 255, 0, 0),
                    height: 1,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: user,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                      color: Colors.black), // เปลี่ยนสีข้อความเป็นสีดำ
                  decoration: InputDecoration(
                    hintText: 'Email / Username',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey, // เปลี่ยนสี hint เป็นสีเทา
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(25), // เพิ่มความโค้งมน
                      borderSide: const BorderSide(
                        color: Colors.transparent, // ลบเส้นขอบ
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white, // เปลี่ยนสีพื้นหลังเป็นสีขาว
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16), // เพิ่ม padding รอบข้อความ
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                      color: Colors.black), // เปลี่ยนสีข้อความเป็นสีดำ
                  controller: pass,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey, // เปลี่ยนสี hint เป็นสีเทา
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(25), // เพิ่มความโค้งมน
                      borderSide: const BorderSide(
                        color: Colors.transparent, // ลบเส้นขอบ
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white, // เปลี่ยนสีพื้นหลังเป็นสีขาว
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16), // เพิ่ม padding รอบข้อความ
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(25), // เพิ่มความโค้งมน
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1C1C1C).withOpacity(0.4),
                        spreadRadius: 4,
                        blurRadius: 8,
                        offset:
                            const Offset(0, 4), // เพิ่มเงาให้ดูเหมือนปุ่มลอย
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: login,
                      borderRadius: BorderRadius.circular(
                          25), // เพิ่มความโค้งมนให้การคลิก
                      splashColor: Colors.white24, // สีเอฟเฟกต์เมื่อกดปุ่ม
                      highlightColor: Colors.white10, // สีเมื่อกดปุ่ม
                      child: const Center(
                        child: Text(
                          "LOGIN",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  "FORGOT PASSWORD?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 231, 0, 0),
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
