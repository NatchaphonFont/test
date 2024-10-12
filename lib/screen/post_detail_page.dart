import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({Key? key, required this.postId}) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _updateExistingComments();
  }

  Future<void> _updateExistingComments() async {
    final postSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .get();

    for (var doc in postSnapshot.docs) {
      if (!doc.exists || !doc.data().containsKey('likedBy')) {
        await doc.reference.update({
          'likes': 0,
          'likedBy': [],
          'occupation': 'Unknown',
        });
      }
    }
  }

  Future<void> _addComment(String postId) async {
    final String comment = _commentController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาใส่ข้อความก่อนคอมเม้น')),
      );
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user?.uid)
          .get();

      String? userName = userDoc['displayName'] ?? 'Anonymous';
      String? occupation = userDoc['occupation'] ?? 'Unknown';

      DocumentReference postRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);

      await postRef.collection('comments').add({
        'comment': comment,
        'userId': _user?.uid,
        'userName': userName,
        'occupation': occupation,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
      });

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot postSnapshot = await transaction.get(postRef);
        if (postSnapshot.exists) {
          int currentCount = postSnapshot['commentCount'] ?? 0;
          transaction.update(postRef, {'commentCount': currentCount + 1});
        }
      });

      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('คอมเม้นสำเร็จ!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<DocumentSnapshot> _getUserData(String userId) async {
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  Stream<QuerySnapshot> _getCommentsStream(String postId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void _showEditDeleteDialog(
      BuildContext context, String commentId, String currentComment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('แก้ไขหรือลบคอมเม้น'),
          content: TextField(
            controller: TextEditingController(text: currentComment),
            decoration: const InputDecoration(labelText: 'แก้ไขคอมเม้น'),
            onChanged: (value) {
              setState(() {
                currentComment = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                _editComment(commentId, currentComment);
                Navigator.of(context).pop();
              },
              child: const Text('บันทึก'),
            ),
            TextButton(
              onPressed: () {
                _deleteComment(commentId);
                Navigator.of(context).pop();
              },
              child: const Text('ลบ'),
            ),
          ],
        );
      },
    );
  }

  void _editComment(String commentId, String updatedComment) {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId)
        .update({'comment': updatedComment});
  }

  void _deleteComment(String commentId) {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  String formatElapsedTime(int minutes) {
    int hours = minutes ~/ 60; // คำนวณจำนวนชั่วโมง
    int remainingMinutes = minutes % 60; // คำนวณนาทีที่เหลือ

    if (hours > 0) {
      return '$hours ชม ${remainingMinutes > 0 ? '$remainingMinutes นาที' : ''}';
    } else {
      return '$minutes นาที';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดโพสต์',
            style: TextStyle(color: Colors.black)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              // ฟังก์ชันแชร์โพสต์
              _sharePost();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .get(),
              builder: (context, postSnapshot) {
                if (!postSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var post = postSnapshot.data!;
                return FutureBuilder<DocumentSnapshot>(
                  future: _getUserData(post['userId']),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var user = userSnapshot.data!;
                    String occupation = user['occupation'] ?? 'Unknown';

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  user['profileImageUrl'] ??
                                      'https://via.placeholder.com/150',
                                ),
                                radius: 30,
                              ),
                              title: Text(
                                post['userName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'อาชีพ: $occupation',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'โพสต์เมื่อ ${formatElapsedTime(DateTime.now().difference(post['timestamp'].toDate()).inMinutes)} ที่แล้ว',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              post['content'],
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black87),
                            ),
                          ),
                          const Divider(height: 40, color: Colors.black87),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'ความคิดเห็น',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _getCommentsStream(widget.postId),
                              builder: (context, commentSnapshot) {
                                if (!commentSnapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: commentSnapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot comment =
                                        commentSnapshot.data!.docs[index];

                                    List<dynamic> likedBy =
                                        comment['likedBy'] ?? [];
                                    bool isLiked = likedBy.contains(_user?.uid);

                                    return FutureBuilder<DocumentSnapshot>(
                                      future: _getUserData(comment['userId']),
                                      builder: (context, commentUserSnapshot) {
                                        if (!commentUserSnapshot.hasData) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }

                                        var commentUser =
                                            commentUserSnapshot.data!;
                                        String commentOccupation =
                                            commentUser['occupation'] ??
                                                'Unknown';

                                        return InkWell(
                                          onTap: () {
                                            if (comment['userId'] ==
                                                _user?.uid) {
                                              _showEditDeleteDialog(
                                                  context,
                                                  comment.id,
                                                  comment['comment']);
                                            }
                                          },
                                          child: Card(
                                            elevation: 2,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 8.0),
                                              leading: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  commentUser[
                                                          'profileImageUrl'] ??
                                                      'https://via.placeholder.com/150',
                                                ),
                                                radius: 25,
                                              ),
                                              title: Text(
                                                comment['userName'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'อาชีพ: $commentOccupation',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    comment['comment'],
                                                    style: const TextStyle(
                                                        color: Colors.black87),
                                                  ),
                                                ],
                                              ),
                                              trailing: Column(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      isLiked
                                                          ? Icons.thumb_up
                                                          : Icons
                                                              .thumb_up_off_alt,
                                                      color: isLiked
                                                          ? Colors.blue
                                                          : Colors.grey,
                                                    ),
                                                    onPressed: () {
                                                      _toggleLike(
                                                          comment.id, isLiked);
                                                    },
                                                  ),
                                                  Text(
                                                    comment['likes'].toString(),
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black87),
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
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'เขียนคอมเม้น...',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30.0)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  backgroundColor: Colors.yellow[700],
                  onPressed: () => _addComment(widget.postId),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(String commentId, bool isLiked) async {
    final commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot commentSnapshot = await transaction.get(commentRef);

      if (commentSnapshot.exists) {
        List<dynamic> likedBy = commentSnapshot['likedBy'] ?? [];
        int likes = commentSnapshot['likes'] ?? 0;

        if (isLiked) {
          likedBy.remove(_user?.uid);
          likes -= 1;
        } else {
          likedBy.add(_user?.uid);
          likes += 1;
        }

        transaction.update(commentRef, {
          'likedBy': likedBy,
          'likes': likes,
        });
      }
    });
  }

  void _sharePost() {
    // ฟังก์ชันการแชร์โพสต์
  }
}
