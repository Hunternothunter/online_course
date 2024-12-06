import 'dart:developer';
import '../models/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to fetch all available courses
  Future<List<Course>> fetchCourses() async {
    List<Course> courses = [];
    try {
      QuerySnapshot snapshot = await _firestore.collection('courses').get();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Handle the modules field
        List<Module> modules = [];
        if (data['modules'] is List) {
          modules = (data['modules'] as List<dynamic>).map((module) {
            return Module.fromMap(module as Map<String, dynamic>);
          }).toList();
        }

        log('Fetched Course: ${data['title']}');
        log('Modules: ${modules.length}'); // Log the number of modules

        courses.add(Course(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          modules: modules,
        ));
      }
    } catch (e) {
      log("Error fetching courses: $e");
    }
    return courses;
  }

  // Method to fetch the enrolled courses for a user
  Future<List<Course>> getEnrolledCourses(String userId) async {
    List<Course> enrolledCourses = [];
    try {
      // Fetch the user's document from 'enrollments'
      DocumentSnapshot userSnapshot =
          await _firestore.collection('enrollments').doc(userId).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        // Get the courses array
        List<dynamic> coursesData = userData['courses'] ?? [];

        // For each course in the array, fetch its details
        for (var courseMap in coursesData) {
          String courseId = courseMap['course_id'];
          Timestamp enrolledDate = courseMap['enrolled_date'];

          // Fetch the course details from the 'courses' collection
          DocumentSnapshot courseSnapshot =
              await _firestore.collection('courses').doc(courseId).get();

          if (courseSnapshot.exists) {
            Map<String, dynamic> courseData =
                courseSnapshot.data() as Map<String, dynamic>;

            enrolledCourses.add(Course(
              id: courseSnapshot.id,
              title: courseData['title'],
              description: courseData['description'],
              modules: courseData['modules'],
            ));
          }
        }
      }
    } catch (e) {
      log("Error fetching enrolled courses: $e");
    }
    return enrolledCourses;
  }

  // Method to enroll a user in a course (store in an array of maps)
  Future<void> enrollInCourse(String userId, String courseId) async {
    try {
      // Get the course details
      DocumentSnapshot courseSnapshot =
          await _firestore.collection('courses').doc(courseId).get();

      if (!courseSnapshot.exists) {
        log("Course not found.");
        return;
      }

      // Get the user's document from 'enrollments'
      DocumentReference userRef =
          _firestore.collection('enrollments').doc(userId);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        List<dynamic> courses = userData['courses'] ?? [];

        // Check if the course is already enrolled
        bool alreadyEnrolled =
            courses.any((course) => course['course_id'] == courseId);
        if (alreadyEnrolled) {
          log('User $userId is already enrolled in course $courseId');
          return;
        }

        // Add the course enrollment to the user's courses array
        courses.add({
          'course_id': courseId,
          'enrolled_date': FieldValue.serverTimestamp(),
        });

        // Update the user's courses array in Firestore
        await userRef.update({
          'courses': courses,
        });

        log('User $userId enrolled in course $courseId');
      } else {
        // If the user doesn't exist, create a new document
        await userRef.set({
          'courses': [
            {
              'course_id': courseId,
              'enrolled_date': FieldValue.serverTimestamp(),
            }
          ],
        });

        log('User $userId enrolled in course $courseId');
      }
    } catch (e) {
      log("Error enrolling in course: $e");
    }
  }
}
