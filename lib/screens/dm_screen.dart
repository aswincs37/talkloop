import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talkloop/provider/chat_provider.dart';
import 'package:talkloop/widgets/chat_tile.dart';
import 'package:talkloop/widgets/side_drawer.dart';

class DmScreens extends StatefulWidget {
  const DmScreens({super.key});

  @override
  State<DmScreens> createState() => _DmScreensState();
}

class _DmScreensState extends State<DmScreens> {
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  double xOffset = 0;
  double yOffset = 0;
  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchChatData(String chatId) async {
    final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    final chatData = chatDoc.data();
    final users = chatData!['users'] as List<dynamic>;
    final receiverId = users.firstWhere((id) => id != loggedInUser!.uid);
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(receiverId).get();
    final userData = userDoc.data();

    return {
      'chatId': chatId,
      'lastMessage': chatData['lastMessage'] ?? '',
      'timestamp': chatData['timestamp']?.toDate() ?? DateTime.now(),
      'receiverData': userData,
    };
  }

  void toggleDrawer() {
    setState(() {
      xOffset = isDrawerOpen ? 0 : 250;
      yOffset = isDrawerOpen ? 0 : 100;
      isDrawerOpen = !isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Stack(
      children: [
        SideDrawer(),
        AnimatedContainer(
          transform: Matrix4.translationValues(xOffset, yOffset, 0)
            ..scale(isDrawerOpen ? 0.85 : 1.00)
            ..rotateZ(isDrawerOpen ? 0.1 : 0),
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isDrawerOpen ? BorderRadius.circular(40) : BorderRadius.circular(0),
          ),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.deepPurple,
              title: const Text(
                "C H A T",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              leading: GestureDetector(
                onTap: toggleDrawer,
                child: isDrawerOpen
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30)),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      )
                    : const Icon(Icons.menu, color: Colors.white, size: 30),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: chatProvider.getChats(loggedInUser!.uid),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final chatDocs = snapshot.data!.docs;
                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: Future.wait(chatDocs.map((chatDoc) => _fetchChatData(chatDoc.id))),
                        builder: (context, chatSnapshot) {
                          if (!chatSnapshot.hasData) {
                            return const SizedBox();
                          }
                          final chatDataList = chatSnapshot.data!;
                          return ListView.builder(
                            itemCount: chatDataList.length * 2 - 1, // Adjust item count for dividers
                            itemBuilder: (context, index) {
                              if (index.isOdd) {
                                // If the index is odd, return a divider
                                return Divider(
                                  height: 1, // Height of the divider
                                  color: Colors.grey[300], // Color of the divider
                                  thickness: 1.5, // Thickness of the divider
                                  indent: 16, // Indent on the leading edge
                                  endIndent: 16, // Indent on the trailing edge
                                );
                              }

                              // If the index is even, return a ChatTile
                              final chatData = chatDataList[index ~/ 2]; // Use integer division to get the chat index
                              return ChatTile(
                                chatId: chatData['chatId'],
                                lastMessage: chatData['lastMessage'],
                                timestamp: chatData['timestamp'],
                                receiverData: chatData['receiverData'],
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
          ),
        ),
      ],
    );
  }
}
