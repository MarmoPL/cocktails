import 'package:cocktails/main.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'Data/ingridients_list.dart';

// var fav = Hive.box("favourites");
// List<int> favList = fav.get("ids");
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

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ));



    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: widget.data["id"],
                    child: CachedNetworkImage(imageUrl: widget.data["imageUrl"]),
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
                      ValueListenableBuilder(
                          valueListenable: Hive.box('favourites').listenable(),
                          builder: (context, box, widget2) {
                            return IconButton(
                              icon: Icon(box.get("ids").contains(widget.data["id"]) ? Icons.favorite : Icons.favorite_border),
                              onPressed: () {
                                var favList = box.get("ids");
                                favList.contains(widget.data["id"]) ? favList.remove(widget.data["id"]) : favList.add(widget.data["id"]);
                                box.put("ids", favList);
                              }

                            );
                          }
                      )
                    ],
                  ),
                  FutureBuilder(
                    future: cocktailRepository.getCocktail(widget.data["id"]),
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
                                padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                                child: Text("Ingredients", style: TextStyle(fontSize: 20),),
                              ),
                              ListView.builder(
                                  padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: result['data']['ingredients'].length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Icon(ingredientIcons['${result['data']['ingredients'][index]['type']}']),
                                    ),
                                    title: Row(
                                      children: [
                                        Text(result['data']['ingredients'][index]['name']),
                                        SizedBox(width: 5,),
                                        Text(result['data']['ingredients'][index]['measure'] ?? "", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                    trailing: result['data']['ingredients'][index]['alcohol'] ? result['data']['ingredients'][index]['percentage']==null ? Text("Unknown") : Text(result['data']['ingredients'][index]['percentage'].toString()+"%") : Text(""),
                                  );

                                }
                              ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Recipe", style: TextStyle(fontSize: 20),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(result['data']['instructions']),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
