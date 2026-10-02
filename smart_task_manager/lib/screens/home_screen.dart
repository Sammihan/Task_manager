import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'create_task_screen.dart';
import 'edit_task_screen.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 1;
  bool hasNextPage = true;
  int limit = 10;
  List tasks = [];
  List allTasks = [];
  final TextEditingController searchController = TextEditingController();
  String selectedCategory = "All";
  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final fetchedTasks = await ApiService.getTasks(currentPage, limit);

    if (!mounted) return;

    setState(() {
      if (fetchedTasks is List) {
        allTasks = fetchedTasks;
        tasks = fetchedTasks.where((task) => task["completed"] == false).toList();
        hasNextPage = fetchedTasks.length == limit;
      } else {
        allTasks = [];
        tasks = [];
        hasNextPage = false;
      }
    });
  }

  Future<void> searchTask(String title) async {
    if (title.isEmpty) {
      loadTasks();
      return;
    }

    final searchedTasks = await ApiService.searchTasks(title);

    if (!mounted) return;

    setState(() {
      tasks = searchedTasks
          .where((task) => task["completed"] == false)
          .toList();
    });
  }

  Future<void> searchCategory(String category) async {
    if (category == "All") {
      loadTasks();
      return;
    }

    final searchedTasks = await ApiService.searchByCategory(
      category.toLowerCase(),
    );

    if (!mounted) return;

    setState(() {
      tasks = searchedTasks
          .where((task) => task["completed"] == false)
          .toList();
    });
  }

  int get totalTasks => allTasks.length;

  int get completedTasks =>
      allTasks.where((task) => task["completed"] == true).length;

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;

  String getCurrentDay() {
    switch (DateTime.now().weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      default:
        return "Sunday";
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildCategoryChip(String category) {
      final bool isSelected = selectedCategory == category;

      return ChoiceChip(
        label: Text(category),

        selected: isSelected,

        selectedColor: Colors.blue,

        backgroundColor: Colors.grey.shade200,

        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        onSelected: (selected) async {
          setState(() {
            selectedCategory = category;
          });

          await searchCategory(category);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.task_alt, color: Colors.blue),
            SizedBox(width: 10),
            Text(
              "Smart Task Manager",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),

            onPressed: () async {
              final navigator = Navigator.of(context);
              SharedPreferences prefs = await SharedPreferences.getInstance();

              await prefs.remove("token");

              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: Center(
        child: SizedBox(
          width: 900,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "${getCurrentDay()}, "
                      "${DateTime.now().day}/"
                      "${DateTime.now().month}/"
                      "${DateTime.now().year}",

                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: searchController,

                      onChanged: (value) {
                        searchTask(value);
                      },

                      decoration: InputDecoration(
                        hintText: "Search tasks...",

                        prefixIcon: const Icon(Icons.search),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),

                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: Row(
                        children: [
                          buildCategoryChip("All"),

                          const SizedBox(width: 10),

                          buildCategoryChip("Coding"),

                          const SizedBox(width: 10),

                          buildCategoryChip("Academics"),

                          const SizedBox(width: 10),

                          buildCategoryChip("Health"),

                          const SizedBox(width: 10),

                          buildCategoryChip("Personal"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text(
                          "$completedTasks of "
                          "$totalTasks completed",

                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Text(
                          "${(progress * 100).toInt()}%",

                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,

                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),

                      elevation: 3,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(8),

                        child: ListTile(
                          leading: Checkbox(
                            value: tasks[index]["completed"],

                            onChanged: (value) async {
                              final messenger = ScaffoldMessenger.of(context);
                              bool success = await ApiService.toggleTask(
                                tasks[index],
                              );

                              if (success) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text("Task Completed ✅"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );

                                loadTasks();
                              }
                            },
                          ),

                          title: Text(
                            tasks[index]["title"],

                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),

                          subtitle: Row(
                            children: [
                              Text(
                                tasks[index]["category"],
                                style: TextStyle(color: Colors.grey.shade700),
                              ),

                              const Spacer(),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: tasks[index]["priority"] == "High"
                                      ? Colors.red
                                      : tasks[index]["priority"] == "Medium"
                                      ? Colors.orange
                                      : Colors.green,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tasks[index]["priority"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),

                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditTaskScreen(task: tasks[index]),
                                    ),
                                  );

                                  loadTasks();
                                },
                              ),

                              IconButton(
                                icon: const Icon(Icons.delete),

                                onPressed: () async {
                                  bool success = await ApiService.deleteTask(
                                    tasks[index]["id"],
                                  );

                                  if (success) {
                                    loadTasks();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: currentPage > 1
                        ? () {
                            setState(() {
                              currentPage--;
                            });

                            loadTasks();
                          }
                        : null,
                    child: const Text("Previous"),
                  ),

                  const SizedBox(width: 20),

                  Text(
                    "Page $currentPage",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(width: 20),

                  ElevatedButton(
                    onPressed: hasNextPage
                        ? () {
                            setState(() {
                              currentPage++;
                            });

                            loadTasks();
                          }
                        : null,
                    child: const Text("Next"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
          );

          loadTasks();
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}
