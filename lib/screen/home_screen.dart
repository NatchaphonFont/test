import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'home_page.dart'
    as customHomePage; // ใช้ alias เพื่อหลีกเลี่ยงการชนกันของชื่อ
import 'search_page.dart';
import 'saved_page.dart';
import 'chat_page.dart';
import 'profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp1());
}

class MyApp1 extends StatelessWidget {
  const MyApp1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ContractorFinder',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const customHomePage.HomePage(), // ใช้ alias เพื่อเรียก HomePage ของเรา
    const SearchPage(),
    SavedPage(),
    const ChatPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'ค้นหา',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'บันทึก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'แชท',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800], // สีของแท็บที่ถูกเลือก
        unselectedItemColor:
            Colors.black, // สีของไอคอนและข้อความของแท็บที่ไม่ได้ถูกเลือก
        unselectedIconTheme: const IconThemeData(
            color: Colors.black), // สีของไอคอนที่ไม่ได้ถูกเลือก
        onTap: _onItemTapped,
      ),
    );
  }
}
