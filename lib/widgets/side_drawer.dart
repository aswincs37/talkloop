import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talkloop/screens/login_screen.dart';

class SideDrawer extends StatefulWidget {
  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  String? userName;
  String? userEmail;
  String? userImageUrl;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    user = _auth.currentUser;

    if (user != null) {
      try {
        // Fetch user details from Firestore using the user's UID
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'] ?? 'User Name';
            userEmail = userDoc['email'] ?? 'user@example.com';
            userImageUrl = userDoc['imageUrl'] ?? '';
          });
        } else {
          print('User document does not exist.');
        }
      } catch (e) {
        print('Error fetching user details: $e');
      }
    } else {
      print('No user is currently signed in.');
    }
  }

  // Sign-out function
  void _signOut() async {
  await   _auth.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurpleAccent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
         
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'T A L K   L O O P',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20), // Add some spacing
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 30, // Adjust the radius for better visibility
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: userImageUrl != null && userImageUrl!.isNotEmpty
                            ? Image.network(
                                userImageUrl!,
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                              )
                            : const Icon(Icons.person, size: 60), // Default icon
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, $userName "  ,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userEmail ?? 'user@example.com',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                     
                      ],
                    ),
                     
                  ],
                ),
              ],
            ),
             const Divider(thickness: 5,color: Colors.white,),
             const SizedBox(height: 50,),
            Column(
              children: <Widget>[
                const NewRow(
                  text: 'Profile',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),
                const NewRow(
                  text: 'Saved',
                  icon: Icons.bookmark_border,
                ),
                const SizedBox(height: 20),
                const NewRow(
                  text: 'Favorites',
                  icon: Icons.favorite_border,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _signOut, // Call the sign-out function on tap
                  child: Container(
                    height: 50,
                    width: 400,
                    color: Colors.white,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Log out',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NewRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const NewRow({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 400,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: Colors.black,
            ),
            const SizedBox(width: 20),
            Text(
              text,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
