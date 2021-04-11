import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'package:intl/intl.dart';

/// Class dt formatter
final DateFormat _hourMinuteFormatter = DateFormat('H:m');

const String CHAINE_PKG_NAME = 'logos/channels/';
const Map<String, String> CHAINE_LOGO = {
  'TF1': 'tf1.png',
  'France 2': 'fr2.png',
  'France 3': 'fr3.png',
  'France 4': 'fr4.png',
  'France 5': 'fr5.png',
  'Canal+': 'canal+.png',
  '6ter': '6ter.png',
  'Gulli': 'gulli.png',
  'W9': 'w9.png',
  'M6': 'm6.png',
  'TMC': 'tmc.png',
  'TFX': 'tfx.png',
  'C8': 'c8.png',
  'Arte': 'arte.png',
  'BFMTV': 'bfm.png',
  'CNews': 'cnews.png',
  'Public Sénat - LCP AN': 'ps.png',
  'NRJ 12': 'nrj12.png',
  'CStar': 'cstar.png',
  'TF1 Séries Films': 'tf1sf.png',
  'RMC Story': 'rmcs.png',
  'RMC Découverte': 'rmcd.png',
  'Chérie 25': 'c25.png',
  'L\'Équipe': 'leq21.png'
};

/// Return a readable time given a certain [number]
String _numberToReadableDTString(int number) {
  if (9 < number) {
    return number.toString();
  } else {
    return '0$number';
  }
}

/// Return a readable time given a certain [number]
String _durationAsReadable(Duration drt) {
  String duration;
  if (0 < drt.inHours) {
    duration = '${drt.inHours} heure' +
        (1 < drt.inHours ? 's' : '') +
        ' et ${drt.inMinutes % 60} minute' +
        (1 < drt.inMinutes % 60 ? 's' : '');
  } else {
    duration = '${drt.inMinutes} minute' + (1 < drt.inMinutes ? 's' : '');
  }
  return duration;
}

enum ProgrammeState {
  FINISHED,
  LIVE,
  NOT_STARTED,
}

/// Tv Programme
class Programme {
  /// Title of the programme
  String title;

  /// Description of the programme
  String description;

  /// Heure where it starts
  DateTime heureDebut;

  /// Heure where it starts
  DateTime heureFin;

  /// Chaine casting it
  String chaine;

  /// Category of the programme
  String category;

  String logoPath;

  ProgrammeState state;

  double percentOfProgram;

  String contextTime;

  Programme(
      {this.title,
      this.category,
      this.chaine,
      this.heureDebut,
      this.heureFin,
      this.logoPath,
      this.description});

  String getTitle() {
    return this.title;
  }

  void setTitle(String title) {
    this.title = title;
  }

  String getDescription() {
    return this.description;
  }

  void setDescription(String description) {
    this.description = description;
  }

  DateTime getHeureDebut() {
    return this.heureDebut;
  }

  /// Get the heure as a readable string
  String getHeureDebutAsString() {
    return 'Début à ${_numberToReadableDTString(heureDebut.hour)}h${_numberToReadableDTString(getHeureDebut().minute)}';
  }

  void setHeureDebut(DateTime heureDebut) {
    this.heureDebut = heureDebut;
  }

  DateTime getHeureFin() {
    return this.heureFin;
  }

  /// Get the heure as a readable string
  String getHeureFinAsString() {
    return 'Fini depuis ${_numberToReadableDTString(heureFin.hour)}h${_numberToReadableDTString(heureFin.minute)}';
  }

  void setHeureFin(DateTime heureFin) {
    this.heureFin = heureFin;
  }

  String getChaine() {
    return this.chaine;
  }

  void setChaine(String chaine) {
    this.chaine = chaine;
  }

  String getCategory() {
    return this.category;
  }

  String getLogoPath() {
    return this.logoPath;
  }

  void setLogoPath(String logoPath) {
    this.logoPath = logoPath;
  }

  void setCategory(String category) {
    this.category = category;
  }

  @override
  String toString() {
    return '[$chaine] $title ($heureDebut)';
  }
}

extension ProgrammeTVList on List<Programme> {
  /// Get a list of programme tv from a given [rssFeed]
  static fromRssFeed(List<RssItem> rssFeed) {
    List<Programme> list = [];
    DateTime now = _hourMinuteFormatter
        .parse('${DateTime.now().hour}:${DateTime.now().minute}');
    for (int i = 0; i < rssFeed.length; i++) {
      RssItem item = rssFeed[i];
      RssItem nextItem = (i + 1 != rssFeed.length ? rssFeed[i + 1] : null);
      Programme p = new Programme(
        title: item.title.split('|').last.trim(),
        category: item.categories.first.value,
        chaine: item.title.split('|').first.trim(),
        description: item.description,
        heureDebut: _hourMinuteFormatter.parse(item.title.split('|')[1].trim()),
        heureFin: (nextItem == null ||
                nextItem.title
                        .split('|')
                        .first
                        .trim()
                        .compareTo(item.title.split('|').first.trim()) !=
                    0)
            ? _hourMinuteFormatter.parse('23:59')
            : _hourMinuteFormatter.parse(nextItem.title.split('|')[1].trim()),
        logoPath: CHAINE_LOGO.containsKey(item.title.split('|').first.trim())
            ? CHAINE_PKG_NAME + CHAINE_LOGO[item.title.split('|').first.trim()]
            : 'logo.png',
      );
      DateTimeRange dr =
          new DateTimeRange(start: p.heureDebut, end: p.heureFin);
      if (dr.start.isBefore(now) || dr.start == now) {
        if (dr.end.isAfter(now)) {
          p.state = ProgrammeState.LIVE;
          Duration durationSinceStart =
              new DateTimeRange(start: p.heureDebut, end: now).duration;
          Duration durationUntilEnd =
              new DateTimeRange(start: now, end: p.heureFin).duration;
          p.percentOfProgram =
              (durationSinceStart.inSeconds / dr.duration.inSeconds);
          if (durationSinceStart < durationUntilEnd) {
            p.contextTime =
                'Commencé depuis ' + _durationAsReadable(durationSinceStart);
          } else {
            p.contextTime =
                'Fini dans ' + _durationAsReadable(durationUntilEnd);
          }
        } else {
          p.state = ProgrammeState.FINISHED;
          p.percentOfProgram = 1;
        }
      } else {
        p.state = ProgrammeState.NOT_STARTED;
        p.percentOfProgram = 0;
      }
      list.add(p);
    }
    return list;
  }

  /// Returns a mapped list where the dt range [dr] is in the programme's
  /// debut heure.
  List<Programme> sortBetweenDR(DateTimeRange dr) {
    return this
        .where((element) =>
            element.heureDebut.isAfter(dr.start) &&
            element.heureDebut.isBefore(dr.end))
        .toList();
  }
}

extension MappedTVList on Map<String, List<Programme>> {
  /// Returns a classed list from a given [rssFeed]
  static Map<String, List<Programme>> setFromRssFeed(List<RssItem> rssFeed) {
    Map<String, List<Programme>> classedList = new Map();
    List<Programme> programList = ProgrammeTVList.fromRssFeed(rssFeed);
    for (int i = 0; i < programList.length; i++) {
      if (classedList.keys.toList().contains(programList[i].chaine)) {
        classedList[programList[i].chaine].add(programList[i]);
      } else {
        classedList[programList[i].chaine] = [];
        classedList[programList[i].chaine].add(programList[i]);
      }
    }
    return classedList;
  }
}
