import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditTaskScreen extends StatefulWidget {
  final Map task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController categoryController;
  String selectedPriority = "Medium";

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.task["title"]);

    selectedPriority = widget.task["priority"];
    categoryController = TextEditingController(text: widget.task["category"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: "Category"),
            ),

            const SizedBox(height: 30),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: selectedPriority,
              decoration: const InputDecoration(
                labelText: "Priority",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "High", child: Text("High")),
                DropdownMenuItem(value: "Medium", child: Text("Medium")),
                DropdownMenuItem(value: "Low", child: Text("Low")),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedPriority = value;
                  });
                }
              },
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  String? error = await ApiService.updateTask(
                    widget.task["id"],
                    titleController.text,
                    categoryController.text,
                    selectedPriority,
                    completed: widget.task["completed"] ?? false,
                  );

                  if (!mounted) return;

                  if (error == null) {
                    navigator.pop();
                  } else {
                    messenger.showSnackBar(SnackBar(content: Text(error)));
                  }
                },
                child: const Text("Update Task"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
