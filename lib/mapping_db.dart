import 'dart:async';

import 'package:webdavsync/mapping_model.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

MappingDb mappingDb = MappingDb();

class MappingDb {
  late final Database db;

  Future<void> init() async {
    db = await openDatabase(path.join(await getDatabasesPath(), 'mapping_database.db'),
        onCreate: (db, version) {
      return db.execute('CREATE TABLE mappings(remotePath TEXT, localPath TEXT PRIMARY KEY)');
    }, version: 1);
  }

  Future<void> insertMapping(
      {required String localPath, required String remotePath, String? eTag}) async {
    Map<String, dynamic> data = {"localPath": localPath, "remotePath": remotePath};
    await db.insert('mappings', data);
  }

  Future<List<FolderMapping>> query() async {
    final List<Map<String, dynamic>> maps = await db.query('mappings');
    return List.generate(maps.length, (i) {
      return FolderMapping(
          remotePath: maps[i]['remotePath'] as String, localPath: maps[i]['localPath'] as String);
    });
  }

  Future<void> delete(String localPath) async {
    await db.delete('mappings', where: 'localPath = ?', whereArgs: [localPath]);
  }

  Future<bool> exists(String localPath) async {
    return (await db.query('mappings', where: "localPath = ?", whereArgs: [localPath])).isNotEmpty;
  }
}
