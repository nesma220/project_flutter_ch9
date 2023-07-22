import 'dart:developer';
import 'package:http/http.dart';
import 'package:chopper/chopper.dart';




const String apiId = '6139de6a';

const String apiKey = '9f9fcbe4e2766c0f985ff9ad9bbce2d0';

const String apiUrl = 'https://api.edamam.com/search';

class RecipeService {
  Future getData(String url) async {
    final response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      log(response.body);
    }
  }

  Future<dynamic> getRecipes(String query, int from, int to) async {
    final recipeData = await getData(
        '$apiUrl?app_id=$apiId&app_key=$apiKey&q=$query&from=$from&to=$to');
    return recipeData;
  }
}




@ChopperApi()
abstract class RecipeService extends ChopperService{
  @Get (path : 'search')
Future<Response<Result<APIRecipeQuery>>> queryRecipes(
  @Query('q') String query, @Query('from') int from,
@Query('to') int to);
// TODO: Add create()

}

// TODO: Add _addQuery()
