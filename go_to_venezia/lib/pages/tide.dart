import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:awesome_icons/awesome_icons.dart';
//import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_to_venezia2/date_extension.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class TideForecast {
  final DateTime timestamp;
  final int value;

  TideForecast(this.timestamp, this.value);
}

Future<List<TideForecast>> getTideForecasts(DateTime date) async  {
  date = date.getDate();
  if(date.isAfter(DateTime.now().getDate(days: 4))) return List.empty();
  http.Response res = await http.get(Uri.parse('https://dati.venezia.it/sites/default/files/dataset/opendata/previsione.json'));
  var jsonBody = json.decode(res.body);
  List<TideForecast> peakList = List.empty(growable: true);
  if (date==DateTime.now().getDate()) {
    int c=1; // Can be set to show next 1 or 2 peaks
    for(var obj in jsonBody) {
      if(obj['TIPO_ESTREMALE']=='max') {
        DateTime pDate = DateTime.parse(obj['DATA_ESTREMALE']);
        peakList.add(TideForecast(pDate, int.parse(obj['VALORE'])));
        if(pDate.isDateAfter(date)) --c;
      }
      if(peakList.length==2 || c==0) break;
    }
  } else {
    for (var obj in jsonBody) {
      final DateTime pDate = DateTime.parse(obj['DATA_ESTREMALE']);
      if (pDate.sameDayOf(date) && obj['TIPO_ESTREMALE'] == 'max') {
        peakList.add(TideForecast(pDate, int.parse(obj['VALORE'])));
      } else if(pDate.isDateAfter(date)) {
        break;
      }
    }
  }
  return peakList;
}


class Tide extends StatelessWidget {
  final List<TideForecast> tideForecastList;
  final DateTime date;

  const Tide({super.key, required this.tideForecastList, required this.date});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    final style = <TextStyle>[
      // stylenumber = 0
      TextStyle(
        color: theme.colorScheme.onPrimary,
        fontSize: 75,
      ),

      // stylewarning = 1
      TextStyle(
        color: theme.colorScheme.onPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),

      // red bold = 2
      TextStyle(
        color: Color(0xFFEF393C),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),

      // black = 3
      TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),

      // black low = 4
      TextStyle(
        color: Colors.black,
        fontSize: 15,
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          appBar: tiAppBar(context, 'Tide', style, date),

        body: Align(
          alignment: AlignmentDirectional(0.00, -1.00),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 25),
                _primaryContainer(context, style, tideForecastList.firstOrNull?.value),
                SizedBox(height: 15),
                _secondaryContainer(context, style, tideForecastList),
                buttonMose(context, date),
              ],
            ),
          ),
        )

      );
    });
  }
}


PreferredSize tiAppBar(BuildContext context, String title, final style, DateTime date) {
  return PreferredSize(
    preferredSize: Size.fromHeight(200),
    child: AppBar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,

      leading: TextButton(
        child: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),

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

Flexible _primaryContainer(BuildContext context, final style, int? tideHeight) {
  LinearGradient grad = greyGradientP();
  List<Widget> children = greyTextP(style);

  switch(tideHeight) {
    case null:
      grad = greyGradientP();
      children = greyTextP(style);
    case <95:
      grad = greenGradientP();
      children = greenTextP(style);

    case <105:
      grad = orangeGradientP();
      children = orangeTextP(style);

    case >=105:
      grad = redGradientP();
      children = redTextP(style);
  }



  return Flexible(
    child: Container(
      width: MediaQuery.sizeOf(context).width * 0.96,
      height: 120,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x33000000),
            offset: Offset(0, 3),
          )
        ],
        gradient: grad,
        borderRadius: BorderRadius.circular(20),
        shape: BoxShape.rectangle,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );
}

Flexible _secondaryContainer(BuildContext context, final style, List<TideForecast> tideForecastList) {
  int? tideHeight1 = tideForecastList.firstOrNull?.value;
  int? tideHeight2 = tideForecastList.elementAtOrNull(1)?.value;

  Color col = Color.fromARGB(255, 75, 72, 73);
  switch(tideHeight1) {
    case null:
      return Flexible(child: Center());
    case <95:
      col = Color.fromARGB(255, 165, 236, 117);

    case <105:
      col = Color(0xFFFBC21F);

    case >=105:
      col = Color(0xFFEF393C);
  }
  String timeTide1 = tideForecastList[0].timestamp.getTimeString();

  Color col2 = Color.fromARGB(255, 75, 72, 73);
  String timeTide2 = 'N/A';
  if(tideHeight2 != null) {
    switch (tideHeight2) {
      case < 95:
        col2 = Color.fromARGB(255, 165, 236, 117);

      case < 105:
        col2 = Color(0xFFFBC21F);

      case >= 105:
        col2 = Color(0xFFEF393C);
    }
    timeTide2 = DateFormat('dd/MM | HH:mm').format(tideForecastList[1].timestamp);
  }

  return Flexible(
    child: Container(
      width: MediaQuery.sizeOf(context).width * 0.96,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x33000000),
            offset: Offset(0, 2),
          )
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _firstPeak(context, style, timeTide1, tideHeight1, col),
            _secondPeak(context, style, timeTide2, tideHeight2, col2),
            Align(
              alignment: AlignmentDirectional(0.00, 1.00),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(3, 5, 3, 3),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.94,
                  height: 190,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Color(0x33000000),
                        offset: Offset(0, 2),
                      )
                    ],
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(
                      color: col,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {},
                    child: InteractiveViewer(
                      panEnabled: true, // Set it to false
                      boundaryMargin: EdgeInsets.all(0),
                      minScale: 1,
                      maxScale: 3,
                      child: Image.network(
                        'https://www.comune.venezia.it/sites/default/files/publicCPSM/png/bollettino_grafico.jpg',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                /*var imageDownload = await ImageDownloader.downloadImage('https://www.comune.venezia.it/sites/default/files/publicCPSM/png/bollettino_grafico.jpg');
                              if(imageDownload == null) {
                                return;
                              }*/
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(20, 30),
                backgroundColor: Color.fromARGB(255, 224, 227, 231),
              ),
              icon: Icon(
                FontAwesomeIcons.fileDownload,
                size: 16,
                color: Colors.black,
              ),
              label: Text(
                "Download Image",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Align _firstPeak(BuildContext context, final style, String timeTide, int expectedTide, Color col) {
  return Align(
    alignment: AlignmentDirectional(0.00, 1.00),
    child: Padding(
      padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.94,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x33000000),
              offset: Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: col,
            width: 4,
          ),
        ),
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {},
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 7,
                child: Align(
                  child: Text(
                    'Next peak expected at:',
                    style: TextStyle(
                      fontSize: 18,
                      color: col,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: Align(
                  alignment: AlignmentDirectional(-1.00, 0.00),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        timeTide,
                        style: style[3],
                      ),
                      Text(
                        "$expectedTide cm",
                        style: style[3],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Align _secondPeak(BuildContext context, final style, String tideTimestamp, int? tideHeight, Color col) {
  if(tideHeight == null) {
    return Align();
  }

  return Align(
    alignment: AlignmentDirectional(0.00, 1.00),
    child: Padding(
      padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.94,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x33000000),
              offset: Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: col,
            width: 4,
          ),
        ),
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {},
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 8,
                child: Align(
                  child: Text(
                    'Other peak expected at:',
                    style: TextStyle(
                      fontSize: 18,
                      color: col,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 4,
                child: Align(
                  alignment: AlignmentDirectional(-1.00, 0.00),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tideTimestamp,
                        style: style[4],
                      ),
                      Text(
                        "$tideHeight cm",
                        style: style[3],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget buttonMose(BuildContext context, DateTime date) {
  if(date.day == DateTime.now().day && date.month == DateTime.now().month) {
    return TextButton.icon(
      onPressed: () async {
        final Uri url = Uri.parse('https://www.commissariostraordinariomose.it/');
        if(!await launchUrl(url)) {
          throw Exception('Could not launch $url');
        }
      },
      label: Text("View Mose Setup"),
      icon: Icon(
        FontAwesomeIcons.link,
        size: 16,
      ),
    );
  }

  return Flexible(child: Center());
}

// Gradient
LinearGradient redGradientP() {
  return LinearGradient(
    colors: [Color(0xFFEF393C), Colors.white],
    stops: [0, 1],
    begin: AlignmentDirectional(1, 0),
    end: AlignmentDirectional(-1, 0),
  );
}

LinearGradient orangeGradientP() {
  return LinearGradient(
    colors: [Color(0xFFFBC21F), Colors.white],
    stops: [0, 1],
    begin: AlignmentDirectional(1, 0),
    end: AlignmentDirectional(-1, 0),
  );
}

LinearGradient greenGradientP() {
  return LinearGradient(
    colors: [Color.fromARGB(255, 130, 239, 57), Color.fromARGB(255, 255, 255, 255)],
    stops: [0, 1],
    begin: AlignmentDirectional(1, 0),
    end: AlignmentDirectional(-1, 0),
  );
}

LinearGradient greyGradientP() {
  return LinearGradient(
    colors: [Color.fromARGB(255, 75, 72, 73), Color.fromARGB(255, 255, 255, 255)],
    stops: [0, 1],
    begin: AlignmentDirectional(1, 0),
    end: AlignmentDirectional(-1, 0),
  );
}

// Text
List<Widget> redTextP(style) {
  return [
    Flexible(
      flex: 3,
      child: Align(
        alignment: AlignmentDirectional(0.00, 0.00),
        child: Icon(
          FontAwesomeIcons.solidWindowClose,
          color: Color(0xFFEF393C),
          size: 80,
        ),
      ),
    ),
    Flexible(
      flex: 7,
      child: Align(
        alignment: AlignmentDirectional(-1.00, 0.00),
        child: Text(
          'Not recommended',
          style: style[1],
        ),
      ),
    ),
  ];
}

List<Widget> orangeTextP(style) {
  return [
    Flexible(
      flex: 3,
      child: Align(
        alignment: AlignmentDirectional(0.00, 0.00),
        child: Icon(
          FontAwesomeIcons.exclamationCircle,
          color: Color(0xFFFBC21F),
          size: 80,
        ),
      ),
    ),
    Flexible(
      flex: 7,
      child: Align(
        alignment: AlignmentDirectional(0.00, 0.00),
        child: Text(
          'Attention',
          style: style[1],
        ),
      ),
    ),
  ];
}

List<Widget> greenTextP(style) {
  return [
    Flexible(
      flex: 3,
      child: Align(
        alignment: AlignmentDirectional(0.00, 0.00),
        child: Icon(
          FontAwesomeIcons.solidCheckSquare,
          color: Color.fromARGB(255, 130, 239, 57),
          size: 80,
        ),
      ),
    ),
    Flexible(
      flex: 7,
      child: Align(
        alignment: AlignmentDirectional(-0.0, 0.00),
        child: Text(
          'Awesome',
          style: style[1],
        ),
      ),
    ),
  ];
}

List<Widget> greyTextP(style) {
  return [
    Flexible(
      flex: 3,
      child: Align(
        alignment: AlignmentDirectional(0.00, 0.00),
        child: Icon(
          Icons.signal_wifi_statusbar_connected_no_internet_4,
          color: Color.fromARGB(255, 75, 72, 73),
          size: 80,
        ),
      ),
    ),
    Flexible(
      flex: 7,
      child: Align(
        alignment: AlignmentDirectional(-0.20, 0.00),
        child: Text(
          'No information',
          style: style[1],
        ),
      ),
    ),
  ];
}
