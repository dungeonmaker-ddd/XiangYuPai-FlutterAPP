// ⏰ 倒计时组件 - 通用倒计时显示组件
// 从unified_home_page.dart中提取的倒计时组件

import 'package:flutter/material.dart';
import 'dart:async';

/// ⏰ 倒计时组件
/// 
/// 功能：显示距离指定时间的剩余时长
/// 用途：限时专享活动的倒计时显示
/// 特性：自动更新、格式化显示、到期处理
class CountdownWidget extends StatefulWidget {
  final DateTime endTime;
  final TextStyle? textStyle;

  const CountdownWidget({
    super.key,
    required this.endTime,
    this.textStyle,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final remaining = widget.endTime.difference(now);
    if (remaining.isNegative) {
      _remaining = Duration.zero;
      _timer.cancel();
    } else {
      _remaining = remaining;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return Text('已结束', style: widget.textStyle);
    }

    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Text(
      '$hours:$minutes:$seconds',
      style: widget.textStyle,
    );
  }
}
