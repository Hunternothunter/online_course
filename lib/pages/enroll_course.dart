import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rafael_flutter/database/course_service.dart';
import 'package:rafael_flutter/models/course.dart';

class EnrollCourse extends StatefulWidget {
  const EnrollCourse({super.key});

  @override
  State<EnrollCourse> createState() => _EnrollCourseState();
}

class _EnrollCourseState extends State<EnrollCourse> {
  // Selected course from the dropdown
  String? _selectedCourse;

  // List of available courses to be fetched from the database
  List<String> _courseTitles = [];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  // Fetch courses from the database
  Future<void> _fetchCourses() async {
    try {
      List<Course> courses = await CourseService().fetchCourses();
      setState(() {
        _courseTitles = courses.map((course) => course.title).toList();
      });
    } catch (e) {
      log('Error fetching courses: $e');
      // Handle error accordingly
    }
  }

  // Show confirmation dialog before enrolling
  void _showConfirmationDialog() {
    if (_selectedCourse != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Enrollment'),
            content:
                Text('Are you sure you want to enroll in $_selectedCourse?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the confirmation dialog
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  // Proceed with enrollment logic
                  log('Enrolled in $_selectedCourse');
                  Navigator.of(context).pop(); // Close the confirmation dialog
                  Navigator.of(context).pop(); // Close the enroll dialog
                },
              ),
            ],
          );
        },
      );
    } else {
      // Handle case where no course is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course first')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enroll in a Course'),
      content: _courseTitles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // DropdownButton for selecting course
                  DropdownButton<String>(
                    value: _selectedCourse,
                    hint: const Text('Select a Course'),
                    isExpanded: true, // Makes the dropdown take full width
                    items: _courseTitles
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCourse = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: _showConfirmationDialog, // Trigger the confirmation dialog
          child: const Text('Enroll'),
        ),
      ],
    );
  }
}
