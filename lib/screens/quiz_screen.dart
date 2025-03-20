import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> questions = [];
  int currentIndex = 0;
  int score = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('https://opentdb.com/api.php?amount=5&type=multiple'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => questions = data['results']);
      } else {
        throw Exception("Failed to load quiz questions");
      }
    } catch (error) {
      print("Error fetching quiz: $error");
    }
    setState(() => isLoading = false);
  }

  void checkAnswer(String selectedAnswer) {
    String correctAnswer = questions[currentIndex]['correct_answer'];
    if (selectedAnswer == correctAnswer) {
      setState(() => score++);
    }

    if (currentIndex < questions.length - 1) {
      setState(() => currentIndex++);
    } else {
      showResultDialog();
    }
  }

  void showResultDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Quiz Completed"),
        content: Text("You scored $score out of ${questions.length}"),
        actions: [
          TextButton(
            child: Text("Retry"),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentIndex = 0;
                score = 0;
                fetchQuestions();
              });
            },
          ),
          TextButton(
            child: Text("Close"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz"),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchQuestions,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : questions.isEmpty
              ? Center(child: Text("No quiz data available."))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Question ${currentIndex + 1} of ${questions.length}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        questions[currentIndex]['question'],
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 20),
                      ...getShuffledOptions().map((option) {
                        return GestureDetector(
                          onTap: () => checkAnswer(option),
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            color: Colors.red.shade100,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                option,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
    );
  }

  List<String> getShuffledOptions() {
    List<String> options = List<String>.from(questions[currentIndex]['incorrect_answers']);
    options.add(questions[currentIndex]['correct_answer']);
    options.shuffle();
    return options;
  }
}
