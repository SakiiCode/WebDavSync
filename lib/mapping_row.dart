import 'package:webdavsync/mapping_db.dart';
import 'package:webdavsync/mapping_model.dart';
import 'package:flutter/material.dart';

class MappingRow extends StatelessWidget {
  const MappingRow({super.key, required this.mapping, required this.refresh});

  final FolderMapping mapping;
  final Function() refresh;

  void showConfirmDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Yes"),
      onPressed: () async {
        await mappingDb.delete(mapping.localPath);
        if (context.mounted) {
          Navigator.pop(context);
        }
        refresh();
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("AlertDialog"),
      content: Text("Are you sure want to delete the mapping of ${mapping.remotePath}?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.link),
      title: Text(mapping.remotePath),
      subtitle: Text(mapping.localPath),
      trailing: Ink(
        decoration: const ShapeDecoration(
            color: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
        child: IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.white,
          onPressed: () {
            showConfirmDialog(context);
          },
        ),
      ),
      /*IconButton.outlined(
        onPressed: () {},
        icon: const Icon(Icons.delete),
        color: Colors.red,
      ),*/
    );
  }
}
