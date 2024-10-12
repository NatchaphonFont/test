import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'details_page.dart'; // Import the DetailsPage class

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  String? _displayName;
  String? _occupation;
  bool _doNotShowAgain = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _currentPopupIndex = 0;
  late Timer _timer;

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedSubDistrict;

  final List<String> _slideshowImages = [
    'assets/images/1.jpg',
    'assets/images/2.jpg',
    'assets/images/3.jpg',
    'assets/images/4.jpg',
  ];

  final List<String> _popupImages = [
    'assets/images/8.jpg',
    'assets/images/9.jpg',
    'assets/images/10.jpg',
  ];

  List<String> provinces = [];
  List<String> districts = [];
  List<String> subDistricts = [];
  List<Map<String, dynamic>> locations = [];

  // Map to hold the availability of craftsmen in selected location
  Map<String, bool> craftsmenAvailability = {
    'ช่างไฟฟ้า': false,
    'ช่างประปา': false,
    'ช่างซ่อมบำรุง': false,
    'วิศวกร': false,
    'ออกแบบ': false,
    'รีโนเวทบ้าน': false,
    'ช่างทาสี': false,
  };

  @override
  void initState() {
    super.initState();
    _loadLocations().then((_) {
      _loadHomePageData();
      _startAutoSlide();
      _checkPopupStatus();
      _checkCraftsmenAvailability(); // Check availability on initial load
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
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

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentPage < _slideshowImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _loadHomePageData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _displayName = userDoc['displayName'] ?? 'Guest';
            _occupation = userDoc['occupation'] ?? 'ผู้ใช้ทั่วไป';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถโหลดข้อมูลได้: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkPopupStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? doNotShow = prefs.getBool('doNotShowPopup');
    if (doNotShow == null || !doNotShow) {
      _showImagePopup();
    }
  }

  void _showImagePopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: Image.asset(
                        _popupImages[_currentPopupIndex],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CheckboxListTile(
                        title: Text('ไม่แสดงอีก'),
                        value: _doNotShowAgain,
                        onChanged: (bool? value) {
                          setState(() {
                            _doNotShowAgain = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: GestureDetector(
                  onTap: () async {
                    if (_doNotShowAgain) {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool('doNotShowPopup', true);
                    }
                    Navigator.of(context).pop(); // Close the current pop-up
                    _currentPopupIndex++;
                    if (_currentPopupIndex < _popupImages.length &&
                        !_doNotShowAgain) {
                      _showImagePopup(); // Show the next image
                    } else {
                      _currentPopupIndex = 0; // Reset index if all images shown
                    }
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  void _checkCraftsmenAvailability() async {
    for (String category in craftsmenAvailability.keys) {
      QuerySnapshot snapshot;

      if (_selectedProvince == null &&
          _selectedDistrict == null &&
          _selectedSubDistrict == null) {
        // No location selected, fetch all craftsmen in this category
        snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('occupation', isEqualTo: category)
            .get();
      } else {
        // Filter by selected location
        snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('occupation', isEqualTo: category)
            .where('province', isEqualTo: _selectedProvince)
            .where('district', isEqualTo: _selectedDistrict)
            .where('subDistrict', isEqualTo: _selectedSubDistrict)
            .get();
      }

      setState(() {
        craftsmenAvailability[category] = snapshot.docs.isNotEmpty;
      });
    }
  }

  void _navigateToDetailsPage(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          category: category,
          selectedProvince: _selectedProvince,
          selectedDistrict: _selectedDistrict,
          selectedSubDistrict: _selectedSubDistrict,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ยินดีต้อนรับ ${_displayName ?? 'Guest'}, ${_occupation ?? 'ผู้ใช้ทั่วไป'}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
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
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.yellow.shade100,
                          Colors.yellow.shade700
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slideshowImages.length,
                      itemBuilder: (context, index) {
                        return Image.asset(
                          _slideshowImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'หาช่างง่ายๆ ใกล้บ้านท่าน',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // Dropdown for province
                        DropdownButtonFormField<String>(
                          value: _selectedProvince,
                          decoration: InputDecoration(
                            labelText: 'จังหวัด',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedProvince = value;
                              _selectedDistrict = null;
                              _selectedSubDistrict = null;
                              _filterDistrictsAndSubDistricts();
                              _checkCraftsmenAvailability();
                            });
                          },
                          items: provinces
                              .map((province) => DropdownMenuItem<String>(
                                    value: province,
                                    child: Text(province),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        // Dropdown for district
                        DropdownButtonFormField<String>(
                          value: _selectedDistrict,
                          decoration: InputDecoration(
                            labelText: 'อำเภอ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onChanged: _selectedProvince != null
                              ? (value) {
                                  setState(() {
                                    _selectedDistrict = value;
                                    _selectedSubDistrict = null;
                                    _filterDistrictsAndSubDistricts();
                                    _checkCraftsmenAvailability();
                                  });
                                }
                              : null,
                          items: _selectedProvince != null &&
                                  districts.isNotEmpty
                              ? districts
                                  .map((district) => DropdownMenuItem<String>(
                                        value: district,
                                        child: Text(district),
                                      ))
                                  .toList()
                              : [],
                        ),
                        const SizedBox(height: 16),
                        // Dropdown for subDistrict
                        DropdownButtonFormField<String>(
                          value: _selectedSubDistrict,
                          decoration: InputDecoration(
                            labelText: 'ตำบล',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onChanged: _selectedDistrict != null
                              ? (value) {
                                  setState(() {
                                    _selectedSubDistrict = value;
                                    _checkCraftsmenAvailability();
                                  });
                                }
                              : null,
                          items: _selectedDistrict != null &&
                                  subDistricts.isNotEmpty
                              ? subDistricts
                                  .map(
                                      (subDistrict) => DropdownMenuItem<String>(
                                            value: subDistrict,
                                            child: Text(subDistrict),
                                          ))
                                  .toList()
                              : [],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: <Widget>[
                        CategoryButton(
                          label: 'ช่างไฟฟ้า',
                          icon: Icons.electrical_services,
                          color: craftsmenAvailability['ช่างไฟฟ้า'] ?? false
                              ? Colors.yellow.shade200
                              : Colors.grey.shade300,
                          onPressed: craftsmenAvailability['ช่างไฟฟ้า'] ?? false
                              ? () =>
                                  _navigateToDetailsPage(context, 'ช่างไฟฟ้า')
                              : null,
                        ),
                        CategoryButton(
                          label: 'ช่างประปา',
                          icon: Icons.plumbing,
                          color: craftsmenAvailability['ช่างประปา'] ?? false
                              ? Colors.yellow.shade200
                              : Colors.grey.shade300,
                          onPressed: craftsmenAvailability['ช่างประปา'] ?? false
                              ? () =>
                                  _navigateToDetailsPage(context, 'ช่างประปา')
                              : null,
                        ),
                        CategoryButton(
                          label: 'ช่างซ่อมบำรุง',
                          icon: Icons.build,
                          color: craftsmenAvailability['ช่างซ่อมบำรุง'] ?? false
                              ? Colors.yellow.shade200
                              : Colors.grey.shade300,
                          onPressed:
                              craftsmenAvailability['ช่างซ่อมบำรุง'] ?? false
                                  ? () => _navigateToDetailsPage(
                                      context, 'ช่างซ่อมบำรุง')
                                  : null,
                        ),
                        CategoryButton(
                          label: 'วิศวกร',
                          icon: Icons.engineering,
                          color: craftsmenAvailability['วิศวกร'] ?? false
                              ? Colors.yellow.shade200
                              : Colors.grey.shade300,
                          onPressed: craftsmenAvailability['วิศวกร'] ?? false
                              ? () => _navigateToDetailsPage(context, 'วิศวกร')
                              : null,
                        ),
                        CategoryButton(
                          label: 'ออกแบบ',
                          icon: Icons.design_services,
                          color: craftsmenAvailability['ออกแบบ'] ?? false
                              ? Colors.yellow.shade200
                              : Colors.grey.shade300,
                          onPressed: craftsmenAvailability['ออกแบบ'] ?? false
                              ? () => _navigateToDetailsPage(context, 'ออกแบบ')
                              : null,
                        ),
                        CategoryButton(
                          label: 'รีโนเวทบ้าน',
                          icon: Icons.home_repair_service,
                          color: craftsmenAvailability['รีโนเวทบ้าน'] ?? false
                              ? Colors.yellow.shade200
                              : Colors.grey.shade300,
                          onPressed: craftsmenAvailability['รีโนเวทบ้าน'] ??
                                  false
                              ? () =>
                                  _navigateToDetailsPage(context, 'รีโนเวทบ้าน')
                              : null,
                        ),
                        CategoryButton(
                          label: 'ช่างทาสี',
                          icon: Icons.format_paint,
                          color: craftsmenAvailability['ช่างทาสี'] ?? false
                              ? Colors.yellow.shade200
                              : Colors.grey.shade300,
                          onPressed: craftsmenAvailability['ช่างทาสี'] ?? false
                              ? () =>
                                  _navigateToDetailsPage(context, 'ช่างทาสี')
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      backgroundColor: Colors.white,
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const CategoryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      ),
    );
  }
}
