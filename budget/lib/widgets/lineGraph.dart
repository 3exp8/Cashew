import 'package:budget/functions.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:budget/colors.dart';
import 'package:intl/intl.dart';

class _LineChart extends StatefulWidget {
  _LineChart({
    required this.spots,
    required this.maxPair,
    required this.minPair,
    required this.color,
    Key? key,
  }) : super(key: key);
  final List<FlSpot> spots;
  final Pair maxPair;
  final Pair minPair;
  final Color color;

  @override
  State<_LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<_LineChart> with WidgetsBindingObserver {
  bool loaded = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        loaded = true;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    print(widget.spots);
  }

  getMaxPoint(spots) {}

  @override
  Widget build(BuildContext context) {
    return LineChart(
      sampleData2,
      swapAnimationDuration: const Duration(milliseconds: 4500),
      swapAnimationCurve: Curves.easeInOutCubic,
    );
  }

  LineChartData get sampleData2 => LineChartData(
        lineTouchData: lineTouchData,
        gridData: gridData,
        borderData: borderData,
        lineBarsData: lineBarsData,
        minX: 0,
        minY: 0,
        maxY: widget.maxPair.y + 0.2,
        maxX: widget.maxPair.x + 1,
        axisTitleData: axisTitleData,
        titlesData: titlesData,
        clipData: FlClipData.all(),
      );

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTitles: (value) {
            DateTime currentDate = DateTime.now();
            return getWordedDateShort(
              DateTime(
                currentDate.year,
                currentDate.month,
                currentDate.day - widget.maxPair.x.toInt() + value.toInt(),
              ),
              showTodayTomorrow: false,
            );
          },
          interval: widget.maxPair.x / 5,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTitles: (value) {
            return getWordedNumber(value);
          },
          reservedSize: 30,
          interval: widget.maxPair.y / 5,
        ),
        topTitles: SideTitles(
          showTitles: false,
        ),
        rightTitles: SideTitles(
          showTitles: false,
        ),
      );

  FlAxisTitleData get axisTitleData => FlAxisTitleData(
        bottomTitle: AxisTitle(
          showTitle: false,
          titleText: "Monthly Spending",
          margin: 10,
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  LineTouchData get lineTouchData => LineTouchData(
        handleBuiltInTouches: false,
      );

  List<LineChartBarData> get lineBarsData => [
        lineChartBarData2_2,
      ];

  FlGridData get gridData => FlGridData(
        show: true,
        verticalInterval: widget.maxPair.x / 5,
        horizontalInterval: widget.maxPair.y / 6,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: widget.color.withAlpha(170),
            strokeWidth: 1,
            dashArray: [1, 5],
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: widget.color.withAlpha(170),
            strokeWidth: 1,
            dashArray: [1, 5],
          );
        },
      );

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: widget.color.withAlpha(200), width: 3),
          left: BorderSide(color: widget.color.withAlpha(200), width: 3),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarData2_2 => LineChartBarData(
        colors: [
          MediaQuery.of(context).platformBrightness == Brightness.light
              ? darken(widget.color, 0.2)
              : lighten(widget.color, 0.2),
        ],
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        isCurved: true,
        belowBarData: BarAreaData(
          show: true,
          colors: [
            widget.color,
            widget.color.withAlpha(100),
          ],
          gradientColorStops: [0, 0.5, 1.0],
          gradientFrom: const Offset(0, 0),
          gradientTo: const Offset(0, 1),
        ),
        spots: loaded ? widget.spots : [],
      );
}

class Pair {
  Pair(this.x, this.y);

  double x;
  double y;
}

class LineChartWrapper extends StatelessWidget {
  const LineChartWrapper({required this.points, Key? key}) : super(key: key);

  final List<Pair> points;

  List<FlSpot> convertPoints(points) {
    List<FlSpot> pointsOut = [];
    for (Pair pair in points) {
      pointsOut.add(FlSpot(pair.x, pair.y));
    }
    return pointsOut;
  }

  Pair getMaxPoint(points) {
    Pair max = Pair(1, 1);
    for (Pair pair in points) {
      if (pair.x > max.x) {
        max.x = pair.x;
      }
      if (pair.y > max.y) {
        max.y = pair.y;
      }
    }
    return max;
  }

  Pair getMinPoint(points) {
    if (points.length <= 0) {
      return Pair(1, 1);
    }
    Pair min = Pair(points[0].x, points[0].y);
    for (Pair pair in points) {
      if (pair.x < min.x) {
        min.x = pair.x;
      }
      if (pair.y < min.y) {
        min.y = pair.y;
      }
    }
    return min;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(
          child: TextFont(
            text: "Monthly Overview",
            textColor: Theme.of(context).colorScheme.black,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 17,
        ),
        Container(
          height: 175,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 6.0),
            child: _LineChart(
              spots: convertPoints(points),
              maxPair: getMaxPoint(points),
              minPair: getMinPoint(points),
              color: Theme.of(context).colorScheme.accentColor,
            ),
          ),
        ),
      ],
    );
  }
}