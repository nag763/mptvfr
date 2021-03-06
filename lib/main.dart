import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'programme.dart';

void main() {
  runApp(MyApp());
}

var feedUrl;

const SENSIBILITY = 22;

String numberToReadableDTString(int number) {
  if (9 < number) {
    return number.toString();
  } else {
    return '0${number}';
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
  Map<String, List<Programme>> classedItems;
  List<Programme> currentItems;
  List<String> keys;
  String currentKey;
  int currentItemCount = 0;

  void changeList(int keyNumber) {
    currentKey = keys[keyNumber];
    currentItems = classedItems[currentKey];
    currentItemCount = currentItems.length;
  }

  Future<void> fetchRSS() async {
    var response =
        await http.get(feedUrl, headers: {'Content-Type': 'charset=utf-8'});
    var _rssFeed = RssFeed.parse(Utf8Decoder().convert(response.bodyBytes));
    classedItems = Programme.classedListFromRSSFeed(_rssFeed.items);
    keys = classedItems.keys.toList();
    setState(() {
      changeList(0);
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
