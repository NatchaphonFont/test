import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'personal_info_page.dart';
import 'job_application_page.dart';
import 'job_hiring_page.dart'; // Correct import for JobHiringPage
import 'privacy_page.dart'; // Import the PrivacyPage class
import 'help_center_page.dart'; // Import the HelpCenterPage class

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  String? _profileImageUrl;
  String? _email;
  String? _occupation;
  bool _isLoading = true;

  final String defaultImageUrl =
      'https://drive.google.com/uc?id=1ONnSB_riKEr_7XZuxY1WEfwtc7BU1fJZ'; // URL รูปโปรไฟล์เริ่มต้นจาก Google Drive

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _profileImageUrl = userDoc['profileImageUrl'] ??
              defaultImageUrl; // ใช้รูปโปรไฟล์เริ่มต้นถ้าไม่มี
          _email = userDoc['email'] ?? _user?.email ?? '';
          _occupation = userDoc['occupation'] ?? 'ผู้ใช้ทั่วไป';
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถโหลดข้อมูลโปรไฟล์ได้: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshProfile() {
    _loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'โปรไฟล์',
          style: TextStyle(color: Colors.black),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImageUrl != null &&
                            _profileImageUrl!.isNotEmpty
                        ? NetworkImage(_profileImageUrl!)
                        : NetworkImage(
                            defaultImageUrl), // ใช้รูปโปรไฟล์เริ่มต้นจาก Google Drive
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ยินดีต้อนรับ, ${_email ?? 'Guest'}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'อาชีพ: ${_occupation ?? 'ผู้ใช้ทั่วไป'}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MyApp()),
                      );
                    },
                    child: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.work),
                    title: const Text('ประวัติจ้างงาน'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JobHiringPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('ข้อมูลส่วนตัว'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonalInfoPage(
                            onProfileUpdated: _refreshProfile,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.business_center),
                    title: const Text('สมัครอาชีพ'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      bool result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JobApplicationPage(),
                        ),
                      );
                      if (result == true) {
                        _refreshProfile(); // อัพเดตข้อมูลในหน้าโปรไฟล์
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('ความเป็นส่วนตัว'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('ศูนย์การช่วยเหลือ'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpCenterPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
