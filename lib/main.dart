import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
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
    feedUrl = Uri.https("webnext.fr", "templates/webnext_exclusive/views/includes/epg_cache/programme-tv-rss_"+formattedDate+".xml");
    return MaterialApp(
      title: 'Mon programme tv du '+formattedDate,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Mon programme tv du '+formattedDate),
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

  var _content='Aucune information';
  Future<String> fetchRSS() async {
    var response = await http.get(feedUrl);
    var _rssFeed = RssFeed.parse(response.body);
    setState(() {
      _content = _rssFeed.items.map((e) => e.title).join("\n");
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.web),
              title: Text(widget.title),
            ),
            Text(
              '$_content',
            ),
          ],
        ),
      ),
    );
  }
}
