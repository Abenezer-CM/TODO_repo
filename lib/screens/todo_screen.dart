import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  int lightBlue = 0xff3EC4FF;
  int darkBlue = 0xff0c242e;
  int darkerBlue = 0xff3EC4FF;
  bool isEdit = false;
  int globalIndex = 0;
  bool themeMode = false;
  TextEditingController taskController = TextEditingController();

  List<Map<String, dynamic>> todoList = [];

  void deleteTask(int index) {
    setState(() {
      todoList.removeAt(index);
      writeData();
    });
  }

  void editTask(int index) {
    setState(() {
      todoList[index]['title'] = taskController.text;
      writeData();
      Navigator.of(context).pop();
    });
  }

  void addTask() {
    if (taskController.text.isNotEmpty) {
      setState(() {
        todoList.add({
          'title': taskController.text,
          'isDone': false,
        });
        Navigator.of(context).pop();
      });
      writeData();
    }
  }

  Future<void> saveThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mode', themeMode);
  }

  Future<void> retrieveThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool repeat = prefs.getBool('mode') ?? false;
    setState(() {
      print("repeat value: $repeat");
      themeMode = repeat!;
      print("themeMode value: $themeMode");
      print("isEqual ${themeMode == repeat}");
    });
  }

  Future<void> writeData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> tasksJson =
        todoList.map((task) => jsonEncode(task)).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  Future<void> readData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? tasksJson = prefs.getStringList('tasks');

    if (tasksJson != null) {
      final List<Map<String, dynamic>> tasks = tasksJson
          .map((taskJson) => jsonDecode(taskJson) as Map<String, dynamic>)
          .toList();

      setState(() {
        todoList = tasks;
      });
    }
  }

  @override
  void initState() {
    retrieveThemeMode();
    readData();

    super.initState();
  }

  void showBottomModalSheetField({int? index}) {
    taskController.clear();
    if (index != null) {
      taskController.text = todoList[index]['title'];
      isEdit = true;
    } else {
      isEdit = false;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: (themeMode) ? Color(darkBlue) : Colors.white,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(25), topLeft: Radius.circular(25)),
            ),
            width: double.infinity,
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                children: [
                  Text(
                    isEdit ? "Edit Task" : "Add Task",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (themeMode)
                          ? const Color.fromARGB(255, 38, 118, 152)
                          : const Color(0xff3EC4FF),
                      fontSize: 30,
                    ),
                  ),
                  TextField(
                    style: TextStyle(
                        color: (themeMode) ? Colors.white : Colors.black),
                    controller: taskController,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: (themeMode)
                              ? const Color.fromARGB(255, 38, 118, 152)
                              : const Color(0xff3EC4FF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (themeMode)
                          ? const Color.fromARGB(255, 38, 118, 152)
                          : const Color(0xff3EC4FF),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      if (isEdit && index != null) {
                        editTask(index);
                      } else {
                        addTask();
                      }
                    },
                    child: Text(
                      isEdit ? "Save" : "Add",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (themeMode) ? Color(darkBlue) : Color(lightBlue),
      body: Container(
        padding: const EdgeInsets.only(
          top: 80,
        ),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Switch(
                      activeColor: const Color.fromARGB(255, 20, 70, 92),
                      inactiveThumbColor: const Color(0xff3EC4FF),
                      value: themeMode,
                      onChanged: (value) {
                        if (themeMode == false) {
                          setState(() {
                            themeMode = value;
                            saveThemeMode();
                          });
                        } else {
                          setState(() {
                            themeMode = value;
                            saveThemeMode();
                          });
                        }
                      }),
                  (themeMode)
                      ? const Text(
                          "Dark",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Light",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                ],
              ),
            ),
            Text(
              "Todoey",
              style: TextStyle(
                fontSize: 60,
                color: (themeMode)
                    ? const Color.fromARGB(255, 199, 199, 199)
                    : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${todoList.length}  Tasks",
              style: TextStyle(
                fontSize: 25,
                color: (themeMode)
                    ? const Color.fromARGB(255, 199, 199, 199)
                    : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                  color: (themeMode)
                      ? const Color.fromARGB(255, 25, 24, 24)
                      : Colors.white,
                ),
                child: (todoList.isEmpty)
                    ? const Center(
                        child: Text(
                        "You Have No Tasks",
                        style:
                            TextStyle(color: Color(0xff3EC4FF), fontSize: 20),
                      ))
                    : Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: ListView.builder(
                          itemCount: todoList.length,
                          itemBuilder: (BuildContext context, int index) {
                            bool isChecked = todoList[index]['isDone'];
                            return ListTile(
                              title: Text(
                                todoList[index]['title'].toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: (themeMode)
                                      ? const Color.fromARGB(255, 19, 113, 154)
                                      : const Color(0xff3EC4FF),
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              leading: Checkbox(
                                activeColor: (themeMode)
                                    ? const Color.fromARGB(255, 31, 97, 126)
                                    : const Color.fromARGB(255, 43, 122, 156),
                                value: isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    todoList[index]['isDone'] = value ?? false;
                                    writeData();
                                  });
                                },
                              ),
                              trailing: Wrap(
                                spacing: -16,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: (themeMode)
                                          ? const Color.fromARGB(
                                              255, 165, 53, 53)
                                          : Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      deleteTask(index);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: (themeMode)
                                          ? const Color.fromARGB(
                                              255, 73, 167, 121)
                                          : Colors.greenAccent,
                                    ),
                                    onPressed: () {
                                      showBottomModalSheetField(index: index);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: (themeMode) ? Color(darkBlue) : Color(lightBlue),
        onPressed: () {
          showBottomModalSheetField();
        },
        child: Icon(
          Icons.add,
          size: 35,
          color: (themeMode)
              ? const Color.fromARGB(255, 218, 217, 217)
              : Colors.white,
        ),
      ),
    );
  }
}
