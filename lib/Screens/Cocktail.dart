import 'package:cocktails/main.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import '../Data/ingridients_list.dart';

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
        const SystemUiOverlayStyle(
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
                  Stack(
                    children: [
                      Hero(
                        tag: widget.data["id"],
                        child: CachedNetworkImage(imageUrl: widget.data["imageUrl"]),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.8),
                                Colors.black.withValues(alpha: 0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: FutureBuilder(
                            future: cocktailRepository.getCocktail(widget.data["id"]),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                var result = snapshot.data as Map;
                                return Wrap(
                                  spacing: 5,
                                  runSpacing: 0,
                                  children: [
                                    Chip(
                                      avatar: const Icon(Icons.category, size: 18),
                                      label: Text(
                                        result['data']['category'],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    Chip(
                                      avatar: const Icon(Icons.bubble_chart, size: 18),
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            "Alcoholic? ",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            result['data']['alcoholic'] ? "✅" : "❌",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: result['data']['alcoholic']
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 48),
                        Expanded(
                          child: Text(
                            widget.data["name"],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: Hive.box('favourites').listenable(),
                          builder: (context, box, widget2) {
                            return IconButton(
                              icon: Icon(
                                box.get("ids").contains(widget.data["id"])
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              onPressed: () {
                                var favList = box.get("ids");
                                favList.contains(widget.data["id"])
                                    ? favList.remove(widget.data["id"])
                                    : favList.add(widget.data["id"]);
                                box.put("ids", favList);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder(
                    future: cocktailRepository.getCocktail(widget.data["id"]),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var result = snapshot.data as Map;
                        return Center(
                          child: Chip(
                            avatar: const Icon(Icons.local_drink, size: 18),
                            label: Text(
                              result['data']['glass'],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
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
                              const Divider(),
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0, left: 8.0),
                                child: Text("Ingredients", style: TextStyle(fontSize: 20)),
                              ),
                              ListView.builder(
                                  padding: const EdgeInsets.all(0),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: result['data']['ingredients'].length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    leading: CircleAvatar(
                                      child: Icon(ingredientIcons['${result['data']['ingredients'][index]['type']}']),
                                    ),
                                    title:
                                        Text(result['data']['ingredients'][index]['name'], style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        )),
                                    subtitle: result['data']['ingredients'][index]['measure'] != null
                                        ? Text(
                                      result['data']['ingredients'][index]['measure'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    )
                                        : null,
                                    trailing: result['data']['ingredients'][index]['alcohol']
                                        ? Text(
                                      result['data']['ingredients'][index]['percentage'] == null
                                          ? "Unknown"
                                          : "${result['data']['ingredients'][index]['percentage']}%",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                        : null,
                                  );

                                }
                              ),
                              const Divider(),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Recipe", style: TextStyle(fontSize: 20)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(result['data']['instructions']),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
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
                  Colors.black.withValues(alpha: 0.6),
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
