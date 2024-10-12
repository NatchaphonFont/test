import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ศูนย์การช่วยเหลือ',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.yellow,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: const Text(
                'ยินดีต้อนรับสู่ศูนย์การช่วยเหลือ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.orangeAccent, thickness: 2),
            const SizedBox(height: 16),
            const Text(
              'คำถามที่พบบ่อย',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 8),
            _buildFaqItem(
              'จะติดต่อฝ่ายสนับสนุนได้อย่างไร?',
              'คุณสามารถติดต่อฝ่ายสนับสนุนได้โดยการส่งอีเมลไปยัง support@example.com หรือโทรไปที่หมายเลข 123-456-7890.',
            ),
            const SizedBox(height: 16),
            _buildFaqItem(
              'ฉันจะรีเซ็ตรหัสผ่านได้อย่างไร?',
              'คุณสามารถรีเซ็ตรหัสผ่านของคุณได้โดยไปที่หน้าจอการตั้งค่าและเลือก "รีเซ็ตรหัสผ่าน".',
            ),
            const SizedBox(height: 16),
            _buildFaqItem(
              'ฉันสามารถเปลี่ยนแปลงข้อมูลส่วนตัวได้หรือไม่?',
              'ได้ คุณสามารถเปลี่ยนแปลงข้อมูลส่วนตัวของคุณได้โดยไปที่หน้าจอโปรไฟล์และเลือก "แก้ไขข้อมูลส่วนตัว".',
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.orangeAccent, thickness: 2),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: const Text(
                'หากคุณต้องการความช่วยเหลือเพิ่มเติม กรุณาติดต่อเรา',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          question,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
