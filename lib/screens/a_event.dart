// flutter stateful widget
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AEvent extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const AEvent({
    Key? key,
    required this.groupName,
    required this.eventdoc,
    required this.userName,
  }) : super(key: key);

  final String groupName;
  final String userName;
  final DocumentSnapshot eventdoc;

  @override
  AEventState createState() => AEventState();
}

class Guest {
  String guestName;
  String inviteeEmail;
  String inviteeName;

  Guest(this.guestName, this.inviteeEmail, this.inviteeName);
}

class AEventState extends State<AEvent> {
  final User? user = FirebaseAuth.instance.currentUser;
  String? errorMessage = '';
  List<Map<String, dynamic>> guetList = [];
  final TextEditingController _addGuestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // populate guest list
    for (var element in (widget.eventdoc['guests'] as List<dynamic>)) {
      guetList.add(element as Map<String, dynamic>);
    }
  }

  Widget _errorMessage() {
    return Text(
      errorMessage ?? '',
      style: const TextStyle(color: Colors.red),
    );
  }

  Future<void> addGuest(
      String guestName, String? inviteeEmail, String inviteeName) async {
    // add guest to guest list
    setState(() {
      guetList.add({
        'guestName': guestName,
        'inviteeEmail': inviteeEmail,
        'inviteeName': inviteeName,
      });
    });

    // update guest list in database
    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventdoc.id)
        .update({
      'guests': guetList,
    });

    // clear text field
    _addGuestController.clear();
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ) {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: 300,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: title,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // displey list of guests of the event
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.eventdoc['eventName'],
                  style: const TextStyle(fontSize: 30),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  widget.eventdoc['location'],
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  '${widget.eventdoc['eventDate'].toDate().day}/${widget.eventdoc['eventDate'].toDate().month}/${widget.eventdoc['eventDate'].toDate().year}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 20,
                ),
                // total number of guests
                Text(
                  'Total number of guests: ${guetList.length}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Add Guest",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 10,
                ),
                _entryField('Guest name', _addGuestController),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    // add guest to the event
                    addGuest(_addGuestController.text, user?.email.toString(),
                        widget.userName);
                  },
                  child: const Text("Add Guest"),
                ),
                _errorMessage(),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                    width: 600,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                            // get guest name from the LinkedHashMap
                            title:
                                Text(guetList[index]['guestName'].toString()),
                            subtitle: Text(
                                'Added by ${guetList[index]['inviteeName'].toString()}'),
                            // if the guest is invited by the user add button to remove the guest
                            trailing: guetList[index]['inviteeEmail'] ==
                                    user?.email.toString()
                                ? ElevatedButton(
                                    onPressed: () {
                                      // remove guest from guests in the event collection
                                      FirebaseFirestore.instance
                                          .collection("events")
                                          .doc(widget.eventdoc.id)
                                          .update({
                                        'guests': FieldValue.arrayRemove([
                                          {
                                            'guestName': guetList[index]
                                                ['guestName'],
                                            'inviteeEmail': guetList[index]
                                                ['inviteeEmail'],
                                            'inviteeName': guetList[index]
                                                ['inviteeName'],
                                          }
                                        ])
                                      }).then((value) {
                                        // remove guest from the guest list
                                        setState(() {
                                          guetList.removeAt(index);
                                        });
                                      }).catchError((error) {
                                        setState(() {
                                          errorMessage = error.toString();
                                        });
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                    ),
                                    child: const Text("Remove"),
                                  )
                                : null,
                          ),
                        );
                      },
                      itemCount: guetList.length,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class Reviews {
//   Reviews({
//     required this.guestName,
//     required this.inviteeEmail,
//     required this.inviteeName,
//   });

//   String guestName;
//   String inviteeEmail;
//   String inviteeName;

//   factory ChatChannel.fromJson(Map<dynamic, dynamic> json) => ChatChannel(
//       userID: json['userID'],
//       userName: json['userName'],
//       ratings: json['ratings']);

//   Map<String, dynamic> toJson() =>
//       {"userID": userID, "userName": userName, 'ratings': ratings};
// }
