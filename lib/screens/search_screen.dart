import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:talkloop/provider/chat_provider.dart';
import 'package:talkloop/screens/chat_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  String searchQuery = '';
  List<String> searchHistory = [];

  final CollectionReference _searchHistoryCollection = 
      FirebaseFirestore.instance.collection('SearchHistoryy');

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchSearchHistory();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;

    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  void handleSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void saveSearchQuery(String query) async {
    await _searchHistoryCollection.add({
      'query': query,
      'userId': loggedInUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
    fetchSearchHistory();
  }

  void fetchSearchHistory() async {
 QuerySnapshot snapshot = await _searchHistoryCollection
    .where('userId', isEqualTo: loggedInUser?.uid)
    .orderBy('timestamp', descending: true)
    .get();


    
    setState(() {
      searchHistory = snapshot.docs.map((doc) => doc['query'] as String).toList();
    });
  }

  void deleteSearchEntry(String query) async {
    QuerySnapshot snapshot = await _searchHistoryCollection
        .where('userId', isEqualTo: loggedInUser?.uid)
        .where('query', isEqualTo: query)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    fetchSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search User"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: handleSearch,
                    decoration: const InputDecoration(
                      hintText: "Search...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.orange),
                  onPressed: () {
                    if (searchQuery.isNotEmpty) {
                      // Perform the search
                      handleSearch(searchQuery);
                    }
                  },
                ),
              ],
            ),
          ),
          if (searchHistory.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Search History', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: searchHistory.length,
                    itemBuilder: (context, index) {
                      final query = searchHistory[index];
                      return ListTile(
                        title: Text(query),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteSearchEntry(query),
                        ),
                        onTap: () {
                          handleSearch(query);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: searchQuery.isEmpty
                  ? Stream.empty()
                  : chatProvider.searchUsers(searchQuery),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return  Center(
                    child: SizedBox(
                          height: 150,
                          width: 150,
                          child: Center(
                            child: Lottie.asset(
                              'assets/Splash_lottie.json', // Path to your Lottie file
                            ),
                          ),
                        )
                  );
                }

                final users = snapshot.data!.docs;
                List<UserTile> userWidgets = [];

                for (var user in users) {
                  final userData = user.data() as Map<String, dynamic>;
                  if (userData['uid'] != loggedInUser?.uid) {
                    final userWidget = UserTile(
                      userId: userData['uid'] ?? '',
                      name: userData['name'] ?? 'Unknown User',
                      email: userData['email'] ?? 'No email',
                      imageUrl: userData['imageUrl'] ?? '',
                      onUserTap: () {
                        saveSearchQuery(userData['name']);  // Save selected user to history
                      },
                    );
                    userWidgets.add(userWidget);
                  }
                }

                return ListView(
                  children: userWidgets,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final String imageUrl;
  final VoidCallback onUserTap;

  const UserTile({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(name),
      subtitle: Text(email),
      onTap: () async {
        onUserTap(); // Save user selection to history
        final chatId = await chatProvider.getChatRoom(userId) ?? await chatProvider.createChatRoom(userId);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId, receiverId: userId)));
      },
    );
  }
}
