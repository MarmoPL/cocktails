import 'package:cocktails/main.dart';
import 'package:cocktails/Screens/mix.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


class Creator extends StatefulWidget {
  const Creator({super.key});

  @override
  State<Creator> createState() => _CreatorState();
}

class _CreatorState extends State<Creator> with SingleTickerProviderStateMixin  {
  late TabController _tabController;

  List<int> _selectedIngredients = [];
  List<String> _selectedGlass = [];

  List filteredItems = [];
  List allIngredients = [];
  TextEditingController searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = allIngredients;
      } else {
        filteredItems = allIngredients
            .where((item) => item['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showSelectedItemsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Selected Items",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        // Ingredients Section
                        if (_selectedIngredients.isNotEmpty) ...[
                          Text(
                            "Ingredients (${_selectedIngredients.length})",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _selectedIngredients.map((id) {
                              var ingredient = allIngredients.firstWhere(
                                    (item) => item['id'] == id,
                                orElse: () => {'name': 'Unknown'},
                              );
                              return Chip(
                                label: Text(ingredient['name']),
                                deleteIcon: Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() {
                                    _selectedIngredients.remove(id);
                                  });
                                  Navigator.pop(context);
                                  _showSelectedItemsBottomSheet();
                                },
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 20),
                        ],

                        // Glasses Section
                        if (_selectedGlass.isNotEmpty) ...[
                          Text(
                            "Glasses (${_selectedGlass.length})",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _selectedGlass.map((glass) {
                              return Chip(
                                label: Text(glass),
                                deleteIcon: Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() {
                                    _selectedGlass.remove(glass);
                                  });
                                  Navigator.pop(context);
                                  _showSelectedItemsBottomSheet();
                                },
                              );
                            }).toList(),
                          ),
                        ],

                        // Empty state
                        if (_selectedIngredients.isEmpty && _selectedGlass.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    "No items selected",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text("Cancel"),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: (_selectedIngredients.isEmpty && _selectedGlass.isEmpty)
                              ? null
                              : () {
                            var stat = Hive.box('stats').get('used_creator', defaultValue: 0);
                            stat = stat + 1;
                            Hive.box('stats').put('used_creator', stat);
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Mixer(
                                  selectedGlass: _selectedGlass,
                                  selectedIngredients: _selectedIngredients,
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.auto_awesome),
                          label: Text("Continue to Mix"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
          _showSelectedItemsBottomSheet,
        label: const Text("Mix up..."),
        icon: const Icon(Icons.auto_awesome),
      ),
      appBar: AppBar(
        title: Column(
          children: [
            Text("Creator"),
            Text("Select ingredients and glasses", style: TextStyle(fontSize: 12))
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Ingredients"),
            Tab(text: "Glass")
          ],
        )
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder(
              future: cocktailsAPI.getIngredients(perPage: 600, sort: "+name"),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var ing = snapshot.data as Map;

                  if (allIngredients.isEmpty) {
                    allIngredients = ing['data'];
                    filteredItems = ing['data'];
                  }


                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: filterItems
                          ),
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(filteredItems[index]['name']),
                              trailing: Checkbox(value: _selectedIngredients.contains(filteredItems[index]['id']), onChanged: (value) {
                                setState(() {
                                  if (value!) {
                                    _selectedIngredients.add(filteredItems[index]['id']);
                                  } else {
                                    _selectedIngredients.remove(filteredItems[index]['id']);
                                  }
                                }
                              );}),
                            );
                    
                          }
                    
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }
          ),
          FutureBuilder(
              future: cocktailsAPI.getCocktailGlasses(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var ing = snapshot.data as Map;
                  return ListView.builder(
                      itemCount: ing['data'].length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(ing['data'][index]),
                          trailing: Checkbox(value: _selectedGlass.contains(ing['data'][index]), onChanged: (value) {
                            setState(() {
                              if (value!) {
                                _selectedGlass.add(ing['data'][index]);
                              } else {
                                _selectedGlass.remove(ing['data'][index]);
                              }
                            }
                            );}),
                        );

                      }

                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }
          ),
        ],
      )
    );
  }
}
