class ForecastModel {
  final String time;
  final String condition;
  final int temp;

  ForecastModel({
    required this.time,
    required this.condition,
    required this.temp,
  });

  factory ForecastModel.fromMap(Map<String, dynamic> map) {
    return ForecastModel(
      time: map['time'],
      condition: map['condition'],
      temp: map['temp'],
    );
  }
}
