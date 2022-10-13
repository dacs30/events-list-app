import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../main.dart';

class CreateAGroup extends StatefulWidget {
  final Function() notifyParent;
  const CreateAGroup({super.key, required this.notifyParent});

  @override
  CreateAGroupState createState() => CreateAGroupState();
}

class CreateAGroupState extends State<CreateAGroup> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupPasswordController =
      TextEditingController();

  bool update = false;

  @override
  void initState() {
    super.initState();
    // populate guest lis
  }

  Future<void> foundAndAddedGroup() async {
    try {
      await FirebaseFirestore.instance
          .collection("groups")
          .where("groupName", isEqualTo: _groupNameController.text)
          .get()
          .then((value) => {
                if (value.docs.isNotEmpty)
                  {
                    if (value.docs[0]['groupPassword'] ==
                        _groupPasswordController.text)
                      {
                        // add user to group members array
                        FirebaseFirestore.instance
                            .collection("groups")
                            .doc(value.docs[0].id)
                            .update({
                          "members": FieldValue.arrayUnion([
                            FirebaseAuth.instance.currentUser!.email.toString()
                          ])
                        }).then(((value) => widget.notifyParent()))
                      }
                  }
                else
                  {
                    // create group
                    FirebaseFirestore.instance.collection("groups").add({
                      "groupName": _groupNameController.text,
                      "groupPassword": _groupPasswordController.text,
                      "members": [
                        FirebaseAuth.instance.currentUser!.email.toString()
                      ]
                    }).then(
                      (value) => widget.notifyParent(),
                    )
                  }
              });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have not created a group yet',
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Create a group to start using the app',
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Click the button below to create a group',
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                // open pop up to create a group or join a group
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: const Text('Create a group'),
                          content: SizedBox(
                            width: 300,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Group name',
                                  ),
                                  controller: _groupNameController,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'group password',
                                  ),
                                  controller: _groupPasswordController,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        foundAndAddedGroup();
                                      },
                                      child: const Text('Create or join'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ));
                    });
              },
              child: const Text('Create a Group'),
            ),
          ],
        ),
      ),
    );
  }
}
