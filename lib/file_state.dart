import 'package:webdavsync/file_model.dart';

class FileState {
  bool existsLocal = false, existsIndex = false, existsRemote = false;
  DateTime? lastModifiedLocal, lastModifiedIndex, lastModifiedRemote;
  late IndexedFile file;

  late FileAction fileAction;
  late IndexAction indexAction;

  FileState(this.file);

  FileState.unitTest(
      {this.existsRemote = false,
      this.existsIndex = false,
      this.existsLocal = false,
      this.lastModifiedRemote,
      this.lastModifiedIndex,
      this.lastModifiedLocal});

  void setActions() {
    assert(existsRemote || existsIndex || existsLocal);
    assert(!existsRemote || (existsRemote && lastModifiedRemote != null));
    assert(!existsIndex || (existsIndex && lastModifiedIndex != null));
    assert(!existsLocal || (existsLocal && lastModifiedLocal != null));

    if (!existsRemote || !existsIndex || !existsLocal) {
      if (existsRemote == existsIndex) {
        if (existsLocal) {
          fileAction = FileAction.upload;
          indexAction = IndexAction.local;
        } else {
          fileAction = FileAction.deleteRemote;
          indexAction = IndexAction.delete;
        }
      } else {
        if (existsLocal && !existsRemote) {
          fileAction = FileAction.deleteLocal;
          indexAction = IndexAction.delete;
        } else if (!existsLocal && !existsRemote) {
          fileAction = FileAction.none;
          indexAction = IndexAction.delete;
        } else if (!existsLocal && existsRemote) {
          fileAction = FileAction.download;
          indexAction = IndexAction.remote;
        } else {
          fileAction = FileAction.ask;
          indexAction = IndexAction.ask;
        }
      }
    } else {
      if (lastModifiedIndex == lastModifiedLocal &&
          lastModifiedIndex == lastModifiedRemote) {
        fileAction = FileAction.none;
        indexAction = IndexAction.none;
      } else if (lastModifiedIndex != lastModifiedLocal &&
          lastModifiedIndex != lastModifiedRemote &&
          lastModifiedLocal != lastModifiedRemote) {
        fileAction = FileAction.ask;
        indexAction = IndexAction.ask;
      } else {
        int difference = lastModifiedRemote!.compareTo(lastModifiedLocal!);
        if (difference < 0) {
          fileAction = FileAction.upload;
          indexAction = IndexAction.local;
        } else if (difference > 0) {
          fileAction = FileAction.download;
          indexAction = IndexAction.remote;
        } else {
          fileAction = FileAction.none;
          if (lastModifiedRemote != lastModifiedIndex) {
            indexAction = IndexAction.remote;
          } else {
            indexAction = IndexAction.none;
          }
        }
      }
    }
  }
}

enum FileAction { upload, download, deleteLocal, deleteRemote, ask, none }

enum IndexAction { remote, local, delete, ask, none }
