import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

class PersonalInfoPage extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const PersonalInfoPage({Key? key, this.onProfileUpdated}) : super(key: key);

  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _workingHoursController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _subDistrictController = TextEditingController();

  User? _user;
  String? _profileImageUrl;
  String? _occupation;
  bool _isLoading = true;

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedSubDistrict;
  final String _selectedCountry = 'Thailand';

  final String defaultImageUrl =
      'https://drive.google.com/uc?id=1ONnSB_riKEr_7XZuxY1WEfwtc7BU1fJZ'; // URL รูปโปรไฟล์เริ่มต้นจาก Google Drive

  List<String> provinces = [];
  List<String> districts = [];
  List<String> subDistricts = [];
  List<Map<String, dynamic>> locations = [];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      _loadLocations().then((_) {
        _loadUserProfile();
      });
    } else {
      _loadLocations();
    }
  }

  Future<void> _loadLocations() async {
    try {
      final jsonString = await rootBundle.loadString('assets/locations.json');
      final jsonResponse = json.decode(jsonString) as List<dynamic>;

      locations = jsonResponse.map((e) => e as Map<String, dynamic>).toList();

      setState(() {
        provinces = locations
            .map<String>((location) => location['province'].trim())
            .toSet()
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถโหลดข้อมูลจังหวัดได้: $e')),
      );
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .set({
          'displayName': _user?.displayName ?? 'ผู้ใช้ใหม่',
          'profileImageUrl': defaultImageUrl,
          'email': _user?.email ?? '',
          'occupation': 'ผู้ใช้ทั่วไป',
          'province': '',
          'district': '',
          'subDistrict': '',
          'country': 'Thailand',
          'workingHours': '',
        }, SetOptions(merge: true));
        userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();
      }

      setState(() {
        _nameController.text = userDoc['displayName'] ?? '';
        _profileImageUrl = userDoc['profileImageUrl'] ?? defaultImageUrl;
        _imageUrlController.text = _profileImageUrl!;
        _occupation = userDoc['occupation'] ?? 'ผู้ใช้ทั่วไป';
        _selectedProvince = userDoc['province'] ??
            (provinces.isNotEmpty ? provinces.first : null);
        _selectedDistrict = userDoc['district'] ?? '';
        _selectedSubDistrict = userDoc['subDistrict'] ?? '';
        _workingHoursController.text = userDoc['workingHours'] ?? '';

        _filterDistrictsAndSubDistricts();
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถโหลดข้อมูลโปรไฟล์ได้: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterDistrictsAndSubDistricts() {
    if (_selectedProvince != null) {
      districts = locations
          .where((location) => location['province'].trim() == _selectedProvince)
          .map<String>((location) => location['district'].trim())
          .toSet()
          .toList();

      if (_selectedDistrict != null) {
        subDistricts = locations
            .where((location) =>
                location['province'].trim() == _selectedProvince &&
                location['district'].trim() == _selectedDistrict)
            .map<String>((location) => location['subDistrict'].trim())
            .toList();
      }
    }
  }

  Future<void> _updateProfile() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
        'displayName': _nameController.text,
        'profileImageUrl': _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : defaultImageUrl,
        'email': _user?.email,
        'occupation': _occupation ?? 'ผู้ใช้ทั่วไป',
        'province': _selectedProvince,
        'district': _selectedDistrict,
        'subDistrict': _selectedSubDistrict,
        'country': _selectedCountry,
        'workingHours': _workingHoursController.text,
      }, SetOptions(merge: true));

      setState(() {
        _profileImageUrl = _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : defaultImageUrl;
      });

      await _loadUserProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อัปเดตโปรไฟล์เรียบร้อยแล้ว!')),
      );

      if (widget.onProfileUpdated != null) {
        widget.onProfileUpdated!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถอัปเดตโปรไฟล์ได้: $e')),
      );
    }
  }

  Future<void> _deleteProfileImage() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
        'profileImageUrl': defaultImageUrl,
      }, SetOptions(merge: true));

      setState(() {
        _profileImageUrl = defaultImageUrl;
        _imageUrlController.text = defaultImageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบรูปโปรไฟล์เรียบร้อยแล้ว!')),
      );

      if (widget.onProfileUpdated != null) {
        widget.onProfileUpdated!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถลบรูปโปรไฟล์ได้: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('ข้อมูลส่วนตัว', style: TextStyle(color: Colors.black)),
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
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImageUrl != null &&
                              _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!)
                          : NetworkImage(defaultImageUrl),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _deleteProfileImage,
                      child: const Text('ลบรูปโปรไฟล์'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _user?.email ?? '',
                      decoration: const InputDecoration(
                        labelText: 'อีเมล',
                        border: OutlineInputBorder(),
                        suffixText: 'ไม่สามารถแก้ไขได้',
                        suffixStyle: TextStyle(color: Colors.red),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _occupation ?? 'ผู้ใช้ทั่วไป',
                      decoration: const InputDecoration(
                        labelText: 'อาชีพ',
                        border: OutlineInputBorder(),
                        suffixText: 'ไม่สามารถแก้ไขได้',
                        suffixStyle: TextStyle(color: Colors.red),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อเต็ม',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL ของรูปโปรไฟล์',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedProvince?.isNotEmpty == true
                          ? _selectedProvince
                          : (provinces.isNotEmpty ? provinces.first : null),
                      items: provinces.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedProvince = newValue;
                          _selectedDistrict = null;
                          _selectedSubDistrict = null;
                          _filterDistrictsAndSubDistricts();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'จังหวัด',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict != null &&
                              districts.contains(_selectedDistrict)
                          ? _selectedDistrict
                          : (districts.isNotEmpty ? districts.first : null),
                      items: districts.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedDistrict = newValue;
                          _selectedSubDistrict = null;
                          _filterDistrictsAndSubDistricts();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'อำเภอ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedSubDistrict != null &&
                              subDistricts.contains(_selectedSubDistrict)
                          ? _selectedSubDistrict
                          : (subDistricts.isNotEmpty
                              ? subDistricts.first
                              : null),
                      items: subDistricts.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSubDistrict = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'ตำบล',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _selectedCountry,
                      decoration: const InputDecoration(
                        labelText: 'ประเทศ',
                        border: OutlineInputBorder(),
                        suffixText: 'ไม่สามารถแก้ไขได้',
                        suffixStyle: TextStyle(color: Colors.red),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _workingHoursController,
                      decoration: const InputDecoration(
                        labelText: 'เวลาทำงาน',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text('บันทึกข้อมูล'),
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
