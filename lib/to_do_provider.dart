import 'package:flutter/material.dart';
import 'package:flutter_application_1/to_do.dart';

class TodoProvider extends ChangeNotifier {
  final Map<DateTime, List<TodoItem>> _todos = {};

  List<TodoItem> getTodos(DateTime date) {
    return _todos[date] ?? [];
  }

  void addTodo(DateTime date, String title) {
    if (_todos[date] == null) {
      _todos[date] = [];
    }
    _todos[date]!.add(TodoItem(title: title));
    notifyListeners();
  }

  void status(DateTime date, TodoItem todo) {
    todo.isDone = !todo.isDone;
    notifyListeners();
  }

  void removetodo(DateTime date, TodoItem todo) {
    if (_todos.containsKey(date)) {
      _todos[date]?.remove(todo);
      notifyListeners(); // Notify listeners to update UI
    }
  }

  Set<DateTime> getDatesWithTodos() {
    return _todos.keys.toSet();
  }
}
