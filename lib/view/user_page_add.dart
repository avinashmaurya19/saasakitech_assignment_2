
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saasakitech_assignment_2/model/user_model.dart';

class UserPageAdd extends StatefulWidget {
  const UserPageAdd({super.key});

  @override
  State<StatefulWidget> createState() => _UserPageAddState();
}

class _UserPageAddState extends State<UserPageAdd> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final controllerTitle = TextEditingController();
  final controllerDescription = TextEditingController();
  final controllerDeadline = TextEditingController();
  final controllerExpectedTaskDuration = TextEditingController();

  final format = DateFormat("yyyy-MM-dd HH:mm");

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Add User'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: controllerTitle,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: controllerDescription,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: controllerDeadline,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Deadline (yyyy-MM-dd HH:mm)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please pick a deadline';
                  }
                  return null;
                },
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
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
                        controllerDeadline.text = format.format(dateTime);
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: controllerExpectedTaskDuration,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Expected Task Duration',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the expected task duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final deadline = DateFormat("yyyy-MM-dd HH:mm")
                          .parse(controllerDeadline.text);
                      final user = User(
                        title: controllerTitle.text,
                        description: controllerDescription.text,
                        deadline: deadline,
                        expetedTaskDuration:
                            controllerExpectedTaskDuration.text,
                      );
                      createUser(user);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'))
            ],
          ),
        ),
      );

  Future createUser(User user) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();
    user.id = docUser.id; // Set the document ID to the user object

    final json = user.toJson();
    await docUser.set(json);
  }
}
