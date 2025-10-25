import 'package:dio/dio.dart';


// final cocktailsApiProvider = Provider<CocktailsApiClient>((ref) {
//   return CocktailsApiClient();
// });
/// Main API client for Solvro Cocktails API
class CocktailsApiClient {
  final Dio _dio;
  static const String baseUrl = 'https://cocktails.solvro.pl/api/v1';

  CocktailsApiClient({Dio? dio})
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ));

  // INGREDIENTS ENDPOINTS

  /// Fetch paginated list of ingredients with optional filtering and sorting
  Future<IngredientsResponse> getIngredients({
    int? id,
    List<int>? ids,
    int? idFrom,
    int? idTo,
    String? name,
    String? description,
    bool? alcohol,
    String? type,
    num? percentage,
    String? createdAt,
    String? updatedAt,
    String? sort,
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{};

    if (id != null) queryParams['id'] = id;
    if (ids != null) queryParams['id[]'] = ids;
    if (idFrom != null) queryParams['id[from]'] = idFrom;
    if (idTo != null) queryParams['id[to]'] = idTo;
    if (name != null) queryParams['name'] = name;
    if (description != null) queryParams['description'] = description;
    if (alcohol != null) queryParams['alcohol'] = alcohol;
    if (type != null) queryParams['type'] = type;
    if (percentage != null) queryParams['percentage'] = percentage;
    if (createdAt != null) queryParams['createdAt'] = createdAt;
    if (updatedAt != null) queryParams['updatedAt'] = updatedAt;
    if (sort != null) queryParams['sort'] = sort;
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['perPage'] = perPage;

    final response = await _dio.get('/ingredients', queryParameters: queryParams);
    return IngredientsResponse.fromJson(response.data);
  }

  /// Fetch a single ingredient by ID
  Future<Ingredient> getIngredient(int id) async {
    final response = await _dio.get('/ingredients/$id');
    return Ingredient.fromJson(response.data['data']);
  }

  /// Fetch list of ingredient types
  Future<List<String>> getIngredientTypes() async {
    final response = await _dio.get('/ingredients/types');
    return List<String>.from(response.data['data']);
  }

  // COCKTAILS ENDPOINTS

  /// Fetch paginated list of cocktails with optional filtering and sorting
  Future<Map> getCocktails({
    int? id,
    List<int>? ids,
    int? idFrom,
    int? idTo,
    String? name,
    String? instructions,
    bool? alcoholic,
    String? category,
    String? glass,
    String? createdAt,
    String? updatedAt,
    String? sort,
    num? ingredientId,
    bool? ingredients,
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, dynamic>{};

    if (id != null) queryParams['id'] = id;
    if (ids != null) queryParams['id[]'] = ids;
    if (idFrom != null) queryParams['id[from]'] = idFrom;
    if (idTo != null) queryParams['id[to]'] = idTo;
    if (name != null) queryParams['name'] = name;
    if (instructions != null) queryParams['instructions'] = instructions;
    if (alcoholic != null) queryParams['alcoholic'] = alcoholic;
    if (category != null) queryParams['category'] = category;
    if (glass != null) queryParams['glass'] = glass;
    if (createdAt != null) queryParams['createdAt'] = createdAt;
    if (updatedAt != null) queryParams['updatedAt'] = updatedAt;
    if (sort != null) queryParams['sort'] = sort;
    if (ingredientId != null) queryParams['ingredientId'] = ingredientId;
    if (ingredients != null) queryParams['ingredients'] = ingredients;
    if (page != null) queryParams['page'] = page;
    if (perPage != null) queryParams['perPage'] = perPage;

    final response = await _dio.get('/cocktails', queryParameters: queryParams);
    return response.data;
  }

  /// Fetch a single cocktail by ID with ingredients
  Future<Map> getCocktail(int id) async {
    final response = await _dio.get('/cocktails/$id');
    return response.data;
  }

  /// Fetch list of cocktail glasses
  Future<Map> getCocktailGlasses() async {
    final response = await _dio.get('/cocktails/glasses');
    return response.data;
  }

  /// Fetch list of cocktail categories
  Future<Map> getCocktailCategories() async {
    final response = await _dio.get('/cocktails/categories');
    return response.data;
  }
}

// MODELS

class Pagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final int firstPage;
  final String firstPageUrl;
  final String lastPageUrl;
  final String? nextPageUrl;
  final String? previousPageUrl;

  Pagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.firstPage,
    required this.firstPageUrl,
    required this.lastPageUrl,
    this.nextPageUrl,
    this.previousPageUrl,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json['total'],
    perPage: json['perPage'],
    currentPage: json['currentPage'],
    lastPage: json['lastPage'],
    firstPage: json['firstPage'],
    firstPageUrl: json['firstPageUrl'],
    lastPageUrl: json['lastPageUrl'],
    nextPageUrl: json['nextPageUrl'],
    previousPageUrl: json['previousPageUrl'],
  );
}

class Ingredient {
  final int id;
  final String name;
  final String? description;
  final bool? alcohol;
  final String? type;
  final num? percentage;
  final String? imageUrl;
  final String createdAt;
  final String updatedAt;

  Ingredient({
    required this.id,
    required this.name,
    this.description,
    this.alcohol,
    this.type,
    this.percentage,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    alcohol: json['alcohol'],
    type: json['type'],
    percentage: json['percentage'],
    imageUrl: json['imageUrl'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );
}

class IngredientWithMeasure extends Ingredient {
  final String? measure;

  IngredientWithMeasure({
    required super.id,
    required super.name,
    super.description,
    super.alcohol,
    super.type,
    super.percentage,
    super.imageUrl,
    required super.createdAt,
    required super.updatedAt,
    this.measure,
  });

  factory IngredientWithMeasure.fromJson(Map<String, dynamic> json) =>
      IngredientWithMeasure(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        alcohol: json['alcohol'],
        type: json['type'],
        percentage: json['percentage'],
        imageUrl: json['imageUrl'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        measure: json['measure'],
      );
}

class IngredientsResponse {
  final Pagination meta;
  final List<Ingredient> data;

  IngredientsResponse({
    required this.meta,
    required this.data,
  });

  factory IngredientsResponse.fromJson(Map<String, dynamic> json) =>
      IngredientsResponse(
        meta: Pagination.fromJson(json['meta']),
        data: (json['data'] as List)
            .map((e) => Ingredient.fromJson(e))
            .toList(),
      );
}

class Cocktail {
  final int id;
  final String name;
  final String? instructions;
  final bool alcoholic;
  final String? category;
  final String? glass;
  final String? imageUrl;
  final String createdAt;
  final String updatedAt;

  Cocktail({
    required this.id,
    required this.name,
    this.instructions,
    required this.alcoholic,
    this.category,
    this.glass,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cocktail.fromJson(Map<String, dynamic> json) => Cocktail(
    id: json['id'],
    name: json['name'],
    instructions: json['instructions'],
    alcoholic: json['alcoholic'],
    category: json['category'],
    glass: json['glass'],
    imageUrl: json['imageUrl'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
  );
}

class CocktailDetail extends Cocktail {
  final List<IngredientWithMeasure>? ingredients;

  CocktailDetail({
    required super.id,
    required super.name,
    super.instructions,
    required super.alcoholic,
    super.category,
    super.glass,
    super.imageUrl,
    required super.createdAt,
    required super.updatedAt,
    this.ingredients,
  });

  factory CocktailDetail.fromJson(Map<String, dynamic> json) => CocktailDetail(
    id: json['id'],
    name: json['name'],
    instructions: json['instructions'],
    alcoholic: json['alcoholic'],
    category: json['category'],
    glass: json['glass'],
    imageUrl: json['imageUrl'],
    createdAt: json['createdAt'],
    updatedAt: json['updatedAt'],
    ingredients: json['ingredients'] != null
        ? (json['ingredients'] as List)
        .map((e) => IngredientWithMeasure.fromJson(e))
        .toList()
        : null,
  );
}

class CocktailsResponse {
  final Pagination meta;
  final List<Cocktail> data;

  CocktailsResponse({
    required this.meta,
    required this.data,
  });

  factory CocktailsResponse.fromJson(Map<String, dynamic> json) =>
      CocktailsResponse(
        meta: Pagination.fromJson(json['meta']),
        data: (json['data'] as List)
            .map((e) => Cocktail.fromJson(e))
            .toList(),
      );
}