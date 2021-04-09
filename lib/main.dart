import 'dart:math';

import 'package:flutter/material.dart';
import 'package:monprogrammetv/chaine.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webfeed/webfeed.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'programme.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

Future main() async {
  await DotEnv().load('.env');
  runApp(MPTVFR());
}

/// Directions of slidable
enum Directions { LEFT, RIGHT }

/// Formatter for date
final DateFormat hourMinuteFormatter = DateFormat('H:m');

class MPTVFR extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MPTVFR',
      theme: ThemeData(brightness: Brightness.dark),
      home: HomePage(title: 'MPTVFR'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Chaine> _chaineList;

  /// Current items being displayed.
  List<Programme> _currentItems;

  /// Keys of the classed items.
  List<String> _keys;

  /// Current key of the list being displayed?
  String _currentKey;

  /// Current item count of items being displayed.
  int _currentItemCount;

  /// Displayed datetime.
  DateTime _fetchedDT;

  /// The feed url.
  Uri _feedUrl;

  /// Title of the list.
  String _title;

  /// The current dt selector.
  String currentDTSelector = dtSelectors.keys.first;

  /// Detect if the element should be swipeable or not.
  bool isSwipeable;

  bool hasBeenFetched;

  /// dtSelectors, map of the available selectors for the list of displayed.
  static final Map<String, DateTimeRange> dtSelectors = {
    "Maintenant": DateTimeRange(
      start: hourMinuteFormatter
          .parse((max(DateTime.now().hour - 2, 0)).toString() + ":00"),
      end: hourMinuteFormatter
          .parse((min(DateTime.now().hour + 2, 24)).toString() + ":00"),
    ),
    "Matinée": DateTimeRange(
        start: hourMinuteFormatter.parse('7:30'),
        end: hourMinuteFormatter.parse('11:30')),
    "Midi": DateTimeRange(
        start: hourMinuteFormatter.parse('11:30'),
        end: hourMinuteFormatter.parse('13:30')),
    "Après-Midi": DateTimeRange(
        start: hourMinuteFormatter.parse('13:30'),
        end: hourMinuteFormatter.parse('20:30')),
    "Soirée": DateTimeRange(
        start: hourMinuteFormatter.parse('20:30'),
        end: hourMinuteFormatter.parse('22:30')),
    "Deuxième partie de soirée": DateTimeRange(
        start: hourMinuteFormatter.parse('22:30'),
        end: hourMinuteFormatter.parse('23:59')),
    'Aucun': null
  };

  _HomePageState() {
    _fetchedDT = DateTime.now();
    setFeedUrl(_fetchedDT);
    _currentItemCount = 0;
    _keys = [];
    _currentItems = [];
    _title = '';
    _chaineList = [];
  }

  /// Change the list to the given [keyNumber]
  void changeList(int keyNumber) {
    _currentKey = _keys[keyNumber];
    if (currentDTSelector != 'Aucun') {
      _currentItems = _chaineList[keyNumber]
          .programmes
          .sortBetweenDR(dtSelectors[currentDTSelector]);
    } else {
      _currentItems = _chaineList[keyNumber].programmes;
    }
    _currentItemCount = _currentItems.length;
  }

  /// Set the feed url for the given DateTime [dt]
  setFeedUrl(DateTime dt) {
    DateFormat formatter = new DateFormat('dd-MM-yyyy');
    String formattedDate = formatter.format(dt);
    _feedUrl = Uri.https(DotEnv().env['domain'],
        DotEnv().env['path'] + formattedDate + DotEnv().env['extension']);
  }

  /// Set the current title to the given DateTime [dt]
  setTitle(DateTime dt) {
    initializeDateFormatting('fr').then((_) {
      final DateFormat formatter = new DateFormat('EEEE d MMMM', 'fr');
      final String dateString = formatter.format(dt);
      _title = 'Programme télé du ${dateString}';
    });
  }

  /// Show the info about the app
  Future<void> showInfo() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('A propos'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(DotEnv().env['app_purpose']),
                Text('\nInformations :\n\nAuteur: LABEYE Loïc\nContact : ' +
                    DotEnv().env['mailto'] +
                    '\nLicence : MIT'),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Fetch the remote rss
  Future<void> fetchRSS() async {
    final ProgressDialog pr = ProgressDialog(context,
        isDismissible: false, type: ProgressDialogType.Normal);
    pr.style(
      message: 'Patientez pendant la récupération des informations.',
    );
    await pr.show();
    await pr.show().then((_) {
      final DateTime now = DateTime.now();
      if (_fetchedDT.month != now.month &&
          _fetchedDT.day != now.day &&
          _fetchedDT.year != now.year) {
        _fetchedDT = now;
        setFeedUrl(_fetchedDT);
      }
      http.get(_feedUrl, headers: {
        'Content-Type': 'charset=utf-8',
        'Access-Control-Allow-Origin': '*'
      }).then((response) {
        if (200 <= response.statusCode && response.statusCode < 300) {
          var _rssFeed =
              RssFeed.parse(Utf8Decoder().convert(response.bodyBytes));
          _chaineList = ChaineTVList.setFromRssFeed(_rssFeed.items);

          _keys = _chaineList.map<String>((e) => e.name).toList();
          setState(() {
            changeList(0);
            setTitle(_fetchedDT);
          });
          pr.hide();
        } else {
          Fluttertoast.showToast(
            msg:
                "[${response.statusCode}] Nous n'avons pas pu joindre le serveur.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          pr.hide();
        }
      }).onError((error, stackTrace) {
        Fluttertoast.showToast(
          msg: "Une erreur est survenue.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        pr.hide();
      });
    });
  }

  /// Change the display according to the given swiped [direction]
  void swipedEvent(Directions direction) async {
    if (direction == Directions.LEFT) {
      if (_currentKey != _keys.first) {
        setState(() {
          changeList(_keys.indexOf(_currentKey) - 1);
        });
      }
    } else if (direction == Directions.RIGHT) {
      if (_currentKey != _keys.last) {
        setState(() {
          changeList(_keys.indexOf(_currentKey) + 1);
        });
      }
    }
  }

  @override
  void initState() {
    fetchRSS();
    this.isSwipeable = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
              icon: new Image(
                image: AssetImage('logos/logo.png'),
              ),
              onPressed: () {
                showInfo();
              })),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (_chaineList.isNotEmpty) {
            if (details.delta.dx > 0 && this.isSwipeable) {
              swipedEvent(Directions.LEFT);
              this.isSwipeable = false;
            } else if (details.delta.dx < 0 && this.isSwipeable) {
              swipedEvent(Directions.RIGHT);
              this.isSwipeable = false;
            }
          }
        },
        onHorizontalDragEnd: (details) {
          this.isSwipeable = true;
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ListTile(
                trailing: IconButton(
                  icon: new Icon(Icons.refresh),
                  onPressed: () {
                    fetchRSS();
                  },
                ),
                title: Text(_title.isEmpty
                    ? 'Aucune information n\'a pu être chargée'
                    : _title),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: Stack(children: [
                    DropdownButton<String>(
                      icon: Icon(Icons.airplay),
                      onChanged: (String newValue) {
                        setState(() {
                          changeList(_keys.indexOf(newValue));
                        });
                      },
                      items: _keys.map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          child: Text(value, style: TextStyle(fontSize: 12)),
                          value: value,
                        );
                      }).toList(),
                      value: _currentKey,
                    ),
                  ])),
                  DropdownButton<String>(
                    icon: Icon(Icons.access_time),
                    onChanged: (String newValue) {
                      setState(() {
                        currentDTSelector = newValue;
                        changeList(_keys.indexOf(_currentKey));
                      });
                    },
                    items:
                        dtSelectors.keys.map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                        child: Text(value, style: TextStyle(fontSize: 12)),
                        value: value,
                      );
                    }).toList(),
                    value: currentDTSelector,
                  ),
                ],
              ),
              Expanded(
                child: _chaineList.isEmpty
                    ? DateTime.now().hour < 2
                        ? Text(
                            "Le programme n'est pas disponnible entre minuit et deux heures du matin, veuillez réessayer au delà de ces heures.")
                        : RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "Une erreur est survenue. Vérifiez votre connexion internet. Si vous essayez entre minuit et deux heures du matin, il se peut que le programme TV ne soit pas encore disponible.\n\n",
                                ),
                                TextSpan(
                                  text:
                                      "Autrement, vous êtes invités à remonter le bogue en envoyant un courriel à l'adresse suivante : loic.labeye@barentin.dev",
                                ),
                                WidgetSpan(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.email,
                                      ),
                                      onPressed: () {
                                        launch(DotEnv().env['mailto']);
                                      },
                                      iconSize: 14.0,
                                    ),
                                    alignment: PlaceholderAlignment.middle),
                                TextSpan(
                                  text:
                                      "\n\nVous pouvez également directement reporter le bogue sur GitHub si vous êtes familier avec l'interface",
                                ),
                                WidgetSpan(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.link,
                                      ),
                                      onPressed: () {
                                        launch(DotEnv().env['github']);
                                      },
                                      iconSize: 14.0,
                                    ),
                                    alignment: PlaceholderAlignment.middle),
                              ],
                            ),
                          )
                    : ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: _currentItemCount,
                        itemBuilder: (context, index) {
                          return Card(
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  leading: new Image.asset(
                                    _currentItems[index].getLogoPath(),
                                    height: 40,
                                    width: 40,
                                  ),
                                  title: Text(_currentItems[index].getTitle()),
                                  subtitle: Text(_currentItems[index]
                                      .getHeureDebutAsString()),
                                  onLongPress: () {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(_currentItems[index]
                                          .getDescription()),
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
