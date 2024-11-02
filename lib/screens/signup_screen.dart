import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:talkloop/bottomnavbar.dart';
import 'package:talkloop/screens/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  
  File? profileImage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final ImagePicker _picker = ImagePicker();
  bool isUsernameAvailable = true;
  bool isUsernameRules = true;
  bool isEmailAvailable = true;
  bool isEmailValid = true;
  bool isPasswordVisible = false;
  bool isPasswordValid = true;
  bool isLoading = false;
  bool isSignUpEnabled = true;

   String verificationCode = '';
  String errorMessage = '';

  // Image picker function
  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        profileImage = File(pickedImage.path);
      });
    }
  }

  // Image upload function
  Future<String> _uploadImage(File image) async {
    final ref =
        _storage.ref().child('profile_images/${_auth.currentUser!.uid}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  // Check if username is available
  Future<void> checkUsernameAvailability(String username) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('name', isEqualTo: username)
        .get();

    setState(() {
      isUsernameAvailable = querySnapshot.docs.isEmpty;
    });
  }

  Future<void> checkEmailAvailability(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    setState(() {
      isEmailAvailable = querySnapshot.docs.isEmpty;
    });
  }

  // SignUp function
  Future<void> _signUp() async {
    setState(() {
      isLoading = true; // Set loading state to true
      isSignUpEnabled = false; // Disable sign up button
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      // Upload profile image and get URL
      final imageUrl = await _uploadImage(profileImage!);

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'imageUrl': imageUrl,
        'dob': dobController.text.trim(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false; // Reset loading state
        isSignUpEnabled = true; // Re-enable sign up button
      });
    }
  }

  bool _isPasswordValid(String password) {
    // Regular expression for password validation
    final RegExp passwordRegExp = RegExp(
      r'^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,.<>\/?])[A-Za-z\d!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,.<>\/?]{6,}$',
    );
    return passwordRegExp.hasMatch(password);
  }

  // Date picker function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Disable SignUp button until all criteria are met
    bool isSignUpEnabled = isUsernameAvailable &&
        isEmailValid &&
        isUsernameRules &&
        isEmailAvailable &&
        profileImage != null &&
        dobController.text.isNotEmpty;

    return isLoading
        ?Container(
  color: Colors.white,
  child: Center(
    child: Lottie.asset(
      'assets/Splash_lottie.json', // Path to your Lottie file
    ),
  ),
)

        : Scaffold(
            body: Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xffB81736),
                        Color(0xff281537),
                      ],
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 60.0, left: 22),
                    child: Text(
                      'Create Your\nAccount',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 240.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 1.3,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40)),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: profileImage != null
                                    ? FileImage(profileImage!)
                                    : null,
                                child: profileImage == null
                                    ? const Icon(Icons.person,
                                        size: 50, color: Colors.grey)
                                    : null,
                              ),
                            ),
                            profileImage == null
                                ? const Text(
                                    "Upload profile picture..!",
                                    style: TextStyle(color: Colors.red),
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 20),

// Inside your widget
                            TextField(
                              controller:usernameController,
                              onChanged: (value) {
                                checkUsernameAvailability(value);
                                setState(() {
                                  // Validate username format: only lowercase letters, numbers, and underscores
                                  isUsernameRules  =
                                      RegExp(r"^[a-z][a-z0-9_.]*$")
                                          .hasMatch(value);
                                });
                              },
                              // controller: usernameController,
                              // inputFormatters: [
                              //   FilteringTextInputFormatter.allow(RegExp(
                              //       r"[a-z0-9_.]")), // Restrict input to lowercase letters, numbers, and underscores
                              // ],
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  isUsernameAvailable && isUsernameRules 
                                      ? Icons.check
                                      : Icons.error,
                                  color: isUsernameAvailable && isUsernameRules 
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                label: const Text(
                                  'Username',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xffB81736),
                                  ),
                                ),
                              ),
                            ),
                              if (!isUsernameAvailable)
                              const Text(
                                "Username is not available..!",
                                style: TextStyle(color: Colors.red),
                              ),
                                if (!isUsernameRules)
                              const Text(
                                "username: lower case letters,numbers,underscore..!",
                                style: TextStyle(color: Colors.red),
                              ),
                            TextField(
                              controller: emailController,
                              onChanged: (value) {
                                checkEmailAvailability(value);
                                setState(() {
                                  isEmailValid = RegExp(
                                          r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
                                      .hasMatch(value);
                                });
                              },
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  isEmailValid ? Icons.check : Icons.error,
                                  color:
                                      isEmailValid ? Colors.green : Colors.red,
                                ),
                                label: const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xffB81736),
                                  ),
                                ),
                              ),
                            ),
                            if (!isEmailAvailable)
                              const Text(
                                "You have and account in this gmail.Please Login..!",
                                style: TextStyle(color: Colors.red),
                              ),
                            TextField(
                              controller: passController,
                              obscureText: !isPasswordVisible,
                              onChanged: (value) {
                                setState(() {
                                  isPasswordValid = _isPasswordValid(
                                      value); // Check if password is valid
                                });
                              },
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                ),
                                label: const Text(
                                  'Password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xffB81736),
                                  ),
                                ),
                                errorText: isPasswordValid
                                    ? null
                                    : "Password: 6 characters,include:letter,number and special character.",
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: TextField(
                                controller: dobController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.calendar_today),
                                  label: Text(
                                    'Date of Birth',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffB81736),
                                    ),
                                  ),
                                ),
                                onTap: () => _selectDate(context),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: isSignUpEnabled && !isLoading
                                  ? _signUp
                                  : null,
                              child: Container(
                                height: 55,
                                width: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: isSignUpEnabled
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xffB81736),
                                            Color(0xff281537)
                                          ],
                                        )
                                      : const LinearGradient(
                                          colors: [Colors.grey, Colors.grey],
                                        ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'SIGN UP',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 60),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
  }
}
