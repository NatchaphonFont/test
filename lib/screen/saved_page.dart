import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'details_page.dart'; // Import your details page

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'รายการที่บันทึกไว้',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .collection('saved_items')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'ไม่มีรายการที่บันทึกไว้',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final savedItems = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: savedItems.length,
            itemBuilder: (context, index) {
              final item = savedItems[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 6.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      item['profileImageUrl'] ??
                          'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                      width: 70,
                      height: 70,
                    ),
                  ),
                  title: Text(
                    item['displayName'] ?? 'ไม่ทราบชื่อ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  subtitle: Text(
                    '${item['subDistrict'] ?? ''}, ${item['district'] ?? ''}, ${item['province'] ?? ''}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      toggleSaveCraftsman(
                          currentUser!.uid, savedItems[index].id, item, true);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CraftsmanDetailPage(
                          userId: savedItems[index].id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void toggleSaveCraftsman(String userId, String craftsmanId,
      Map<String, dynamic> craftsmanData, bool isCurrentlySaved) async {
    final savedDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('saved_items')
        .doc(craftsmanId);

    if (isCurrentlySaved) {
      await savedDocRef.delete();
    } else {
      await savedDocRef.set(craftsmanData);
    }
  }
}
