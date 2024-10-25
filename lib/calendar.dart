import 'package:flutter/material.dart';
import 'package:flutter_application_1/to_do_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class calendarScreen extends StatefulWidget {
  const calendarScreen({super.key});

  @override
  State<calendarScreen> createState() => _calendarScreenState();
}

class _calendarScreenState extends State<calendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController controller = TextEditingController();
  Color selectedDayColor = Colors.grey.withOpacity(0.6); // Default color

  @override
  void initState() {
    super.initState();
    // Fetch todos for the current date when the screen loads
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    todoProvider.fetchTodos(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    //final Set<DateTime> datesWithTodos = todoProvider.getDatesWithTodos();

    return SingleChildScrollView(
      child: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            onDaySelected: (selectedDay, focusedDay) async {
              setState(() {
                _selectedDate = selectedDay;
              });
              await todoProvider.fetchTodos(selectedDay);
              // Fetch todos for selected day
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                // Color dayColor =
                //  hasTodos ? Colors.red : Colors.grey.withOpacity(0.6);
                bool hasTodos = todoProvider.getTodos(day).isNotEmpty;

                selectedDayColor = hasTodos
                    ? const Color.fromARGB(255, 8, 4, 15).withOpacity(0.6)
                    : Colors.deepPurple.withOpacity(0.6);
                Color dayColor = hasTodos
                    ? _getColorFromHex(todoProvider
                        .getTodos(day)
                        .first
                        .color) // Use the color of the first todo
                    : Colors.grey.withOpacity(0.6); // Default color if no todos
                if (day == focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: dayColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                } else if (hasTodos) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: dayColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey,
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: ListView.builder(
                      itemCount: todoProvider.getTodos(_selectedDate).length,
                      itemBuilder: (context, index) {
                        final todo =
                            todoProvider.getTodos(_selectedDate)[index];
                        return Slidable(
                          key: ValueKey(todo),
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  final success = await todoProvider.removeTodo(
                                      _selectedDate,
                                      todo); // Delete the todo and get success status
                                  if (success) {
                                    await todoProvider.fetchTodos(
                                        _selectedDate); // Fetch the updated list
                                  }
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              todo.title,
                              style: TextStyle(
                                decoration: todo.isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: _getColorFromHex(todo
                                    .color), // Use the helper function), // Convert hex to Color
                              ),
                            ),
                            tileColor: _getColorFromHex(todo
                                .color), // Set background colorbackground color
                            onTap: () {
                              // Implement toggle status if needed
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey,
                        ),
                        height: 300,
                        child: TextField(
                          controller: controller,
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              String colorString = selectedDayColor.value
                                  .toRadixString(16)
                                  .padLeft(8, '0')
                                  .substring(
                                      2); // Get the 6-character hex without alpha

                              todoProvider
                                  .addTodo(_selectedDate, value, colorString)
                                  .then((_) {
                                controller.clear();
                              }).catchError((error) {
                                // Handle error (e.g., show a message)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed to add todo: $error')),
                                );
                              });
                            }
                          },
                          decoration:
                              const InputDecoration(labelText: 'Add a todo'),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _getColorFromHex(String colorString) {
  // Remove '#' if present
  if (colorString.startsWith('#')) {
    colorString = colorString.substring(1);
  }
  // Parse the hex string to a Color
  return Color(int.parse('0xff$colorString'));
}
