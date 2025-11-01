import 'package:cocktails/creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'Cocktail.dart';
import 'api.dart';
import 'ImageCard.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'cache.dart';


void main() async {
  await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();
  await cocktailRepository.init();

  var favTest = await Hive.openBox('favourites');
  if (!favTest.containsKey("ids")) {
    favTest.put("ids", []);
  }
  runApp(const ProviderScope(child: MyApp()));
}

Set selectedMode = {"Discover"};

var cocktailRepository = CocktailRepository(CocktailsApiClient());
var cocktailsAPI = CocktailsApiClient();


final cocktailsProvider = FutureProvider<Map>((ref) async {
  var fav = await Hive.openBox('favourites');
  //print("tryb "+selectedMode.toString());
  if (selectedMode.contains("Favourite")) {
    //print("favourites");
    var favourites = await fav.get("ids");
    final List<int>? ids = favourites != null
        ? List<int>.from(favourites)
        : null;
    //print(favourites.runtimeType);
    var response = await cocktailRepository.getCocktails(ids: ids, perPage: 300);
    //print(response);
    return response;
  } else {
    //print("discover");
    var response = await cocktailRepository.getCocktails(perPage: 300);
    //print("DONE");
    return response;
  }
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final PageController _pageController = PageController();

    return MaterialApp(
      title: 'Cocktails',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: Home(),
    );
  }
}

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  SearchController controllerS = SearchController();

  String? _query;

  late Iterable<Widget> _lastOptions = <Widget>[];


  @override
  void initState() {
    Hive.box('favourites').listenable().addListener(_onFavouritesChanged);
    super.initState();
  }

  @override
  void dispose() {
    Hive.box('favourites').listenable().removeListener(_onFavouritesChanged);
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final favouritesBox = Hive.box('favourites');
    final List<dynamic> favouriteIds = favouritesBox.get('ids', defaultValue: []);

    AsyncValue<Map> cocktails = ref.watch(cocktailsProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
        elevation: 0,

      ),
      body: cocktails.when(
        loading: () => Skeletonizer(
          enabled: true,
            child: MasonryGridView.count(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 20,
          mainAxisSpacing: 2,
          crossAxisSpacing: 20,
          crossAxisCount: 2,
          itemBuilder: (context, index) {
            return ImageCard(
              data: {},
              title: "Loading...",
              imageUrl: "example",
            );
          },

        ),),
        error: (err, stack) => Center(child: Text("Something went wrong")),
        data: (config) {
          return CustomScrollView(

            slivers: [
              SliverToBoxAdapter(
                child: Card(
                  child: Column(
                    children: [
                      Text("Don't know what to drink?"),
                      Text("Choose what you want, and we will create the perfect cocktail for You."),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Creator(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome),
                              SizedBox(width: 5),
                              Text("Create now!")
                            ],
                          )
                      )
                    ],
                  )
                )
              ),
              SliverMasonryGrid.count(
                childCount: config["data"].length,
                mainAxisSpacing: 2,
                crossAxisSpacing: 1,
                crossAxisCount: 2,
                itemBuilder: (context, index) {
                    return ImageCard(
                      data: config["data"][index],
                      title: config["data"][index]["name"],
                      imageUrl: config["data"][index]["imageUrl"],
                    );
                },

              ),
            ],
          );
        }

      ),
      floatingActionButton: cocktails.when(
        loading: () => Container(),
        error: (err, stack) => Container(),
        data: (config) => SearchAnchor(
            builder: (context, controllerS) {
              return FloatingActionButton(onPressed: () {
                controllerS.openView();
              }, child: Icon(Icons.search));
            },
            searchController: controllerS,
            suggestionsBuilder: (context, controllerS) async {
              _query = controllerS.text;
              final Map options = (await cocktailsAPI.getCocktails(
                  name: "%${_query!}%"));
              if (_query != controllerS.text) {
                return _lastOptions;
              }

              _lastOptions = List<ListTile>.generate(options["data"].length, (index) {
                return ListTile(
                    title: Text(options["data"][index]["name"]),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CocktailDetails(data: options["data"][index]),
                        ),
                      );
                    },
                );
              });

              return _lastOptions;
            }
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            SegmentedButton(
                showSelectedIcon: false,
                segments: [
                  const ButtonSegment(value: "Discover", label: Icon(Icons.travel_explore_outlined)),
                  ButtonSegment(value: "Favourite", label: Icon(Icons.favorite_outline), enabled: favouriteIds.isNotEmpty)
                ],
                selected: selectedMode,
                onSelectionChanged: (value) {
                  setState(() {
                    selectedMode = value;
                    print(selectedMode);
                  });
                  var test = ref.invalidate(cocktailsProvider);
                }

            ),
            Spacer(),
            IconButton(onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return BottomSheetFilter(mode: "category");
                  }
              );
            }, icon: const Icon(Icons.category)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.local_drink)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.bubble_chart))
          ],
        ),
      ),
    );
  }

  void _onFavouritesChanged() {
    setState(() {});
  }
}


class BottomSheetFilter extends StatefulWidget {
  final String mode;

  const BottomSheetFilter({super.key, required this.mode});

  @override
  State<BottomSheetFilter> createState() => _BottomSheetFilterState();
}

class _BottomSheetFilterState extends State<BottomSheetFilter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: cocktailsAPI.getCocktailCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text("done");
          } else {
            return Text("loading");
          }
        }
      )
    );
  }
}
