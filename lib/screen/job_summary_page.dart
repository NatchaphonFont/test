import 'package:flutter/material.dart';

class JobSummaryPage extends StatelessWidget {
  final Map<String, String> job;

  const JobSummaryPage({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chatMessages = getChatMessagesForJob(job);

    return Scaffold(
      appBar: AppBar(
        title: Text(job['jobTitle']!),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'ผู้รับเหมา: ${job['contractorName']}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'วันที่: ${job['date']}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'รายละเอียดงาน',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              job['description']!,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'สถานะงาน',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'สถานะ: ${job['status']}',
              style: TextStyle(
                fontSize: 18,
                color:
                    job['status'] == 'เสร็จสิ้น' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'การสนทนา',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final message = chatMessages[index];
                  return ChatBubble(
                    text: message['text'],
                    isSender: message['isSender'],
                    time: message['time'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> getChatMessagesForJob(Map<String, String> job) {
    // Define chat messages for each job based on job title
    if (job['jobTitle'] == 'ติดตั้งระบบไฟฟ้า') {
      return [
        {
          'text': 'สวัสดีครับ, สนใจจะติดตั้งระบบไฟฟ้าในบ้านใช่ไหมครับ?',
          'isSender': false,
          'time': '09:30',
        },
        {
          'text': 'ใช่ครับ อยากให้ช่วยมาตรวจสอบระบบให้หน่อยครับ',
          'isSender': true,
          'time': '09:32',
        },
        {
          'text': 'ไม่มีปัญหาครับ รายละเอียดงานมีอะไรบ้างครับ?',
          'isSender': false,
          'time': '09:34',
        },
        {
          'text': 'ติดตั้งระบบไฟฟ้าภายในบ้าน พร้อมตรวจเช็คความปลอดภัยครับ',
          'isSender': true,
          'time': '09:35',
        },
        {
          'text': 'เข้าใจแล้วครับ ค่าบริการจะอยู่ที่ 25,000 บาทครับ',
          'isSender': false,
          'time': '09:36',
        },
        {
          'text': 'ตกลงครับ ผมขอเบอร์โทรของช่างด้วยครับ',
          'isSender': true,
          'time': '09:37',
        },
        {
          'text': 'เบอร์โทรของผมคือ 089-123-4567 ครับ',
          'isSender': false,
          'time': '09:38',
        },
        {
          'text': 'ขอบคุณครับ จะติดตามงานยังไงได้บ้างครับ?',
          'isSender': true,
          'time': '09:39',
        },
        {
          'text': 'ผมจะแจ้งความคืบหน้าทางแชทนี้ครับ แล้วพบกันครับ',
          'isSender': false,
          'time': '09:40',
        },
      ];
    } else if (job['jobTitle'] == 'ทาสีบ้านทั้งหลัง') {
      return [
        {
          'text': 'สวัสดีครับ ต้องการให้ทาสีบ้านใช่ไหมครับ?',
          'isSender': false,
          'time': '14:00',
        },
        {
          'text': 'ใช่ครับ บ้านทั้งหลังเลย รายละเอียดงานคืออะไรครับ?',
          'isSender': true,
          'time': '14:02',
        },
        {
          'text': 'ทาสีภายในและภายนอกบ้านด้วยสีคุณภาพสูงครับ',
          'isSender': false,
          'time': '14:03',
        },
        {
          'text': 'ราคาประมาณเท่าไหร่ครับ?',
          'isSender': true,
          'time': '14:04',
        },
        {
          'text': 'ราคาจะอยู่ที่ประมาณ 50,000 บาทครับ',
          'isSender': false,
          'time': '14:05',
        },
        {
          'text': 'ตกลงครับ ขอเบอร์โทรไว้ติดตามงานด้วยครับ',
          'isSender': true,
          'time': '14:06',
        },
        {
          'text': 'เบอร์ผม 085-987-6543 ครับ แจ้งความคืบหน้าทางนี้ได้เลยครับ',
          'isSender': false,
          'time': '14:07',
        },
        {
          'text': 'โอเคครับ ขอบคุณมาก',
          'isSender': true,
          'time': '14:08',
        },
      ];
    } else if (job['jobTitle'] == 'ปูกระเบื้องพื้น') {
      return [
        {
          'text': 'สวัสดีครับ, อยากให้ปูกระเบื้องพื้นห้องไหนบ้างครับ?',
          'isSender': false,
          'time': '11:00',
        },
        {
          'text': 'ห้องนั่งเล่นและห้องครัวครับ',
          'isSender': true,
          'time': '11:02',
        },
        {
          'text': 'รายละเอียดงานคืออะไรครับ?',
          'isSender': false,
          'time': '11:03',
        },
        {
          'text': 'ปูกระเบื้องเกรดเอทั้งสองห้องครับ',
          'isSender': true,
          'time': '11:04',
        },
        {
          'text': 'ราคาประมาณ 30,000 บาทครับ ขอเบอร์โทรไว้ติดตามงานด้วยครับ',
          'isSender': false,
          'time': '11:05',
        },
        {
          'text': 'เบอร์ผมคือ 086-345-6789 ครับ',
          'isSender': true,
          'time': '11:06',
        },
        {
          'text': 'ขอบคุณครับ ผมจะแจ้งความคืบหน้าทางแชทนี้ครับ',
          'isSender': false,
          'time': '11:07',
        },
      ];
    } else if (job['jobTitle'] == 'ซ่อมแซมหลังคารั่ว') {
      return [
        {
          'text': 'สวัสดีครับ, หลังคารั่วบริเวณไหนครับ?',
          'isSender': false,
          'time': '08:00',
        },
        {
          'text': 'บริเวณห้องนอนใหญ่ครับ',
          'isSender': true,
          'time': '08:02',
        },
        {
          'text': 'รายละเอียดงานคืออะไรครับ?',
          'isSender': false,
          'time': '08:03',
        },
        {
          'text': 'ซ่อมแซมหลังคาที่รั่วและตรวจสอบการรั่วไหลครับ',
          'isSender': true,
          'time': '08:04',
        },
        {
          'text': 'ราคาจะอยู่ที่ประมาณ 15,000 บาทครับ ขอเบอร์โทรด้วยครับ',
          'isSender': false,
          'time': '08:05',
        },
        {
          'text': 'เบอร์ผม 083-456-7890 ครับ',
          'isSender': true,
          'time': '08:06',
        },
        {
          'text': 'ขอบคุณครับ ผมจะแจ้งความคืบหน้าทางแชทนี้ครับ',
          'isSender': false,
          'time': '08:07',
        },
      ];
    } else {
      return [];
    }
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSender;
  final String time;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isSender,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSender ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                color: isSender ? Colors.white : Colors.black,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              time,
              style: TextStyle(
                color: isSender ? Colors.white70 : Colors.black54,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
