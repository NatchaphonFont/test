import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:test/screen/ChatConversationPage.dart'; // Import ChatConversationPage

class DetailsPage extends StatelessWidget {
  final String category;
  final String? selectedProvince;
  final String? selectedDistrict;
  final String? selectedSubDistrict;

  const DetailsPage({
    required this.category,
    this.selectedProvince,
    this.selectedDistrict,
    this.selectedSubDistrict,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
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
        stream: _buildStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('ไม่พบข้อมูลในหมวดหมู่นี้'));
          }

          final users = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.75,
            ),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(users[index].id)
                    .collection('ratings')
                    .snapshots(),
                builder: (context, ratingSnapshot) {
                  if (ratingSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final ratings = ratingSnapshot.data?.docs ?? [];
                  double averageRating = 0.0;
                  int totalReviews = ratings.length;

                  if (totalReviews > 0) {
                    final totalRating =
                        ratings.fold(0.0, (previousValue, rating) {
                      return previousValue +
                          (rating.data() as Map<String, dynamic>)['rating'];
                    });
                    averageRating = totalRating / totalReviews;
                  }

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser?.uid)
                        .collection('saved_items')
                        .doc(users[index].id)
                        .snapshots(),
                    builder: (context, savedSnapshot) {
                      final isSaved = savedSnapshot.hasData &&
                          savedSnapshot.data?.exists == true;

                      return Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CraftsmanDetailPage(
                                  userId: users[index].id,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                  ),
                                  child: Image.network(
                                    user['profileImageUrl'] ??
                                        'https://via.placeholder.com/150',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['displayName'] ?? 'ไม่ทราบชื่อ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      user['occupation'] ?? 'ไม่ระบุอาชีพ',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      '${user['subDistrict'] ?? ''}, ${user['district'] ?? ''}, ${user['province'] ?? ''}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16.0,
                                        ),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          averageRating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          '($totalReviews รีวิว)',
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8.0),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            isSaved
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isSaved
                                                ? Colors.red
                                                : Colors.redAccent,
                                          ),
                                          onPressed: () {
                                            toggleSaveCraftsman(
                                                currentUser!.uid,
                                                users[index].id,
                                                user,
                                                isSaved);
                                          },
                                        ),
                                        const SizedBox(width: 4.0),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.chat_bubble_outline,
                                            color: Colors.blueAccent,
                                          ),
                                          onPressed: () {
                                            final String currentUserId =
                                                FirebaseAuth
                                                    .instance.currentUser!.uid;
                                            final String craftsmanId =
                                                users[index].id;
                                            final String chatId =
                                                generateChatId(
                                                    currentUserId, craftsmanId);

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatConversationPage(
                                                  chatId: chatId,
                                                  chatUserId: craftsmanId,
                                                  chatUserName:
                                                      user['displayName'],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

  Stream<QuerySnapshot> _buildStream() {
    var query = FirebaseFirestore.instance
        .collection('users')
        .where('occupation', isEqualTo: category);

    if (selectedProvince != null) {
      query = query.where('province', isEqualTo: selectedProvince);
    }
    if (selectedDistrict != null) {
      query = query.where('district', isEqualTo: selectedDistrict);
    }
    if (selectedSubDistrict != null) {
      query = query.where('subDistrict', isEqualTo: selectedSubDistrict);
    }

    return query.snapshots();
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

  String generateChatId(String currentUserId, String userId) {
    return currentUserId.compareTo(userId) < 0
        ? '${currentUserId}_$userId'
        : '${userId}_$currentUserId';
  }
}

class CraftsmanDetailPage extends StatelessWidget {
  final String userId;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  CraftsmanDetailPage({required this.userId, super.key});

  String generateChatId(String currentUserId, String userId) {
    return currentUserId.compareTo(userId) < 0
        ? '${currentUserId}_$userId'
        : '${userId}_$currentUserId';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดช่าง'),
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('ไม่พบข้อมูลช่าง'));
          }

          final user = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Profile cover image
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(user['profileCover'] ??
                                'https://via.placeholder.com/800x400'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Profile picture
                      Positioned(
                        bottom: -50,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: user['profileImageUrl'] != null
                              ? NetworkImage(user['profileImageUrl'])
                              : const AssetImage('assets/default_profile.png')
                                  as ImageProvider,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Text(
                    user['displayName'] ?? 'ไม่ระบุชื่อ',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('ratings')
                        .snapshots(),
                    builder: (context, ratingSnapshot) {
                      if (!ratingSnapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final ratings = ratingSnapshot.data!.docs;
                      double averageRating = 0.0;

                      if (ratings.isNotEmpty) {
                        final totalRating =
                            ratings.fold(0.0, (previousValue, rating) {
                          return previousValue +
                              (rating.data() as Map<String, dynamic>)['rating'];
                        });
                        averageRating = totalRating / ratings.length;
                      }

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                averageRating.toStringAsFixed(2),
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 24),
                              const SizedBox(width: 4),
                              Text('${ratings.length} รีวิว',
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser?.uid)
                                .collection('saved_items')
                                .doc(userId)
                                .snapshots(),
                            builder: (context, savedSnapshot) {
                              final isSaved = savedSnapshot.hasData &&
                                  savedSnapshot.data?.exists == true;

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isSaved
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isSaved
                                          ? Colors.red
                                          : Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      toggleSaveCraftsman(currentUser!.uid,
                                          userId, user, isSaved);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chat_bubble_outline,
                                        color: Colors.blue),
                                    onPressed: () {
                                      final String chatId = generateChatId(
                                          currentUser!.uid, userId);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ChatConversationPage(
                                            chatId: chatId,
                                            chatUserId: userId,
                                            chatUserName: user['displayName'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Divider(color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.location_on, 'ที่อยู่:',
                              '${user['subDistrict'] ?? 'ไม่ระบุ'}, ${user['district'] ?? 'ไม่ระบุ'}, ${user['province'] ?? 'ไม่ระบุ'}, ${user['country'] ?? 'ไม่ระบุประเทศ'}'),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.email, 'อีเมล:',
                              user['email'] ?? 'ไม่ระบุอีเมล'),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.work, 'อาชีพ:',
                              user['occupation'] ?? 'ไม่ระบุอาชีพ'),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.access_time, 'เวลาทำงาน:',
                              user['workingHours'] ?? 'ไม่ระบุเวลาทำงาน'),
                          const SizedBox(height: 16),
                          Divider(color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'รูปผลงาน',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _buildPortfolioImages(
                              context, user['portfolioLinks'] ?? []),
                          const SizedBox(height: 16),
                          Divider(color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          _buildRatingAndReviewSection(context, user),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showReviewDialog(context, userId);
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'เพิ่มรีวิว',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 24.0),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
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

  Widget _buildInfoRow(IconData icon, String label, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label $info',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioImages(BuildContext context, List<dynamic> images) {
    if (images.isEmpty) {
      return const Text('ไม่มีรูปผลงาน', style: TextStyle(color: Colors.grey));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: images.map((imageUrl) {
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.network(
                imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRatingAndReviewSection(
      BuildContext context, Map<String, dynamic> user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'คะแนนและรีวิว',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('ratings')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final ratings = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                final rating = ratings[index].data() as Map<String, dynamic>;
                final ratingValue = rating['rating'] as double;
                final comment =
                    rating['comment'] as String? ?? 'ไม่มีคอมเม้นท์';
                final timestamp = rating['timestamp'] as Timestamp?;
                final formattedTime = timestamp != null
                    ? DateFormat('dd MMM yyyy HH:mm').format(timestamp.toDate())
                    : 'ไม่ระบุเวลา';
                final reviewerId = rating['reviewerId'] as String?;

                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(reviewerId)
                      .snapshots(),
                  builder: (context, reviewerSnapshot) {
                    if (!reviewerSnapshot.hasData ||
                        !reviewerSnapshot.data!.exists) {
                      return const ListTile(
                        leading: CircleAvatar(
                          radius: 20.0,
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text('ไม่พบผู้ใช้'),
                      );
                    }

                    final reviewerData =
                        reviewerSnapshot.data!.data() as Map<String, dynamic>;
                    final reviewerName =
                        reviewerData['displayName'] as String? ?? 'Anonymous';
                    final reviewerProfileUrl =
                        reviewerData['profileImageUrl'] as String?;
                    final isCurrentUser = reviewerId == currentUser?.uid;

                    return GestureDetector(
                      onTap: isCurrentUser
                          ? () {
                              _showEditReviewDialog(context, rating,
                                  ratingValue, comment, ratings[index].id);
                            }
                          : null,
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 20.0,
                            backgroundColor: Colors.teal,
                            backgroundImage: reviewerProfileUrl != null
                                ? NetworkImage(reviewerProfileUrl)
                                : null,
                            child: reviewerProfileUrl == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Row(
                            children: [
                              RatingBarIndicator(
                                rating: ratingValue,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 20.0,
                                direction: Axis.horizontal,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                ratingValue.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (reviewerName != null)
                                Text('โดย $reviewerName'),
                              Text('คอมเม้นท์: $comment'),
                              Text(formattedTime),
                            ],
                          ),
                          trailing: isCurrentUser
                              ? IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _deleteReview(ratings[index].id);
                                  },
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _deleteReview(String reviewId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('ratings')
        .doc(reviewId)
        .delete();
  }

  void _showReviewDialog(BuildContext context, String userId) {
    double rating = 0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เพิ่มรีวิว'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  rating = newRating;
                },
              ),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'ความคิดเห็น',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                if (rating > 0) {
                  final currentUserDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser?.uid)
                      .get();

                  final reviewerName =
                      currentUserDoc['displayName'] ?? 'Anonymous';
                  final reviewerProfileUrl =
                      currentUserDoc['profileImageUrl'] ?? '';

                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('ratings')
                      .add({
                    'rating': rating,
                    'comment': commentController.text,
                    'timestamp': Timestamp.now(),
                    'reviewerName': reviewerName,
                    'reviewerId': currentUser?.uid,
                    'reviewerProfileUrl': reviewerProfileUrl,
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text('โพสต์'),
            ),
          ],
        );
      },
    );
  }

  void _showEditReviewDialog(BuildContext context, Map<String, dynamic> rating,
      double ratingValue, String comment, String reviewId) {
    double newRating = ratingValue;
    final newCommentController = TextEditingController(text: comment);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('แก้ไขรีวิว'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: ratingValue,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRatingValue) {
                  newRating = newRatingValue;
                },
              ),
              TextField(
                controller: newCommentController,
                decoration: const InputDecoration(
                  labelText: 'ความคิดเห็น',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                if (newRating > 0) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('ratings')
                      .doc(reviewId)
                      .update({
                    'rating': newRating,
                    'comment': newCommentController.text,
                    'timestamp': Timestamp.now(),
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }
}
