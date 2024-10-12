import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'นโยบายความเป็นส่วนตัว',
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color.fromARGB(255, 250, 237, 127)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.privacy_tip,
                        color: Colors.orangeAccent, size: 30),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'นโยบายความเป็นส่วนตัว',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.orangeAccent, thickness: 2),
              const SizedBox(height: 16),
              _buildSectionTitle('การเก็บข้อมูลส่วนบุคคล'),
              _buildSectionContent(
                'เราให้ความสำคัญกับการรักษาความเป็นส่วนตัวของคุณ ข้อมูลส่วนบุคคลของคุณจะถูกเก็บรักษาและใช้ตามที่กำหนดในนโยบายนี้เท่านั้น ข้อมูลส่วนบุคคลที่เราอาจเก็บรวบรวมได้แก่ ชื่อ อีเมล เบอร์โทรศัพท์ และข้อมูลอื่น ๆ ที่คุณให้กับเรา',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('การใช้ข้อมูลส่วนบุคคล'),
              _buildSectionContent(
                'ข้อมูลส่วนบุคคลของคุณจะถูกใช้เพื่อปรับปรุงบริการของเรา เราจะไม่เปิดเผยข้อมูลของคุณให้กับบุคคลที่สามยกเว้นในกรณีที่จำเป็นตามกฎหมายหรือได้รับความยินยอมจากคุณ',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('สิทธิ์ของคุณ'),
              _buildSectionContent(
                'คุณมีสิทธิ์ที่จะเข้าถึง แก้ไข หรือลบข้อมูลส่วนบุคคลของคุณ หากคุณมีข้อสงสัยหรือต้องการใช้สิทธิ์ของคุณ โปรดติดต่อเรา',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('การเปลี่ยนแปลงนโยบาย'),
              _buildSectionContent(
                'เราขอสงวนสิทธิ์ในการปรับปรุงหรือเปลี่ยนแปลงนโยบายความเป็นส่วนตัวนี้โดยไม่ต้องแจ้งให้ทราบล่วงหน้า เราขอแนะนำให้คุณตรวจสอบนโยบายนี้เป็นประจำเพื่อรับทราบข้อมูลที่อัปเดต',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Icon(Icons.label_important, color: Colors.orangeAccent, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orangeAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionContent(String content) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }
}
