/// 🎯 组局中心数据验证工具
/// 
/// 包含各种数据验证方法

/// 📋 表单验证工具类
class TeamCenterValidators {
  const TeamCenterValidators._();
  
  /// 验证活动标题
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入活动标题';
    }
    
    if (value.trim().length < 3) {
      return '标题至少需要3个字符';
    }
    
    if (value.length > 30) {
      return '标题不能超过30个字符';
    }
    
    // 检查敏感词
    if (_containsSensitiveWords(value)) {
      return '标题包含敏感词，请修改';
    }
    
    return null;
  }
  
  /// 验证活动内容
  static String? validateContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入活动内容';
    }
    
    if (value.trim().length < 10) {
      return '内容至少需要10个字符';
    }
    
    if (value.length > 200) {
      return '内容不能超过200个字符';
    }
    
    // 检查敏感词
    if (_containsSensitiveWords(value)) {
      return '内容包含敏感词，请修改';
    }
    
    return null;
  }
  
  /// 验证价格
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入价格';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return '请输入有效的价格';
    }
    
    if (price < 0) {
      return '价格不能为负数';
    }
    
    if (price > 9999) {
      return '价格不能超过9999';
    }
    
    return null;
  }
  
  /// 验证人数
  static String? validateParticipants(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入人数';
    }
    
    final count = int.tryParse(value);
    if (count == null) {
      return '请输入有效的人数';
    }
    
    if (count < 1) {
      return '人数至少为1人';
    }
    
    if (count > 50) {
      return '人数不能超过50人';
    }
    
    return null;
  }
  
  /// 验证手机号
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // 手机号可选
    }
    
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return '请输入有效的手机号';
    }
    
    return null;
  }
  
  /// 验证邮箱
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // 邮箱可选
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    
    return null;
  }
  
  /// 验证时间
  static String? validateDateTime(DateTime? value) {
    if (value == null) {
      return '请选择时间';
    }
    
    final now = DateTime.now();
    if (value.isBefore(now)) {
      return '时间不能早于当前时间';
    }
    
    final maxDate = now.add(const Duration(days: 90));
    if (value.isAfter(maxDate)) {
      return '时间不能超过90天后';
    }
    
    return null;
  }
  
  /// 验证地址
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入地址';
    }
    
    if (value.trim().length < 5) {
      return '地址至少需要5个字符';
    }
    
    if (value.length > 100) {
      return '地址不能超过100个字符';
    }
    
    return null;
  }
  
  /// 检查敏感词（简化版本）
  static bool _containsSensitiveWords(String text) {
    const sensitiveWords = [
      '政治', '反动', '暴力', '色情', '赌博',
      '违法', '犯罪', '毒品', '恐怖', '分裂'
    ];
    
    final lowerText = text.toLowerCase();
    return sensitiveWords.any((word) => lowerText.contains(word));
  }
}

/// 🔍 验证结果类
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  
  const ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
  
  factory ValidationResult.valid() {
    return const ValidationResult(isValid: true);
  }
  
  factory ValidationResult.invalid(String message) {
    return ValidationResult(
      isValid: false,
      errorMessage: message,
    );
  }
}
