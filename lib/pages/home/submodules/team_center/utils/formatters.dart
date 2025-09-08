/// 🎯 组局中心数据格式化工具
/// 
/// 包含各种数据格式化方法

import 'package:flutter/services.dart';

/// 📊 数据格式化工具类
class TeamCenterFormatters {
  const TeamCenterFormatters._();
  
  /// 格式化价格显示
  static String formatPrice(double price, {String unit = '金币'}) {
    if (price == price.toInt()) {
      return '${price.toInt()}$unit';
    }
    return '${price.toStringAsFixed(1)}$unit';
  }
  
  /// 格式化距离显示
  static String formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).toInt()}m';
    }
    return '${distance.toStringAsFixed(1)}km';
  }
  
  /// 格式化时间显示
  static String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天后';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时后';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟后';
    } else {
      return '即将开始';
    }
  }
  
  /// 格式化日期时间
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateStr;
    if (targetDate == today) {
      dateStr = '今天';
    } else if (targetDate == today.add(const Duration(days: 1))) {
      dateStr = '明天';
    } else if (targetDate == today.add(const Duration(days: 2))) {
      dateStr = '后天';
    } else {
      dateStr = '${dateTime.month}月${dateTime.day}日';
    }
    
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr $timeStr';
  }
  
  /// 格式化人数显示
  static String formatParticipants(int current, int max) {
    return '$current/$max人';
  }
  
  /// 格式化剩余名额
  static String formatAvailableSpots(int current, int max) {
    final available = max - current;
    if (available <= 0) {
      return '已满员';
    } else if (available <= 3) {
      return '仅剩${available}个名额';
    } else {
      return '还有${available}个名额';
    }
  }
  
  /// 格式化持续时间
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}天${duration.inHours % 24}小时';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}小时${duration.inMinutes % 60}分钟';
    } else {
      return '${duration.inMinutes}分钟';
    }
  }
  
  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
  
  /// 截断长文本
  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength - suffix.length) + suffix;
  }
}

/// 🔢 输入格式化器
class PriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 只允许数字和小数点
    final regExp = RegExp(r'^\d*\.?\d*$');
    if (!regExp.hasMatch(newValue.text)) {
      return oldValue;
    }
    
    // 限制小数点后最多2位
    if (newValue.text.contains('.')) {
      final parts = newValue.text.split('.');
      if (parts.length > 2 || (parts.length == 2 && parts[1].length > 2)) {
        return oldValue;
      }
    }
    
    return newValue;
  }
}

/// 📱 手机号格式化器
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 只允许数字
    final regExp = RegExp(r'^\d*$');
    if (!regExp.hasMatch(newValue.text)) {
      return oldValue;
    }
    
    // 限制最多11位
    if (newValue.text.length > 11) {
      return oldValue;
    }
    
    return newValue;
  }
}
