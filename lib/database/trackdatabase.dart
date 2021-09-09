import 'dart:convert';
import 'dart:io';
import 'package:fiberapp/screenrendring.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data {
  final int? id;
  final String name;
  var track;
  var markerposition;

  Data({this.id, required this.name, this.track, this.markerposition});

  factory Data.fromMap(Map<String, dynamic> json) => new Data(
        id: json['id'],
        name: json['name'],
        track: json['track'],
        markerposition: json['markerposition'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'track': track,
      'markerposition': markerposition,
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
      "id": id
    });
    prefs.setString('trackslist', jsonEncode(trackslist));
    print(trackslist);
  }

  Future<List<Data>> gettrack() async {
    Future<SharedPreferences> pref = SharedPreferences.getInstance();
    final SharedPreferences prefs = await pref;
    String? vol = prefs.getString('trackslist');
    List trackslist = jsonDecode(vol!);
    List<Data> dataList = trackslist.isNotEmpty
        ? trackslist.map((c) => Data.fromMap(c)).toList()
        : [];
    print(dataList);
    return dataList;
  }

  Future<Database> initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'tracks.db');
    await deleteDatabase(path);
    print(path);
    print('path');
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

  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete('tracks', where: 'id = ?', whereArgs: [id]);
  }
}
