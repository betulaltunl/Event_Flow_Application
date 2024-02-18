import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventFlow',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EventListScreen(),
    );
  }
}

class Event {
  int? id;
  String? title;
  DateTime? date;
  int? attendees;
  String? image;
  bool? selected;

  Event({this.id, this.title, this.date, this.attendees, this.image, this.selected});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date?.toIso8601String(),
      'attendees': attendees,
      'image': image,

    };
  }

  static Event fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      attendees: map['attendees'],
      image: map['image'],
      selected: false,
    );
  }
}

class EventDatabase {
  Future<Database> get database async {
    return openDatabase(
      'events.db',
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE events(id INTEGER PRIMARY KEY, title TEXT, date TEXT, attendees INTEGER, image TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertEvent(Event event) async {
    final Database db = await database;
    await db.insert('events', event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Event>> getEvents() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  Future<void> deleteEvent(int id) async {
    final Database db = await database;
    await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  EventDatabase eventDatabase = EventDatabase();
  List<Event> events = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadEvents();
    startTimer();
  }

  void loadEvents() async {
    events = await eventDatabase.getEvents();
    setState(() {});
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  Duration calculateRemainingTime(Event event) {
    if (event.date == null) {
      return Duration.zero;
    }

    DateTime now = DateTime.now();
    Duration remainingTime = event.date!.isAfter(now) ? event.date!.difference(now) : Duration.zero;
    return remainingTime;
  }

  void deleteSelectedEvents() async {
    events.forEach((event) {
      if (event.selected ?? false) {
        if (event.id != null) {
          eventDatabase.deleteEvent(event.id!); // '!' kullanarak null değeri olmadığını belirtiyoruz.
        }
      }

    });
    loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EventFlow'),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final remainingTime = calculateRemainingTime(event);

          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: event.image != null ? FileImage(File(event.image!)) : AssetImage('assets/placeholder_image.jpg') as ImageProvider,
                ),
                title: Text(event.title ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.date != null ? DateFormat('dd.MM.yyyy').format(event.date!) : ''),
                    Text('Participants: ${event.attendees}'),
                  ],
                ),
                trailing: Checkbox(
                  value: event.selected ?? false,
                  onChanged: (value) {
                    setState(() {
                      event.selected = value;
                    });
                  },
                ),
              ),

              if (remainingTime.inSeconds > 0)
                Column(
                  children: [
                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('KS: ${event.attendees}'),
                      ],
                    ),*/
                    Slider(
                      value: remainingTime.inSeconds.toDouble(),
                      min: 0,
                      max: event.date!.difference(event.date!.subtract(Duration(
                          days: event.attendees!))).inSeconds.toDouble(),
                      onChanged: (double value) {},
                    ),
                  ],
                )

            ],
          );
        },
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () async {
                List<Event> selectedEvents = events.where((event) => event.selected ?? false).toList();
                bool anyEventNotDeleted = false; // Silinemeyen en az bir etkinlik var mı kontrolü için bir bayrak
                for (Event event in selectedEvents) {
                  if (event.date != null && event.date!.isBefore(DateTime.now())) {
                    await eventDatabase.deleteEvent(event.id!);
                  } else {
                    anyEventNotDeleted = true; // Silinemeyen bir etkinlik varsa bayrağı true ayarla
                  }
                }
                if (anyEventNotDeleted) {
                  // Silinemeyen etkinlikler olduğunu bildiren bir iletişim kutusu
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Warning'),
                      content: Text('Events with future dates could not be deleted.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Okay'),
                        ),
                      ],
                    ),
                  );
                }
                loadEvents();
              },
              child: Text('Remove Selected'),
            ),
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEventScreen()),
                ).then((value) {
                  loadEvents();
                });
              },
              child: Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  TextEditingController titleController = TextEditingController();
  int attendees = 0;
  DateTime selectedDate = DateTime.now();
  File? selectedImage;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Event Name'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Event Date: ${DateFormat('dd.MM.yyyy').format(selectedDate)}'),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => selectDate(context),
                  child: Text('Select Date'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Participants: $attendees'),
                SizedBox(width: 8),
                Slider(
                  value: attendees.toDouble(),
                  min: 0,
                  max: 100,
                  onChanged: (value) {
                    setState(() {
                      attendees = value.toInt();
                    });
                  },
                  label: 'Participants: $attendees',
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectImage,
              child: Text('Add Image'),
            ),
            SizedBox(height: 16),
            selectedImage != null
                ? Image.file(
              selectedImage!,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            )
                : SizedBox.shrink(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                Event newEvent = Event(
                  title: titleController.text,
                  date: selectedDate,
                  attendees: attendees,
                  image: selectedImage != null ? selectedImage!.path : "", // Resim varsa yolu, yoksa boş dize
                );
                await EventDatabase().insertEvent(newEvent);
                Navigator.pop(context);
              },
              child: Text('Etkinlik Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}


