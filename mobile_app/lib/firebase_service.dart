import 'package:firebase_database/firebase_database.dart';
import 'data_model.dart';

class FirebaseService {
  final databaseReference = FirebaseDatabase.instance.ref();

  Future<SensorData> getSensorData() async {
    try {
      DatabaseEvent event = await databaseReference.once();
      DataSnapshot dataSnapshot = event.snapshot;

      if (dataSnapshot.value is Map<Object?, Object?>) {
        Map<Object?, Object?> dataMap =
            dataSnapshot.value as Map<Object?, Object?>;

        double humidity = (dataMap['Humidity'] as num?)?.toDouble() ?? 0.0;
        double soilMoisture =
            (dataMap['Soil_Moisture'] as num?)?.toDouble() ?? 0.0;
        double temperature =
            (dataMap['Temperature'] as num?)?.toDouble() ?? 0.0;
        int humidityInt = humidity.round();
        int soilMoistureInt = soilMoisture.round();
        int temperatureInt = temperature.round();

        bool motorState = dataMap['motor_state'] as bool? ?? false;

        return SensorData(
          humidity: humidityInt,
          rainData: dataMap['Rain_data']?.toString() ?? '',
          soilMoisture: soilMoistureInt,
          temperature: temperatureInt,
          motorState: motorState,
        );
      } else {
        throw Exception("Data retrieved is not in the expected format");
      }
    } catch (e) {
      throw Exception("Error getting sensor data: $e");
    }
  }

  // Method to update motor_state in the database
  Future<void> updateMotorState(bool newState) async {
    try {
      await databaseReference.update({'motor_state': newState});
    } catch (e) {
      throw Exception("Error updating motor state: $e");
    }
  }
}
