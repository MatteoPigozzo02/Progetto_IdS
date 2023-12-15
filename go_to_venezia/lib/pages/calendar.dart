import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


class Calendar extends StatefulWidget {
  final DateTime? originalDate;
  Calendar({super.key, this.originalDate});

  @override
  State<Calendar> createState() => _CalendarState();
}




class _CalendarState extends State<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final theme = Theme.of(context);

    final stylecal = <TextStyle>[
      // stylenumber = 0
      TextStyle(
        color: theme.colorScheme.onPrimary,
        fontSize: 75,
      ),
    ];

    return PopScope(
        onPopInvoked: (didPop) {
          if (!didPop) Navigator.pop(context, _selectedDay);
        },
        canPop: false,
        child: Scaffold(
          appBar: cAppBar(context, "Calendar", stylecal),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 1,
            iconSize: 30,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'Calendar',
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                Navigator.pop(context, _selectedDay);
              }
            },
          ),
          body: SingleChildScrollView(child: Center(
            child: Column(
              children: [
                SizedBox(height: 20),
                Text("Select a day: ", style: TextStyle(fontSize: 20),),
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.utc(today.year, today.month + 3, today.day),
                  focusedDay: _selectedDay ?? DateTime.now(),
                  currentDay: widget.originalDate ?? DateTime.now(),
                  calendarFormat: _calendarFormat,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                      });
                    }
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    //_currentDay = focusedDay;
                  },
                ),
                /*SizedBox(height:10),
                Container(
                  height: 50,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Selected day: ${DateFormat('dd/MM/yy').format(_selectedDay ?? widget.originalDate ?? DateTime.now())}",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height:5),
                Text(
                    "Return to the homepage to apply the changes"
                )*/
              ],
            )),
          ),
        ));
  }
}

PreferredSize cAppBar(BuildContext context, String title, final style) {
  return PreferredSize(
    preferredSize: Size.fromHeight(200),
    child: AppBar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,

      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0, -1),
            end: Alignment(-1, 1),
            colors: <Color>[Color.fromARGB(255, 57, 210, 192), Color.fromARGB(255, 75, 57, 239)]
          ),
          boxShadow: [
            BoxShadow(blurRadius: 40)
          ],
          borderRadius: BorderRadius.vertical(
            bottom: Radius.elliptical(40, 40)
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 95),
            Center(
              child: Text(
                title,
                style: style[0]),
            ),
          ],
        ),
      ),
      
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(40),
        )
      ),
    ),
  ); 
}