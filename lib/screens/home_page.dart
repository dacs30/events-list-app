import 'package:final_project_flutter/screens/a_event.dart';
import 'package:final_project_flutter/screens/events_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_project_flutter/auth/authenticate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'create_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;

  final emailController = TextEditingController();

  late String data;

  int currentIndex = 0;

  String userName = '';
  String userEmail = '';
  String groupName = '';
  String groupId = '';
  DocumentSnapshot? groupDoc;
  List<String> groupList = [];
  bool areWeInEvent = false;
  DocumentSnapshot? eventDoc;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.email)
        .get()
        .then((value) => {
              setState(() {
                userName = value.data()!['name'];
                userEmail = value.data()!['email'];
              })
            });
    FirebaseFirestore.instance
        .collection("groups")
        .where("members", arrayContains: user!.email)
        .get()
        .then((value) => {
              if (value.docs.isNotEmpty)
                {
                  setState(() {
                    groupName = value.docs[0].data()['groupName'];
                  }),
                  for (var i = 0; i < value.docs.length; i++)
                    {
                      groupList.add(value.docs[i].data()['groupName']),
                    }
                }
            });
    // create snapchot of the group
    FirebaseFirestore.instance
        .collection("groups")
        .where("members", arrayContains: user!.email)
        .snapshots()
        .listen((event) {
      setState(() {
        groupId = event.docs[0].reference.id;
      });
    });

    // store document snapshot of the group
    setState(() {
      data = groupName;
    });
  }

  Widget getPage(int index) {
    switch (index) {
      case 0:
        // check if groupName and groupId are empty circle spin loader if true
        if (groupName == '' && groupId == '') {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return EventsPage(
            groupName: groupName,
            documentId: groupId,
            currentIndex: currentIndex,
            onEventViewPressed: (DocumentSnapshot eventDoc) => {
              setState(() {
                areWeInEvent = true;
                this.eventDoc = eventDoc;
              })
            },
          );
        }
      case 1:
        return Scaffold(
            body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text.rich(
                  TextSpan(
                    text: 'Group members',
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: StreamBuilder<QuerySnapshot>(
                    // create a list of all memebers in group of grouName
                    stream: FirebaseFirestore.instance
                        .collection("groups")
                        .where("groupName", isEqualTo: groupName)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Loading");
                      }

                      return ListView(
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          // members list
                          List<dynamic> members = document['members'];
                          return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: members.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Card(
                                    child: ListTile(
                                      title: Text(members[index]),
                                      // button to remove member from group if
                                      // not the current user
                                      trailing: members[index] == userEmail
                                          ? const SizedBox()
                                          : IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                setState(() {
                                                  members.removeAt(index);
                                                });
                                                FirebaseFirestore.instance
                                                    .collection("groups")
                                                    .doc(document.id)
                                                    .update({
                                                  'members': members,
                                                });
                                              },
                                            ),
                                    ),
                                  ),
                                );
                              });
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ));
      case 2:
        return const Scaffold(
          body: Center(
            child: Text("Page 3"),
          ),
        );
      default:
        if (groupName == '' && groupId == '') {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return EventsPage(
            groupName: groupName,
            documentId: groupId,
            currentIndex: currentIndex,
            onEventViewPressed: (DocumentSnapshot eventDoc) => {
              setState(() {
                areWeInEvent = true;
                this.eventDoc = eventDoc;
              })
            },
          );
        }
    }
  }

  onTabTapped(int index) {
    setState(() {
      areWeInEvent = false;
      currentIndex = index;
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Widget _title() {
    return Text(groupName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _title(),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(userName),
                accountEmail: Text(userEmail),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    "D",
                    style: TextStyle(fontSize: 40.0),
                  ),
                ),
              ),
              ...groupList.map((group) {
                return ListTile(
                  title: Text(group),
                  onTap: () {
                    setState(() {
                      groupName = group;
                      areWeInEvent = false;
                      currentIndex = 0;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              ListTile(
                title: const Text('Sign Out'),
                onTap: () {
                  signOut();
                },
              ),
            ],
          ),
        ),
        body: areWeInEvent
            ? AEvent(
                groupName: groupName, eventdoc: eventDoc!, userName: userName)
            : getPage(currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Group',
            ),
          ],
          currentIndex: currentIndex,
          onTap: (value) => onTabTapped(value),
          selectedItemColor: Colors.blue,
        ),
        floatingActionButton: !areWeInEvent
            ? FloatingActionButton(
                onPressed: () {
                  if (currentIndex == 1) {
                    // pop up to add member to group with email field
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Add member'),
                            content: TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter email'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection("groups")
                                      .where("groupName", isEqualTo: groupName)
                                      .get()
                                      .then((value) {
                                    List<dynamic> members =
                                        value.docs[0]['members'];
                                    members.add(emailController.text);
                                    FirebaseFirestore.instance
                                        .collection("groups")
                                        .doc(value.docs[0].id)
                                        .update({
                                      'members': members,
                                    });
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          );
                        });
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateEvent(
                          groupName: groupName,
                        ),
                      ),
                    );
                  }
                },
                child: const Icon(Icons.add),
                backgroundColor: Colors.blue,
              )
            : null);
  }
}
