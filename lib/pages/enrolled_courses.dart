import 'package:flutter/material.dart';
import 'package:rafael_flutter/models/course.dart'; // Import your Course model
import 'package:rafael_flutter/database/course_service.dart';
import 'package:rafael_flutter/pages/enroll_course.dart'; // Import your Course service

class EnrolledCourses extends StatefulWidget {
  const EnrolledCourses({super.key});

  @override
  State<EnrolledCourses> createState() => _EnrolledCoursesState();
}

class _EnrolledCoursesState extends State<EnrolledCourses> {
  late Future<List<Course>> _enrolledCourses;

  // Replace with the user's ID (you could pass this dynamically if needed)
  final String userId = "OxG8L5m7Qfur9BXTdF1c";

  @override
  void initState() {
    super.initState();
    _enrolledCourses = CourseService().getEnrolledCourses(userId);
  }

  // Show dialog to add a course
  void _showAddCourseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EnrollCourse(); // Your course enrollment dialog
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Enrolled Courses"),
        ),
        body: FutureBuilder<List<Course>>(
          future: _enrolledCourses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                  child: Text("Failed to load enrolled courses."));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text("No enrolled courses available."));
            }

            final enrolledCourses = snapshot.data!;

            return ListView.builder(
              itemCount: enrolledCourses.length,
              itemBuilder: (context, index) {
                final course = enrolledCourses[index];
                return _buildCourseCard(course, context);
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddCourseDialog,
          backgroundColor: const Color.fromARGB(255, 36, 209, 42),
          tooltip: 'Enroll courses',
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course, BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          title: Text(
            course.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            course.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            // Handle course detail navigation here if needed
          },
        ),
      ),
    );
  }
}
