/// 🎯 组局中心日期时间工具
/// 
/// 包含日期时间相关的工具方法

/// 📅 日期时间工具类
class TeamCenterDateUtils {
  const TeamCenterDateUtils._();
  
  /// 获取今天的开始时间
  static DateTime get todayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  /// 获取今天的结束时间
  static DateTime get todayEnd {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }
  
  /// 获取明天的开始时间
  static DateTime get tomorrowStart {
    return todayStart.add(const Duration(days: 1));
  }
  
  /// 获取本周的开始时间（周一）
  static DateTime get thisWeekStart {
    final now = DateTime.now();
    final weekday = now.weekday;
    return todayStart.subtract(Duration(days: weekday - 1));
  }
  
  /// 获取本月的开始时间
  static DateTime get thisMonthStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }
  
  /// 判断是否为今天
  static bool isToday(DateTime date) {
    final today = todayStart;
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }
  
  /// 判断是否为明天
  static bool isTomorrow(DateTime date) {
    final tomorrow = tomorrowStart;
    return date.year == tomorrow.year &&
           date.month == tomorrow.month &&
           date.day == tomorrow.day;
  }
  
  /// 判断是否为本周
  static bool isThisWeek(DateTime date) {
    final weekStart = thisWeekStart;
    final weekEnd = weekStart.add(const Duration(days: 7));
    return date.isAfter(weekStart) && date.isBefore(weekEnd);
  }
  
  /// 判断是否为过去时间
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }
  
  /// 判断是否为未来时间
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }
  
  /// 获取两个时间的差值描述
  static String getTimeDifference(DateTime from, DateTime to) {
    final difference = to.difference(from);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟';
    } else {
      return '刚刚';
    }
  }
  
  /// 获取友好的时间描述
  static String getFriendlyTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }
  
  /// 获取下一个工作日
  static DateTime getNextWorkday() {
    var nextDay = DateTime.now().add(const Duration(days: 1));
    
    // 跳过周末
    while (nextDay.weekday == DateTime.saturday || 
           nextDay.weekday == DateTime.sunday) {
      nextDay = nextDay.add(const Duration(days: 1));
    }
    
    return nextDay;
  }
  
  /// 获取时间段描述
  static String getTimeOfDayDescription(DateTime dateTime) {
    final hour = dateTime.hour;
    
    if (hour >= 6 && hour < 12) {
      return '上午';
    } else if (hour >= 12 && hour < 14) {
      return '中午';
    } else if (hour >= 14 && hour < 18) {
      return '下午';
    } else if (hour >= 18 && hour < 22) {
      return '晚上';
    } else {
      return '深夜';
    }
  }
  
  /// 获取日期的星期描述
  static String getWeekdayName(DateTime date) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[date.weekday - 1];
  }
  
  /// 检查时间是否在范围内
  static bool isTimeInRange(DateTime time, DateTime start, DateTime end) {
    return time.isAfter(start) && time.isBefore(end);
  }
  
  /// 获取时间到截止时间的剩余时间描述
  static String getTimeRemaining(DateTime deadline) {
    final now = DateTime.now();
    final remaining = deadline.difference(now);
    
    if (remaining.isNegative) {
      return '已截止';
    }
    
    if (remaining.inDays > 0) {
      return '还有${remaining.inDays}天';
    } else if (remaining.inHours > 0) {
      return '还有${remaining.inHours}小时';
    } else if (remaining.inMinutes > 0) {
      return '还有${remaining.inMinutes}分钟';
    } else {
      return '即将截止';
    }
  }
}
