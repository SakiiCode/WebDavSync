import 'package:webdavsync/credentials.dart';
import 'package:webdavsync/file_db.dart';
import 'package:webdavsync/mapping_db.dart';
import 'package:webdavsync/mappings.dart';
import 'package:webdavsync/sync.dart';
import 'package:flutter/material.dart';
import 'package:webdavsync/client.dart';
import 'package:webdavsync/file_browser.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await webDavHelper.load();
  webDavHelper.connect();
  await fileDb.init();
  await mappingDb.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String title = "/";
  int selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      FileBrowserPage(
        onChange: (path) {
          setState(() {
            title = path;
          });
        },
      ),
      const Mappings(),
      const Credentials(),
    ];
  }

  void onItemTapped(int index, String title) {
    setState(() {
      selectedIndex = index;
      this.title = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[selectedIndex],
      appBar: AppBar(title: Text(title)),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(webDavHelper.user),
              accountEmail: Text(Uri.parse(webDavHelper.url).host),
              currentAccountPicture:
                  const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.cloud)),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('File browser'),
              onTap: () {
                onItemTapped(0, "/");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Mappings'),
              onTap: () {
                onItemTapped(1, "Mappings");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.key),
              title: const Text('Credentials'),
              onTap: () {
                onItemTapped(2, "Credentials");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Force sync'),
              onTap: () {
                syncHelper.doSync();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Logs'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
