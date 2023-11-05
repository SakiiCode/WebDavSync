import 'package:shared_preferences/shared_preferences.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

WebDavHelper webDavHelper = WebDavHelper();

class WebDavHelper {
  late String url, user, pwd;
  late int interval;
  late TimeUnit intervalUnits;

  late webdav.Client client;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    url = prefs.getString("url") ?? "";
    user = prefs.getString("user") ?? "";
    pwd = prefs.getString("pwd") ?? "";
    interval = prefs.getInt("interval") ?? 0;
    intervalUnits = TimeUnit.values[prefs.getInt("intervalUnits") ?? 0];
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("url", url);
    prefs.setString("user", user);
    prefs.setString("pwd", pwd);
    prefs.setInt("interval", interval);
    prefs.setInt("intervalUnits", intervalUnits.index);
  }

  void connect() {
    client = webdav.newClient(
      url,
      user: user,
      password: pwd,
      debug: true,
    );
  }

  Future<void> update(
      {required String url,
      required String user,
      String? pwd,
      required int interval,
      required TimeUnit intervalUnits}) async {
    this.url = url;
    this.user = user;
    if (pwd != null) {
      this.pwd = pwd;
    }
    this.interval = interval;
    this.intervalUnits = intervalUnits;
    await save();
    connect();
  }

  Future<List<webdav.File>> readDir(String dirPath) {
    return client.readDir(dirPath);
  }

  Future<void> download(String remotePath, String localPath) {
    return client.read2File(remotePath, localPath);
  }

  Future<webdav.File> readProps(String remotePath) {
    return client.readProps(remotePath);
  }

  Future<void> upload(String localPath, String remotePath, [DateTime? lastModified]) async {
    if (lastModified != null) {
      client.setHeaders({"X-OC-Mtime": (lastModified.millisecondsSinceEpoch ~/ 1000).toString()});
      await client.writeFromFile(localPath, remotePath);
      client.setHeaders({});
    } else {
      await client.writeFromFile(localPath, remotePath);
    }
  }

  Future<void> delete(String remotePath) {
    return client.remove(remotePath);
  }
}

enum TimeUnit {
  minutes,
  hours,
  days,
}
