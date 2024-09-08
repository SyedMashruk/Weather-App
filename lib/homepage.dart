import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Map<String, dynamic>? weatherMap, forecastMap;
  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  Widget getWeatherIcon(int code, double size) {
    switch (code) {
      case >= 200 && < 300:
        return Image.asset(
          'assets/1.png',
          height: size,
          width: size,
        );
      case >= 300 && < 400:
        return Image.asset(
          'assets/2.png',
          height: size,
          width: size,
        );
      case >= 500 && < 600:
        return Image.asset(
          'assets/3.png',
          height: size,
          width: size,
        );
      case >= 600 && < 700:
        return Image.asset(
          'assets/4.png',
          height: size,
          width: size,
        );
      case >= 700 && < 800:
        return Image.asset(
          'assets/5.png',
          height: size,
          width: size,
        );
      case == 800:
        return Image.asset(
          'assets/6.png',
          height: size,
          width: size,
        );
      case > 800 && <= 804:
        return Image.asset(
          'assets/7.png',
          height: size,
          width: size,
        );
      default:
        return Image.asset(
          'assets/7.png',
          height: size,
          width: size,
        );
    }
  }

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    position = await Geolocator.getCurrentPosition();
    getWeatherData();
  }

  getWeatherData() async {
    var weather = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=992fd6e80facf77236de130be0d989f5&units=metric'));
    var forecast = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon=${position!.longitude}&appid=992fd6e80facf77236de130be0d989f5&units=metric'));

    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weather.body));
      forecastMap = Map<String, dynamic>.from(jsonDecode(forecast.body));
    });
  }

  Position? position;
  @override
  Widget build(BuildContext context) {
    return weatherMap != null
        ? Scaffold(
            backgroundColor: Colors.black,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarBrightness: Brightness.dark,
              ),
            ),
            body: Padding(
              padding:
                  const EdgeInsets.fromLTRB(10, 1.2 * kToolbarHeight, 10, 20),
              child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(7, -0.3),
                        child: Container(
                          height: 300,
                          width: 300,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(-7, -0.3),
                        child: Container(
                          height: 300,
                          width: 300,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0, -1.2),
                        child: Container(
                          height: 300,
                          width: 600,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFAB40),
                          ),
                        ),
                      ),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '📍 ${weatherMap!['name']}, ${weatherMap!['sys']['country']}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${weatherMap!['weather'][0]['main']}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                              Center(
                                  child: getWeatherIcon(
                                      weatherMap!['weather'][0]['id'], 275)),
                              Center(
                                child: Text(
                                  '${weatherMap!['main']['temp']}°C',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Center(
                                child: Text(
                                  'Feels Like ${weatherMap!['main']['feels_like']}°C',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Center(
                                child: Text(
                                  DateFormat('MMM d, h:mm a')
                                      .format(DateTime.now()),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/11.png',
                                        scale: 8,
                                      ),
                                      const SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Sunrise',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w300),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            Jiffy.parse(
                                                    '${DateTime.fromMicrosecondsSinceEpoch(weatherMap!['sys']['sunrise'] * 1000)}')
                                                .format(pattern: 'h:mm a'),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/12.png',
                                        scale: 8,
                                      ),
                                      const SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Sunset',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w300),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            Jiffy.parse(
                                                    '${DateTime.fromMicrosecondsSinceEpoch(weatherMap!['sys']['sunset'] * 1000)}')
                                                .format(pattern: 'h:mm a'),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5.0,
                                  horizontal: 25,
                                ),
                                child: Divider(
                                  color: Colors.grey.withOpacity(.2),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(children: [
                                    Image.asset(
                                      'assets/13.png',
                                      scale: 8,
                                    ),
                                    const SizedBox(width: 5),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Temp Max',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${weatherMap!['main']['temp_max']}°C',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    )
                                  ]),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/14.png',
                                        scale: 8,
                                      ),
                                      const SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Temp Min',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w300),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${weatherMap!['main']['temp_min']}°C',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 250,
                                child: ListView.builder(
                                    itemCount: forecastMap!['cnt'],
                                    padding: const EdgeInsets.all(10),
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.all(10),
                                        width: 150,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: Colors.white.withOpacity(.2),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              Jiffy.parse(
                                                      '${forecastMap!['list'][index]['dt_txt']}')
                                                  .format(
                                                      pattern: 'MMM d, h:mm a'),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Center(
                                              child: getWeatherIcon(
                                                  forecastMap!['list'][index]
                                                      ['weather'][0]['id'],
                                                  75),
                                            ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            Center(
                                              child: Text(
                                                '${forecastMap!['list'][index]['weather'][0]['main']}',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            Center(
                                              child: Text(
                                                '${forecastMap!['list'][index]['main']['temp']}°C',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            Center(
                                              child: Text(
                                                'Feels Like ${forecastMap!['list'][index]['main']['temp']}°C',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
