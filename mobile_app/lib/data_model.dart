class SensorData {
  int humidity;
  String rainData;
  int soilMoisture;
  int temperature;
  bool motorState;

  SensorData({
    required this.humidity,
    required this.rainData,
    required this.soilMoisture,
    required this.temperature,
    required this.motorState,
  });

  factory SensorData.fromMap(Map<String, dynamic> map) {
    return SensorData(
      humidity: map['Humidity'] ?? 0,
      rainData: map['Rain_data'] ?? '',
      soilMoisture: map['Soil_Moisture'] ?? 0,
      temperature: map['Temperature'] ?? 0,
      motorState: map['motor_state'] ?? false,
    );
  }
}
