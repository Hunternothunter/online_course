import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:rafael_flutter/auth/login.dart';
import 'package:rafael_flutter/auth/auth_service.dart';
import 'package:rafael_flutter/pages/course_list.dart';
import 'package:rafael_flutter/pages/enroll_course.dart';
import 'package:rafael_flutter/pages/enrolled_courses.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore

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
  final String _userId = "OxG8L5m7Qfur9BXTdF1cOxG8L5m7Qfur9BXTdF1c";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  // Fetch user profile info directly from Firestore
  Future<void> _fetchUserInfo() async {
    try {
      // Assume _userId is already available, otherwise you'll need to get it from local storage, context, or pass it in
      // if (_userId != null) {
      // Fetch user profile info from Firestore using the userId
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_userId).get();

      if (userDoc.exists) {
        setState(() {
          _userName = '${userDoc['firstname']} ${userDoc['lastname']}';
          _userEmail = userDoc['email'];
          _profilePicUrl = userDoc['photoURL']; // If available
        });
      } else {
        log("User profile does not exist");
        // Set default values or show a placeholder if no profile exists
        setState(() {
          _userName = 'Guest';
          _userEmail = 'No Email';
          _profilePicUrl = null;
        });
      }
      // } else {
      // log("User ID is null");
      // Handle case where _userId is null
      // }
    } catch (e) {
      log("Error fetching user info from Firestore: $e");
      setState(() {
        _userName = 'Guest';
        _userEmail = 'No Email';
        _profilePicUrl = null;
      });
    }
  }

  Future<void> _logout() async {
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
        appBarTitle = 'Home';
        break;
      case 1:
        appBarTitle = 'Courses';
        break;
      case 2:
        appBarTitle = 'Finished Courses';
        break;
      case 3:
        appBarTitle = 'Profile';
        break;
      default:
        appBarTitle = 'Home';
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
            title: const Text('Home'),
            onTap: () {
              setState(() {
                _currentIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Courses'),
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
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              setState(() {
                _currentIndex = 3;
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
          label: 'Home',
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
        return const EnrolledCourses();
      case 3:
        return const EnrolledCourses();
      default:
        return const Center(child: Text('Page not found'));
    }
  }
}
