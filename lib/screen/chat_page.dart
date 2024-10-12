import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test/screen/ChatConversationPage.dart'; // Import ChatConversationPage

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'แชทของคุณ',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
            fontSize: 24,
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
        elevation: 10.0,
        shadowColor: Colors.black45,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: _currentUser?.uid)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint('Error loading chats: ${snapshot.error}');
            return const Center(
              child: Text('เกิดข้อผิดพลาดในการโหลดแชท'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            debugPrint('No chat data available');
            return const Center(
              child: Text(
                'ไม่มีการสนทนา',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var chat = snapshot.data!.docs[index];
              var otherUserId = (chat['participants'] as List).firstWhere(
                (uid) => uid != _currentUser?.uid,
                orElse: () => null,
              );

              if (otherUserId == null) {
                debugPrint('No other user found in chat');
                return Container(); // Skip if no other user found
              }

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('กำลังโหลดข้อมูลผู้ใช้...'),
                    );
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    debugPrint('User data not found for userId: $otherUserId');
                    return const ListTile(
                      title: Text('ไม่พบข้อมูลผู้ใช้'),
                    );
                  }

                  var otherUser = userSnapshot.data!;
                  String lastMessage = chat['lastMessage'] ?? 'ไม่มีข้อความ';

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(_currentUser!.uid)
                        .snapshots(),
                    builder: (context, customNameSnapshot) {
                      String displayName =
                          otherUser['displayName'] ?? 'No Name';

                      if (customNameSnapshot.hasData &&
                          customNameSnapshot.data!.exists) {
                        var data = customNameSnapshot.data!.data()
                            as Map<String, dynamic>;
                        var customNames = data['customNames'];

                        if (customNames != null &&
                            customNames[otherUserId] != null) {
                          displayName = customNames[otherUserId];
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8.0,
                              spreadRadius: 1.0,
                              offset: Offset(2, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              otherUser['profileImageUrl'] ??
                                  'https://via.placeholder.com/150',
                            ),
                            backgroundColor: Colors.grey.shade300,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.orangeAccent,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: lastMessage == 'ไม่มีข้อความ'
                                  ? Colors.red
                                  : Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey.shade400,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatConversationPage(
                                  chatId: chat.id,
                                  chatUserName: displayName,
                                  chatUserId: otherUser.id,
                                ),
                              ),
                            );
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 20.0,
                          ),
                        ),
                      );
                    },
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
