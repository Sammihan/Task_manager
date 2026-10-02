import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8001";

  static String _extractErrorMessage(dynamic data) {
    if (data == null) return "An unexpected error occurred";
    if (data is String) return data;
    if (data is Map) {
      if (data["detail"] != null) {
        return _extractErrorMessage(data["detail"]);
      }
      if (data["message"] != null) {
        return data["message"].toString();
      }
    }
    if (data is List && data.isNotEmpty) {
      final first = data[0];
      if (first is Map && first["msg"] != null) {
        return first["msg"].toString();
      }
      return first.toString();
    }
    return data.toString();
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email.trim(), "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "token": data["access_token"]};
      }

      return {"success": false, "message": _extractErrorMessage(data)};
    } catch (e) {
      return {
        "success": false,
        "message": "Unable to connect to server. Please ensure backend is running.",
      };
    }
  }

  static Future<dynamic> getTasks(int page, int limit) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("$baseUrl/tasks?page=$page&limit=$limit"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<String?> createTask(
    String title,
    String category,
    String priority,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("$baseUrl/tasks"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "title": title.trim(),
          "category": category.trim(),
          "priority": priority,
          "completed": false,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null;
      }

      final data = jsonDecode(response.body);
      return _extractErrorMessage(data);
    } catch (e) {
      return "Unable to connect to server";
    }
  }

  static Future<bool> deleteTask(int taskId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.delete(
        Uri.parse("$baseUrl/tasks/$taskId"),
        headers: {"Authorization": "Bearer $token"},
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> updateTask(
    int taskId,
    String title,
    String category,
    String priority, {
    bool completed = false,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.put(
        Uri.parse("$baseUrl/tasks/$taskId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "title": title.trim(),
          "category": category.trim(),
          "completed": completed,
          "priority": priority,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null;
      }

      final data = jsonDecode(response.body);
      return _extractErrorMessage(data);
    } catch (e) {
      return "Unable to connect to server";
    }
  }

  static Future<bool> toggleTask(Map task) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.put(
        Uri.parse("$baseUrl/tasks/${task["id"]}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "title": task["title"],
          "category": task["category"],
          "completed": !(task["completed"] == true),
          "priority": task["priority"] ?? "Medium",
        }),
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> signup(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username.trim(),
          "email": email.trim(),
          "password": password,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null;
      }

      final data = jsonDecode(response.body);
      return _extractErrorMessage(data);
    } catch (e) {
      return "Unable to connect to server. Please ensure backend is running.";
    }
  }

  static Future<List> searchTasks(String title) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("$baseUrl/search?title=${Uri.encodeComponent(title)}"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List> searchByCategory(String category) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.get(
        Uri.parse(
          "$baseUrl/tasks/category/${Uri.encodeComponent(category)}",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) return data;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
