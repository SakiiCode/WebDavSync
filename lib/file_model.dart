import 'dart:io' as dart_io;
import 'package:webdav_client/webdav_client.dart' as webdav;

class IndexedFile {
  final String localPath;
  final String remotePath;
  final DateTime lastModified;

  const IndexedFile({required this.localPath, required this.remotePath, required this.lastModified});

  Map<String, dynamic> toMap() {
    return {
      'localPath': localPath,
      'remotePath': remotePath,
      'lastModified': lastModified.millisecondsSinceEpoch
    };
  }

  @override
  String toString() {
    return 'File{localPath: $localPath, remotePath: $remotePath, lastModified: $lastModified}';
  }

  static IndexedFile fromLocalFile(dart_io.File input, String remotePath) {
    return IndexedFile(
        localPath: input.path, remotePath: remotePath, lastModified: input.lastModifiedSync());
  }

  static IndexedFile fromWebDavFile(webdav.File input, String localPath) {
    return IndexedFile(localPath: localPath, remotePath: input.path!, lastModified: input.mTime!);
  }
}
