import 'package:webdavsync/mapping_db.dart';
import 'package:webdavsync/mapping_model.dart';
import 'package:webdavsync/mapping_row.dart';
import 'package:flutter/material.dart';

class Mappings extends StatefulWidget {
  const Mappings({super.key});

  @override
  State<Mappings> createState() => _MappingsState();
}

class _MappingsState extends State<Mappings> {
  List<FolderMapping>? mappings;

  Future<void> fetchMappings() async {
    List<FolderMapping> mappings = await mappingDb.query();
    setState(() {
      this.mappings = mappings;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMappings();
  }

  @override
  Widget build(BuildContext context) {
    //return FutureBuilder(future: mappingDb.query(), builder: _buildFuture);
    if (mappings == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
        itemCount: mappings!.length,
        itemBuilder: (context, index) => MappingRow(
              mapping: mappings![index],
              refresh: fetchMappings,
            ));
  }

  /*Widget _buildFuture(BuildContext context, AsyncSnapshot<List<FolderMapping>> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.active:
      case ConnectionState.waiting:
        return const Center(child: CircularProgressIndicator());
      case ConnectionState.done:
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        List<FolderMapping> result = snapshot.data ?? [];
        return ListView.builder(
            itemCount: result.length,
            itemBuilder: (context, index) => MappingRow(mapping: result[index]));
    }
  }*/
}
