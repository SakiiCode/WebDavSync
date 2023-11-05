import 'dart:io';

import 'package:webdavsync/client.dart';
import 'package:webdavsync/file_state.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:webdavsync/file_db.dart';
import 'package:webdavsync/file_model.dart';
import 'package:webdavsync/mapping_db.dart';
import 'package:webdavsync/mapping_model.dart';

SyncHelper syncHelper = SyncHelper();

class SyncHelper {
  Future<void> doSync() async {
    List<FolderMapping> mappings = await mappingDb.query();
    for (FolderMapping mapping in mappings) {
      List<IndexedFile> dbFiles = await fileDb.query();
      List<IndexedFile> indexedFiles =
          dbFiles.where((element) => element.localPath.startsWith(mapping.localPath)).toList();
      List<IndexedFile> remoteFiles = (await recursiveWebDav(
              mapping.remotePath, List.empty(growable: true)))
          .map((e) =>
              IndexedFile.fromWebDavFile(e, e.path!.replaceFirst(mapping.remotePath, mapping.localPath)))
          .toList();

      Directory localDir = Directory(mapping.localPath);
      List<IndexedFile> localFiles = (await recursiveLocalDir(localDir))
          .map((e) =>
              IndexedFile.fromLocalFile(e, e.path.replaceFirst(mapping.localPath, mapping.remotePath)))
          .toList();

      Map<String, FileState> fileMap = {};

      for (IndexedFile indexedFile in indexedFiles) {
        FileState state = FileState(indexedFile);
        state.existsIndex = true;
        state.lastModifiedIndex = indexedFile.lastModified;
        fileMap.addAll({indexedFile.localPath: state});
      }

      for (IndexedFile remoteFile in remoteFiles) {
        FileState? state = fileMap[remoteFile.localPath];
        if (state == null) {
          state ??= FileState(remoteFile);
          fileMap.addAll({remoteFile.localPath: state});
        }

        state.existsRemote = true;
        state.lastModifiedRemote = remoteFile.lastModified;
      }

      for (IndexedFile localFile in localFiles) {
        FileState? state = fileMap[localFile.localPath];
        if (state == null) {
          state ??= FileState(localFile);
          fileMap.addAll({localFile.localPath: state});
        }

        state.existsLocal = true;
        state.lastModifiedLocal = localFile.lastModified;
      }

      for (FileState state in fileMap.values) {
        state.setActions();
      }

      for (FileState state in fileMap.values) {
        await doFileAction(state);
        await doIndexAction(state);
      }
    }
  }

  Future<void> doFileAction(FileState state) async {
    switch (state.fileAction) {
      case FileAction.download:
        print("Download ${state.file.remotePath}");
        await webDavHelper.download(state.file.remotePath, state.file.localPath);
        File(state.file.localPath).setLastModifiedSync(state.lastModifiedRemote!);
        break;
      case FileAction.upload:
        print("Upload ${state.file.localPath}");
        await webDavHelper.upload(state.file.localPath, state.file.remotePath, state.lastModifiedLocal!);
        break;
      case FileAction.deleteLocal:
        print("Delete ${state.file.localPath}");
        File(state.file.localPath).deleteSync();
        break;
      case FileAction.deleteRemote:
        print("Delete ${state.file.remotePath}");
        await webDavHelper.delete(state.file.remotePath);
        break;
      case FileAction.ask:
        print("Ask ${state.file.localPath}");
        break;
      case FileAction.none:
        print("OK ${state.file.localPath}");
        break;
    }
  }

  Future<void> doIndexAction(FileState state) async {
    switch (state.indexAction) {
      case IndexAction.remote:
        fileDb.insertFile(IndexedFile(
            localPath: state.file.localPath,
            remotePath: state.file.remotePath,
            lastModified: state.lastModifiedRemote!));
        print(await fileDb.query());
        break;
      case IndexAction.local:
        fileDb.insertFile(IndexedFile(
            localPath: state.file.localPath,
            remotePath: state.file.remotePath,
            lastModified: state.lastModifiedLocal!));
        print(await fileDb.query());
        break;
      case IndexAction.delete:
        fileDb.delete(state.file.localPath);
        print(await fileDb.query());
        break;
      case IndexAction.ask:
        break;
      case IndexAction.none:
        break;
    }
  }

  Future<List<webdav.File>> recursiveWebDav(String path, List<webdav.File> result) async {
    List<webdav.File> contents = await webDavHelper.readDir(path);
    for (webdav.File content in contents) {
      if (content.isDir == true) {
        result.addAll(await recursiveWebDav(content.path!, result));
      } else {
        result.add(content);
      }
    }

    return result;
  }

  Future<List<File>> recursiveLocalDir(Directory dir) async {
    Stream<FileSystemEntity> contents = dir.list(recursive: true, followLinks: false);
    List<File?> tmp = List.empty(growable: true);
    tmp.addAll(await contents.map((content) {
      if (content is File) {
        return content;
      }
    }).toList());
    return tmp.nonNulls.toList();
  }
}
