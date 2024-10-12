import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test/screen/ChatConversationPage.dart'; // Import ChatConversationPage

class FindUserPage extends StatefulWidget {
  const FindUserPage({Key? key}) : super(key: key);

  @override
  _FindUserPageState createState() => _FindUserPageState();
}

class _FindUserPageState extends State<FindUserPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = '';
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  String generateChatId(String currentUserId, String userId) {
    return currentUserId.compareTo(userId) < 0
        ? '${currentUserId}_${userId}'
        : '${userId}_${currentUserId}';
  }

  Future<void> _findUserAndStartChat() async {
    setState(() {
      _isLoading = true;
    });

    String searchQuery = _searchController.text.trim();
    if (searchQuery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกชื่อผู้ใช้หรืออีเมล')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('displayName', isEqualTo: searchQuery)
          .get();

      if (userSnapshot.docs.isEmpty) {
        userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: searchQuery)
            .get();
      }

      if (userSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบผู้ใช้')),
        );
      } else {
        DocumentSnapshot userDoc = userSnapshot.docs.first;

        if (userDoc.id == _currentUser!.uid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่สามารถแชทกับตัวเองได้')),
          );
        } else {
          // Generate chat ID based on participants' IDs
          String chatId = generateChatId(_currentUser!.uid, userDoc.id);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatConversationPage(
                chatId: chatId,
                chatUserId: userDoc.id,
                chatUserName: userDoc['displayName'],
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildUserList(Stream<QuerySnapshot> stream) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(child: Text('ไม่พบผู้ใช้ที่ตรงกับการค้นหา'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var userDoc = users[index];

            if (userDoc.id == _currentUser!.uid) {
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      userDoc['profileImageUrl'] ??
                          'https://via.placeholder.com/150',
                    ),
                  ),
                  title: Text(userDoc['displayName'] ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(userDoc['email'] ?? 'No Email',
                      style: const TextStyle(color: Colors.grey)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ไม่สามารถแชทกับตัวเองได้')),
                    );
                  },
                ),
              );
            }

            // Generate chat ID based on participants' IDs
            String chatId = generateChatId(_currentUser!.uid, userDoc.id);

            return Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    userDoc['profileImageUrl'] ??
                        'https://via.placeholder.com/150',
                  ),
                ),
                title: Text(userDoc['displayName'] ?? 'No Name',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(userDoc['email'] ?? 'No Email',
                    style: const TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatConversationPage(
                        chatId: chatId,
                        chatUserId: userDoc.id,
                        chatUserName: userDoc['displayName'],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหาและแชท', style: TextStyle(color: Colors.black)),
        bottom: _tabController != null
            ? TabBar(
                controller: _tabController,
                indicatorColor: Colors.orangeAccent,
                tabs: const [
                  Tab(text: 'ค้นหาผู้ใช้'),
                  Tab(text: 'รายชื่อทั้งหมด'),
                ],
              )
            : null,
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
      body: _tabController != null
          ? TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'กรอกชื่อผู้ใช้หรืออีเมล',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _findUserAndStartChat,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text('ค้นหาและแชท'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _searchQuery.isEmpty
                            ? const Center(
                                child: Text(
                                    'กรุณากรอกข้อมูลเพื่อค้นหาผู้ใช้', // Show a message when the search query is empty
                                    style: TextStyle(fontSize: 18)),
                              )
                            : _buildUserList(FirebaseFirestore.instance
                                .collection('users')
                                .where('displayName',
                                    isGreaterThanOrEqualTo: _searchQuery)
                                .where('displayName',
                                    isLessThanOrEqualTo:
                                        _searchQuery + '\uf8ff')
                                .snapshots()),
                      ),
                    ],
                  ),
                ),
                _buildUserList(FirebaseFirestore.instance
                    .collection('users')
                    .snapshots()), // Show all users in this tab
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
