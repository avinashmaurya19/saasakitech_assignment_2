import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saasakitech_assignment_2/LoginSignup/login_screen.dart';
import 'package:saasakitech_assignment_2/helper.dart';
import 'package:saasakitech_assignment_2/model/user_model.dart';
import 'package:saasakitech_assignment_2/notification/notifi_service.dart';
import 'package:saasakitech_assignment_2/view/user_page_add.dart';
import 'package:saasakitech_assignment_2/view/user_page_edit.dart';

class UserPageList extends StatefulWidget {
  const UserPageList({super.key});

  @override
  State<StatefulWidget> createState() => _UserPageListState();
}

class _UserPageListState extends State<UserPageList> {
  final NotificationService notificationService = NotificationService();
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final successMessage =
  //       ModalRoute.of(context)?.settings.arguments as String?;
  //   if (successMessage != null) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(successMessage)),
  //       );
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    notificationService.initNotification();
  }

  Future updateUserCompletion(User user) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(user.id);
    await docUser.update({'completed': user.completed});
  }

  void scheduleTaskNotifications(List<User> users) {
    for (var user in users) {
      if (!user.completed && user.deadline.isAfter(DateTime.now())) {
        final notificationTime =
            user.deadline.subtract(const Duration(minutes: 10));
        notificationService.scheduleNotification(
          id: user.id.hashCode, // unique id based on user id
          title: 'Task Reminder',
          body: 'Your task "${user.title}" is due in 10 minutes.',
          scheduledTime: notificationTime,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('All Users'),
          actions: [
            ElevatedButton(
              child: const Text('Show notifications'),
              onPressed: () {
                notificationService.showNotification(
                    title: 'Sample title', body: 'It works!');
              },
            ),
            IconButton(
              onPressed: () {
                FireBaseLogout().logOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: StreamBuilder<List<User>>(
          stream: readUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong! ${snapshot.error}');
            } else if (snapshot.hasData) {
              final users = snapshot.data!;
              scheduleTaskNotifications(users);
              return ListView(
                children: users.map(buildUser).toList(),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const UserPageAdd(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      );

  Widget buildUser(User user) => Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.grey[100]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat("yyyy-MM-dd HH:mm").format(user.deadline),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.expetedTaskDuration,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    const Text('Mark as Completed'),
                    Checkbox(
                      value: user.completed,
                      onChanged: (bool? newValue) {
                        setState(() {
                          user.completed = newValue!;
                          updateUserCompletion(user);
                        });
                      },
                    ),
                  ],
                ),
                Text(
                  user.completed ? 'Completed' : 'Incomplete',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserPageEdit(
                            id: user.id,
                            name: user.title,
                            description: user.description,
                            deadline: user.deadline,
                            expetedTaskDuration: user.expetedTaskDuration,
                            completed: user.completed,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit)),
                IconButton(
                    onPressed: () {
                      AlertDialog delete = AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Confirmation",
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 10),
                            Text("Are you sure for deleting ${user.title}?")
                          ],
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                final docUser = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.id);
                                docUser.delete();
                                Navigator.pop(context);
                              },
                              child: const Text("Yes")),
                          TextButton(
                            child: const Text('No'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                      showDialog(
                          context: context, builder: (context) => delete);
                    },
                    icon: const Icon(Icons.delete)),
              ],
            ),
          ],
        ),
      );

  Stream<List<User>> readUsers() => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());
}
