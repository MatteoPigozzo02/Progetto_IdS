import 'package:awesome_icons/awesome_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_to_venezia2/date_extension.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;


enum WeatherTypes {
  sunny,
  cloudy,
  rain,
  storm,
  fog,
  snow,
}

class WeatherForecast {
  final WeatherTypes forecast;
  final int? tMin;
  final int? tMax;

  WeatherForecast._(this.forecast, this.tMin, this.tMax);

  factory WeatherForecast.fromTypeCode(String type, int? tMin, int? tMax) {
    WeatherTypes forecast;
    switch(type[0]) {
      case 'a':
        forecast = (int.parse(type[1]) <= 3) ? WeatherTypes.sunny : WeatherTypes.cloudy;
      case 'b':
        forecast = WeatherTypes.rain;
      case 'c':
        forecast = WeatherTypes.storm;
      case 'd' 'e':
        forecast = WeatherTypes.snow;
      case 'f':
      default:
        forecast = WeatherTypes.fog;
    }
    return WeatherForecast._(forecast, tMin, tMax);
  }
}

Future<List<WeatherForecast>> getWeatherForecast(DateTime date) async {
  date = date.getDate();
  if(date.isAfter(DateTime.now().getDate(days: 4))) return List.empty();
  http.Response httpResponse = await http.get(Uri.parse('https://wwwold.arpa.veneto.it/previsioni/it/xml/bollettino_utenti.xml'));
  String response = httpResponse.body;
  List<WeatherForecast> forecastList = List.empty(growable: true);
  int startIndex = response.indexOf('''<meteogramma zoneid="11''');
  String forecastXml = response.substring(
      startIndex,
      response.indexOf('''</meteogramma>''',startIndex+1)
          + '''</meteogramma>'''.length
  );

  List<RegExpMatch> forecastIndex =
  RegExp('''<scadenza data="... ( )?${date.day} ''')
      .allMatches(forecastXml)
      .toList(growable: false);
  if(forecastIndex.firstOrNull != null) {
    List<RegExpMatch> temps = RegExp(r'''(-)?[0-9]{1,2}/[0-9]{1,2}''')
        .allMatches(forecastXml, forecastIndex.first.end).toList(growable: false);
    int? tMin;
    int? tMax;
    if (forecastIndex.length == 2) {
      tMin = int.tryParse(temps.firstOrNull?.group(0)?.split('/').firstOrNull ?? '');
      tMax = int.tryParse(temps.elementAtOrNull(1)?.group(0)?.split('/').elementAtOrNull(1) ?? '');
    }
    if (forecastIndex.length == 1) {
      tMax = int.tryParse(temps.firstOrNull?.group(0)?.split('/').elementAtOrNull(1) ?? '');
    }
    int i=0;
    while(i<forecastIndex.length) {
      List<RegExpMatch> forecastValue = RegExp(r'''[a-f][0-9]\.png''')
          .allMatches(forecastXml, forecastIndex[i].end).toList();
      if(forecastValue.isEmpty) return List.empty();
      forecastList.add(
          WeatherForecast
              .fromTypeCode(forecastValue.first[0]!.substring(0, 2), tMin, tMax)
      );
      ++i;
    }
    return forecastList;
  } else {
    return List.empty();
  }
}

class Weather extends StatelessWidget {
  final List<WeatherForecast> weatherForecastList;
  final DateTime date;
  const Weather({super.key, required this.weatherForecastList,required this.date});

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

      // black bold = 3
      TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),

      // black = 4
      TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),

      // black high bold = 5
      TextStyle(
        color: Colors.black,
        fontSize: 30,
        fontWeight: FontWeight.bold
      ),
    ];

    List<Column> forecastUIList = List.empty(growable: true);
    int warning;
    if (weatherForecastList.isEmpty) {
      forecastUIList.add(Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            'N/A',
            style: style[5],
          ),
          _buildForecastContainer(null, style),
        ],
      ));
      warning = -1;
    } else {
      final String label;
      if(weatherForecastList.length == 2) {
        label = 'Morning';
      } else if(date.sameDayOf(DateTime.now())) {
        label = 'Afternoon / Evening';
      } else {
        label = 'Day';
      }
      forecastUIList.add(Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            label,
            style: style[5],
          ),
          _buildForecastContainer(weatherForecastList.first, style),
        ],
      ));
      warning = getWeatherWarning(weatherForecastList[0].forecast);
      if (weatherForecastList.length == 2) {
        forecastUIList.add(Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'Afternoon',
              style: style[5],
            ),
            _buildForecastContainer(weatherForecastList[1], style),
          ],
        ));
        warning = getWeatherWarning(weatherForecastList[1].forecast);
        // other possible implementation
        // max(warning, _getWeatherWarning(_weatherForecastList[1].forecast));
      }
    }

    return Scaffold(
      appBar: weAppBar(context, "Weather", style, date),
      
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 25),
              primaryContainer(context, style, warning),
              SizedBox(height: 15),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: forecastUIList,
              ),
              SizedBox(height: 10),
              TextButton.icon(
                onPressed: () async {
                  final Uri url = Uri.parse('https://www.3bmeteo.com/meteo/venezia');
                  if(!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                label: Text("View Weather"),
                icon: Icon(
                  FontAwesomeIcons.link,
                  size: 16,
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}

Flexible primaryContainer(BuildContext context, final style, int warning) {
  LinearGradient grad = greyGradientP();
  List<Widget> children = greyTextP(style);
  
  switch(warning) {
    case -1:
      grad = greyGradientP();
      children = greyTextP(style);

    case 0:
      grad = greenGradientP();
      children = greenTextP(style);

    case 1:
      grad = orangeGradientP();
      children = orangeTextP(style);

    case 2:
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

int getWeatherWarning(WeatherTypes? weather) {
  switch (weather) {
    case null:
      return 2;
    case WeatherTypes.sunny:
      return 0;
    case WeatherTypes.rain:
      return 1;
    case WeatherTypes.fog:
      return 1;
    case WeatherTypes.cloudy:
      return 0;
    case WeatherTypes.storm:
      return 2;
    case WeatherTypes.snow:
      return 2;
  }
}

Container _buildForecastContainer(WeatherForecast? forecast, final style) {
  Container forecastContainerBuilder(final style, final String forecast,
      final int? tMin, final int? tMax, final String imageUrl) =>
    Container(
      width: 159,
      height: 259,
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
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Container(
            width: 139,
            height: 139,
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: Image.network(
                  imageUrl,
                ).image,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  color: Color(0x33000000),
                  offset: Offset(0, 2),
                )
              ],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 10),
          Text(
            forecast,
            style: style[3],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Min: ',
                style: style[3],
              ),
              Text(
                tMin?.toString() ?? '-',
                style: style[4],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Max:',
                style: style[3],
              ),
              Text(
                tMax?.toString() ?? '-',
                style: style[4],
              ),
            ],
          ),
        ],
      ),
    );

  if(forecast == null) {
    return forecastContainerBuilder(style, 'N/A', null, null,
        'https://cdns.iconmonstr.com/wp-content/releases/preview/2018/240/iconmonstr-x-mark-thin.png');
  }
  switch(forecast.forecast) {
    case WeatherTypes.sunny :
      return forecastContainerBuilder(style, 'Sunny', forecast.tMin, forecast.tMax,
          'https://cdn-icons-png.flaticon.com/512/6635/6635633.png'
      );
    case WeatherTypes.rain :
      return forecastContainerBuilder(style, 'Rain', forecast.tMin, forecast.tMax,
          'https://cdn-icons-png.flaticon.com/512/6635/6635651.png'
      );
    case WeatherTypes.fog:
      return forecastContainerBuilder(style, 'Fog', forecast.tMin, forecast.tMax,
          'https://cdn-icons-png.flaticon.com/512/6635/6635975.png'
      );
    case WeatherTypes.cloudy:
      return forecastContainerBuilder(style, 'Cloudy', forecast.tMin, forecast.tMax,
          'https://cdn-icons-png.flaticon.com/512/6635/6635686.png'
      );
    case WeatherTypes.storm:
      return forecastContainerBuilder(style, 'Storm', forecast.tMin, forecast.tMax,
          'https://cdn-icons-png.flaticon.com/512/6635/6635762.png'
      );
    case WeatherTypes.snow:
      return forecastContainerBuilder(style, 'Snow', forecast.tMin, forecast.tMax,
          'https://cdn-icons-png.flaticon.com/512/6635/6635788.png'
      );
  }
}

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


PreferredSize weAppBar(BuildContext context, String title, final style, DateTime date) {
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

