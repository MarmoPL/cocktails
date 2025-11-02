import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'API/api.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'API/cache.dart';
import 'Home.dart';
import 'API/ThemeProvider.dart';


void main() async {
  await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();
  await cocktailRepository.init();

  var favTest = await Hive.openBox('favourites');
  if (!favTest.containsKey("ids")) {
    favTest.put("ids", []);
  }

  await Hive.openBox('settings');
  var stats = await Hive.openBox('stats');
  if (!stats.containsKey("opened")) {
    favTest.put("opened", 0);
  }
  if (!stats.containsKey("used_creator")) {
    favTest.put("used_creator", 0);
  }

  runApp(const ProviderScope(child: MyApp()));
}

var cocktailRepository = CocktailRepository(CocktailsApiClient());
var cocktailsAPI = CocktailsApiClient();

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Cocktails',
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Home(),
    );
  }
}