import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../data_model.dart';
import '../firebase_service.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService firebaseService = FirebaseService();
  bool isLoading = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    _refreshData();
  }

  Future<void> initializeNotifications() async {
    // Initialize notifications for Android
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    // Initialize overall notification settings
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Initialize the plugin with the settings
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // Handle the notification tap event here
    print('Notification tapped!');
  }

  Future<void> showNotification(
      int notificationId, String title, String body) async {
    // Configure Android notification details
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Change this to your channel ID
      'Your Channel Name', // Change this to your channel name
      importance: Importance.max,
      priority: Priority.high,
    );

    // Combine Android notification details with general notification details
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Show the notification
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });

    // Fetch updated sensor data
    SensorData sensorData = await firebaseService.getSensorData();

    // Check if values are below or above the ideal range
    if (sensorData.temperature < 80 || sensorData.temperature > 90) {
      showNotification(
          1, 'Temperature Alert', 'Temperature is outside the ideal range!');
    }
    if (sensorData.humidity < 80 || sensorData.humidity > 85) {
      showNotification(
          2, 'Humidity Alert', 'Humidity is outside the ideal range!');
    }
    if (sensorData.soilMoisture < 80 || sensorData.soilMoisture > 90) {
      showNotification(3, 'Soil Moisture Alert',
          'Soil Moisture is outside the ideal range!');
    }

    // Add similar checks for other sensor values

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _showSnackbar(String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String convertTemperature(String value) {
    try {
      // Attempt to convert temperature to Celsius and Kelvin
      double temperature = double.parse(value);
      double celsius = temperature;
      double kelvin = temperature + 273.15;

      return '$celsius°C / $kelvin K';
    } catch (e) {
      // Handle the case where parsing fails (e.g., 'No Rain' or other non-numeric values)
      return 'N/A';
    }
  }

  String _getBackgroundImage(String rainData) {
    // Map the rain data to the respective image
    switch (rainData.toLowerCase()) {
      case 'rainy':
        return 'assets/images/rain.jpg';
      case 'sunny':
        return 'assets/images/sunny.jpg';
      case 'cloudy':
        return 'assets/images/cloudy.jpg';
      default:
        return 'assets/images/rain.jpg';
    }
  }

  Widget buildRainDataContainers(String rainData) {
    return OpenContainer(
      closedBuilder: (context, openContainer) {
        return buildAnimatedDataField(
          'Weather',
          _getBackgroundImage(rainData), // Default image
          rainData,
          'Weather Condition',
          'Weather condition based on the database output. Ideal: Rainy, Sunny, Cloudy',
        );
      },
      openBuilder: (context, closeContainer) {
        return Scaffold(
          body: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_getBackgroundImage(rainData)),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Weather',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Condition: $rainData',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      tappable: true,
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 700),
    );
  }

  Widget buildAnimatedDataField(
    String label,
    String imageUrl,
    String value,
    String metricName,
    String metricDescription,
  ) {
    return OpenContainer(
      closedBuilder: (context, openContainer) {
        return Container(
          height: 100.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: AssetImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      openBuilder: (context, closeContainer) {
        return Scaffold(
          body: Stack(
            children: [
              Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text(
                      //   label,
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      SizedBox(height: 7),
                      if (label == 'Temperature') ...{
                        Text(
                          'Temperature: ${convertTemperature(value)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          metricDescription,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      } else if (label == 'Weather') ...{
                        Text(
                          value,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                          ),
                        ),
                      } else if (label == 'Humidity' ||
                          label == 'Soil Moisture') ...{
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        label,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24.0,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      buildGauge(value),
                                      SizedBox(height: 10),
                                      Text(
                                        metricName,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        metricDescription,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Column(
                            children: [
                              Text(
                                '$label: $value',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30.0,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                metricName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                metricDescription,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      } else ...{
                        Text(
                          '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                          ),
                        ),
                      },
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      tappable: true,
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 700),
    );
  }

  Widget buildGauge(String value) {
    return CircularPercentIndicator(
      radius: 120.0,
      lineWidth: 10.0,
      animation: true,
      percent: double.parse(value) / 100.0,
      center: Text(
        '$value%',
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.blue,
    );
  }

  Widget buildMotorControlSwitch(bool motorState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Motor Control: ',
          style: TextStyle(fontSize: 18.0),
        ),
        Switch(
          value: motorState,
          onChanged: (bool newValue) async {
            await firebaseService.updateMotorState(newValue);
            setState(() {
              motorState = newValue;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Data App'),
        actions: [
          IconButton(
            icon: Image.asset('assets/images/icon.png', width: 24, height: 24),
            onPressed: () {
              _refreshData();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? CircularProgressIndicator()
              : FutureBuilder<SensorData>(
                  future: firebaseService.getSensorData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      SensorData sensorData = snapshot.data!;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildAnimatedDataField(
                            'Humidity',
                            'assets/images/humidity.jpg',
                            '${sensorData.humidity}%',
                            'Humidity Level',
                            'Humidity is the amount of moisture in the air. Ideal: 80-85%',
                          ),
                          buildRainDataContainers(sensorData.rainData),
                          buildAnimatedDataField(
                            'Soil Moisture',
                            'assets/images/soil_temp.jpg',
                            '${sensorData.soilMoisture} %',
                            'Soil Moisture Level',
                            'Soil moisture indicates the water content in the soil. Ideal: 80 - 90%',
                          ),
                          buildAnimatedDataField(
                            'Temperature',
                            'assets/images/temp.jpg',
                            '${sensorData.temperature}',
                            'Temperature Level',
                            'Temperature is a measure of heat in the environment. Ideal: 18-30°C',
                          ),
                          buildMotorControlSwitch(sensorData.motorState),
                        ],
                      );
                    }
                  },
                ),
        ),
      ),
    );
  }
}
