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
  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final TextEditingController _controller = TextEditingController();
    final Set<DateTime> datesWithTodos = todoProvider.getDatesWithTodos();
    return SingleChildScrollView(
      child: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            onDaySelected: (selectedDay, focusedDay) => {
              setState(() {
                _selectedDate = selectedDay;
              })
            },
            calendarBuilders:
                CalendarBuilders(defaultBuilder: (context, day, focusedDay) {
              if (datesWithTodos.contains(day)) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.6),
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
            }),
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
                          // Add key for better performance
                          key: ValueKey(todo),
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  todoProvider.removetodo(_selectedDate, todo);
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                                borderRadius: BorderRadius.circular(14),
                              ),
                              /*   SlidableAction(
                                onPressed: (context) {
                                  // Add more actions like "Edit" here
                                  todoProvider.toggleComplete(todo);
                                },
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                icon: Icons.edit,
                                label: 'Edit',
                              ),
                              */
                            ],
                          ),
                          child: ListTile(
                            title: Text(todo.title,
                                style: TextStyle(
                                  decoration: todo.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                )),
                            onTap: () {
                              todoProvider.status(_selectedDate, todo);
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
                          controller: _controller,
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              todoProvider.addTodo(_selectedDate, value);
                              _controller.clear();
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
