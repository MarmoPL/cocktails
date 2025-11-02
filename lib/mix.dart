import 'package:cocktails/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'mixed.dart';

Future<Map> createCocktails(List<int>? sI, List<String>? sG) async {
  List<Map<String, dynamic>> cocktails = [];

  // Handle empty or null inputs
  List<int> selectedIngredients = sI ?? [];
  List<String> selectedGlasses = sG ?? [];

  // If no ingredients and no glasses, return empty result
  if (selectedIngredients.isEmpty && selectedGlasses.isEmpty) {
    return {
      'cocktails': [],
      'total': 0,
      'best_best_match': null,
    };
  }

  // Generate all non-empty subsets of ingredients (or empty list if no ingredients)
  List<List<int>> ingredientCombinations = selectedIngredients.isEmpty
      ? [[]] // Empty combination when no ingredients selected
      : _generateCombinations(selectedIngredients);

  // Cache API results to avoid duplicate calls
  Map<String, List<dynamic>> apiCache = {};

  // If no glasses provided, use null (no glass filter)
  List<String?> glassesToProcess = selectedGlasses.isEmpty ? [null] : selectedGlasses;

  // Track all best matches to find the best of the best
  List<Map<String, dynamic>> allBestMatches = [];

  // For each glass (or null), fetch cocktails only once
  for (String? glass in glassesToProcess) {
    String cacheKey = glass ?? 'no_glass';

    // Fetch cocktails for this glass with selected ingredients
    if (!apiCache.containsKey(cacheKey)) {
      var response = await cocktailsAPI.getCocktails(
        glass: glass,
        ingredientId: selectedIngredients.isEmpty ? null : selectedIngredients,
      );
      apiCache[cacheKey] = response['data'] ?? [];
    }

    List<dynamic> glassResults = apiCache[cacheKey]!;

    // For each ingredient combination
    for (List<int> ingredients in ingredientCombinations) {
      // Calculate compatibility percentage
      double compatibility = selectedIngredients.isEmpty
          ? 100.0
          : (ingredients.length / selectedIngredients.length) * 100;

      // Get matching cocktails
      List<dynamic> matchingCocktails;

      if (ingredients.isEmpty) {
        // If no ingredients filter, return all results
        matchingCocktails = glassResults;
      } else {
        // Filter cocktails that contain ALL ingredients from this combination
        matchingCocktails = glassResults.where((cocktail) {
          List<int> cocktailIngredientIds = (cocktail['ingredients'] as List)
              .map((ing) => ing['id'] as int)
              .toList();

          // Check if the cocktail contains ALL ingredients from this combination
          bool allIngredientsMatch = ingredients.every(
                  (ingId) => cocktailIngredientIds.contains(ingId)
          );

          return allIngredientsMatch;
        }).toList();
      }

      // Find best match for this combination
      var bestMatchResult = _findBestMatch(
        matchingCocktails,
        ingredients,
        selectedIngredients,
      );

      Map<String, dynamic>? bestMatch = bestMatchResult['cocktail'];
      double bestMatchScore = bestMatchResult['score'];

      // Store best match with its metadata for global comparison
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

  // Find the best of the best matches
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

// Find the best matching cocktail based on ingredient match percentage
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

    // Calculate match score based on:
    // 1. How many of the combination ingredients are used (primary)
    // 2. How few extra ingredients the cocktail has (secondary)
    int matchedIngredients = combinationIngredients
        .where((id) => cocktailIngredientIds.contains(id))
        .length;

    // Primary score: percentage of combination ingredients matched
    double primaryScore = combinationIngredients.isEmpty
        ? 1.0
        : matchedIngredients / combinationIngredients.length;

    // Secondary score: inverse of extra ingredients (prefer simpler cocktails)
    // Extra ingredients = total ingredients - matched ingredients
    int extraIngredients = cocktailIngredientIds.length - matchedIngredients;
    double secondaryScore = 1 / (extraIngredients + 1); // +1 to avoid division by zero

    // Combined score (primary is weighted more heavily)
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

// Find the best of all best matches across all combinations
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

    // Calculate comprehensive score based on multiple factors:

    // 1. Compatibility (what % of selected ingredients are in this combination)
    double compatibilityScore = compatibility / 100.0;

    // 2. How many selected ingredients the cocktail actually uses
    int usedSelectedIngredients = selectedIngredients
        .where((id) => cocktailIngredientIds.contains(id))
        .length;
    double usageScore = selectedIngredients.isEmpty
        ? 1.0
        : usedSelectedIngredients / selectedIngredients.length;

    // 3. Simplicity (fewer total ingredients is better)
    double simplicityScore = 1 / (cocktailIngredientIds.length + 1);

    // 4. Individual match quality from _findBestMatch
    double matchQualityScore = individualScore / 11.0; // Normalize (max is ~11)

    // Combined weighted score:
    // - Usage score (40%): Prioritize cocktails using more of the selected ingredients
    // - Compatibility (30%): Prefer combinations with higher ingredient coverage
    // - Match quality (20%): Consider how well it matches within its combination
    // - Simplicity (10%): Slight preference for simpler recipes
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

// Helper function to generate all non-empty subsets (combinations)
List<List<int>> _generateCombinations(List<int> items) {
  if (items.isEmpty) return [[]];

  List<List<int>> result = [];
  int n = items.length;

  // Generate all subsets using bit manipulation
  // Start from 1 to exclude empty set, go to 2^n - 1
  for (int i = 1; i < (1 << n); i++) {
    List<int> subset = [];
    for (int j = 0; j < n; j++) {
      // Check if j-th bit is set
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

    print(widget.selectedIngredients);
    print(widget.selectedGlass);


    Widget title = const Text(
      'Mixing the best cocktails...',
      style: TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 40,
        color: Color(0xFF666870),
        height: 1,
        letterSpacing: -1,
      ),
    );

    // here's an interesting little trick, we can nest Animate to have
    // effects that repeat and ones that only run once on the same item:
    title = title
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: Colors.purple)
        .shimmer(duration: 800.ms, color: Colors.blue)
        .shimmer(duration: 600.ms, color: Colors.green)
        .animate() // this wraps the previous Animate in another Animate
        .fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad);

    List<Widget> progress = [
      Container(
          padding: const EdgeInsets.all(8),
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.search, color: const Color(0xFF80DDFF)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "Searching for best matches",
                ),
              ),
              SizedBox(width: 10),
              SizedBox(width: 8, height: 8, child: CircularProgressIndicator())
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
            Icon(Icons.query_stats, color: const Color(0xFF80DDFF)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "Considering multiple combinations",
              ),
            ),
            SizedBox(width: 10),
            SizedBox(width: 8, height: 8, child: CircularProgressIndicator())
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
            Icon(Icons.queue, color: const Color(0xFF80DDFF)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "Selecting the best one",
              ),
            ),
            SizedBox(width: 10),
            SizedBox(width: 8, height: 8, child: CircularProgressIndicator())
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
            Icon(Icons.question_mark, color: const Color(0xFF80DDFF)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "Thinking about, what to drink this friday...",
              ),
            ),
            SizedBox(width: 10),
            SizedBox(width: 8, height: 8, child: CircularProgressIndicator())
          ],
        ),
      )
      ];

    // Animate all of the info items in the list:
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
            child: title,
          ),
          ...progress,
          FutureBuilder(
              future: createCocktails(widget.selectedIngredients, widget.selectedGlass),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                    Future.delayed(const Duration(seconds: 9), () {
                    if (context.mounted) {
                    // Use pushReplacement to replace Mix screen with Mixed screen
                    // This ensures back gesture goes to Creator, not Mix
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
