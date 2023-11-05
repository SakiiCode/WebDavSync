import 'package:webdavsync/mapping_new.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

class FileRow extends StatefulWidget {
  final webdav.File file;
  final Function(String) onClick;

  const FileRow({super.key, required this.file, required this.onClick});

  @override
  State<FileRow> createState() => _FileRowState();
}

class _FileRowState extends State<FileRow> {
  Offset _tapPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    String name = widget.file.name ?? "";
    return GestureDetector(
        child: ListTile(
          leading: Icon(widget.file.isDir == true
              ? Icons.folder
              : Icons.file_present_rounded),
          title: Text(name),
          subtitle: Text(widget.file.mTime.toString()),
          onTap: () {
            if (widget.file.isDir == true) {
              widget.onClick(widget.file.path ?? "/");
              //Navigator.push(context, MaterialPageRoute(builder: (_) => FileBrowserPage(dirPath: "${widget.file.path}")));
            } else {
              _showContents(name, widget.file.eTag ?? "ETag unknown", context);
            }
          },
          onLongPress: () => _showContextMenu(context),
        ),
        onTapDown: (position) => {
              setState(() {
                _tapPosition = position.globalPosition;
              })
            });
  }

  Future<void> _showContents(
      String title, String contents, BuildContext context) async {
    return showDialog(
      context: context, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(contents),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showContextMenu(BuildContext context) async {
    final RenderObject? overlay =
        Overlay.of(context).context.findRenderObject();

    final result = await showMenu(
        context: context,

        // Show the context menu at the tap location
        position: RelativeRect.fromRect(
            Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 0, 0),
            overlay!.paintBounds),

        // set a list of choices for the context menu
        items: [
          ...(widget.file.isDir == true
              ? [
                  const PopupMenuItem(
                    value: 'map',
                    child: Text('Map to local folder'),
                  )
                ]
              : []),
          const PopupMenuItem(
            value: 'info',
            child: Text('Details'),
          ),
        ]);

    if (!context.mounted) {
      return;
    }

    // Implement the logic for each choice here
    switch (result) {
      case 'map':
        String remotePath = widget.file.path ?? "";
        if (remotePath != "") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NewMapping(remotePath: normalize(remotePath))));
        } else {
          showDialog(
              context: context,
              builder: (context) => const AlertDialog(
                    title: Text("Error"),
                    content: SingleChildScrollView(
                      child: Text("file.path is empty"),
                    ),
                  ));
        }
        break;
      case 'info':
        String title = widget.file.name ?? "Filename unknown";
        String contents =
            "Path: ${widget.file.path}\nSize:${widget.file.size}\nETag: ${widget.file.eTag}\nCreated: ${widget.file.cTime}\nModified: ${widget.file.mTime}";

        _showContents(title, contents, context);
        break;
    }
  }
}
