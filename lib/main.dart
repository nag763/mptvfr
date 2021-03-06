import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

var feedUrl;

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
  List<RssItem> items;
  int itemCount = 0;

  Future<String> fetchRSS() async {
    var response = await http.get(feedUrl, headers:{'Content-Type':'charset=utf-8'});
    var _rssFeed = RssFeed.parse(Utf8Decoder().convert(response.bodyBytes));
    setState(() {
      items = _rssFeed.items;
      itemCount = _rssFeed.items.length;
    });
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
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
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(items[index].title),
                          subtitle: Text(items[index].description),
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
    );
  }
}
