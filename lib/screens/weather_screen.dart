import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  TextEditingController cityController = TextEditingController();
  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String errorMessage = '';
  final String defaultCity = "Mumbai"; // Default city

  @override
  void initState() {
    super.initState();
    fetchWeather(defaultCity); // Load Mumbai weather by default
  }

  Future<void> fetchWeather(String city) async {
    if (city.isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final apiKey = "8f26a3e5cfb44543959172649252003";
    final url = "https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() => weatherData = json.decode(response.body));
      } else {
        setState(() => errorMessage = "City not found! Try again.");
      }
    } catch (error) {
      setState(() => errorMessage = "Failed to fetch weather. Check connection.");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Weather App"), backgroundColor: Colors.blue),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // City Input Field
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: "Enter city",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => fetchWeather(cityController.text.trim()),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Loading Indicator
            if (isLoading) CircularProgressIndicator(),

            // Error Message
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 18)),

            // Weather Info
            if (weatherData != null) weatherWidget(),
          ],
        ),
      ),
    );
  }

  Widget weatherWidget() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              weatherData!['location']['name'],
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Image.network("https:${weatherData!['current']['condition']['icon']}", width: 80),
            SizedBox(height: 10),

            Text(
              "${weatherData!['current']['temp_c']}°C",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 5),

            Text(
              weatherData!['current']['condition']['text'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            Divider(),

            // Extra Weather Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                weatherDetail("Humidity", "${weatherData!['current']['humidity']}%"),
                weatherDetail("Wind", "${weatherData!['current']['wind_kph']} km/h"),
                weatherDetail("Feels Like", "${weatherData!['current']['feelslike_c']}°C"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget weatherDetail(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
      ],
    );
  }
}
