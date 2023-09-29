import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class VelocimeterWidget extends StatefulWidget {
  const VelocimeterWidget({Key? key}) : super(key: key);

  @override
  State<VelocimeterWidget> createState() => _VelocimeterWidgetState();
}

class _VelocimeterWidgetState extends State<VelocimeterWidget> {
  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(minimum: 0, maximum: 200, labelOffset: 30,
              axisLineStyle: const AxisLineStyle(
                  thicknessUnit: GaugeSizeUnit.factor,thickness: 0.03),
              majorTickStyle: const MajorTickStyle(length: 6,thickness: 4,color: Colors.white),
              minorTickStyle: const MinorTickStyle(length: 3,thickness: 3,color: Colors.white),
              axisLabelStyle: const GaugeTextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 14 )
          )
        ]
    );
  }
}
