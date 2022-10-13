// flutter stateful widget
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter/screens/a_event.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const EventsPage(
      {Key? key,
      required this.groupName,
      required this.documentId,
      required this.currentIndex,
      required this.onEventViewPressed})
      : super(key: key);

  final Set<void> Function(DocumentSnapshot<Object?>) onEventViewPressed;
  final String groupName;
  final String documentId;
  final int currentIndex;

  @override
  EventsPageState createState() => EventsPageState();
}

class EventsPageState extends State<EventsPage> {
  List<String> eventList = [];

  // void setItem(string itemValue) {
  //   widget.groupName = itemValue;
  //   this.itemChanged();
  // }

  @override
  initState() {
    // get events associated with groupname
    super.initState();
    if (eventList.isEmpty) {
      loadEvents();
    }
  }

  Future<void> loadEvents() async {
    await FirebaseFirestore.instance
        .collection("events")
        .where("groupCreator", isEqualTo: widget.groupName)
        .get()
        .then((value) => {
              if (value.docs.isNotEmpty)
                {
                  for (var i = 0; i < value.docs.length; i++)
                    {
                      setState(() {
                        eventList.add(value.docs[i].data()['eventName']);
                      })
                    }
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    // list of events for the group
    return Center(
      child: SizedBox(
        width: 600,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: 'Events for ',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: widget.groupName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: // streambuilder for events
                  StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("events")
                    .where("groupCreator", isEqualTo: widget.groupName)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading",
                        style: TextStyle(fontSize: 30));
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Card(
                          child: ListTile(
                            title: Text(document['eventName']),
                            subtitle:
                                // transform eventDate timestamp to date
                                Text(
                                    '${document['eventDate'].toDate().day}/${document['eventDate'].toDate().month}/${document['eventDate'].toDate().year}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    'Toal guests: ${document['guests'].length.toString()}'),
                                const SizedBox(width: 30),
                                ElevatedButton(
                                  onPressed: (() {
                                    widget.onEventViewPressed(document);
                                  }),
                                  child: const Text('View'),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
