import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({Key? key, required this.groupName}) : super(key: key);

  final String groupName;
  @override
  CreateEventState createState() => CreateEventState();
}

class CreateEventState extends State<CreateEvent> {
  String? errorMessage = '';

  DateTime dateCreated = DateTime.now();

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventTimeController = TextEditingController();
  final TextEditingController _eventLocationController =
      TextEditingController();
  Position? position;

  Future<void> createEvent() async {
    try {
      await FirebaseFirestore.instance.collection('events').add({
        'eventName': _eventNameController.text,
        'eventDate': Timestamp.fromDate(dateCreated),
        'location': _eventLocationController.text,
        'groupCreator': widget.groupName,
        'maxGuests': 10,
        'maxGuestsPerMember': 2,
        'guests': [],
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  void _positionGet() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _kOptions.add(position.toString());
    });
  }

  Widget _errorMessage() {
    return Text(
      errorMessage ?? '',
      style: const TextStyle(color: Colors.red),
    );
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ) {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: 300,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: title,
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () {
        createEvent();
        // navigate back
        Navigator.pop(context);
      },
      child: const Text('Create Eve'),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        dateCreated = DateTime(
          dateCreated.year,
          dateCreated.month,
          dateCreated.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateCreated,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    // call time picker
    if (picked != null && picked != dateCreated) {
      // call time picker after selecting date
      setState(() {
        dateCreated = picked;
      });
      await _selectTime(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _positionGet();
  }

  List<String> _kOptions = <String>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Create Event', style: Theme.of(context).textTheme.headline4),
          _errorMessage(),
          const SizedBox(height: 20),
          _entryField('Event Name', _eventNameController),
          const SizedBox(height: 20),
          Text(dateCreated.toString()),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () => _selectDate(context),
              child: const Text('Select Date')),
          const SizedBox(height: 20),
          SizedBox(
            width: 300,
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return _kOptions.where((String option) {
                  return option.contains(textEditingValue.text.toLowerCase());
                });
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) =>
                  SizedBox(
                width: 300,
                child: TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Event Location',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _submitButton(),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // navigate back
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red)),
                  child: const Text('Cancel'),
                )
              ]),
        ],
      ),
    );
  }
}
