import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import 'package:webdavsync/file_row.dart';
import 'package:webdavsync/client.dart';

class FileBrowserPage extends StatefulWidget {
  const FileBrowserPage({super.key, required this.onChange});

  final Function(String) onChange;

  @override
  FileBrowserPageState createState() => FileBrowserPageState();
}

class FileBrowserPageState extends State<FileBrowserPage> {
  String dirPath = "/";

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (dirPath != "/") {
      String newPath = path.dirname(dirPath);
      setState(() {
        dirPath = newPath;
      });
      widget.onChange(newPath);
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: SharedPreferences.getInstance(), builder: load);
  }

  Widget load(BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData && snapshot.data != null) {
        SharedPreferences prefs = snapshot.data!;
        String url = prefs.getString("url") ?? "";
        if (url.isEmpty) {
          return const Center(child: Text("Please fill your login data in the Credentials screen"));
        } else {
          return FutureBuilder(future: webDavHelper.readDir(dirPath), builder: _buildFuture);
        }
      } else {
        return const Center(child: Text("Could not open SharedPreferences"));
      }
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildFuture(BuildContext context, AsyncSnapshot<List<webdav.File>> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.active:
      case ConnectionState.waiting:
        return const Center(child: CircularProgressIndicator());
      case ConnectionState.done:
        if (snapshot.hasError) {
          return Center(
              child: Text(
            'Could not connect to the server.\n\nPlease check your network connection\nand login details in the Credentials page\n\n${snapshot.error?.toString()}',
            textAlign: TextAlign.center,
          ));
        }
        return _buildListView(context, snapshot.data ?? []);
    }
  }

  Widget _buildListView(BuildContext context, List<webdav.File> list) {
    list.sort((file1, file2) {
      String name1 = file1.name ?? "";
      String name2 = file2.name ?? "";
      if (file1.isDir == file2.isDir) {
        return name1.compareTo(name2);
      } else {
        return file1.isDir == true ? -1 : 1;
      }
    });
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) => FileRow(
            file: list[index],
            onClick: (newPath) {
              setState(() {
                dirPath = newPath;
              });
              widget.onChange(newPath);
            }));
  }
}
