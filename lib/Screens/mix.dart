import 'package:cocktails/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'mixed.dart';

Future<Map> createCocktails(List<int>? sI, List<String>? sG) async {
  List<Map<String, dynamic>> cocktails = [];

  List<int> selectedIngredients = sI ?? [];
  List<String> selectedGlasses = sG ?? [];

  if (selectedIngredients.isEmpty && selectedGlasses.isEmpty) {
    return {
      'cocktails': [],
      'total': 0,
      'best_best_match': null,
    };
  }

  List<List<int>> ingredientCombinations = selectedIngredients.isEmpty
      ? [[]]
      : _generateCombinations(selectedIngredients);

  Map<String, List<dynamic>> apiCache = {};

  List<String?> glassesToProcess = selectedGlasses.isEmpty ? [null] : selectedGlasses;

  List<Map<String, dynamic>> allBestMatches = [];

  for (String? glass in glassesToProcess) {
    String cacheKey = glass ?? 'no_glass';

    if (!apiCache.containsKey(cacheKey)) {
      var response = await cocktailsAPI.getCocktails(
        glass: glass,
        ingredientId: selectedIngredients.isEmpty ? null : selectedIngredients,
      );
      apiCache[cacheKey] = response['data'] ?? [];
    }

    List<dynamic> glassResults = apiCache[cacheKey]!;

    for (List<int> ingredients in ingredientCombinations) {
      double compatibility = selectedIngredients.isEmpty
          ? 100.0
          : (ingredients.length / selectedIngredients.length) * 100;

      List<dynamic> matchingCocktails;

      if (ingredients.isEmpty) {
        matchingCocktails = glassResults;
      } else {
        matchingCocktails = glassResults.where((cocktail) {
          List<int> cocktailIngredientIds = (cocktail['ingredients'] as List)
              .map((ing) => ing['id'] as int)
              .toList();

          bool allIngredientsMatch = ingredients.every(
                  (ingId) => cocktailIngredientIds.contains(ingId)
          );

          return allIngredientsMatch;
        }).toList();
      }

      var bestMatchResult = _findBestMatch(
        matchingCocktails,
        ingredients,
        selectedIngredients,
      );

      Map<String, dynamic>? bestMatch = bestMatchResult['cocktail'];
      double bestMatchScore = bestMatchResult['score'];

      if (bestMatch != null) {
        allBestMatches.add({
          'cocktail': bestMatch,
          'score': bestMatchScore,
          'compatibility': compatibility,
          'ingredients': ingredients,
          'glass': glass,
        });
      }

      cocktails.add({
        'ingredients': ingredients,
        'glass': glass,
        'results': matchingCocktails,
        'compatibility': compatibility.roundToDouble(),
        'best_match': bestMatch,
      });
    }
  }

  Map<String, dynamic>? bestBestMatch = _findBestBestMatch(
    allBestMatches,
    selectedIngredients,
  );

  return {
    'cocktails': cocktails,
    'total': cocktails.length,
    'best_best_match': bestBestMatch,
  };
}

Map<String, dynamic> _findBestMatch(
    List<dynamic> cocktails,
    List<int> combinationIngredients,
    List<int> allSelectedIngredients,
    ) {
  if (cocktails.isEmpty) {
    return {
      'cocktail': null,
      'score': 0.0,
    };
  }

  Map<String, dynamic>? bestMatch;
  double bestScore = -1;

  for (var cocktail in cocktails) {
    List<int> cocktailIngredientIds = (cocktail['ingredients'] as List)
        .map((ing) => ing['id'] as int)
        .toList();

    int matchedIngredients = combinationIngredients
        .where((id) => cocktailIngredientIds.contains(id))
        .length;

    double primaryScore = combinationIngredients.isEmpty
        ? 1.0
        : matchedIngredients / combinationIngredients.length;

    int extraIngredients = cocktailIngredientIds.length - matchedIngredients;
    double secondaryScore = 1 / (extraIngredients + 1);

    double score = primaryScore * 10 + secondaryScore;

    if (score > bestScore) {
      bestScore = score;
      bestMatch = cocktail;
    }
  }

  return {
    'cocktail': bestMatch,
    'score': bestScore,
  };
}

Map<String, dynamic>? _findBestBestMatch(
    List<Map<String, dynamic>> allBestMatches,
    List<int> selectedIngredients,
    ) {
  if (allBestMatches.isEmpty) return null;

  Map<String, dynamic>? bestBest;
  double bestBestScore = -1;

  for (var matchData in allBestMatches) {
    var cocktail = matchData['cocktail'];
    List<int> combinationIngredients = matchData['ingredients'];
    double compatibility = matchData['compatibility'];
    double individualScore = matchData['score'];

    List<int> cocktailIngredientIds = (cocktail['ingredients'] as List)
        .map((ing) => ing['id'] as int)
        .toList();

    double compatibilityScore = compatibility / 100.0;

    int usedSelectedIngredients = selectedIngredients
        .where((id) => cocktailIngredientIds.contains(id))
        .length;
    double usageScore = selectedIngredients.isEmpty
        ? 1.0
        : usedSelectedIngredients / selectedIngredients.length;

    double simplicityScore = 1 / (cocktailIngredientIds.length + 1);

    double matchQualityScore = individualScore / 11.0;

    double finalScore =
        (usageScore * 40) +
            (compatibilityScore * 30) +
            (matchQualityScore * 20) +
            (simplicityScore * 10);

    if (finalScore > bestBestScore) {
      bestBestScore = finalScore;
      bestBest = {
        'cocktail': cocktail,
        'matched_ingredients': combinationIngredients,
        'glass': matchData['glass'],
        'compatibility': compatibility,
        'score': finalScore,
        'ingredients_used': usedSelectedIngredients,
        'total_ingredients': cocktailIngredientIds.length,
      };
    }
  }

  return bestBest;
}

List<List<int>> _generateCombinations(List<int> items) {
  if (items.isEmpty) return [[]];

  List<List<int>> result = [];
  int n = items.length;

  for (int i = 1; i < (1 << n); i++) {
    List<int> subset = [];
    for (int j = 0; j < n; j++) {
      if ((i & (1 << j)) != 0) {
        subset.add(items[j]);
      }
    }
    result.add(subset);
  }

  return result;
}

class Mixer extends StatefulWidget {
  final List<int> selectedIngredients;

  final List<String> selectedGlass;

  const Mixer({super.key, required this.selectedIngredients, required this.selectedGlass});

  @override
  State<Mixer> createState() => _MixerState();
}

class _MixerState extends State<Mixer> {


  @override
  Widget build(BuildContext context) {


    const Widget title = Text(
      'Mixing the best cocktails...',
      style: TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 40,
        color: Color(0xFF666870),
        height: 1,
        letterSpacing: -1,
      ),
    );


    final animatedTitle = title
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: Colors.purple)
        .shimmer(duration: 800.ms, color: Colors.blue)
        .shimmer(duration: 600.ms, color: Colors.green)
        .animate()
        .fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad);

    List<Widget> progress = [
      Container(
          padding: const EdgeInsets.all(8),
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.search, color: Color(0xFF80DDFF)),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  "Searching for best matches",
                ),
              ),
              const SizedBox(width: 10),
              const SizedBox(width: 8, height: 8, child: CircularProgressIndicator())
            ],
          ),
        ),
      Container(
        padding: const EdgeInsets.all(8),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.query_stats, color: Color(0xFF80DDFF)),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                "Considering multiple combinations",
              ),
            ),
            const SizedBox(width: 10),
            const SizedBox(width: 8, height: 8, child: CircularProgressIndicator())
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.queue, color: Color(0xFF80DDFF)),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                "Selecting the best one",
              ),
            ),
            const SizedBox(width: 10),
            const SizedBox(width: 8, height: 8, child: CircularProgressIndicator())
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.question_mark, color: Color(0xFF80DDFF)),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                "Thinking about what to drink this Friday...",
              ),
            ),
            const SizedBox(width: 10),
            const SizedBox(width: 8, height: 8, child: CircularProgressIndicator())
          ],
        ),
      )
      ];

    progress = progress
        .animate(interval: 1500.ms)
        .fadeIn(duration: 900.ms, delay: 300.ms)
        .shimmer(blendMode: BlendMode.srcOver, color: Colors.white12)
        .move(begin: const Offset(-16, 0), curve: Curves.easeOutQuad);




    return Scaffold(
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: animatedTitle,
          ),
          ...progress,
          FutureBuilder(
              future: createCocktails(widget.selectedIngredients, widget.selectedGlass),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                    Future.delayed(const Duration(seconds: 9), () {
                    if (context.mounted) {
                    Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                    builder: (context) => Mixed(results: snapshot.data as Map)
                    )
                    );
                    }});
                return const SizedBox.shrink();
                } else {
                  return const SizedBox.shrink();
                }
              }
          )
        ],
      ))
    );
  }
}
