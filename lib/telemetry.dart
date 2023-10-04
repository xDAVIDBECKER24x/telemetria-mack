

class Telemetry {
  final double speed;
  final String miliseconds;

  Telemetry(this.speed, this.miliseconds);

  Telemetry.fromJson(Map<String, dynamic> json)
      : speed = json['speed'],
        miliseconds = json['miliseconds'];

  Map<String, dynamic> toJson() => {
    'speed': speed,
    'miliseconds': miliseconds,
  };


}