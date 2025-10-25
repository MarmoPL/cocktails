import 'package:cocktails/main.dart';
import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';

// var fav = Hive.box("favourites");
List<int> favList = fav.get("ids");
// List<int> favList = [123];

class CocktailDetails extends StatefulWidget {
  final Map data;
  const CocktailDetails({super.key, required this.data});

  @override
  State<CocktailDetails> createState() => _CocktailDetailsState();
}

class _CocktailDetailsState extends State<CocktailDetails> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: widget.data["id"],
                child: Image.network(widget.data["imageUrl"]),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                    child: Text(widget.data["name"], style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                  Spacer(),
                  IconButton(
                    icon: favList.contains(widget.data["id"]) ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
                    onPressed: () {
                      favList = fav.get("fav");
                      favList.add(widget.data["id"]);
                      fav.put("fav", favList);
                      setState(() {

                      });
                    },
                  ),
                ],
              ),
              FutureBuilder(
                future: cocktailsAPI.getCocktail(widget.data["id"]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var result = snapshot.data as Map;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 0,
                            children: [
                              Chip(
                                avatar: Icon(Icons.category),
                                label: Text(result['data']['category'])
                              ),
                              Chip(
                                  avatar: Icon(Icons.local_drink),
                                  label: Text(result['data']['glass'])
                              ),
                              Chip(
                                  avatar: Icon(Icons.bubble_chart),
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("Alcoholic? "),
                                      Text(result['data']['alcoholic'] ? "Yes ✅" : "No ❌", style: TextStyle(
                                        color: result['data']['alcoholic'] ? Colors.green : Colors.red,
                                      )),
                                    ],
                                  )
                              ),

                            ],
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Ingredients", style: TextStyle(fontSize: 20),),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: result['data']['ingredients'].length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text("${index + 1}"),
                                ),
                                title: Text(result['data']['ingredients'][index]['name']),
                                trailing: result['data']['ingredients'][index]['alcohol'] ? result['data']['ingredients'][index]['percentage']==null ? Text("Unknown") : Text(result['data']['ingredients'][index]['percentage'].toString()) : Text(""),
                              );

                            }
                          ),
                        ],
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
