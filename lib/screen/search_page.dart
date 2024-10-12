import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/screen/SearchPageOption.dart';
import 'package:test/screen/post_detail_page.dart';
import 'package:test/screen/FindUserPage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _postController = TextEditingController();
  final User? _user = FirebaseAuth.instance.currentUser;
  late final SearchPageOption _searchPageOption;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchPageOption = SearchPageOption(
      user: _user,
      postController: _postController,
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ชม. ${difference.inMinutes.remainder(60)} นาทีที่แล้ว';
    } else {
      final days = difference.inDays;
      return '$days วัน${days > 1 ? '' : ''}ที่แล้ว';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'บล็อกโพสต์',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
        elevation: 5.0,
        shadowColor: Colors.black54,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FindUserPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _postController,
              decoration: InputDecoration(
                labelText: 'เขียนโพสต์ใหม่...',
                labelStyle: TextStyle(color: Colors.grey[800]),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading
                      ? null
                      : () => _searchPageOption.submitPost(context),
                ),
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.yellow.shade700, width: 2.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot post = snapshot.data!.docs[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(post['userId'])
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        var user = userSnapshot.data!;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10.0,
                                spreadRadius: 1.0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15.0),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetailPage(
                                    postId: post.id,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Hero(
                                        tag: 'profile-${post['userId']}',
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            user['profileImageUrl'] ??
                                                'https://via.placeholder.com/150',
                                          ),
                                          radius: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post['userName'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            _formatTimestamp(post['timestamp']),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    post['content'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.comment),
                                        color: Colors.yellow.shade700,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PostDetailPage(
                                                postId: post.id,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      if (_user?.uid == post['userId']) ...[
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          color: Colors.blueAccent,
                                          onPressed: () async {
                                            TextEditingController
                                                editController =
                                                TextEditingController(
                                                    text: post['content']);
                                            final newContent =
                                                await showDialog<String>(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title:
                                                      const Text('แก้ไขโพสต์'),
                                                  content: TextField(
                                                    controller: editController,
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: 'แก้ไขโพสต์',
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child:
                                                          const Text('ยกเลิก'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(editController
                                                                .text);
                                                      },
                                                      child:
                                                          const Text('บันทึก'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                            if (newContent != null) {
                                              _searchPageOption.editPost(
                                                  context, post.id, newContent);
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.redAccent,
                                          onPressed: () => _searchPageOption
                                              .deletePost(context, post.id),
                                        ),
                                      ]
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
