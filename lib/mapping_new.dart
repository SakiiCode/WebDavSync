import 'dart:io';

import 'package:webdavsync/mapping_db.dart';
import 'package:flutter/material.dart';
import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class NewMapping extends StatefulWidget {
  const NewMapping({super.key, required this.remotePath});

  final String remotePath;

  @override
  State<NewMapping> createState() => _NewMappingState();
}

class _NewMappingState extends State<NewMapping> {
  Directory? selectedDirectory;

  /*Future<bool> requestManagePermission() async {
    var status = await Permission.manageExternalStorage.status;
    //print(status);
    // if (status.isRestricted) {
    //   status = await Permission.manageExternalStorage.request();
    //   print(status);
    // }

    if (status.isRestricted || status.isDenied) {
      status = await Permission.manageExternalStorage.request();
      //print(status);
    }
    // if (status.isPermanentlyDenied && context.mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //     backgroundColor: Colors.green,
    //     content: Text('Please add permission for app to manage external storage'),
    //   ));
    //   print(status);
    // }
    // print(status);
    return status.isGranted;
  }*/

  Future<void> _pickDirectory(BuildContext context) async {
    Directory? directory = selectedDirectory;
    if (directory == null) {
      // this is a workaround if /storage/emulated/0 is not the home dir
      Directory? externalStorageDir = await getExternalStorageDirectory();
      if (externalStorageDir == null) {
        directory = Directory(FolderPicker.rootPath);
      }
      List<String> parts = path.split(externalStorageDir!.path);
      String homeDir = parts.skip(1).take(3).join("/");
      directory = Directory("/$homeDir");
    }

    if (!context.mounted) {
      return;
    }

    Directory? newDirectory = await FolderPicker.pick(
        allowFolderCreation: true,
        context: context,
        rootDirectory: directory,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))));

    if (newDirectory == null) {
      return;
    }

    if (await mappingDb.exists(newDirectory.path)) {
      if (!context.mounted) {
        return;
      }
      showDialog<void>(
          context: context, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("This local directory is already used in a mapping"),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
      return;
    }
    setState(() {
      selectedDirectory = newDirectory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New mapping")),
      body: Column(
        children: [
          ListTile(
            title: const Text("Remote path"),
            subtitle: Text(widget.remotePath),
            enabled: false,
          ),
          const Divider(),
          ListTile(
            title: const Text("Local path"),
            subtitle: Text(selectedDirectory?.path ?? "Tap to select"),
            onTap: () {
              _pickDirectory(context);
            },
          ),
        ],
      ),
      floatingActionButton: (() {
        if (selectedDirectory != null) {
          return FloatingActionButton(
            onPressed: () {
              mappingDb.insertMapping(remotePath: widget.remotePath, localPath: selectedDirectory!.path);
              Navigator.pop(context);
            },
            tooltip: 'Save mapping',
            child: const Icon(Icons.check),
          );
        } else {
          return null;
        }
      })(),
    );
  }
}
