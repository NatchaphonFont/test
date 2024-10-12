import 'package:flutter/material.dart';
import 'job_summary_page.dart'; // Import the renamed JobSummaryPage

class JobHiringPage extends StatelessWidget {
  const JobHiringPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for job hiring records
    final List<Map<String, String>> jobHiringRecords = [
      {
        'jobTitle': 'ติดตั้งระบบไฟฟ้า',
        'contractorName': 'ช่างวิทยา สมชาย',
        'date': '15 สิงหาคม 2024',
        'description': 'ติดตั้งระบบไฟฟ้าภายในบ้านพร้อมตรวจเช็คความปลอดภัย',
        'status': 'เสร็จสิ้น'
      },
      {
        'jobTitle': 'ทาสีบ้านทั้งหลัง',
        'contractorName': 'ช่างปรีชา ศรีสุข',
        'date': '10 กรกฎาคม 2024',
        'description': 'ทาสีภายในและภายนอกบ้านทั้งหลังด้วยสีคุณภาพสูง',
        'status': 'เสร็จสิ้น'
      },
      {
        'jobTitle': 'ปูกระเบื้องพื้น',
        'contractorName': 'ช่างสมหมาย อินทร',
        'date': '5 มิถุนายน 2024',
        'description':
            'ปูกระเบื้องพื้นห้องนั่งเล่นและห้องครัวด้วยกระเบื้องเกรดเอ',
        'status': 'กำลังดำเนินการ'
      },
      {
        'jobTitle': 'ซ่อมแซมหลังคารั่ว',
        'contractorName': 'ช่างสมบัติ ชื่นใจ',
        'date': '22 พฤษภาคม 2024',
        'description': 'ซ่อมแซมหลังคาที่รั่วและตรวจสอบการรั่วไหล',
        'status': 'เสร็จสิ้น'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ประวัติจ้างงาน',
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: jobHiringRecords.length,
        itemBuilder: (context, index) {
          final job = jobHiringRecords[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    job['jobTitle']!,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 4),
                      Text('ผู้รับเหมา: ${job['contractorName']}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text('วันที่: ${job['date']}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    job['description']!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'สถานะ: ${job['status']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: job['status'] == 'เสร็จสิ้น'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to JobSummaryPage with the selected job data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JobSummaryPage(job: job),
                            ),
                          );
                        },
                        child: const Text('ดูรายละเอียด'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
