import 'package:hive_flutter/hive_flutter.dart';
import 'api.dart';

class CocktailRepository {
  final CocktailsApiClient _apiClient;
  late Box<dynamic> _cocktailsListCache;
  late Box<dynamic> _cocktailDetailsCache;

  CocktailRepository(this._apiClient);

  Future<void> init() async {
    _cocktailsListCache = await Hive.openBox('cocktails_list_cache');
    _cocktailDetailsCache = await Hive.openBox('cocktail_details_cache');
  }

  String _getCocktailsListCacheKey({
    List<int>? ids,
    int? perPage,
    String? name,
  }) {
    final parts = <String>[];
    if (ids != null && ids.isNotEmpty) {
      parts.add('ids:${ids.join(',')}');
    }
    if (perPage != null) {
      parts.add('perPage:$perPage');
    }
    if (name != null) {
      parts.add('name:$name');
    }
    return parts.isEmpty ? 'default' : parts.join('|');
  }

  Future<Map<String, dynamic>> getCocktails({
    List<int>? ids,
    int? perPage,
    String? name,
  }) async {
    final cacheKey = _getCocktailsListCacheKey(ids: ids, perPage: perPage, name: name);

    if (_cocktailsListCache.containsKey(cacheKey)) {
      final cached = _cocktailsListCache.get(cacheKey);
      return Map<String, dynamic>.from(cached as Map);
    }

    final response = await _apiClient.getCocktails(
      ids: ids,
      perPage: perPage,
      name: name,
    );

    await _cocktailsListCache.put(cacheKey, response);

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> getCocktail(int id) async {
    final cacheKey = 'cocktail_$id';

    if (_cocktailDetailsCache.containsKey(cacheKey)) {
      print('getting from cache');
      final cached = _cocktailDetailsCache.get(cacheKey);
      return Map<String, dynamic>.from(cached as Map);
    }

    final response = await _apiClient.getCocktail(id);

    await _cocktailDetailsCache.put(cacheKey, response);

    return Map<String, dynamic>.from(response);
  }

  Future<void> clearCache() async {
    await _cocktailsListCache.clear();
    await _cocktailDetailsCache.clear();
  }

  Future<void> clearCocktailsListCache() async {
    await _cocktailsListCache.clear();
  }

  Future<void> clearCocktailCache(int id) async {
    final cacheKey = 'cocktail_$id';
    await _cocktailDetailsCache.delete(cacheKey);
  }

}