import 'package:cocktails/main.dart';
import 'package:cocktails/mix.dart';
import 'package:flutter/material.dart';

class Creator extends StatefulWidget {
  const Creator({super.key});

  @override
  State<Creator> createState() => _CreatorState();
}

class _CreatorState extends State<Creator> with SingleTickerProviderStateMixin  {
  late TabController _tabController;

  List<int> _selectedIngredients = [];
  List<String> _selectedGlass = [];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Mixer(selectedGlass: _selectedGlass, selectedIngredients: _selectedIngredients,),
            ),
          );
        },
        label: const Text("Mix up..."),
        icon: const Icon(Icons.auto_awesome),
      ),
      appBar: AppBar(
        title: Text("Creator"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Ingridients"),
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
                  return ListView.builder(
                    itemCount: ing['data'].length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(ing['data'][index]['name']),
                        trailing: Checkbox(value: _selectedIngredients.contains(ing['data'][index]['id']), onChanged: (value) {
                          setState(() {
                            if (value!) {
                              _selectedIngredients.add(ing['data'][index]['id']);
                            } else {
                              _selectedIngredients.remove(ing['data'][index]['id']);
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
