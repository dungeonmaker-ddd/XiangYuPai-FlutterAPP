/// 🎯 服务系统数据验证工具
/// 
/// 包含各种数据验证方法

/// 📋 服务系统验证工具类
class ServiceSystemValidators {
  const ServiceSystemValidators._();
  
  /// 验证服务名称
  static String? validateServiceName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入服务名称';
    }
    
    if (value.trim().length < 2) {
      return '服务名称至少需要2个字符';
    }
    
    if (value.length > 50) {
      return '服务名称不能超过50个字符';
    }
    
    return null;
  }
  
  /// 验证服务描述
  static String? validateServiceDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入服务描述';
    }
    
    if (value.trim().length < 10) {
      return '服务描述至少需要10个字符';
    }
    
    if (value.length > 500) {
      return '服务描述不能超过500个字符';
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
    
    if (price > 99999) {
      return '价格不能超过99999';
    }
    
    return null;
  }
  
  /// 验证服务数量
  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入服务数量';
    }
    
    final quantity = int.tryParse(value);
    if (quantity == null) {
      return '请输入有效的数量';
    }
    
    if (quantity < 1) {
      return '数量至少为1';
    }
    
    if (quantity > 999) {
      return '数量不能超过999';
    }
    
    return null;
  }
  
  /// 验证评分
  static String? validateRating(double? value) {
    if (value == null || value < 1 || value > 5) {
      return '请选择有效的评分(1-5星)';
    }
    
    return null;
  }
  
  /// 验证评价内容
  static String? validateReviewContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入评价内容';
    }
    
    if (value.trim().length < 10) {
      return '评价内容至少需要10个字符';
    }
    
    if (value.length > 500) {
      return '评价内容不能超过500个字符';
    }
    
    // 检查敏感词
    if (_containsSensitiveWords(value)) {
      return '评价内容包含敏感词，请修改';
    }
    
    return null;
  }
  
  /// 验证订单备注
  static String? validateOrderNotes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // 备注可选
    }
    
    if (value.length > 200) {
      return '备注不能超过200个字符';
    }
    
    return null;
  }
  
  /// 验证支付密码
  static String? validatePaymentPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入支付密码';
    }
    
    if (value.length != 6) {
      return '支付密码必须是6位数字';
    }
    
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return '支付密码只能包含数字';
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
  
  /// 验证距离
  static String? validateDistance(double? value) {
    if (value == null) {
      return '距离信息无效';
    }
    
    if (value < 0) {
      return '距离不能为负数';
    }
    
    if (value > 1000) {
      return '距离超出服务范围';
    }
    
    return null;
  }
  
  /// 验证服务时长
  static String? validateDuration(int? minutes) {
    if (minutes == null) {
      return '请输入服务时长';
    }
    
    if (minutes < 15) {
      return '服务时长至少15分钟';
    }
    
    if (minutes > 1440) { // 24小时
      return '服务时长不能超过24小时';
    }
    
    return null;
  }
  
  /// 验证服务标签
  static String? validateServiceTags(List<String>? tags) {
    if (tags == null || tags.isEmpty) {
      return '请至少选择一个服务标签';
    }
    
    if (tags.length > 10) {
      return '最多只能选择10个标签';
    }
    
    for (final tag in tags) {
      if (tag.trim().isEmpty) {
        return '标签不能为空';
      }
      if (tag.length > 20) {
        return '标签长度不能超过20个字符';
      }
    }
    
    return null;
  }
  
  /// 检查敏感词（简化版本）
  static bool _containsSensitiveWords(String text) {
    const sensitiveWords = [
      '政治', '反动', '暴力', '色情', '赌博',
      '违法', '犯罪', '毒品', '恐怖', '分裂',
      '欺诈', '诈骗', '传销', '非法'
    ];
    
    final lowerText = text.toLowerCase();
    return sensitiveWords.any((word) => lowerText.contains(word));
  }
}

/// 🔍 验证结果类
class ServiceValidationResult {
  final bool isValid;
  final String? errorMessage;
  final Map<String, dynamic>? data;
  
  const ServiceValidationResult({
    required this.isValid,
    this.errorMessage,
    this.data,
  });
  
  factory ServiceValidationResult.valid({Map<String, dynamic>? data}) {
    return ServiceValidationResult(isValid: true, data: data);
  }
  
  factory ServiceValidationResult.invalid(String message) {
    return ServiceValidationResult(
      isValid: false,
      errorMessage: message,
    );
  }
}
