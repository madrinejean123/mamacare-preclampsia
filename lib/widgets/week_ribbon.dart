import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// The signature pregnancy-week ribbon: 10 rounded segments spanning
/// weeks 4-40. Completed weeks fill tealMid, future weeks stay tealLight,
/// and the segment where elevated risk was first detected fills amber.
class WeekRibbon extends StatelessWidget {
  final int currentWeek;
  final int riskWeek; // 0 = no elevated risk detected yet
  final double height;

  const WeekRibbon({
    super.key,
    required this.currentWeek,
    this.riskWeek = 0,
    this.height = 8,
  });

  static const int _segments = 10;
  static const int _startWeek = 4;
  static const int _endWeek = 40;

  int _segmentForWeek(int week) {
    final span = _endWeek - _startWeek;
    final ratio = (week - _startWeek) / span;
    return (ratio * _segments).floor().clamp(0, _segments - 1);
  }

  @override
  Widget build(BuildContext context) {
    final currentSegment = _segmentForWeek(currentWeek);
    final riskSegment = riskWeek > 0 ? _segmentForWeek(riskWeek) : -1;

    return Row(
      children: List.generate(_segments, (i) {
        Color color;
        if (i == riskSegment) {
          color = AppColors.of(context).riskModerate;
        } else if (i <= currentSegment) {
          color = AppColors.of(context).tealMid;
        } else {
          color = AppColors.of(context).tealLight;
        }
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i == _segments - 1 ? 0 : 4),
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
          ),
        );
      }),
    );
  }
}
