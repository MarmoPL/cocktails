import 'package:cached_network_image/cached_network_image.dart';
import 'package:cocktails/Screens/Cocktail.dart';
import 'package:flutter/material.dart';

List<Map> getChips(Map match) {
  List<int> matchedIngredients = match['matched_ingredients'];
  List<Map> ingredients = [];
  for (int i = 0; i < match['cocktail']['ingredients'].length; i++) {
    ingredients.add({
      'id': match['cocktail']['ingredients'][i]['id'],
      'name': match['cocktail']['ingredients'][i]['name'],
      'used': false,
    });
    if (matchedIngredients.contains(match['cocktail']['ingredients'][i]['id'])) {
      ingredients[i]['used'] = true;
    }
  }
  return ingredients;

}

class Match extends StatelessWidget {
  final Map match;
  final bool best;
  final List ingredients;


  const Match({super.key, required this.match, required this.best, required this.ingredients});



  @override
  Widget build(BuildContext context) {

    // print(getChips(match));
    double score = 0;
    if (match['score'] != null) {
      score = match['score'] as double;
    }



    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          children: [
            best ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome),
                  const SizedBox(width: 5),
                  const Text("Best Match"),
                  const Spacer(),
                  Text("Score ${score.round()}")
                ]
              ),
            ) : Container(),
            Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(100),
                1: FlexColumnWidth(100),
              },
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                            imageUrl: best ? match['cocktail']['imageUrl'] : match['imageUrl']
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: !best ? const EdgeInsets.all(8.0) : const EdgeInsets.all(0),
                          child: Text(best ? match['cocktail']['name'] : match['name'], style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                        ),
                        best ? const Text("We think this is the best choice for you 🍾", style: TextStyle(fontSize: 15)) : Container(),
                        TextButton(onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CocktailDetails(data: best ? match['cocktail'] : match)),
                          );
                        },
                        child: const Text("See Details"),
                        )
                      ],
                    ),
                  ])
              ]
            ),
            best ? Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Wrap(
                children: [
                  for (int i = 0; i < getChips(match).length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Chip(
                        label: Text(getChips(match)[i]['name']),
                        avatar: Icon(
                          getChips(match)[i]['used'] ? Icons.check : Icons.close,
                          color: getChips(match)[i]['used'] ? Colors.green : Colors.red,
                          ),
                      ),
                    ),
                ],
              ),
            ) : Container()
          ],
        )
      ),
    );
  }
}
