import 'package:flutter/material.dart';
import 'package:go_to_venezia2/main.dart';
import 'package:go_to_venezia2/pages/calendar.dart';
import 'package:go_to_venezia2/pages/tide.dart';
import 'package:go_to_venezia2/pages/transport.dart';
import 'package:go_to_venezia2/pages/weather.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool _loaded = false;
  late MyAppState appState;
  List<TideForecast> _tideForecastList = List.empty();
  List<WeatherForecast> _weatherForecastList = List.empty();
  (bool?, bool?) _strikes = (null, null);


  Future<void> _loadInfo() async {
    if (!_loaded) {
      _loaded = true;
      getTideForecasts(appState.date).then((value) {
                setState(() {
                  _tideForecastList = value;
                });
              });
      getWeatherForecast(appState.date).then((value) {
        setState(() {
          _weatherForecastList = value;
        });
      });
      checkStrikes(appState.date).then((value) {
        setState(() {
          _strikes = value;
        });
      });
      setState(() {
        _strikes = (null, null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<MyAppState>();
    _loadInfo();
    final theme = Theme.of(context);

    final style = <TextStyle>[
      // stylenumber = 0
      TextStyle(
        color: theme.colorScheme.onPrimary,
        fontSize: 120,
        letterSpacing: -5,
      ),

      // styleday = 1
      TextStyle(
        color: theme.colorScheme.onPrimary,
        fontSize: 35,
      ),

      // stylemonth = 2
      TextStyle(
        color: theme.colorScheme.onPrimary,
        fontSize: 25,
      ),

      // styletext = 3
      TextStyle(
        color: Colors.black,
        fontSize: 20,
      ),

      // exclamationtext = 4
      TextStyle(
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 50,
      ),

      // checktext = 5
      TextStyle(
        color: theme.colorScheme.onPrimary,
        fontSize: 32,
      ),

      // xtext = 6
      TextStyle(
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 35,
      )
    ];

    Widget shown = home(context, style);

    return Scaffold(
      appBar: kAppBar(context, style),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
        onTap: (index) async {
          if (index == 1) {
            appState.setDate(await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Calendar(originalDate: appState.date))) ??
                appState.date);
            _loaded = false;
          }
        },
      ),
      body: shown,
    );
  }

  Widget home(BuildContext context, final style) {

    //int expectedPeople = 0; //TODO
    int expectedTransport;
    if(_strikes.$1 != null) {
      expectedTransport = (_strikes.$1! ? 1 : 0) + (_strikes.$2! ? 1 : 0);
    } else {
      expectedTransport = -1;
    }
    int expectedTide;
    switch(_tideForecastList.firstOrNull?.value ?? 999) {
      case <95:
        expectedTide = 0;
      case <105:
        expectedTide = 1;
      default:
        expectedTide = 2;
    }
    int expectedWeather = getWeatherWarning(_weatherForecastList.firstOrNull?.forecast);

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(height: 18),
            // Container persone attese
            //peopleContainer(context, expectedPeople, style),
            SizedBox(height: 18),
            // Checlist
            Container(
                width: MediaQuery.sizeOf(context).width * 0.96,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 235, 230, 230),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 4,
                        color: Color(0x33000000),
                        offset: Offset(0, 2))
                  ],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //mapContainer(context, style),
                    transportContainer(context, style, expectedTransport),
                    tideContainer(context, style, expectedTide),
                    weatherContainer(context, style, expectedWeather)
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget loading(BuildContext context, final style) {
    return Center(
      child: Container(
        height: 270,
        width: 270,
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x33000000),
              offset: Offset(3, 3),
            )
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(
              height: 20,
            ),
            Text("Loading information",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                ))
          ],
        ),
      ),
    );
  }

  // Appbar
  PreferredSize kAppBar(BuildContext context, final style) {
    DateTime date = context.watch<MyAppState>().date;
    String titleNumber = DateFormat('d').format(date);
    String titleMonth = DateFormat('MMMM y').format(date);
    String titleDay = DateFormat('EEEE').format(date);

    return PreferredSize(
      preferredSize: Size.fromHeight(200),
      child: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment(0, -1),
                end: Alignment(-1, 1),
                colors: <Color>[
                  Color.fromARGB(255, 57, 210, 192),
                  Color.fromARGB(255, 75, 57, 239)
                ]),
            boxShadow: [BoxShadow(blurRadius: 40)],
            borderRadius:
                BorderRadius.vertical(bottom: Radius.elliptical(40, 40)),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentDirectional(0.00, 0.00),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(23, 23, 23, 23),
                    child: Text(
                      titleNumber,
                      style: style[0],
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.00, 1.00),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1.00, 0.00),
                        child: Text(
                          titleDay,
                          style: style[1],
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 70),
                          child: Text(
                            titleMonth,
                            style: style[2],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(40),
        )),
      ),
    );
  }
/*
  // Container
  Container peopleContainer(
      BuildContext context, int expectedPeople, final style) {
    if (expectedPeople > 1) {
      return Container(
          width: MediaQuery.sizeOf(context).width * 0.96,
          height: 140,

          // Box shadow
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x33000000),
                offset: Offset(0, 3),
              )
            ],
            gradient: LinearGradient(
              colors: [Color(0xFFEF393C), Colors.white],
              stops: [0, 1],
              begin: AlignmentDirectional(1, 0),
              end: AlignmentDirectional(-1, 0),
            ),
            borderRadius: BorderRadius.circular(20),
            shape: BoxShape.rectangle,
          ),
          child: Align(
              alignment: AlignmentDirectional(0.00, -1.00),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      flex: 1,
                      child: Align(
                          alignment: AlignmentDirectional(-0.3, 0.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                                'https://www.pngmart.com/files/15/Red-Exclamation-Mark-Transparent-Background.png',
                                width: 79,
                                height: 79,
                                fit: BoxFit.contain,
                                alignment: Alignment(0.00, 0.00)),
                          ))),
                  Flexible(
                    flex: 2,
                    child: Align(
                      alignment: AlignmentDirectional(-1.00, 0.00),
                      child: Text(
                        'Many people expected',
                        style: style[3],
                      ),
                    ),
                  )
                ],
              )));
    } else if (expectedPeople > 0) {
      return Container(
          width: MediaQuery.sizeOf(context).width * 0.96,
          height: 140,

          // Box shadow
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x33000000),
                offset: Offset(0, 3),
              )
            ],
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 239, 166, 57), Colors.white],
              stops: [0, 1],
              begin: AlignmentDirectional(1, 0),
              end: AlignmentDirectional(-1, 0),
            ),
            borderRadius: BorderRadius.circular(20),
            shape: BoxShape.rectangle,
          ),
          child: Align(
              alignment: AlignmentDirectional(0.00, -1.00),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      flex: 1,
                      child: Align(
                          alignment: AlignmentDirectional(-0.3, 0.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                                'https://icones.pro/wp-content/uploads/2021/05/symbole-d-avertissement-jaune.png',
                                width: 94,
                                height: 94,
                                fit: BoxFit.fill,
                                alignment: Alignment(0.00, 0.00)),
                          ))),
                  Flexible(
                    flex: 2,
                    child: Align(
                      alignment: AlignmentDirectional(-1.00, 0.00),
                      child: Text(
                        'Several people expected',
                        style: style[3],
                      ),
                    ),
                  )
                ],
              )));
    } else if (expectedPeople == 0) {
      return Container(
          width: MediaQuery.sizeOf(context).width * 0.96,
          height: 140,

          // Box shadow
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x33000000),
                offset: Offset(0, 3),
              )
            ],
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 130, 239, 57), Colors.white],
              stops: [0, 1],
              begin: AlignmentDirectional(1, 0),
              end: AlignmentDirectional(-1, 0),
            ),
            borderRadius: BorderRadius.circular(20),
            shape: BoxShape.rectangle,
          ),
          child: Align(
              alignment: AlignmentDirectional(0.00, -1.00),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      flex: 1,
                      child: Align(
                          alignment: AlignmentDirectional(-0.3, 0.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/Eo_circle_green_checkmark.svg/1200px-Eo_circle_green_checkmark.svg.png',
                                width: 89,
                                height: 89,
                                fit: BoxFit.fill,
                                alignment: Alignment(0.00, 0.00)),
                          ))),
                  Flexible(
                    flex: 2,
                    child: Align(
                      alignment: AlignmentDirectional(-1.00, 0.00),
                      child: Text(
                        'Few people expected',
                        style: style[3],
                      ),
                    ),
                  )
                ],
              )));
    } else {
      return Container(
          width: MediaQuery.sizeOf(context).width * 0.96,
          height: 140,

          // Box shadow
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x33000000),
                offset: Offset(0, 3),
              )
            ],
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 112, 110, 110), Colors.white],
              stops: [0, 1],
              begin: AlignmentDirectional(1, 0),
              end: AlignmentDirectional(-1, 0),
            ),
            borderRadius: BorderRadius.circular(20),
            shape: BoxShape.rectangle,
          ),
          child: Align(
              alignment: AlignmentDirectional(0.00, -1.00),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      flex: 1,
                      child: Align(
                          alignment: AlignmentDirectional(-0.3, 0.0),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Icon(
                                Icons
                                    .signal_wifi_statusbar_connected_no_internet_4,
                                color: Color.fromARGB(255, 105, 105, 105),
                                size: 60,
                              )))),
                  Flexible(
                    flex: 2,
                    child: Align(
                      alignment: AlignmentDirectional(-1.00, 0.00),
                      child: Text(
                        'No information',
                        style: style[3],
                      ),
                    ),
                  )
                ],
              )));
    }
  }

  Widget mapContainer(BuildContext context, final style) {
    return Align(
      alignment: AlignmentDirectional(0.00, 1.00),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.94,
          height: 70,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x33000000),
                offset: Offset(0, 2),
              )
            ],
            gradient: LinearGradient(
              colors: [Color(0x78EE8B60), Colors.white],
              stops: [0, 1],
              begin: AlignmentDirectional(1, 0),
              end: AlignmentDirectional(-1, 0),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              /*Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        Maps(date: _dateSelected),
                    transitionDuration: Durations.extralong4,
                    reverseTransitionDuration: Duration.zero,
                  ));*/
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 2,
                  child: Align(
                    alignment: AlignmentDirectional(-0.70, 0.00),
                    child: Text(
                      'Map',
                      style: style[3],
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Align(
                    alignment: AlignmentDirectional(0.80, 0.00),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.network(
                        'https://www.objectsmag.it/wp-content/uploads/2018/07/venice-aerial-view-2.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }*/

  Widget transportContainer(
      BuildContext context, final style, int expectedTransport) {
    LinearGradient grad = greyGradient();
    Align textAlign = noInformation(style);

    switch (expectedTransport) {
      case -1:
        grad = greyGradient();
        textAlign = noInformation(style);
      case 0:
        grad = greenGradient();
        textAlign = checkAlign(style);

      case 1:
        grad = orangeGradient();
        textAlign = exclamationAlign(style);

      case 2:
        grad = redGradient();
        textAlign = xAlign(style);
    }

    return Align(
      alignment: AlignmentDirectional(0.00, 1.00),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.94,
          height: 70,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x33000000),
                offset: Offset(0, 2),
              )
            ],
            gradient: grad,
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Transport(
                          bus: _strikes.$1 ?? false,
                          train: _strikes.$2 ?? false)));
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 2,
                  child: Align(
                    alignment: AlignmentDirectional(-0.70, 0.00),
                    child: Text(
                      'Trasports',
                      style: style[3],
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: textAlign,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tideContainer(BuildContext context, final style, int expectedTide) {
    LinearGradient grad = greyGradient();
    Align textAlign = noInformation(style);

    switch (expectedTide) {
      case 0:
        grad = greenGradient();
        textAlign = checkAlign(style);

      case 1:
        grad = orangeGradient();
        textAlign = exclamationAlign(style);

      case 2:
        grad = redGradient();
        textAlign = xAlign(style);
    }

    return Align(
      alignment: AlignmentDirectional(0.00, 1.00),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.94,
          height: 70,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x33000000),
                offset: Offset(0, 2),
              )
            ],
            gradient: grad,
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Tide(
                          tideForecastList: _tideForecastList,
                          date: appState.date)));
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 2,
                  child: Align(
                    alignment: AlignmentDirectional(-0.70, 0.00),
                    child: Text(
                      'Tide',
                      style: style[3],
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: textAlign,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget weatherContainer(
      BuildContext context, final style, int expectedWeather) {
    LinearGradient grad = greyGradient();
    Align textAlign = noInformation(style);

    switch (expectedWeather) {
      case 0:
        grad = greenGradient();
        textAlign = checkAlign(style);

      case 1:
        grad = orangeGradient();
        textAlign = exclamationAlign(style);

      case 2:
        grad = redGradient();
        textAlign = xAlign(style);
    }

    return Align(
      alignment: AlignmentDirectional(0.00, 1.00),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.94,
          height: 70,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x33000000),
                offset: Offset(0, 2),
              )
            ],
            gradient: grad,
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            splashColor: Color.fromARGB(255, 0, 0, 0),
            focusColor: const Color.fromARGB(255, 0, 0, 0),
            hoverColor: const Color.fromARGB(255, 0, 0, 0),
            highlightColor: const Color.fromARGB(255, 0, 0, 0),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Weather(
                          weatherForecastList: _weatherForecastList,
                          date: appState.date)));
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 2,
                  child: Align(
                    alignment: AlignmentDirectional(-0.70, 0.00),
                    child: Text(
                      'Weather',
                      style: style[3],
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: textAlign,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Gradient
  LinearGradient greenGradient() {
    return LinearGradient(
      colors: [
        Color.fromARGB(255, 130, 239, 57),
        Color.fromARGB(255, 177, 211, 186)
      ],
      stops: [0, 1],
      begin: AlignmentDirectional(1, 0),
      end: AlignmentDirectional(-1, 0),
    );
  }

  LinearGradient orangeGradient() {
    return LinearGradient(
      colors: [Color(0xFFFBC21F), Color(0xFFFFE8A5)],
      stops: [0, 1],
      begin: AlignmentDirectional(1, 0),
      end: AlignmentDirectional(-1, 0),
    );
  }

  LinearGradient redGradient() {
    return LinearGradient(
      colors: [Color(0xFFE6161A), Color(0xFFF9A7A8)],
      stops: [0, 1],
      begin: AlignmentDirectional(1, 0),
      end: AlignmentDirectional(-1, 0),
    );
  }

  LinearGradient greyGradient() {
    return LinearGradient(
      colors: [
        Color.fromARGB(255, 75, 72, 73),
        Color.fromARGB(255, 172, 166, 166)
      ],
      stops: [0, 1],
      begin: AlignmentDirectional(1, 0),
      end: AlignmentDirectional(-1, 0),
    );
  }

  // Icons
  Align checkAlign(final style) {
    return Align(
        alignment: AlignmentDirectional(0.55, 0.00),
        child: Text(
          "✔",
          style: style[5],
        ));
  }

  Align exclamationAlign(final style) {
    return Align(
        alignment: AlignmentDirectional(0.4, 0.00),
        child: Text(
          "!",
          style: style[4],
        ));
  }

  Align xAlign(final style) {
    return Align(
        alignment: AlignmentDirectional(0.45, 0.00),
        child: Text(
          "X",
          style: style[6],
        ));
  }

  Align noInformation(final style) {
    return Align(
        alignment: AlignmentDirectional(0.5, 0.00),
        child: Icon(
          Icons.signal_wifi_statusbar_connected_no_internet_4,
          color: Colors.white,
          size: 35,
        ));
  }
}