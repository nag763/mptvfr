import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'programme.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

var feedUrl;

const SENSIBILITY = 22;

String numberToReadableDTString(int number) {
  if (9 < number) {
    return number.toString();
  } else {
    return '0$number';
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime now = new DateTime.now();
    var formatter = new DateFormat('dd-MM-yyyy');
    String formattedDate = formatter.format(now);
    feedUrl = Uri.https(
        "webnext.fr",
        "templates/webnext_exclusive/views/includes/epg_cache/programme-tv-rss_" +
            formattedDate +
            ".xml");
    return MaterialApp(
      title: 'Mon programme tv du ' + formattedDate,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Mon programme tv du ' + formattedDate),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, List<Programme>> classedItems = {};
  List<Programme> currentItems = [];
  List<String> keys = [];
  String currentKey = '';
  int currentItemCount = 0;
  static const List<String> DT_SELECTORS = ['Matinée', 'Midi', 'Après-Midi', 'Soirée', 'Deuxième partie de soirée', 'Aucun'];
  String currentDTSelector = DT_SELECTORS.last;

  void changeList(int keyNumber) {
    currentKey = keys[keyNumber];
    currentItems = classedItems[currentKey];
    if(currentDTSelector != 'Aucun'){
      currentItems = sortedAfterDT(currentItems);
    }
    currentItemCount = currentItems.length;
  }

  List<Programme> sortedAfterDT(List<Programme> itemList){
    DateTimeRange dtSelector;
    final formatter = DateFormat('H:m');
    switch(currentDTSelector){
      case 'Matinée':
        dtSelector = new DateTimeRange(start: formatter.parse('7:30'), end: formatter.parse('11:30'));
        break;
      case 'Midi':
        dtSelector = new DateTimeRange(start: formatter.parse('11:30'), end: formatter.parse('13:30'));
        break;
      case 'Après-Midi':
        dtSelector = new DateTimeRange(start: formatter.parse('13:30'), end: formatter.parse('20:30'));
        break;
      case 'Soirée':
        dtSelector = new DateTimeRange(start: formatter.parse('20:30'), end: formatter.parse('22:30'));
        break;
      case 'Deuxième partie de soirée':
      dtSelector = new DateTimeRange(start: formatter.parse('22:30'), end: formatter.parse('23:59'));
        break;
      case 'Aucun':
        break;
    }
    if(currentDTSelector != 'Aucun') {
      var newItemList = itemList.where(
              (element) => element.heureDebut.isAfter(dtSelector.start) && element.heureDebut.isBefore(dtSelector.end)
      ).toList();
      return newItemList;
    }
  }

  Future<void> fetchRSS() async {
    final ProgressDialog pr = ProgressDialog(context,
        isDismissible: false, type: ProgressDialogType.Normal);
    pr.style(
      message: 'Patientez pendant la récupération des informations.',
    );
    await pr.show();
    await pr.show().then((_) {
      http.get(feedUrl, headers: {'Content-Type': 'charset=utf-8'}).then(
          (response) {
        if (200 <= response.statusCode && response.statusCode < 300) {
          var _rssFeed =
              RssFeed.parse(Utf8Decoder().convert(response.bodyBytes));
          classedItems = Programme.classedListFromRSSFeed(_rssFeed.items);
          keys = classedItems.keys.toList();
          setState(() {
            changeList(0);
          });
          pr.hide();
        } else {
          Fluttertoast.showToast(
            msg:
                "[${response.statusCode}] Nous n'avons pas pu joindre le serveur.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
          pr.hide();
        }
      }).onError((error, stackTrace) {
        Fluttertoast.showToast(
          msg: "Une erreur est survenue.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        pr.hide();
      });
    });
  }

  Future<void> swipedEvent(String direction) async {
    if (direction == 'right') {
      if (currentKey != keys.first) {
        setState(() {
          changeList(keys.indexOf(currentKey) - 1);
        });
      }
    } else if (direction == 'left') {
      if (currentKey != keys.last) {
        setState(() {
          changeList(keys.indexOf(currentKey) + 1);
        });
      }
    }
  }

  @override
  void initState() {
    fetchRSS();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > SENSIBILITY) {
            swipedEvent('right');
          } else if (details.delta.dx < -SENSIBILITY) {
            swipedEvent('left');
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.web),
                title: Text(widget.title),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    icon: Icon(Icons.airplay),
                    onChanged: (String newValue){
                      setState(() {
                        changeList(keys.indexOf(newValue));
                      });
                    },
                    items: keys.map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                        child: Text(value),
                        value: value,
                      );
                    }).toList(),
                    value: currentKey,
                  ),
                  DropdownButton<String>(
                    icon: Icon(Icons.access_time),
                    onChanged: (String newValue){
                      setState(() {
                        currentDTSelector = newValue;
                        changeList(keys.indexOf(currentKey));
                      });
                    },
                    items: DT_SELECTORS.map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                        child: Text(value),
                        value: value,
                      );
                    }).toList(),
                    value: currentDTSelector,
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: currentItemCount,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: Text(currentItems[index].getChaine()),
                            title: Text(currentItems[index].getTitle()),
                            subtitle: Text(
                                'Début à ${numberToReadableDTString(currentItems[index].getHeureDebut().hour)}h${numberToReadableDTString(currentItems[index].getHeureDebut().minute)}'),
                            onLongPress: () {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content:
                                    Text(currentItems[index].getDescription()),
                              ));
                            },
                          )
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
