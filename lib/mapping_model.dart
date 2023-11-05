class FolderMapping {
  final String remotePath;
  final String localPath;

  const FolderMapping({required this.remotePath, required this.localPath});

  Map<String, dynamic> toMap() {
    return {'remotePath': remotePath, 'localPath': localPath};
  }

  @override
  String toString() {
    return 'FolderMapping{remotePath: $remotePath, localPath: $localPath}';
  }
}
