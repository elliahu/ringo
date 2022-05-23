import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

const String _filename = 'savedMatches.json';

class Match {
  String? id;
  String? teamOne;
  String? teamTwo;
  String? allowOvertime;
  int? roundsToWin;
  List<int>? score;
  List<int>? history;
  String? finished;

  Match(
      {
      this.teamOne = 'Červení',
      this.teamTwo = 'Modří',
      this.allowOvertime = 'true',
      this.roundsToWin = 15,
      this.finished = 'false'}) : id = Uuid().v1().toLowerCase(), score = [0,0], history = [];

  Match.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    teamOne = json['teamOne'];
    teamTwo = json['teamTwo'];
    allowOvertime = json['allowOvertime'];
    roundsToWin = json['roundsToWin'];
    score = json['score'].cast<int>();
    history = json['history'].cast<int>();
    finished = json['finished'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['teamOne'] = this.teamOne;
    data['teamTwo'] = this.teamTwo;
    data['allowOvertime'] = this.allowOvertime;
    data['roundsToWin'] = this.roundsToWin;
    data['score'] = this.score;
    data['history'] = this.history;
    data['finished'] = this.finished;
    return data;
  }

  void addScore(int teamOne, int teamTwo){
    score![0] += teamOne;
    score![1] += teamTwo;
    print('score added');
    print(score);
    addToHistory(teamOne, teamTwo);
  }

  void addToHistory(int teamOne, int teamTwo){
    history!.add(teamOne);
    history!.add(teamTwo);
    print('history added');
    print(history);
  }


  void undo(){
    if(history!.isNotEmpty){
      int teamOne = history![history!.length-2];
      int teamTwo = history![history!.length-1];
      
      score![0] -= teamOne;
      score![1] -= teamTwo;

      history!.removeLast();
      history!.removeLast();
      print('undo performed');
      print(history);
    }
  }

  bool get isWin {
    if(score![0] >= roundsToWin!){
      if(score![1] <= score![0] - 2){
        finished = "true";
        return true;
      }
    }
    else if (score![1] >= roundsToWin!){
      if(score![0] <= score![1] - 2){
        finished = "true";
        return true;
      }
    }
    return false;
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_filename');
  }

  Future saveMatch(Match match) async {
    final file = await _localFile;

    if(!(await file.exists())){
      // create file if not exists
      await file.writeAsString('[]');
    }
    else{
      List<Match> matches = await readData();

      var found = matches.where((element) => element.id == match.id);

      if(found.isEmpty){
        matches.add(match);
      }
      else{
        matches.remove(found.first);
        matches.add(match);
      }
      await file.writeAsString(jsonEncode(matches));
    }
  } 

  static Future<File> deleteSavedData() async {
    final file = await _localFile;
  
    return file.writeAsString('[]');
  }

  static Future<List<Match>> readData() async {
  
    final file = await _localFile;

    // if file doesn't exists, create it
    if(!(await file.exists())){
      await file.writeAsString('[]');
    }

    // Read the file
    final contents = await file.readAsString();
    
    final rawData = jsonDecode(contents);

    List<Match> matches = [];

    for(var match in rawData){
      matches.add(Match.fromJson(match));
    }

    return matches;   
}

}
