import 'package:flutter/material.dart';

import '../Widgets/Mixed/Match.dart';
import '../Widgets/Mixed/NotFound.dart';
import '../main.dart';

String getIngredientName(Map data, int id) {
  String name = "";
  for (int a = 0; a < data['cocktails'].length; a++ ){
    for (int i = 0; i < data['cocktails'][a]['results'].length; i++) {
      for (int x = 0; x < data['cocktails'][a]['results'][i]['ingredients'].length; x++) {
        if (data['cocktails'][a]['results'][i]['ingredients'][x]['id'] == id) {
          name = data['cocktails'][a]['results'][i]['ingredients'][x]['name'];
  }
  }
  }
  }

  return name;
}

String createName(List<int> ing, Map data) {
  String name = "";
  for(int a = 0; a < ing.length; a++) {
    name = name + getIngredientName(data, ing[a]);
    if (a != ing.length - 1) {
      name = name + ", ";
    }
  }
  return name;
}

class Mixed extends StatefulWidget {
  final Map results;

  const Mixed({super.key, required this.results
  });

  @override
  State<Mixed> createState() => _MixedState();
}

class _MixedState extends State<Mixed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            IconButton(onPressed: () {
              Navigator.pop(context);
            }, icon: Icon(Icons.arrow_back)),
          ],
        ),
      ),
      body: widget.results['best_best_match'] == null ? NotFound() :
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(widget.results.toString()),
                // Text(widget.results.toString()),
                Match(match: widget.results['best_best_match'], best: true, ingredients: [],),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("See other matches", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.results['cocktails'].length,
                    itemBuilder: (context, index) {
                    if (widget.results['cocktails'][index]['results'].length > 0) {
                      return ExpansionTile(
                          title: Text(createName(widget.results['cocktails'][index]['ingredients'], widget.results)),
                          children: [ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: widget.results['cocktails'][index]['results'].length,
                              itemBuilder: (context, index2) {
                                return Match(match: widget.results['cocktails'][index]['results'][index2], best: false, ingredients: widget.results['cocktails'][index]['ingredients'],);
                              }
                          ),]
                      );
                    } else {
                      return Container();
                    }

                    }
                )
              ],
            ),
          )
    );
  }
}