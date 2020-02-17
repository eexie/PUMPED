//Timeseries with production data

class ProductionDataPoint{
  final DateTime time;
  final double volume;

  ProductionDataPoint(this.time, this.volume);
  Map<String, dynamic> toMap() {
    return {
      'timestamp': time,
      'volume': volume,
    };
  }
}

class SessionData{
  final List<ProductionDataPoint> datapoints;
  final int letdownLength;
  final int sessionLength;
  final String timeOfDay;
  final DateTime endTime;
  final List<String> mood;
  List<int> pumpPowerLvl;
  int sessionNumber;

  SessionData(this.datapoints,
      this.letdownLength,
      this.pumpPowerLvl,
      this.sessionLength,
      this.timeOfDay,
      this.endTime,
      this.sessionNumber,
      this.mood    //['anxious', 'happy', 'sad', 'tired', 'energetic', 'angry']
      );

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> datapointsArray = [];
    datapoints.forEach((point) {
      datapointsArray.add(point.toMap());
    });

    return {
      'datapoints': datapointsArray,
      'letdownLength': letdownLength,
      'pumpPowerLvl': pumpPowerLvl,
      'sessionLength': sessionLength,
      'timeOfDay': timeOfDay,
      'endTime': endTime,
      'sessionNumber': sessionNumber,
      'mood': mood,
    };
  }
}

