import 'package:monprogrammetv/programme.dart';
import 'package:webfeed/webfeed.dart';

/// A Chaine is a list of programmes
class Chaine {
  /// Name of the chaine.
  String name;

  /// List of programme.
  List<Programme> programmes;

  Chaine({this.name, this.programmes});
}

extension ChaineTVList on List<Programme> {
  /// Returns a list of chaine from a RSS Feed
  static setFromRssFeed(List<RssItem> rssFeed) {
    List<Chaine> chaineList = [];
    List<String> chaineNames = [];
    List<Programme> programList = ProgrammeTVList.fromRssFeed(rssFeed);
    for (int i = 0; i < programList.length; i++) {
      Programme currentProgramme = programList[i];
      String currentChaine = programList[i].getChaine();
      if (chaineNames.contains(currentChaine)) {
        chaineList[chaineNames.indexOf(currentChaine)]
            .programmes
            .add(currentProgramme);
      } else {
        chaineList
            .add(Chaine(name: currentChaine, programmes: [currentProgramme]));
        chaineNames.add(currentChaine);
      }
    }
    return chaineList;
  }
}
