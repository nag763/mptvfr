import 'package:webfeed/webfeed.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat('H:m');

class Programme {
  String title;
  String description;
  DateTime heureDebut;
  String chaine;
  String category;

  static List<Programme> fromRssFeed(List<RssItem> rssFeed) {
    List<Programme> programList = [];
    for (int i = 0; i < rssFeed.length; i++) {
      Programme p = new Programme();
      RssItem item = rssFeed[i];
      p.setTitle(item.title.split('|').last.trim());
      p.setCategory(item.categories.first.value);
      p.setChaine(item.title.split('|').first.trim());
      p.setDescription(item.description);
      p.setHeureDebut(formatter.parse(item.title.split('|')[1].trim()));
      programList.add(p);
    }
    return programList;
  }

  static Map<String, List<Programme>> classedListFromRSSFeed(List<RssItem> rssFeed) {
    Map<String, List<Programme>> classedList = new Map();
    List<Programme> programList = fromRssFeed(rssFeed);
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

  void setHeureDebut(DateTime heureDebut) {
    this.heureDebut = heureDebut;
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

  void setCategory(String category) {
    this.category = category;
  }
}
