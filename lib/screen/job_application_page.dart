import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobApplicationPage extends StatefulWidget {
  const JobApplicationPage({Key? key}) : super(key: key);

  @override
  _JobApplicationPageState createState() => _JobApplicationPageState();
}

class _JobApplicationPageState extends State<JobApplicationPage> {
  String? _selectedOccupation;
  final List<String> _occupations = [
    'ช่างไฟฟ้า',
    'ช่างประปา',
    'ช่างซ่อมบำรุง',
    'วิศวกร',
    'ออกแบบ',
    'รีโนเวทบ้าน',
    'ช่างทาสี',
  ];

  final TextEditingController _portfolioLink1Controller =
      TextEditingController();
  final TextEditingController _portfolioLink2Controller =
      TextEditingController();
  final TextEditingController _portfolioLink3Controller =
      TextEditingController();
  final TextEditingController _portfolioLink4Controller =
      TextEditingController();
  final TextEditingController _portfolioLink5Controller =
      TextEditingController();
  final TextEditingController _portfolioLink6Controller =
      TextEditingController();
  final TextEditingController _pageController = TextEditingController();
  final TextEditingController _lineIdController = TextEditingController();
  final TextEditingController _profileCoverController = TextEditingController();

  bool _isLoading = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _submitApplication() async {
    if (_selectedOccupation == null ||
        _profileCoverController.text.trim().isEmpty ||
        (_portfolioLink1Controller.text.trim().isEmpty &&
            _portfolioLink2Controller.text.trim().isEmpty &&
            _portfolioLink3Controller.text.trim().isEmpty &&
            _portfolioLink4Controller.text.trim().isEmpty &&
            _portfolioLink5Controller.text.trim().isEmpty &&
            _portfolioLink6Controller.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'กรุณากรอกข้อมูลให้ครบถ้วน โดยใส่ลิงค์รูปปกหน้าโปรไฟล์และลิงค์ผลงานอย่างน้อย 1 ลิงค์')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
        'occupation': _selectedOccupation,
        'profileCover': _profileCoverController.text.trim(),
        'portfolioLinks': [
          _portfolioLink1Controller.text.trim(),
          _portfolioLink2Controller.text.trim(),
          _portfolioLink3Controller.text.trim(),
          _portfolioLink4Controller.text.trim(),
          _portfolioLink5Controller.text.trim(),
          _portfolioLink6Controller.text.trim(),
        ].where((link) => link.isNotEmpty).toList(),
        'page': _pageController.text.trim().isEmpty
            ? '-'
            : _pageController.text.trim(),
        'lineID': _lineIdController.text.trim().isEmpty
            ? '-'
            : _lineIdController.text.trim(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('สมัครอาชีพสำเร็จ!')),
      );

      Navigator.pop(context, true); // กลับไปยังหน้า home_screen พร้อมรีเฟรช
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครอาชีพ', style: TextStyle(color: Colors.black)),
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
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'เลือกอาชีพ',
                        border: OutlineInputBorder(),
                      ),
                      items: _occupations.map((String occupation) {
                        return DropdownMenuItem<String>(
                          value: occupation,
                          child: Text(occupation),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOccupation = newValue;
                        });
                      },
                      value: _selectedOccupation,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _profileCoverController,
                      decoration: const InputDecoration(
                        labelText: 'ลิงค์รูปปกหน้าโปรไฟล์ (บังคับ)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกลิงค์รูปปกหน้าโปรไฟล์';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(6, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: [
                            _portfolioLink1Controller,
                            _portfolioLink2Controller,
                            _portfolioLink3Controller,
                            _portfolioLink4Controller,
                            _portfolioLink5Controller,
                            _portfolioLink6Controller,
                          ][index],
                          decoration: InputDecoration(
                            labelText: 'ลิงค์ผลงานที่ ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pageController,
                      decoration: const InputDecoration(
                        labelText: 'เพจ (ถ้าไม่มีใส่ - )',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lineIdController,
                      decoration: const InputDecoration(
                        labelText: 'LineID (ถ้าไม่มีใส่ - )',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitApplication,
                      child: const Text('สมัครอาชีพ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
