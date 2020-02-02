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

