import 'dart:async';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'package:webdavsync/file_model.dart';

FileDb fileDb = FileDb();

class FileDb {
  late final Database db;

  Future<void> init() async {
    db = await openDatabase(path.join(await getDatabasesPath(), 'file_database.db'),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE files(localPath TEXT PRIMARY KEY, remotePath TEXT, lastModified INTEGER)');
    }, version: 1);
  }

  Future<void> insertFile(IndexedFile file) {
    return db.insert('files', file.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<IndexedFile>> query() async {
    final List<Map<String, dynamic>> maps = await db.query('files');
    return List.generate(maps.length, (i) {
      return IndexedFile(
          localPath: maps[i]['localPath'] as String,
          remotePath: maps[i]['remotePath'] as String,
          lastModified: DateTime.fromMillisecondsSinceEpoch((maps[i]['lastModified'] as int)));
    });
  }

  Future<void> delete(String localPath) {
    return db.delete('files', where: 'localPath = ?', whereArgs: [localPath]);
  }

  Future<void> editFile(String localPath, Map<String, dynamic> props) {
    return db.update('files', props, where: "localPath = ?", whereArgs: [localPath]);
  }

  Future<bool> exists(String localPath) async {
    return (await db.query('files', where: 'localPath = ?', whereArgs: [localPath])).isEmpty;
  }
}
