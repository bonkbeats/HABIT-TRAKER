import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodoProvider with ChangeNotifier {
  final Map<DateTime, List<Todo>> _todos = {}; // Store todos by date

  List<Todo> getTodos(DateTime date) {
    return _todos[date] ?? [];
  }

  Set<DateTime> getDatesWithTodos() {
    return _todos.keys.toSet();
  }

  // Fetch todos from backend
  Future<void> fetchTodos(DateTime date) async {
    final response = await http.get(Uri.parse(
        'http://192.168.178.251:5000/api/todos/${date.toIso8601String()}'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _todos[date] = data.map((json) => Todo.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  // Add a todo and save it to backend
  Future<void> addTodo(DateTime date, String title, String color) async {
    print("Fetching todos for date: ${date.toIso8601String()}"); // Debug line
    print(
        "Adding todo for date: ${date.toIso8601String()} with color $color"); // Debug line
    // Ensure color has '#' prefix
    if (!color.startsWith('#')) {
      color = '#$color';
    }

    final response = await http.post(
      Uri.parse('http://192.168.178.251:5000/api/todos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title, 'date': date.toIso8601String(),
        'color': color, // Include the color in the request body
      }),
    );

    if (response.statusCode == 201) {
      _todos[date]?.add(Todo.fromJson(jsonDecode(response.body)));
      notifyListeners();
    } else {
      throw Exception('Failed to add todo');
    }
  }

  Future<bool> removeTodo(DateTime date, Todo todo) async {
    //z  print("Attempting to delete todo: ${todo.title}"); // Debug line
    try {
      final response = await http.delete(
          Uri.parse('http://192.168.178.251:5000/api/todos/${todo.id}'));

      //  print("Attempting to delete todo: ${todo.id}");
      //print("HTTP Status Code: ${response.statusCode}");
      // print("Response Body: ${response.body}");
      if (response.statusCode == 204) {
        // THE PROBLEM WAS OF THE STATUS CODE BRA
        _todos[date]?.remove(todo);
        notifyListeners(); // Notify listeners after removing the todo
        return true;
      } else {
        //  print("Error: ${response.body}");
        throw Exception('Failed to delete todo');
      }
    } catch (error) {
      //print("Caught error: $error");
      throw error;
    }
  }
}

class Todo {
  final String id;
  final String title;
  final bool isDone;
  final DateTime date;
  final String color; // Add a color field

  Todo({
    required this.id,
    required this.title,
    required this.isDone,
    required this.date,
    required this.color,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['_id'],
      title: json['title'],
      isDone: json['isDone'],
      date: DateTime.parse(json['date']),
      color: json['color'], // Parse the color field from JSON
    );
  }
}
