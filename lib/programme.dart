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

/// Tv Programme
class Programme {
  /// Title of the programme
  String _title;

  /// Description of the programme
  String _description;

  /// Heure where it starts
  DateTime heureDebut;

  /// Chaine casting it
  String _chaine;

  /// Category of the programme
  String _category;

  String _logoPath;

  String getTitle() {
    return this._title;
  }

  void setTitle(String title) {
    this._title = title;
  }

  String getDescription() {
    return this._description;
  }

  void setDescription(String description) {
    this._description = description;
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

  String getChaine() {
    return this._chaine;
  }

  void setChaine(String chaine) {
    this._chaine = chaine;
  }

  String getCategory() {
    return this._category;
  }

  String getLogoPath() {
    return this._logoPath;
  }

  void setLogoPath(String logoPath) {
    this._logoPath = logoPath;
  }

  void setCategory(String category) {
    this._category = category;
  }

  @override
  String toString() {
    return '[$_chaine] $_title ($getHeureDebutAsString())';
  }
}

extension ProgrammeTVList on List<Programme> {
  /// Get a list of programme tv from a given [rssFeed]
  static fromRssFeed(List<RssItem> rssFeed) {
    List<Programme> list = [];
    for (int i = 0; i < rssFeed.length; i++) {
      Programme p = new Programme();
      RssItem item = rssFeed[i];
      p.setTitle(item.title.split('|').last.trim());
      p.setCategory(item.categories.first.value);
      p.setChaine(item.title.split('|').first.trim());
      p.setDescription(item.description);
      p.setHeureDebut(
          _hourMinuteFormatter.parse(item.title.split('|')[1].trim()));
      if (CHAINE_LOGO.containsKey(p.getChaine())) {
        p.setLogoPath(CHAINE_PKG_NAME + CHAINE_LOGO[p.getChaine()]);
      } else {
        p.setLogoPath('logo.png');
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
      if (classedList.keys.toList().contains(programList[i]._chaine)) {
        classedList[programList[i]._chaine].add(programList[i]);
      } else {
        classedList[programList[i]._chaine] = [];
        classedList[programList[i]._chaine].add(programList[i]);
      }
    }
    return classedList;
  }
}
