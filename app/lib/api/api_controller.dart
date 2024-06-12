import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:szabsync/api/api_routes.dart';

class ApiController {
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await http.post(
      Uri.parse(APIRoutes.login),
      body: {'username': username, 'password': password},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> signup(
      String name, String email, String password, String studentID) async {
    final response = await http.post(
      Uri.parse(APIRoutes.signup),
      body: {'name': name, 'email': email, 'password': password},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> sendVerification(String email) async {
    final response = await http.post(
      Uri.parse(APIRoutes.sendVerification),
      body: {'email': email},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> buyTicket(
      String eventId, String userId) async {
    final response = await http.post(
      Uri.parse(APIRoutes.buyTicket),
      body: {'eventId': eventId, 'userId': userId},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> completeEvent(String eventId) async {
    final response = await http.post(
      Uri.parse(APIRoutes.completeEvent),
      body: {'eventId': eventId},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> createCategory(
      String categoryName) async {
    final response = await http.post(
      Uri.parse(APIRoutes.createCategory),
      body: {'categoryName': categoryName},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> createEvent(
      String eventName, String categoryId, String userId) async {
    final response = await http.post(
      Uri.parse(APIRoutes.createEvent),
      body: {
        'eventName': eventName,
        'categoryId': categoryId,
        'userId': userId
      },
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> createEventPost(
      String eventId, String userId, String content) async {
    final response = await http.post(
      Uri.parse(APIRoutes.createEventPost),
      body: {'eventId': eventId, 'userId': userId, 'content': content},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> createNotification(
      String userId, String message) async {
    final response = await http.post(
      Uri.parse(APIRoutes.createNotification),
      body: {'userId': userId, 'message': message},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> deletePost(String postId) async {
    final response = await http.post(
      Uri.parse(APIRoutes.deletePost),
      body: {'postId': postId},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> editCategory(
      String categoryId, String newName) async {
    final response = await http.post(
      Uri.parse(APIRoutes.editCategory),
      body: {'categoryId': categoryId, 'newName': newName},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> editEvent(
      String eventId, String newName) async {
    final response = await http.post(
      Uri.parse(APIRoutes.editEvent),
      body: {'eventId': eventId, 'newName': newName},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> getNotifs(String userId) async {
    final response = await http.post(
      Uri.parse(APIRoutes.getNotifs),
      body: {'userId': userId},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> likeEventPost(
      String postId, String userId) async {
    final response = await http.post(
      Uri.parse(APIRoutes.likeEventPost),
      body: {'postId': postId, 'userId': userId},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> searchEvent(String query) async {
    final response = await http.post(
      Uri.parse(APIRoutes.searchEvent),
      body: {'query': query},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> ticketStatus(String ticketId) async {
    final response = await http.post(
      Uri.parse(APIRoutes.ticketStatus),
      body: {'ticketId': ticketId},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> unbanStudent(String studentId) async {
    final response = await http.post(
      Uri.parse(APIRoutes.unbanStudent),
      body: {'studentId': studentId},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> unlikeEventPost(
      String postId, String userId) async {
    final response = await http.post(
      Uri.parse(APIRoutes.unlikeEventPost),
      body: {'postId': postId, 'userId': userId},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> uploadFile(
      String filePath, String userId) async {
    final response = await http.post(
      Uri.parse(APIRoutes.uploadFile),
      body: {'filePath': filePath, 'userId': userId},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> verifyTicket(String ticketId) async {
    final response = await http.post(
      Uri.parse(APIRoutes.verifyTicket),
      body: {'ticketId': ticketId},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> viewActiveEvents() async {
    final response = await http.post(
      Uri.parse(APIRoutes.viewActiveEvents),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> viewAllCategories() async {
    final response = await http.post(
      Uri.parse(APIRoutes.viewAllCategories),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> viewAllStudents() async {
    final response = await http.post(
      Uri.parse(APIRoutes.viewAllStudents),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> viewArchivedEvents() async {
    final response = await http.post(
      Uri.parse(APIRoutes.viewArchivedEvents),
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> viewCategoryEvents(
      String categoryId) async {
    final response = await http.post(
      Uri.parse(APIRoutes.viewCategoryEvents),
      body: {'categoryId': categoryId},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> viewEventPosts(String eventId) async {
    final response = await http.post(
      Uri.parse(APIRoutes.viewEventPosts),
      body: {'eventId': eventId},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> viewSingleEvent(String eventId) async {
    final response = await http.post(
      Uri.parse(APIRoutes.viewSingleEvent),
      body: {'eventId': eventId},
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> viewTopEvents() async {
    final response = await http.post(
      Uri.parse(APIRoutes.viewTopEvents),
    );
    return _processResponse(response);
  }

  // Helper function to process HTTP response
  static Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
