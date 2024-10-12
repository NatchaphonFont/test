import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobDetailPage extends StatelessWidget {
  final String jobId;

  const JobDetailPage({Key? key, required this.jobId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('รายละเอียดงาน', style: TextStyle(color: Colors.black)),
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('jobs').doc(jobId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var jobData = snapshot.data!;
          // Extract job data
          String jobTitle = jobData['jobTitle'] ?? 'ไม่ระบุชื่อ';
          String jobDescription =
              jobData['jobDescription'] ?? 'ไม่ระบุรายละเอียด';
          String createdByOccupation =
              jobData['createdByOccupation'] ?? 'ไม่ระบุอาชีพ';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  jobTitle,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  jobDescription,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'สร้างโดย: $createdByOccupation',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _contactCraftsman(
                        context, jobTitle, jobDescription, createdByOccupation);
                  },
                  child: const Text('ติดต่อช่าง'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _contactCraftsman(BuildContext context, String jobTitle,
      String jobDescription, String createdByOccupation) {
    // Implement the logic to contact the craftsman
    // You can pass the job data to another screen or a chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactCraftsmanPage(
          jobTitle: jobTitle,
          jobDescription: jobDescription,
          createdByOccupation: createdByOccupation,
        ),
      ),
    );
  }
}

class ContactCraftsmanPage extends StatelessWidget {
  final String jobTitle;
  final String jobDescription;
  final String createdByOccupation;

  const ContactCraftsmanPage({
    Key? key,
    required this.jobTitle,
    required this.jobDescription,
    required this.createdByOccupation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ติดต่อช่าง'),
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
              'งาน: $jobTitle',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'รายละเอียด: $jobDescription',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'สร้างโดย: $createdByOccupation',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement chat or other interaction logic here
              },
              child: const Text('เริ่มการสนทนา'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
