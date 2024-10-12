import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPageOption {
  final User? user;
  final TextEditingController postController;

  SearchPageOption({required this.user, required this.postController});

  Future<void> submitPost(BuildContext context) async {
    final String content = postController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาใส่ข้อความก่อนโพสต์')),
      );
      return;
    }

    try {
      String userName = 'Anonymous';

      // Fetch the user's display name
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      if (userDoc.exists) {
        userName = userDoc['displayName'] ?? userName;
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'content': content,
        'userId': user?.uid,
        'userName': userName,
        'commentCount': 0, // Initialize comment count
        'timestamp': FieldValue.serverTimestamp(),
      });

      postController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โพสต์สำเร็จ!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> deletePost(BuildContext context, String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบโพสต์สำเร็จ!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> editPost(
      BuildContext context, String postId, String newContent) async {
    if (newContent.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาใส่ข้อความก่อนแก้ไข')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .update({'content': newContent});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('แก้ไขโพสต์สำเร็จ!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> addComment(
      BuildContext context, String postId, String comment) async {
    if (comment.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาใส่ข้อความก่อนคอมเม้น')),
      );
      return;
    }

    try {
      String userName = 'Anonymous';

      // Fetch the user's display name
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      if (userDoc.exists) {
        userName = userDoc['displayName'] ?? userName;
      }

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'comment': comment,
        'userId': user?.uid,
        'userName': userName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Increment the comment count
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('คอมเม้นสำเร็จ!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }
}
