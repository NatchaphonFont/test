import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/screen/JobDetailPage.dart';

class HirePage extends StatefulWidget {
  const HirePage({Key? key}) : super(key: key);

  @override
  _HirePageState createState() => _HirePageState();
}

class _HirePageState extends State<HirePage> {
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จ้างงาน', style: TextStyle(color: Colors.black)),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'ไม่พบรายการจ้างงาน',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot job = snapshot.data!.docs[index];
              return ListTile(
                title: Text(job['jobTitle']),
                subtitle: Text(
                    'อาชีพ: ${job['createdByOccupation']}'), // แสดงอาชีพของผู้สร้างงาน
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailPage(jobId: job.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
