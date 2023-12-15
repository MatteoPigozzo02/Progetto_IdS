import 'package:flutter/material.dart';
import 'package:go_to_venezia2/date_extension.dart';
import 'package:go_to_venezia2/main.dart';
import 'package:provider/provider.dart';
import 'package:awesome_icons/awesome_icons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


Future<bool> _checkStrike(Uri url) async {
  http.Response httpResponse = await http.get(url);
  String response = httpResponse.body;
  return response.indexOf('meta-search', 40000) != -1;
}

Future<(bool, bool)> checkStrikes(DateTime date) async {
  String dateString = date.getDateString();
  bool bus = false;
  bool train = false;
  bool general = false;
  var resList = List<Future<bool>>.empty(growable: true);
  // Bus
  resList.add(_checkStrike(Uri.parse( // 0
      'https://www.cgsse.it/calendario-scioperi?data_inizio=$dateString'
          '&data_fine=$dateString&settore[]=112&regione[]=457'
          '&provincia[]=498&rilevanza[]=98&rilevanza[]=106&rilevanza[]=102'
          '&azienda[]=19341&azienda[]=22188&azienda[]=8731&attivo=1'))
      .then((value) {
    if (value) bus = true;
    return bus;
  }));
  // Train
  resList.add(_checkStrike(Uri.parse( // 1
      'https://www.cgsse.it/calendario-scioperi?data_inizio=$dateString'
          '&data_fine=$dateString&settore[]=110&regione[]=457'
          '&provincia[]=498&rilevanza[]=102&rilevanza[]=100&rilevanza[]=104'
          '&rilevanza[]=106&azienda[]=1229&attivo=1'))
      .then((value) {
        if(value) train = true;
        return train;
  }));
  resList.add(_checkStrike(Uri.parse( // 2
      'https://www.cgsse.it/calendario-scioperi?data_inizio=$dateString'
          '&data_fine=$dateString&settore[]=110&regione[]=457'
          '&rilevanza[]=98&azienda[]=1229&attivo=1'))
      .then((value) {
        if(value) train = true;
        return train;
  }));
  resList.add(_checkStrike(Uri.parse( // 3
      'https://www.cgsse.it/calendario-scioperi?data_inizio=$dateString'
          '&data_fine=$dateString&settore[]=110&regione[]=457'
          '&rilevanza[]=92&azienda[]=1229&attivo=1'))
      .then((value) {
        if(value) train = true;
        return train;
  }));
  // General
  resList.add(_checkStrike(Uri.parse( // 4
      'https://www.cgsse.it/calendario-scioperi?data_inizio=$dateString'
          '&data_fine=$dateString&settore[]=112&rilevanza[]=92&attivo=1'))
      .then((value) {
        if(value) general = true;
        return general;
  }));
  resList.add(_checkStrike(Uri.parse( // 5
      'https://www.cgsse.it/calendario-scioperi?data_inizio=$dateString'
          '&data_fine=$dateString&rilevanza[]=92&attivo=1&generale=1'))
      .then((value) {
        if(value) general = true;
        return general;
  }));
  await Future.wait(resList);
  return (general || bus, general || train);
}


class Transport extends StatelessWidget {
  final bool bus;
  final bool train;

  const Transport({super.key, required this.bus, required this.train});

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
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),

      // yellow = 2
      TextStyle(
        color: Color(0xFFFBC21F),
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),

      // black = 3
      TextStyle(
        color: Colors.black,
        fontSize: 15,
      ),

      // 4
      TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),

      // 5
      TextStyle(
        color: const Color.fromRGBO(0, 0, 0, 1),
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),

      // 6
      TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.normal,
      ),

      // 7
      TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
        fontSize: 35,
        fontWeight: FontWeight.w500,
      ),

      // checktext = 8
      TextStyle(
        color: theme.colorScheme.onPrimary,
        fontSize: 37,
      ),

      // exclamationtext = 9
      TextStyle(
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 50,
      ),

      // xtext = 10
      TextStyle(
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 40,
      )
    ];

    int expectedTransport = (bus?1:0)+(train?1:0);

    return Scaffold(
      appBar: trAppBar(context, "Transports", style),
      body: Align(
        alignment: AlignmentDirectional(0.00, -1.00),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 25),
              _primaryContainer(context, style, expectedTransport),
              SizedBox(height: 20),
              _transportContainer(context, style, train, bus),
              SizedBox(height: 30),
              //secondaryContainer(context, style, expectedTransport),
              //SizedBox(height: 30),
              tertiaryContainer(context, style, expectedTransport),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}


PreferredSize trAppBar(BuildContext context, String title, final styletran) {
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

      title: Container(
        alignment: Alignment.topRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.calendar_month,
              color: Colors.white,
              size: 28,
            ),
            SizedBox(width: 2),
            Text(
              DateFormat('dd/MM').format(context.watch<MyAppState>().date),
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                //fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10,)
          ],
        ),
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
                style: styletran[0]),
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

Flexible _primaryContainer(BuildContext context, final style, int expectedTransport) {
  LinearGradient grad = greyGradient();
  List<Widget> children = greyTextP(style);

  switch(expectedTransport) {
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

Flexible _transportContainer(BuildContext context, final style, bool? trainStrike, bool? busStrike){
  
  Widget train, bus, trainButton, busButton;

  
  switch (trainStrike) {
    case false: 
      train = okTrain(context, style);
      trainButton = Center();

    case true:
      train = noTrain(context, style);
      trainButton = buttonTrain();

    case null:
      train = noInformation(context, style);
      trainButton = Center();
  }

  switch (busStrike) {
    case false:
      bus = okBus(context, style);
      busButton = Center();

    case true:
      bus = noBus(context, style);
      busButton = buttonBus();

    case null:
      bus = noInformation(context, style);
      busButton = Center();
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
          bus,
          busButton,
          train,
          trainButton,
        ],
      ),
      ),         
    ),
  );
}

Flexible secondaryContainer(BuildContext context, final style, int expectedTransport) {
  Color col = Colors.grey;

  switch(expectedTransport) {
    case 0: 
      col = Color.fromARGB(255, 165, 236, 117);

    case 1:
      col = Color(0xFFFBC21F);

    case 2: 
      col = Color(0xFFEF393C);
  }


  if(expectedTransport == -1) return Flexible(child: Center());

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
          Align(
            alignment: AlignmentDirectional(0.00, 1.00),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
              child: Container(
                width: 260,
                height: 50,
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
                  onTap: () async {

                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        flex: 7,
                        child: Align(
                          child: Text(
                            'Train strike 29/11',
                            style: TextStyle(
                              color: col,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,  
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          Align(
            alignment: AlignmentDirectional(0.00, 1.00),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(3, 5, 3, 3),
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.94,
                height: 110,
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
                    width: 2,
                  ),
                ),
                child: Align(
                  alignment: AlignmentDirectional(-1.00, 0.00),
                  child: Text(
                    '  Lines involved:\n      - Line Calalzo <-> Venezia\n      - Line Milano <-> Venezia\n      - Line Trento <-> Bassano D.G. <-> Venezia \n      - Line Venezia <-> Bologna',
                    style: style[3],
                  ),
                ),
              ),
            ),
          ),
                          
          ElevatedButton.icon(
            onPressed: () async {
              /*var imageDownload = await ImageDownloader.downloadImage('https://www.trenitalia.com/content/dam/tcom/allegati/trenitalia_2014/in_regione/treni-garantiti/Regionale%20Veneto_sito.pdf');
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
              "Download guaranteed trains",
               style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            
          ),
        ],
      ),
    ),    )    );
}

Flexible tertiaryContainer(BuildContext context, final style, int  expectedTransport) {
  if(expectedTransport == -1) return Flexible(child: Center());

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
            SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional(0.00, 0.00),
              child: Container(
                width: 230,
                height: 60,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 76, 134, 209),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Color.fromARGB(255, 38, 108, 199),
                    width: 3,
                  ),
                ),
                child: Align(
                  alignment: AlignmentDirectional(0.00, 0.00),
                  child: Text(
                    'Parks',
                    textAlign: TextAlign.start,
                    style: style[7],
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
            Align(
              alignment: AlignmentDirectional(0.00, 1.00),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(3, 5, 3, 3),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.94,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        color: Color(0x33000000),
                        offset: Offset(0, 2),
                      )
                    ],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(0xFF3FC363),
                      width: 3,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-0.90, 0.00),
                            child: Container(
                              width: 170,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Color(0xFF3FC363),
                                  width: 1.5,
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.00, 0.00),
                                child: Text(
                                  'Venezia Center \nParking Garage',
                                  textAlign: TextAlign.start,
                                  style: style[5],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Align(
                            alignment: AlignmentDirectional(1.00, 0.00),
                            child: Container(
                              width: 80,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: Color(0xFF3FC363),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(0.00, 0.00),
                                    child: Text(
                                      '5€',
                                      textAlign: TextAlign.center,
                                      style: style[6],
                                    ),
                                  ),
                                  Text(
                                    '1 hour',
                                    style: style[4],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 7),
                          Align(
                            alignment: AlignmentDirectional(1.00, 0.00),
                            child: Container(
                              width: 80,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: Color(0xFF3FC363),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    '4.5',
                                    textAlign: TextAlign.center,
                                    style: style[6],
                                  ),
                                  Icon(
                                    Icons.star,
                                  )
                                ],
                              )
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0.00, 1.00),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(3, 5, 3, 3),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.94,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        color: Color(0x33000000),
                        offset: Offset(0, 2),
                      )
                    ],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(0xFFEF393C),
                      width: 3,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-0.90, 0.00),
                            child: Container(
                              width: 170,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Color(0xFFEF393C),
                                  width: 1.5,
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.00, 0.00),
                                child: Text(
                                  'Autorimessa Comunale',
                                  textAlign: TextAlign.center,
                                  style: style[5],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Align(
                            alignment: AlignmentDirectional(1.00, 0.00),
                            child: Container(
                              width: 80,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: Color(0xFFEF393C),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(0.00, 0.00),
                                    child: Text(
                                      '35€',
                                      textAlign: TextAlign.center,
                                      style: style[6],
                                    ),
                                  ),
                                  Text(
                                    '1 hour',
                                    style: style[4],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 7),
                          Align(
                            alignment: AlignmentDirectional(1.00, 0.00),
                            child: Container(
                              width: 80,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: Color(0xFFEF393C),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    '3.9',
                                    textAlign: TextAlign.center,
                                    style: style[6],
                                  ),
                                  Icon(
                                    Icons.star,
                                  )
                                ],
                              )
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0.00, 1.00),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(3, 5, 3, 3),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.94,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        color: Color(0x33000000),
                        offset: Offset(0, 2),
                      )
                    ],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(0xFFFBC21F),
                      width: 3,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-0.90, 0.00),
                            child: Container(
                              width: 170,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Color(0xFFFBC21F),
                                  width: 1.5,
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.00, 0.00),
                                child: Text(
                                  'Garage San Marco',
                                  textAlign: TextAlign.center,
                                  style: style[5],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Align(
                            alignment: AlignmentDirectional(1.00, 0.00),
                            child: Container(
                              width: 80,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: Color(0xFFFBC21F),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(0.00, 0.00),
                                    child: Text(
                                      '51€',
                                      textAlign: TextAlign.center,
                                      style: style[6],
                                    ),
                                  ),
                                  Text(
                                    '1 day',
                                    style: style[4],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 7),
                          Align(
                            alignment: AlignmentDirectional(1.00, 0.00),
                            child: Container(
                              width: 80,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: Color(0xFFFBC21F),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    '4.2',
                                    textAlign: TextAlign.center,
                                    style: style[6],
                                  ),
                                  Icon(
                                    Icons.star,
                                  )
                                ],
                              )
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0.00, 1.00),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(3, 5, 3, 3),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.94,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        color: Color(0x33000000),
                        offset: Offset(0, 2),
                      )
                    ],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(0xFFFBC21F),
                      width: 3,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-0.90, 0.00),
                            child: Container(
                              width: 170,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Color(0xFFFBC21F),
                                  width: 1.5,
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.00, 0.00),
                                child: Text(
                                  'Marco Polo Park',
                                  textAlign: TextAlign.center,
                                  style: style[5],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Align(
                            alignment: AlignmentDirectional(1.00, 0.00),
                            child: Container(
                              width: 80,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: Color(0xFFFBC21F),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(0.00, 0.00),
                                    child: Text(
                                      '56€',
                                      textAlign: TextAlign.center,
                                      style: style[6],
                                    ),
                                  ),
                                  Text(
                                    '1 day',
                                    style: style[4],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 7),
                          Align(
                            alignment: AlignmentDirectional(1.00, 0.00),
                            child: Container(
                              width: 80,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                shape: BoxShape.rectangle,
                                border: Border.all(
                                  color: Color(0xFFFBC21F),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    '4.3',
                                    textAlign: TextAlign.center,
                                    style: style[6],
                                  ),
                                  Icon(
                                    Icons.star,
                                  )
                                ],
                              )
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
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

LinearGradient greyGradient() {
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


Align okBus(BuildContext context, final style) {
  return Align(
    alignment: AlignmentDirectional(0.00, 1.00),
    child: Padding(
      padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.94,
        height: 80,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 165, 236, 117),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x33000000),
              offset: Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:  Color.fromARGB(255, 165, 236, 117),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: Align(
                alignment: AlignmentDirectional(-0.50, 0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                  child: Text(
                    'Bus',
                    style: style[7],
                  )
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Align(
                alignment: AlignmentDirectional(0.55, 0.00),
                child: Text(
                  "✔",
                  style: style[8],
                )
              ),
            )
          ]
        ),
      ),
    ),
  );
}

Align noBus(BuildContext context, final style) {
  return Align(
    alignment: AlignmentDirectional(0.00, 1.00),
    child: Padding(
      padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.94,
        height: 80,
        decoration: BoxDecoration(
          color: Color(0xFFFBC21F),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x33000000),
              offset: Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:  Color(0xFFFBC21F),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: Align(
                alignment: AlignmentDirectional(-0.50, 0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                  child: Text(
                    'Bus',
                    style: style[7],
                  )
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child:Align(
                alignment: AlignmentDirectional(0.48, 0.00),
                child: Text(
                  "!",
                  style: style[9],
                )
              ),
            )
          ]
        ), 
      ),
    ),
  );
}

Align noTrain(BuildContext context, final style) {
  return Align(
    alignment: AlignmentDirectional(0.00, 1.00),
    child: Padding(
      padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.94,
        height: 80,
        decoration: BoxDecoration(
          color: Color(0xFFFBC21F),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x33000000),
              offset: Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:  Color(0xFFFBC21F),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: Align(
                alignment: AlignmentDirectional(-0.50, 0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                  child: Text(
                    'Train',
                    style: style[7],
                  )
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Align(
                alignment: AlignmentDirectional(0.48, 0.00),
                child: Text(
                  "!",
                  style: style[9],
                )
              ),
            )
          ]
        ), 
      ),
    ),
  );
}

Align okTrain(BuildContext context, final style) {
  return Align(
    alignment: AlignmentDirectional(0.00, 1.00),
    child: Padding(
      padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.94,
        height: 80,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 165, 236, 117),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x33000000),
              offset: Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:  Color.fromARGB(255, 165, 236, 117),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: Align(
                alignment: AlignmentDirectional(-0.50, 0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                  child: Text(
                    'Train',
                    style: style[7],
                  )
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Align(
                alignment: AlignmentDirectional(0.55, 0.00),
                child: Text(
                  "✔",
                  style: style[8],
                )
              ),
            )
          ]
        ),
      ),
    ),
  );
}

Align noInformation(BuildContext context, final style) {
  return Align(
    alignment: AlignmentDirectional(0.00, 1.00),
    child: Padding(
      padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.94,
        height: 80,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 75, 72, 73),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x33000000),
              offset: Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:  Color.fromARGB(255, 75, 72, 73),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: Align(
                alignment: AlignmentDirectional(-0.50, 0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                  child: Text(
                    'Train',
                    style: style[7],
                  )
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Align(
                alignment: AlignmentDirectional(0.5, 0.00),
                child: Icon(
                  Icons.signal_wifi_statusbar_connected_no_internet_4,
                  color: Colors.white,
                  size: 35,
                )
              )
            )
          ]
        ),
      ),
    ),
  );
}


ElevatedButton buttonBus() {
  return ElevatedButton.icon(
    onPressed: () async {},
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
      "Download guaranteed buses",
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
      ),
    ),
  );
}

ElevatedButton buttonTrain() {
  return ElevatedButton.icon(
    onPressed: () async {},
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
      "Download guaranteed trains",
      style: TextStyle(
        color: Colors.black,
        fontSize: 14,
      ),
    ),
  );
}