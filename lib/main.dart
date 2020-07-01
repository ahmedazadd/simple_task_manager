import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_task_manager/models/event.dart';
import 'package:simple_task_manager/screens/add_event.dart';
import 'package:simple_task_manager/services/db_service.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarController _calendarController;
  TextEditingController _eventController;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  List<dynamic> _nextEvents;
  SharedPreferences prefs;
  DbService dbService;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _eventController = TextEditingController();
    _events = {};
    _selectedEvents = [];
    dbService = DbService();
    initPrefs();
  }

  Map<DateTime, List<dynamic>> _fromModelToEvent(List<EventModel> events) {
    Map<DateTime, List<dynamic>> data = {};
    events.forEach((event) {
      DateTime date = DateTime(
          event.eventDate.year, event.eventDate.month, event.eventDate.day, 12);
      if (data[date] == null) data[date] = [];
      data[date].add(event);
    });
    return data;
  }

  initPrefs() async {
    // prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   _events = Map<DateTime, List<dynamic>>.from(
    //       decodeMap(json.decode(prefs.getString("events") ?? "{}")));
    // });
  }

  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });

    return newMap;
  }

  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<EventModel>>(
          future: dbService.getEvents(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<EventModel> allEvents = snapshot.data;
              if (allEvents.isNotEmpty) {
                _events = _fromModelToEvent(allEvents);
              }
            }
            return SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.bottomLeft,
                  height: 80,
                  child: IconButton(
                      icon: Icon(Icons.arrow_back), onPressed: () {}),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Daily",
                        style: TextStyle(fontSize: 32),
                      ),
                      SizedBox(height: 10),
                      Text("Task Report",
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TableCalendar(
                    events: _events,
                    initialCalendarFormat: CalendarFormat.month,
                    calendarStyle: CalendarStyle(
                      todayColor: Theme.of(context).primaryColor,
                      selectedColor: Theme.of(context).primaryColor,
                      todayStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white),
                      weekendStyle:
                          TextStyle(color: Colors.black.withOpacity(0.3)),
                      outsideDaysVisible: false,
                    ),
                    headerStyle: HeaderStyle(
                        centerHeaderTitle: true,
                        formatButtonDecoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        formatButtonTextStyle: TextStyle(color: Colors.white),
                        formatButtonShowsNext: false),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        weekendStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    onDaySelected: (date, events) {
                      setState(() {
                        _selectedEvents = events;
                      });
                    },
                    builders: CalendarBuilders(
                        selectedDayBuilder: (context, date, events) =>
                            Container(
                                margin: EdgeInsets.all(4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle),
                                child: Text(
                                  date.day.toString(),
                                  style: TextStyle(color: Colors.white),
                                )),
                        todayDayBuilder: (context, date, enevts) => Container(
                            margin: EdgeInsets.all(4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.teal.shade300,
                                shape: BoxShape.circle),
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(color: Colors.white),
                            ))),
                    calendarController: _calendarController,
                  ),
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Daily Tasks',
                      style: TextStyle(fontSize: 20),
                    )),
                ..._selectedEvents.map((event) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            child: Text(
                          event.eventDate.hour.toString() +
                              ' : ' +
                              event.eventDate.minute.toString(),
                          style: TextStyle(fontSize: 16),
                        )),
                        Container(
                            margin: EdgeInsets.only(bottom: 10),
                            alignment: Alignment.center,
                            height: 100,
                            width: 200,
                            decoration: BoxDecoration(
                                color: Colors.teal[300],
                                borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  event.title,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  event.description,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ))
                      ],
                    )))
              ],
            ));
          }),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _awaitReturnValueFromAddEvent();
            // Navigator.push(
            //     context, MaterialPageRoute(builder: (context) => AddEvent()));
            // _showAddDialog();
          }),
    );
  }

  _awaitReturnValueFromAddEvent() async {
     await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddEvent(),
        ));

    setState(() {
      
    });
  }

  _showAddDialog() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: _eventController,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("Save"),
                  onPressed: () {
                    // dbService.addEvent();
                    Navigator.pop(context);
                    setState(() {});
                    // if (_eventController.text.isEmpty) return;
                    // if (_events[_calendarController.selectedDay] != null) {
                    //   _events[_calendarController.selectedDay]
                    //       .add(_eventController.text);
                    // } else {
                    //   _events[_calendarController.selectedDay] = [
                    //     _eventController.text
                    //   ];
                    // }
                    // prefs.setString("events", json.encode(encodeMap(_events)));

                    // _eventController.clear();
                    // Navigator.pop(context);
                  },
                )
              ],
            ));
    // setState(() {
    //   _selectedEvents = _events[_calendarController.selectedDay];
    // });
  }
}
