import 'dart:convert';
import 'dart:io';
import 'package:fiberapp/screenrendring.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert' as convert;

class Data {
  final int? id;
  final String name;
  var track;
  var polyline;

  Data({this.id, required this.name, this.track, this.polyline});

  factory Data.fromMap(Map<String, dynamic> json) => new Data(
        id: json['id'],
        name: json['name'],
        track: json['track'],
        polyline: json['mapPolylines'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'track': track,
      "polyline": polyline,
    };
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await initDatabase();

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

  Future<List<Data>> gettrack() async {
    Database db = await instance.database;
    var tracks = await db.query('tracks', orderBy: 'id');
    List<Data> dataList =
        tracks.isNotEmpty ? tracks.map((c) => Data.fromMap(c)).toList() : [];
    return dataList;
  }

  Future<int?> addtrack(String data) async {
    String arrayText = "[['dart', 'flutter'],['dart', 'flutt']]";
    print(arrayText.runtimeType);
    print('arrayText.runtimeType');
    Database db = await instance.database;
    int id1 = await db.rawInsert(
        'INSERT INTO tracks(name, track, markerposition, mapPolylines) VALUES("$data", "$arrayText", "${switchscreen!.markerposition}", "${switchscreen?.mapPolylines}")');
    print('inserted1: $id1');
    var trackdata = await db.query('tracks', orderBy: 'id');
    print(trackdata);
  }

  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete('tracks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Data data) async {
    Database db = await instance.database;
    return await db
        .update('tracks', data.toMap(), where: "id = ?", whereArgs: [data.id]);
  }
}
