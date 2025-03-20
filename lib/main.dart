import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:task2/screens/news_screen.dart';
import 'package:task2/screens/weather_screen.dart';
import 'package:task2/screens/recipe_screen.dart';
import 'package:task2/screens/quotes_screen.dart';
import 'package:task2/screens/quiz_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Multi-API App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, String> topResponses = {}; // Store top API responses
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    // Fetch all API data
    await Future.wait([
      fetchNews(),
      fetchWeather(),
      fetchRecipe(),
      fetchQuote(),
      fetchQuiz(),
    ]);

    setState(() => isLoading = false);
  }

  Future<void> fetchNews() async {
    try {
      final response = await http.get(Uri.parse("https://newsapi.org/v2/top-headlines?country=us&apiKey=2767be0ed245459eb6f86bbdcc2398ab"));
      final data = json.decode(response.body);
      if (data['articles'] != null && data['articles'].isNotEmpty) {
        topResponses['News'] = data['articles'][0]['title'];
      }
    } catch (e) {
      topResponses['News'] = "Error fetching news";
    }
  }

  Future<void> fetchWeather() async {
    final apiKey = "8f26a3e5cfb44543959172649252003"; 
    final city = "Mumbai";
    try {
      final response = await http.get(Uri.parse("https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city"));
      final data = json.decode(response.body);
      topResponses['Weather'] = "${data['current']['temp_c']}°C in ${data['location']['name']}";
    } catch (e) {
      topResponses['Weather'] = "Error fetching weather";
    }
  }

  Future<void> fetchRecipe() async {
    try {
      final response = await http.get(Uri.parse("https://www.themealdb.com/api/json/v1/1/search.php?s="));
      final data = json.decode(response.body);
      topResponses['Recipes'] = data['meals'][0]['strMeal'];
      print(topResponses['Recipe']);
    } catch (e) {
      topResponses['Recipe'] = "Error fetching recipe";
    }
  }

  Future<void> fetchQuote() async {
    try {
      final response = await http.get(Uri.parse("https://dummyjson.com/quotes"));
      final data = json.decode(response.body);
      if (data['quotes'] != null && data['quotes'].isNotEmpty) {
        topResponses['Quotes'] = "\"${data['quotes'][0]['quote']}\"";
      }
    } catch (e) {
      topResponses['Quotes'] = "Error fetching quotes";
    }
  }

  Future<void> fetchQuiz() async {
    try {
      final response = await http.get(Uri.parse("https://opentdb.com/api.php?amount=1&type=multiple"));
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        topResponses['Quiz'] = data['results'][0]['question'];
      }
    } catch (e) {
      topResponses['Quiz'] = "Error fetching quiz";
    }
  }

  final List<Map<String, dynamic>> apiScreens = [
    {"title": "News", "icon": Icons.article, "screen": NewsScreen(), "color": Colors.blue},
    {"title": "Weather", "icon": Icons.wb_sunny, "screen": WeatherScreen(), "color": Colors.orange},
    {"title": "Recipes", "icon": Icons.fastfood, "screen": RecipeScreen(), "color": Colors.green},
    {"title": "Quotes", "icon": Icons.format_quote, "screen": QuotesScreen(), "color": Colors.purple},
    {"title": "Quiz", "icon": Icons.quiz, "screen": QuizScreen(), "color": Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 50),
            Text(
              "Explore APIs",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            isLoading
                ? Expanded(child: Center(child: CircularProgressIndicator()))
                : Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: apiScreens.length,
                      itemBuilder: (context, index) {
                        return AnimatedCard(apiScreens[index], topResponses);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class AnimatedCard extends StatelessWidget {
  final Map<String, dynamic> apiScreen;
  final Map<String, String> topResponses;

  AnimatedCard(this.apiScreen, this.topResponses);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => apiScreen['screen'],
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
        ),
      ),
      child: Card(
        elevation: 6,
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: apiScreen['color'].withOpacity(0.9),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          leading: Icon(apiScreen['icon'], size: 40, color: Colors.white),
          title: Text(
            apiScreen['title'],
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          subtitle: Text(
            topResponses[apiScreen['title']] ?? "Loading...",
            style: TextStyle(fontSize: 16, color: Colors.white70),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
        ),
      ),
    );
  }
}
