/// 🎯 服务系统数据格式化工具
/// 
/// 包含各种数据格式化方法

import 'package:flutter/services.dart';

/// 📊 服务系统格式化工具类
class ServiceSystemFormatters {
  const ServiceSystemFormatters._();
  
  /// 格式化价格显示
  static String formatPrice(double price, {String unit = '金币', String serviceUnit = '次'}) {
    if (price == price.toInt()) {
      return '${price.toInt()} $unit/$serviceUnit';
    }
    return '${price.toStringAsFixed(1)} $unit/$serviceUnit';
  }
  
  /// 格式化简单价格
  static String formatSimplePrice(double price, {String unit = '金币'}) {
    if (price == price.toInt()) {
      return '${price.toInt()} $unit';
    }
    return '${price.toStringAsFixed(1)} $unit';
  }
  
  /// 格式化距离显示
  static String formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).toInt()}m';
    } else if (distance < 10) {
      return '${distance.toStringAsFixed(1)}km';
    } else {
      return '${distance.toInt()}km';
    }
  }
  
  /// 格式化评分显示
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }
  
  /// 格式化评价数量
  static String formatReviewCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    } else {
      return count.toString();
    }
  }
  
  /// 格式化好评率
  static String formatGoodRatePercentage(double rating) {
    final percentage = (rating * 20).toInt();
    return '$percentage%';
  }
  
  /// 格式化时间显示
  static String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.isNegative) {
      // 过去时间
      final pastDifference = now.difference(dateTime);
      if (pastDifference.inDays > 30) {
        return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
      } else if (pastDifference.inDays > 0) {
        return '${pastDifference.inDays}天前';
      } else if (pastDifference.inHours > 0) {
        return '${pastDifference.inHours}小时前';
      } else if (pastDifference.inMinutes > 0) {
        return '${pastDifference.inMinutes}分钟前';
      } else {
        return '刚刚';
      }
    } else {
      // 未来时间
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
  }
  
  /// 格式化日期时间
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  /// 格式化时长
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}天${duration.inHours % 24}小时';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}小时${duration.inMinutes % 60}分钟';
    } else {
      return '${duration.inMinutes}分钟';
    }
  }
  
  /// 格式化服务时长（分钟转换）
  static String formatServiceDuration(int minutes) {
    if (minutes >= 1440) { // 24小时
      final days = minutes ~/ 1440;
      final remainingHours = (minutes % 1440) ~/ 60;
      return '$days天${remainingHours > 0 ? '${remainingHours}小时' : ''}';
    } else if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours小时${remainingMinutes > 0 ? '${remainingMinutes}分钟' : ''}';
    } else {
      return '$minutes分钟';
    }
  }
  
  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }
  
  /// 截断长文本
  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength - suffix.length) + suffix;
  }
  
  /// 格式化订单状态
  static String formatOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '待确认';
      case 'confirmed':
        return '已确认';
      case 'paid':
        return '已支付';
      case 'in_progress':
        return '进行中';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return status;
    }
  }
  
  /// 格式化支付状态
  static String formatPaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '待支付';
      case 'processing':
        return '支付中';
      case 'success':
        return '支付成功';
      case 'failed':
        return '支付失败';
      case 'cancelled':
        return '已取消';
      default:
        return status;
    }
  }
  
  /// 格式化手机号（中间四位用*替换）
  static String formatPhoneNumber(String phone) {
    if (phone.length == 11) {
      return '${phone.substring(0, 3)}****${phone.substring(7)}';
    }
    return phone;
  }
  
  /// 格式化用户名（显示首末字符，中间用*替换）
  static String formatUserName(String name) {
    if (name.length <= 2) {
      return name;
    } else if (name.length <= 4) {
      return '${name[0]}*${name.substring(name.length - 1)}';
    } else {
      return '${name.substring(0, 2)}***${name.substring(name.length - 1)}';
    }
  }
}

/// 🔢 输入格式化器
class ServicePriceInputFormatter extends TextInputFormatter {
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
    
    // 限制整数部分最多5位
    final wholePart = newValue.text.split('.')[0];
    if (wholePart.length > 5) {
      return oldValue;
    }
    
    return newValue;
  }
}

/// 🔢 数量输入格式化器
class ServiceQuantityInputFormatter extends TextInputFormatter {
  final int maxValue;
  
  const ServiceQuantityInputFormatter({this.maxValue = 999});
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 只允许数字
    if (!RegExp(r'^\d*$').hasMatch(newValue.text)) {
      return oldValue;
    }
    
    // 检查最大值
    if (newValue.text.isNotEmpty) {
      final value = int.tryParse(newValue.text);
      if (value != null && value > maxValue) {
        return oldValue;
      }
    }
    
    // 限制最多3位数字
    if (newValue.text.length > 3) {
      return oldValue;
    }
    
    return newValue;
  }
}

/// 📱 支付密码输入格式化器
class PaymentPasswordInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 只允许数字
    if (!RegExp(r'^\d*$').hasMatch(newValue.text)) {
      return oldValue;
    }
    
    // 限制最多6位
    if (newValue.text.length > 6) {
      return oldValue;
    }
    
    return newValue;
  }
}
