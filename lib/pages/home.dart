import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rafael_flutter/auth/login.dart';
import 'package:rafael_flutter/auth/auth_service.dart';
import 'package:rafael_flutter/pages/course_list.dart';
import 'package:rafael_flutter/pages/enrolled_courses.dart';
import 'package:rafael_flutter/pages/finished_courses.dart';
import 'package:rafael_flutter/pages/profile.dart';
import 'package:rafael_flutter/pages/quizzes.dart'; // Import the Quizzes page
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  String? _userName;
  String? _userEmail;
  String? _profilePicUrl;
  int _currentIndex = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      Map<String, String?> userInfo = await _auth.getCurrentUserProfile();
      setState(() {
        _userName = userInfo['name'];
        _userEmail = userInfo['email'];
        _profilePicUrl = userInfo['profilePicUrl'];
      });
    } catch (e) {
      log('Error loading user info: $e');
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                try {
                  await _auth.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                } catch (e) {
                  log("Logout failed: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to log out. Please try again.")),
                  );
                }
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildSelectedPage(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    String appBarTitle = '';
    switch (_currentIndex) {
      case 0:
        appBarTitle = 'My Courses';
        break;
      case 1:
        appBarTitle = 'Available Courses';
        break;
      case 2:
        appBarTitle = 'Finished Courses';
        break;
      case 3:
        appBarTitle = 'My Quizzes';
        break;
      case 4:
        appBarTitle = 'Profile Information';
        break;
      default:
        appBarTitle = 'My Courses';
    }

    return AppBar(
      title: Text(
        appBarTitle,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 36, 209, 42),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Log Out',
          onPressed: _logout,
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_userName ?? 'User Name'),
            accountEmail: Text(_userEmail ?? 'Email'),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  _profilePicUrl != null ? NetworkImage(_profilePicUrl!) : null,
              child: _profilePicUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('My Courses'),
            onTap: () {
              setState(() {
                _currentIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Available Courses'),
            onTap: () {
              setState(() {
                _currentIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('Finished Courses'),
            onTap: () {
              setState(() {
                _currentIndex = 2;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('Quizzes'),
            onTap: () {
              setState(() {
                _currentIndex = 3;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile Information'),
            onTap: () {
              setState(() {
                _currentIndex = 4;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: const Color.fromARGB(255, 36, 209, 42),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'My Courses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Courses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle),
          label: 'Finished Courses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.quiz),
          label: 'Quizzes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildSelectedPage() {
    switch (_currentIndex) {
      case 0:
        return const EnrolledCourses();
      case 1:
        return const CourseList();
      case 2:
        return const FinishedCourses();
      case 3:
        return const Quizzes(); // Add the Quizzes page here
      case 4:
        return const ProfilePage();
      default:
        return const Center(child: Text('Page not found'));
    }
  }
}
