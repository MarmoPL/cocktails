import 'package:dio/dio.dart';

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


  Future<Map> getIngredients({
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
    return response.data as Map;
  }

  Future<List<String>> getIngredientTypes() async {
    final response = await _dio.get('/ingredients/types');
    return List<String>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> getCocktails({
    List<int>? ids,
    int? perPage,
    String? name,
    List<int>? ingredientId,
    String? glass
  }) async {
    final queryParams = <String, dynamic>{};

    if (ids != null && ids.isNotEmpty) {
      queryParams['id[]'] = ids;
    }

    if (glass != null) {
      queryParams['glass'] = glass;
    }

    queryParams['ingredients'] = 1;


    if (ingredientId != null && ingredientId.isNotEmpty) {
      queryParams['ingredientId[]'] = ingredientId;
    }

    if (name != null) {
      queryParams['name'] = name;
    }
    if (perPage != null) {
      queryParams['perPage'] = perPage;
    }
    try {

      final response = await _dio.get(
        '/cocktails',
        queryParameters: queryParams,
        options: Options(
          listFormat: ListFormat.multiCompatible,
        ),
      );
      return response.data as Map<String, dynamic>;

    } on DioException catch (e) {
      print('Error: $e');
      rethrow;

    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<Map> getCocktail(int id) async {
    final response = await _dio.get('/cocktails/$id');
    return response.data;
  }

  Future<Map> getCocktailGlasses() async {
    final response = await _dio.get('/cocktails/glasses');
    return response.data;
  }

  Future<Map> getCocktailCategories() async {
    final response = await _dio.get('/cocktails/categories');
    return response.data;
  }
}
