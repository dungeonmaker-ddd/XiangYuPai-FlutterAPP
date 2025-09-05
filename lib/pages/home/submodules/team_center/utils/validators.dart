/// ✅ 组局中心验证工具
/// 
/// 提供各种数据验证功能

/// 组局中心验证器
class TeamCenterValidators {
  /// 验证组局标题
  static String? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return '请输入组局标题';
    }
    if (title.trim().length < 2) {
      return '标题至少需要2个字符';
    }
    if (title.trim().length > 50) {
      return '标题不能超过50个字符';
    }
    return null;
  }
  
  /// 验证组局描述
  static String? validateDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return '请输入组局描述';
    }
    if (description.trim().length < 10) {
      return '描述至少需要10个字符';
    }
    if (description.trim().length > 500) {
      return '描述不能超过500个字符';
    }
    return null;
  }
  
  /// 验证价格
  static String? validatePrice(String? price) {
    if (price == null || price.trim().isEmpty) {
      return '请输入价格';
    }
    
    final priceValue = double.tryParse(price);
    if (priceValue == null) {
      return '请输入有效的价格';
    }
    
    if (priceValue < 0) {
      return '价格不能为负数';
    }
    
    if (priceValue > 10000) {
      return '价格不能超过10000元';
    }
    
    return null;
  }
  
  /// 验证人数
  static String? validateParticipantCount(String? count) {
    if (count == null || count.trim().isEmpty) {
      return '请输入参与人数';
    }
    
    final countValue = int.tryParse(count);
    if (countValue == null) {
      return '请输入有效的人数';
    }
    
    if (countValue < 1) {
      return '人数至少为1人';
    }
    
    if (countValue > 100) {
      return '人数不能超过100人';
    }
    
    return null;
  }
  
  /// 验证联系方式
  static String? validateContact(String? contact) {
    if (contact == null || contact.trim().isEmpty) {
      return '请输入联系方式';
    }
    
    // 简单的手机号验证
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (phoneRegex.hasMatch(contact.trim())) {
      return null;
    }
    
    // 简单的邮箱验证
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (emailRegex.hasMatch(contact.trim())) {
      return null;
    }
    
    return '请输入有效的手机号或邮箱';
  }
  
  /// 验证地址
  static String? validateAddress(String? address) {
    if (address == null || address.trim().isEmpty) {
      return '请输入活动地址';
    }
    if (address.trim().length < 5) {
      return '地址至少需要5个字符';
    }
    if (address.trim().length > 100) {
      return '地址不能超过100个字符';
    }
    return null;
  }
  
  /// 验证时间
  static String? validateDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '请选择活动时间';
    }
    
    final now = DateTime.now();
    if (dateTime.isBefore(now)) {
      return '活动时间不能早于当前时间';
    }
    
    final maxDate = now.add(const Duration(days: 30));
    if (dateTime.isAfter(maxDate)) {
      return '活动时间不能超过30天后';
    }
    
    return null;
  }
}
