import 'dart:convert';
import 'dart:io';
import 'package:fiberapp/screenrendring.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Data {
  final int? id;
  final String name;
  var track;
  var markerposition;
  var time;

  Data(
      {this.id,
      required this.name,
      this.track,
      this.markerposition,
      this.time});

  factory Data.fromMap(Map<String, dynamic> json) => new Data(
      id: json['id'],
      name: json['name'],
      track: json['track'],
      markerposition: json['markerposition'],
      time: json['time']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'track': track,
      'markerposition': markerposition,
      'time': time
    };
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  Future<Database> get database async => _database ??= await initDatabase();

  Future<int?> addtrack(String data) async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    DateTime time = DateTime.now();
    final SharedPreferences prefs = await pref;
    if (prefs.getString('trackslist') == null) {
      List<dynamic> trackslist = [];
      prefs.setString('trackslist', jsonEncode(trackslist));
    }
    String? vol = prefs.getString('trackslist');
    List trackslist = jsonDecode(vol!);
    int? id = trackslist.length;

    if (id > 0) {
      id = trackslist[id - 1]['id']!;
      id = (id! + 1);
    } else {
      id = 1;
    }

    trackslist.add({
      "name": data,
      "track": switchscreen!.uploadtrack,
      "markerposition": switchscreen!.markerposition,
      "id": id,
      "time": '$time'
    });
    prefs.setString('trackslist', jsonEncode(trackslist));
  }

  Future<List<Data>> gettrack() async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    final SharedPreferences prefs = await pref;
    String? vol = prefs.getString('trackslist');
    List trackslist = jsonDecode(vol!);
    print(trackslist);
    List<Data> dataList = trackslist.isNotEmpty
        ? trackslist.map((c) => Data.fromMap(c)).toList()
        : [];
    return dataList;
  }

  Future<int?> removetrack(int id) async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    final SharedPreferences prefs = await pref;
    String? vol = prefs.getString('trackslist');
    List trackslist = jsonDecode(vol!);
    for (int i = 0; i < trackslist.length; i++) {
      if (trackslist[i]['id'] == id) {
        trackslist.removeAt(i);
      }
    }
    print(trackslist);
    prefs.setString('trackslist', jsonEncode(trackslist));
  }

  Future<int?> uploadtrack(int id) async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    final SharedPreferences prefs = await pref;
    String? vol = prefs.getString('trackslist');
    List trackslist = jsonDecode(vol!);
    var data;
    for (int i = 0; i < trackslist.length; i++) {
      if (trackslist[i]['id'] == id) {
        data = trackslist[i];
        trackslist.removeAt(i);
      }
    }
    if (data != null) {
      data = convert.jsonEncode(data);
      var url = Uri.https(
          'joyndigital.com', '/Latitude/public/api/fiber', {'data': '$data'});
      var response = await http.post(url);
      if (response.statusCode == 200) {
        prefs.setString('trackslist', jsonEncode(trackslist));
        var jsonResponse = response.body;
        print('Number of books about http: $jsonResponse.');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    }
  }

  Future<Database> initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'tracks.db');
    await deleteDatabase(path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: onCreate,
    );
  }

  Future onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tracks(
          id INTEGER PRIMARY KEY,
          name TEXT,
          track TEXT,
          markerposition TEXT,
          mapPolylines Text
      )
      ''');
  }
}
