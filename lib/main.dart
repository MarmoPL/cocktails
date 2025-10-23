import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api.dart';

void main() {

  runApp(const ProviderScope(child: MyApp()));
}

final cocktailsApiProvider = Provider<CocktailsApiClient>((ref) {
  return CocktailsApiClient();
});

final cocktailsProvider = FutureProvider<List<Cocktail>>((ref) async {
  final api = ref.watch(cocktailsApiProvider);
  final response = await api.getCocktails();
  return response.data;
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Cocktails',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

  @override
  Widget build(BuildContext context) {
    final cocktailsAsync = ref.watch(cocktailsProvider);

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: cocktailsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) => Text(error.toString()),
              data: (cocktails) => ListView.builder(
                itemCount: cocktails.length,
                itemBuilder: (context, index) {
                  final cocktail = cocktails[index];
                  return ListTile(
                    title: Text(cocktail.name),
                    subtitle: Text(cocktail.category ?? 'No category'),);
                }
              )
            )
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: Icon(Icons.search)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border_outlined)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.water_drop)),
          ],
        ),
      ),
    );
  }
}