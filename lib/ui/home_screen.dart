import 'package:flutter/material.dart';
import '../model/weather_model.dart';
import '../service/api_service.dart';
import 'components/future_forecast_list_item.dart';
import 'components/hourly_weather_list_item.dart';
import 'components/todays_weather.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ApiService apiService = ApiService();
  final _textFieldController = TextEditingController();
  String queryText = "auto:ip";

  _showTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title: Text('Search Location',style: TextStyle(color: Colors.white),),
            content: TextField(
             // textDirection: TextDecoration(Colors.white),
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "search by city",hintStyle: TextStyle(color: Colors.white),

              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: Text("Cancel",style: TextStyle(color: Colors.white),),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: Text('OK',style: TextStyle(color: Colors.white),),
                  onPressed: () {
                    if (_textFieldController.text.isEmpty) {
                      return;
                    }
                    Navigator.pop(context, _textFieldController.text);
                  },
              ),
            ],
          );
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Flutter Weather App",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black12,
        actions: [
          IconButton(
              onPressed: () async {
                _textFieldController.clear();
                String text = await _showTextInputDialog(context);
                setState(() {
                  queryText = text;
                },
                );
              },
              icon: Icon(Icons.search,color: Colors.white,),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  queryText = "auto:ip";
                },
                );
              },
              icon: const Icon(Icons.my_location,color: Colors.white,),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              WeatherModel? weatherModel = snapshot.data;
              return SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    TodaysWeather(weatherModel: weatherModel),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          Hour? hour = weatherModel
                              ?.forecast?.forecastday?[0].hour?[index];

                          return HourlyWeatherListItem(
                            hour: hour,
                          );
                        },
                        itemCount: weatherModel
                                ?.forecast?.forecastday?[0].hour?.length ?? 0,
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                    Expanded(
                        child: ListView.builder(
                      itemBuilder: (context, index) {
                        return FutureForcastListItem(
                          forecastday:
                              weatherModel?.forecast?.forecastday?[index],
                        );
                      },
                      itemCount: weatherModel?.forecast?.forecastday?.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                    ),
                    )
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text("Error Has occurred"),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          future: apiService.getWeatherData(queryText),
        ),
      ),
    );
  }
}
