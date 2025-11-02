import 'package:cocktails/Profile.dart';
import 'package:cocktails/Settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cocktails/main.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'ImageCard.dart';
import 'package:cocktails/Widgets/Home/CreatorPrompt.dart';
import 'Cocktail.dart';
import 'package:cocktails/creator.dart';

Set selectedMode = {"Discover"};


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


class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  SearchController controllerS = SearchController();
  ScrollController _scrollController = ScrollController();
  bool _showAppBar = false;
  double _lastScrollPosition = 0;

  String? _query;
  late Iterable<Widget> _lastOptions = <Widget>[];

  @override
  void initState() {
    Hive.box('favourites').listenable().addListener(_onFavouritesChanged);
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    Hive.box('favourites').listenable().removeListener(_onFavouritesChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentScroll = _scrollController.position.pixels;

    // Show app bar when scrolling down and past 100 pixels
    if (currentScroll > 100 && currentScroll > _lastScrollPosition) {
      if (!_showAppBar) {
        setState(() {
          _showAppBar = true;
        });
      }
    }
    // Hide app bar when scrolling up or at the top
    else if (currentScroll < _lastScrollPosition || currentScroll < 50) {
      if (_showAppBar) {
        setState(() {
          _showAppBar = false;
        });
      }
    }

    _lastScrollPosition = currentScroll;
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
      body: Stack(
        children: [
          // Main content
          cocktails.when(
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
              ),
            ),
            error: (err, stack) => Center(child: Text("Something went wrong")),
            data: (config) {
              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Add padding at top for the hidden app bar space
                  SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  Creatorprompt(),
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
            },
          ),

          // Animated collapsible app bar
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _showAppBar ? 0 : -100,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // App title/logo
                      Text(
                        "Cocktails",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Right side buttons
                      Row(
                        children: [
                          // Settings button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.settings_outlined),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SettingsPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 8),

                          // Profile button
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurple,
                                  Colors.purple,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.person_outline, color: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: cocktails.when(
        loading: () => Container(),
        error: (err, stack) => Container(),
        data: (config) => SearchAnchor(
          builder: (context, controllerS) {
            return FloatingActionButton(
              onPressed: () {
                controllerS.openView();
              },
              child: Icon(Icons.search),
            );
          },
          searchController: controllerS,
          suggestionsBuilder: (context, controllerS) async {
            _query = controllerS.text;
            final Map options = (await cocktailsAPI.getCocktails(
              name: "%${_query!}%",
            ));
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
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            SegmentedButton(
              showSelectedIcon: false,
              segments: [
                const ButtonSegment(
                  value: "Discover",
                  label: Icon(Icons.travel_explore_outlined),
                ),
                ButtonSegment(
                  value: "Favourite",
                  label: Icon(Icons.favorite_outline),
                  enabled: favouriteIds.isNotEmpty,
                )
              ],
              selected: selectedMode,
              onSelectionChanged: (value) {
                setState(() {
                  selectedMode = value;
                });
                var test = ref.invalidate(cocktailsProvider);
              },
            ),
            Spacer(),
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
                  Text("Creator")
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onFavouritesChanged() {
    setState(() {});
  }
}
