import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_apprentice_chpter9/network/recipe_model.dart';
import 'package:flutter_apprentice_chpter9/ui/recipe_card.dart';
import 'package:flutter_apprentice_chpter9/ui/recipes/recipe_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_dropdown.dart';
import '../colors.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({Key? key}) : super(key: key);

  @override
  State createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  static const String prefSearchKey = 'previousSearches';

  late TextEditingController searchTextController;
  final ScrollController _scrollController = ScrollController();
  List currentSearchList = [];
  int currentCount = 0;
  int currentStartPosition = 0;
  int currentEndPosition = 20;
  int pageCount = 20;
  bool hasMore = false;
  bool loading = false;
  bool inErrorState = false;
  List<String> previousSearches = <String>[];
  APIRecipeQuery? _currentRecipes1;

  @override
  void initState() {
    super.initState();
    loadRecipes();

    getPreviousSearches();

    searchTextController = TextEditingController(text: '');
    _scrollController.addListener(() {
      final triggerFetchMoreSize =
          0.7 * _scrollController.position.maxScrollExtent;

      if (_scrollController.position.pixels > triggerFetchMoreSize) {
        if (hasMore &&
            currentEndPosition < currentCount &&
            !loading &&
            !inErrorState) {
          setState(() {
            loading = true;
            currentStartPosition = currentEndPosition;
            currentEndPosition =
                min(currentStartPosition + pageCount, currentCount);
          });
        }
      }
    });
  }

  Future loadRecipes() async {
    final jsonString = await rootBundle.loadString('assets/recipes1.json');
    setState(() {
      _currentRecipes1 = APIRecipeQuery.fromJson(jsonDecode(jsonString));
    });
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  void savePreviousSearch() async {
    final pref = await SharedPreferences.getInstance();
    //2
    pref.setStringList(prefSearchKey, previousSearches);
  }

  void getPreviousSearches() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(prefSearchKey)) {
      final searces = prefs.getStringList(prefSearchKey);
      if (searces != null) {
        previousSearches = searces;
      } else {
        previousSearches = <String>[];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildSearchCard(),
            _buildRecipeLoader(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            // Replace
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                final currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
            ),
            const SizedBox(
              width: 6.0,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                      // 3
                      child: TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Search'),
                    autofocus: false, // 4
                    textInputAction: TextInputAction.done, // 5
                    onSubmitted: (value) {
                      startSearch(searchTextController.text);
                    },
                    controller: searchTextController,
                  )),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: lightGrey,
                    ),
                    onSelected: (String value) {
                      searchTextController.text = value;
                      startSearch(searchTextController.text);
                    },
                      itemBuilder: (BuildContext context) {
                      return previousSearches
                          .map<CustomDropdownMenuItem<String>>((String value) {
                        return CustomDropdownMenuItem<String>(
                          text: value,
                          value: value,
                          callback: () {
                            setState(() {
                              previousSearches.remove(value);
                              savePreviousSearch();
                              Navigator.pop(context);
                            });
                          },
                        );
                      }).toList();
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

//   الدالة
//البحث وتحديث الواجهة المستخدمة بناءً على القيمة المدخلة.
  void startSearch(String value) {
    setState(() {
      // currentSearchList.clear();
      currentCount = 0;
      currentEndPosition = 0;
      hasMore = true;

      //لإزالة الفراغات الزائدة في بداية
      value = value.trim();

      if (!previousSearches.contains(value)) {
        previousSearches.add(value);
        savePreviousSearch();
      }
    });
  }

  Widget _buildRecipeLoader(BuildContext context) {
    if (_currentRecipes1 == null || _currentRecipes1?.hits == null) {
      return Container();
    }
    return Flexible(
      child: ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Center(
              child: _buildRecipeCard(context, _currentRecipes1!.hits, 0));
        },
      ),
    );
  }

  Widget _buildRecipeCard(
      BuildContext topLevelContext, List<APIHits> hits, int index) {
    final recipe = hits[index].recipe;
    return GestureDetector(
      onTap: () {
        Navigator.push(topLevelContext, MaterialPageRoute(
          builder: (context) {
            return const RecipeDetails();
          },
        ));
      },
      child: recipeStringCard(recipe.image, recipe.label),
    );
  }
}
