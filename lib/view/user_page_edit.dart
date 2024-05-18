import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saasakitech_assignment_2/model/user_model.dart';

class UserPageEdit extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final DateTime deadline;
  final String expetedTaskDuration;
  final bool completed;

  const UserPageEdit({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.deadline,
    required this.expetedTaskDuration,
    required this.completed,
  });

  @override
  State<StatefulWidget> createState() => _UserPageEditState();
}

class _UserPageEditState extends State<UserPageEdit> {
  final controllerTitle = TextEditingController();
  final controllerDescription = TextEditingController();
  final controllerDeadline = TextEditingController();
  final controllerExpectedTaskDuration = TextEditingController();
  bool isCompleted = false;

  final format = DateFormat("yyyy-MM-dd HH:mm");
  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    controllerTitle.text = widget.name;
    controllerDescription.text = widget.description;
    controllerDeadline.text =
        DateFormat("yyyy-MM-dd HH:mm").format(widget.deadline);
    controllerExpectedTaskDuration.text = widget.expetedTaskDuration;
    isCompleted = widget.completed;
    selectedDateTime = widget.deadline;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Edit User'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: controllerTitle,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Title',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controllerDescription,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Description',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controllerDeadline,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Deadline (yyyy-MM-dd HH:mm)',
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDateTime ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(
                        selectedDateTime ?? DateTime.now()),
                  );

                  if (pickedTime != null) {
                    final dateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                    setState(() {
                      selectedDateTime = dateTime;
                      controllerDeadline.text = format.format(dateTime);
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controllerExpectedTaskDuration,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Expected Task Duration',
              ),
            ),
            const SizedBox(height: 24),
            // CheckboxListTile(
            //   title: const Text('Mark as Complete'),
            //   value: isCompleted,
            //   onChanged: (bool? value) {
            //     setState(() {
            //       isCompleted = value!;
            //     });
            //   },
            // ),
            const SizedBox(height: 32),
            ElevatedButton(
                onPressed: () {
                  if (selectedDateTime != null) {
                    final user = User(
                      id: widget.id,
                      title: controllerTitle.text,
                      description: controllerDescription.text,
                      deadline: selectedDateTime!,
                      expetedTaskDuration: controllerExpectedTaskDuration.text,
                      completed: isCompleted,
                    );
                    updateUser(user);
                    Navigator.pop(context);
                  } else {
                    // Show an error message if the date is not selected
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a deadline'),
                      ),
                    );
                  }
                },
                child: const Text('Update'))
          ],
        ),
      );

  Future updateUser(User user) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(user.id);
    await docUser.update(user.toJson());
  }
}
