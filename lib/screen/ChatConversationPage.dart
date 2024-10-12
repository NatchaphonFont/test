import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatConversationPage extends StatefulWidget {
  final String chatId;
  final String chatUserId;
  final String chatUserName;

  const ChatConversationPage({
    super.key,
    required this.chatId,
    required this.chatUserId,
    required this.chatUserName,
  });

  @override
  _ChatConversationPageState createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _customChatUserName;

  Set<String> _pinnedMessages = {}; // สำหรับการปักหมุดข้อความ
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCustomChatUserName();
  }

  Future<void> _loadCustomChatUserName() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .get();

    setState(() {
      _customChatUserName = userDoc['customNames']?[widget.chatUserId];
    });
  }

  Future<void> _updateCustomChatUserName() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .set({
      'customNames': {widget.chatUserId: _nicknameController.text.trim()}
    }, SetOptions(merge: true));

    setState(() {
      _customChatUserName = _nicknameController.text.trim();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('เปลี่ยนชื่อสำเร็จ'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context, rootNavigator: true).pop();
  }

  void _showEditNicknameDialog() {
    _nicknameController.text = _customChatUserName ?? widget.chatUserName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('เปลี่ยนชื่อ'),
          content: TextField(
            controller: _nicknameController,
            decoration: const InputDecoration(hintText: 'ตั้งชื่อใหม่'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: _updateCustomChatUserName,
              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .get();

    final message = {
      'text': _messageController.text.trim(),
      'senderId': _currentUser!.uid,
      'senderName': currentUserDoc['displayName'] ?? 'Anonymous',
      'profileImageUrl': currentUserDoc['profileImageUrl'] ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'readBy': [_currentUser!.uid],
    };

    final chatDoc =
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

    final chatSnapshot = await chatDoc.get();

    if (!chatSnapshot.exists) {
      await chatDoc.set({
        'participants': [widget.chatUserId, _currentUser!.uid],
        'lastMessage': _messageController.text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } else {
      await chatDoc.update({
        'lastMessage': _messageController.text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }

    await chatDoc.collection('messages').add(message);

    _messageController.clear();
  }

  void _createWorkDetails() async {
    String workDetails = '''
    รายละเอียดงาน:
    เริ่ม: ${_startDate != null ? DateFormat('dd/MM/yyyy').format(_startDate!) : 'N/A'}
    สิ้นสุด: ${_endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'N/A'}
    รายละเอียด: ${_detailController.text.trim()}
    ราคา: ${_priceController.text.trim()}
    เบอร์โทร: ${_phoneController.text.trim()}
    ''';

    await _sendMessage();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showWorkDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('สร้างรายละเอียดงาน'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2021),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                          });
                        }
                      },
                      child: Text(
                        _startDate != null
                            ? 'เริ่ม: ${DateFormat('dd/MM/yyyy').format(_startDate!)}'
                            : 'เลือกวันเริ่มงาน',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2021),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            _endDate = picked;
                          });
                        }
                      },
                      child: Text(
                        _endDate != null
                            ? 'สิ้นสุด: ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                            : 'เลือกวันสิ้นสุด',
                      ),
                    ),
                    TextField(
                      controller: _detailController,
                      decoration:
                          const InputDecoration(labelText: 'รายละเอียดงาน'),
                    ),
                    TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'ราคา'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'เบอร์โทร'),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('ยกเลิก'),
                ),
                ElevatedButton(
                  onPressed: _createWorkDetails,
                  child: const Text('สร้าง'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showWorkTrackingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ติดตามงาน'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('สถานะ: กำลังดำเนินการ'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _sendMessage();
                    _sendMessage();
                    Navigator.of(context).pop();
                  },
                  child: const Text('อัพเดตเป็นงานเสร็จสิ้น'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _sendMessage();
                    Navigator.of(context).pop();
                  },
                  child: const Text('ยกเลิกงาน'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _promptForRating() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double rating = 0;
        String comment = ''; // เพิ่มตัวแปรเพื่อเก็บคอมเม้น
        return AlertDialog(
          title: const Text('ให้คะแนนช่าง'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('โปรดให้คะแนนช่างสำหรับงานนี้:'),
              const SizedBox(height: 10),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      Slider(
                        value: rating,
                        onChanged: (newRating) {
                          setState(() {
                            rating = newRating;
                          });
                        },
                        divisions: 5,
                        label: '${rating.toStringAsFixed(1)} ดาว',
                        min: 0,
                        max: 5,
                      ),
                      TextField(
                        onChanged: (text) {
                          setState(() {
                            comment = text;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'เขียนคอมเม้น...',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                _submitRating(rating, comment); // ส่งคอมเม้นไปพร้อมคะแนน
                Navigator.of(context).pop();
              },
              child: const Text('ส่งคะแนน'),
            ),
          ],
        );
      },
    );
  }

  void _submitRating(double rating, String comment) async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(widget.chatUserId);

    final ratingDoc = userDoc.collection('ratings').doc(_currentUser!.uid);

    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .get();

    final reviewerName = currentUserDoc['displayName'] ?? 'Anonymous';
    final reviewerProfileUrl = currentUserDoc['profileImageUrl'] ?? '';

    await ratingDoc.set({
      'rating': rating,
      'comment': comment, // บันทึกคอมเม้นไปยังฐานข้อมูล
      'timestamp': FieldValue.serverTimestamp(),
      'reviewerName': reviewerName,
      'reviewerId': _currentUser!.uid,
      'reviewerProfileUrl': reviewerProfileUrl,
    });

    // อัปเดตคะแนนเฉลี่ย
    final ratingsSnapshot = await userDoc.collection('ratings').get();
    final totalRatings = ratingsSnapshot.docs.length;
    final sumRatings = ratingsSnapshot.docs
        .fold(0.0, (sum, doc) => sum + (doc['rating'] as double));

    final averageRating = sumRatings / totalRatings;

    await userDoc.update({'averageRating': averageRating});

    // ส่งข้อความแจ้งเตือนในแชท
    await _sendMessage();

    // คุณสามารถอัปเดตหน้าอื่น ๆ หรือแสดงการแจ้งเตือนได้ตามต้องการ
  }

  void _handleMessageTap(String messageId, String messageText) {
    if (messageText.contains('กรุณาให้คะแนนกับงานครั้งนี้')) {
      _promptForRating();
    } else if (messageText.contains('รายละเอียดงาน:')) {
      _showWorkTrackingDialog();
    }
  }

  void _togglePinMessage(String messageId) async {
    final chatDoc =
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

    setState(() {
      if (_pinnedMessages.contains(messageId)) {
        _pinnedMessages.remove(messageId);
      } else {
        _pinnedMessages.add(messageId);
      }
    });

    await chatDoc.update({
      'pinnedMessages': _pinnedMessages.toList(),
    });
  }

  void _showPinnedMessages() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ข้อความที่ปักหมุด'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _pinnedMessages.map((messageId) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chatId)
                      .collection('messages')
                      .doc(messageId)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final messageData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(messageData['text']),
                      onTap: () {
                        Navigator.of(context).pop();
                        _scrollToMessage(messageId);
                      },
                    );
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  void _scrollToMessage(String messageId) {
    final index = _pinnedMessages.toList().indexOf(messageId);
    if (index != -1) {
      _scrollController.animateTo(
        index * 60.0, // Approximate height of each message
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _searchMessages(String query) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ผลการค้นหา'),
          content: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .doc(widget.chatId)
                .collection('messages')
                .where('text', isGreaterThanOrEqualTo: query)
                .where('text', isLessThanOrEqualTo: '$query\uf8ff')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final searchResults = snapshot.data!.docs;
              if (searchResults.isEmpty) {
                return const Text('ไม่พบข้อความที่ค้นหา');
              }
              return ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final message = searchResults[index];
                  return ListTile(
                    title: Text(message['text']),
                    subtitle: Text(
                        '${message['senderName']} • ${_formatTimestamp(message['timestamp'] as Timestamp)}'),
                    onTap: () {
                      Navigator.of(context)
                          .pop(); // ปิด Dialog เมื่อกดที่ข้อความ
                      _scrollToMessage(message.id);
                    },
                  );
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ค้นหาข้อความ'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'ค้นหา...'),
            onSubmitted: _searchMessages,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
          ],
        );
      },
    );
  }

  void _onMenuItemSelected(int item) {
    switch (item) {
      case 1:
        _showPinnedMessages();
        break;
      case 2:
        _showSearchDialog();
        break;
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    var date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.chatUserId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(
                    backgroundColor: Colors.grey,
                  );
                }
                if (snapshot.hasError) {
                  return const CircleAvatar(
                    backgroundColor: Colors.red,
                  );
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.error, color: Colors.white),
                  );
                }

                var userDoc = snapshot.data!;
                var profileImageUrl = userDoc['profileImageUrl'] ?? '';
                if (profileImageUrl.isEmpty) {
                  return const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  );
                }

                return CircleAvatar(
                  backgroundImage: NetworkImage(profileImageUrl),
                );
              },
            ),
            const SizedBox(width: 10),
            Text(
              _customChatUserName ?? widget.chatUserName,
              style: const TextStyle(color: Colors.black),
            ),
          ],
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditNicknameDialog,
          ),
          IconButton(
            icon: const Icon(Icons.work),
            onPressed: _showWorkDetailsDialog,
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.menu),
            onSelected: (item) => _onMenuItemSelected(item),
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.push_pin, color: Colors.black),
                    SizedBox(width: 8),
                    Text('ข้อความที่ปักหมุด'),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.black),
                    SizedBox(width: 8),
                    Text('ค้นหาข้อความ'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            reverse: true,
            controller: _scrollController,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var message = snapshot.data!.docs[index];
              var isCurrentUser = message['senderId'] == _currentUser!.uid;
              var timestamp = message['timestamp'] as Timestamp?;

              return GestureDetector(
                onTap: () => _handleMessageTap(message.id, message['text']),
                child: Align(
                  alignment: isCurrentUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: isCurrentUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isCurrentUser)
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            message['profileImageUrl'] ??
                                'https://via.placeholder.com/150',
                          ),
                          radius: 20,
                        ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Colors.blue.shade100
                                : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft:
                                  Radius.circular(isCurrentUser ? 16 : 0),
                              bottomRight:
                                  Radius.circular(isCurrentUser ? 0 : 16),
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          child: Column(
                            crossAxisAlignment: isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['text'],
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${message['senderName']} • ${_formatTimestamp(timestamp)}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              if (isCurrentUser)
                                message['readBy'].contains(widget.chatUserId)
                                    ? const Icon(Icons.done_all,
                                        color: Colors.blue, size: 14)
                                    : const Icon(Icons.done,
                                        color: Colors.grey, size: 14),
                            ],
                          ),
                        ),
                      ),
                      if (isCurrentUser) const SizedBox(width: 8),
                      if (isCurrentUser)
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            message['profileImageUrl'] ??
                                'https://via.placeholder.com/150',
                          ),
                          radius: 20,
                        ),
                      IconButton(
                        icon: Icon(
                          _pinnedMessages.contains(message.id)
                              ? Icons.push_pin
                              : Icons.push_pin_outlined,
                        ),
                        onPressed: () => _togglePinMessage(message.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'เขียนข้อความ...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.yellow.shade700,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send),
                color: Colors.white,
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset:
          true, // Prevent keyboard from blocking the input field
    );
  }
}
