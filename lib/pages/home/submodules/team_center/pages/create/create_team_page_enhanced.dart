// 🎯 发布组局页面(增强版) - 基于架构设计文档的完整实现
// 实现6种活动类型选择、完整表单验证、约定项配置、支付确认流程

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dart核心库
import 'dart:async';
import 'dart:developer' as developer;

// 项目内部文件 - 按依赖关系排序
import '../../models/team_models.dart';      // 数据模型
import '../../models/join_models.dart';      // 报名相关模型
import '../../services/team_services.dart';  // 业务服务
import '../../utils/constants.dart';         // 常量定义
import '../../widgets/dialogs/create_team_dialogs.dart'; // 选择器对话框

// ============== 2. CONSTANTS ==============
/// 🎨 发布组局页面增强版常量
class _CreateTeamEnhancedConstants {
  const _CreateTeamEnhancedConstants._();
  
  // 页面标识
  static const String pageTitle = '发布组局';
  static const String routeName = '/create_team_enhanced';
  
  // 表单配置
  static const int titleMaxLength = 30;
  static const int contentMaxLength = 200;
  static const int parametersMaxLength = 100;
  
  // UI配置
  static const double sectionSpacing = 20.0;
  static const double cardPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double typeIconSize = 48.0;
  static const double inputFieldHeight = 56.0;
  
  // 颜色配置
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color backgroundGray = Color(0xFFF5F5F7);
  static const Color cardWhite = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);
  
  // 动画配置
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Duration quickAnimationDuration = Duration(milliseconds: 150);
}

// ============== 3. MODELS ==============
/// 📋 增强版活动类型配置
class EnhancedActivityType {
  final ActivityType type;
  final String displayName;
  final IconData iconData;
  final Color backgroundColor;
  final Color iconColor;
  final String description;

  const EnhancedActivityType({
    required this.type,
    required this.displayName,
    required this.iconData,
    required this.backgroundColor,
    required this.iconColor,
    required this.description,
  });

  static const List<EnhancedActivityType> allTypes = [
    EnhancedActivityType(
      type: ActivityType.store,
      displayName: '探店',
      iconData: Icons.restaurant,
      backgroundColor: Color(0xFFFEF3C7),
      iconColor: Color(0xFFD97706),
      description: '美食探索，分享美味',
    ),
    EnhancedActivityType(
      type: ActivityType.movie,
      displayName: '私影',
      iconData: Icons.movie,
      backgroundColor: Color(0xFFDDD6FE),
      iconColor: Color(0xFF7C3AED),
      description: '私人影院，专属观影',
    ),
    EnhancedActivityType(
      type: ActivityType.billiards,
      displayName: '台球',
      iconData: Icons.sports_tennis,
      backgroundColor: Color(0xFFBFDBFE),
      iconColor: Color(0xFF2563EB),
      description: '技巧对决，精准博弈',
    ),
    EnhancedActivityType(
      type: ActivityType.ktv,
      displayName: 'K歌',
      iconData: Icons.mic,
      backgroundColor: Color(0xFFFCE7F3),
      iconColor: Color(0xFFDB2777),
      description: '尽情歌唱，释放激情',
    ),
    EnhancedActivityType(
      type: ActivityType.drink,
      displayName: '喝酒',
      iconData: Icons.local_bar,
      backgroundColor: Color(0xFFD1FAE5),
      iconColor: Color(0xFF059669),
      description: '微醺时光，畅聊人生',
    ),
    EnhancedActivityType(
      type: ActivityType.massage,
      displayName: '按摩',
      iconData: Icons.spa,
      backgroundColor: Color(0xFFFED7AA),
      iconColor: Color(0xFFEA580C),
      description: '身心放松，舒缓疲劳',
    ),
  ];
}

/// 🕐 时间配置模型
class TimeConfiguration {
  final DateTime? activityDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final Duration? duration;

  const TimeConfiguration({
    this.activityDate,
    this.startTime,
    this.endTime,
    this.duration,
  });

  TimeConfiguration copyWith({
    DateTime? activityDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    Duration? duration,
  }) {
    return TimeConfiguration(
      activityDate: activityDate ?? this.activityDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
    );
  }

  bool get isComplete => 
      activityDate != null && 
      startTime != null && 
      (endTime != null || duration != null);

  String get displayText {
    if (!isComplete) return '请选择时间';
    
    final dateStr = '${activityDate!.month}月${activityDate!.day}日';
    final startStr = '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
    
    if (endTime != null) {
      final endStr = '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
      return '$dateStr $startStr-$endStr';
    } else if (duration != null) {
      return '$dateStr $startStr (${duration!.inHours}小时)';
    }
    
    return '$dateStr $startStr';
  }
}

/// 📍 地点配置模型
class LocationConfiguration {
  final String? address;
  final String? detailAddress;
  final double? latitude;
  final double? longitude;
  final double? distance;

  const LocationConfiguration({
    this.address,
    this.detailAddress,
    this.latitude,
    this.longitude,
    this.distance,
  });

  LocationConfiguration copyWith({
    String? address,
    String? detailAddress,
    double? latitude,
    double? longitude,
    double? distance,
  }) {
    return LocationConfiguration(
      address: address ?? this.address,
      detailAddress: detailAddress ?? this.detailAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
    );
  }

  bool get isComplete => address != null && address!.isNotEmpty;

  String get displayText {
    if (!isComplete) return '请选择地点';
    if (detailAddress != null && detailAddress!.isNotEmpty) {
      return '$address\n$detailAddress';
    }
    return address!;
  }
}

/// 💰 定价配置模型
class PricingConfiguration {
  final double? price;
  final String? priceUnit;
  final PricingMethod? method;
  final PaymentMethod? paymentMethod;

  const PricingConfiguration({
    this.price,
    this.priceUnit,
    this.method,
    this.paymentMethod,
  });

  PricingConfiguration copyWith({
    double? price,
    String? priceUnit,
    PricingMethod? method,
    PaymentMethod? paymentMethod,
  }) {
    return PricingConfiguration(
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
      method: method ?? this.method,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  bool get isComplete => price != null && price! > 0 && method != null;

  String get displayText {
    if (!isComplete) return '请设置定价';
    
    final priceStr = '${price!.toStringAsFixed(0)}${priceUnit ?? '金币'}';
    final methodStr = method?.displayName ?? '';
    
    return '$priceStr/$methodStr';
  }
}

/// 💰 计费方式枚举
enum PricingMethod {
  perHour('小时'),
  perPerson('人'),
  fixed('固定价格');

  const PricingMethod(this.displayName);
  final String displayName;
}

/// 👥 人数配置模型
class ParticipantConfiguration {
  final int? maxParticipants;
  final int? minParticipants;
  final GenderRatio? genderRatio;
  final AgeRange? ageRange;

  const ParticipantConfiguration({
    this.maxParticipants,
    this.minParticipants,
    this.genderRatio,
    this.ageRange,
  });

  ParticipantConfiguration copyWith({
    int? maxParticipants,
    int? minParticipants,
    GenderRatio? genderRatio,
    AgeRange? ageRange,
  }) {
    return ParticipantConfiguration(
      maxParticipants: maxParticipants ?? this.maxParticipants,
      minParticipants: minParticipants ?? this.minParticipants,
      genderRatio: genderRatio ?? this.genderRatio,
      ageRange: ageRange ?? this.ageRange,
    );
  }

  bool get isComplete => maxParticipants != null && maxParticipants! > 0;

  String get displayText {
    if (!isComplete) return '请设置人数';
    
    String result = '最多${maxParticipants}人';
    if (minParticipants != null && minParticipants! > 0) {
      result = '${minParticipants}-${maxParticipants}人';
    }
    
    if (genderRatio != null && genderRatio != GenderRatio.unlimited) {
      result += ' • ${genderRatio!.displayName}';
    }
    
    if (ageRange != null && ageRange != AgeRange.unlimited) {
      result += ' • ${ageRange!.displayName}';
    }
    
    return result;
  }
}

/// 👫 性别比例枚举
enum GenderRatio {
  unlimited('不限性别'),
  femaleOnly('仅限女生'),
  maleOnly('仅限男生'),
  balanced('男女均衡'),
  moreFemale('女生优先'),
  moreMale('男生优先');

  const GenderRatio(this.displayName);
  final String displayName;
}

/// 🎂 年龄范围枚举
enum AgeRange {
  unlimited('不限年龄'),
  teens('18-25岁'),
  twenties('26-35岁'),
  thirties('36-45岁'),
  forties('46-55岁'),
  seniors('55岁以上');

  const AgeRange(this.displayName);
  final String displayName;
}

/// ⏰ 截止时间配置模型
class DeadlineConfiguration {
  final DateTime? deadline;
  final QuickDeadline? quickOption;

  const DeadlineConfiguration({
    this.deadline,
    this.quickOption,
  });

  DeadlineConfiguration copyWith({
    DateTime? deadline,
    QuickDeadline? quickOption,
  }) {
    return DeadlineConfiguration(
      deadline: deadline ?? this.deadline,
      quickOption: quickOption ?? this.quickOption,
    );
  }

  bool get isComplete => deadline != null;

  String get displayText {
    if (!isComplete) return '请设置截止时间';
    
    final now = DateTime.now();
    final diff = deadline!.difference(now);
    
    if (diff.inDays > 0) {
      return '${deadline!.month}月${deadline!.day}日 ${deadline!.hour.toString().padLeft(2, '0')}:${deadline!.minute.toString().padLeft(2, '0')}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时后';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟后';
    } else {
      return '已截止';
    }
  }
}

/// ⚡ 快速截止时间选项
enum QuickDeadline {
  oneHour(Duration(hours: 1), '提前1小时'),
  sixHours(Duration(hours: 6), '提前6小时'),
  oneDay(Duration(days: 1), '提前1天');

  const QuickDeadline(this.duration, this.displayName);
  final Duration duration;
  final String displayName;
}

/// 📋 发布组局表单状态模型
class CreateTeamFormState {
  final EnhancedActivityType? selectedType;
  final String title;
  final String content;
  final String parameters;
  final TimeConfiguration timeConfig;
  final LocationConfiguration locationConfig;
  final PricingConfiguration pricingConfig;
  final ParticipantConfiguration participantConfig;
  final DeadlineConfiguration deadlineConfig;
  final bool isSubmitting;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  const CreateTeamFormState({
    this.selectedType,
    this.title = '',
    this.content = '',
    this.parameters = '',
    this.timeConfig = const TimeConfiguration(),
    this.locationConfig = const LocationConfiguration(),
    this.pricingConfig = const PricingConfiguration(),
    this.participantConfig = const ParticipantConfiguration(),
    this.deadlineConfig = const DeadlineConfiguration(),
    this.isSubmitting = false,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  CreateTeamFormState copyWith({
    EnhancedActivityType? selectedType,
    String? title,
    String? content,
    String? parameters,
    TimeConfiguration? timeConfig,
    LocationConfiguration? locationConfig,
    PricingConfiguration? pricingConfig,
    ParticipantConfiguration? participantConfig,
    DeadlineConfiguration? deadlineConfig,
    bool? isSubmitting,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return CreateTeamFormState(
      selectedType: selectedType ?? this.selectedType,
      title: title ?? this.title,
      content: content ?? this.content,
      parameters: parameters ?? this.parameters,
      timeConfig: timeConfig ?? this.timeConfig,
      locationConfig: locationConfig ?? this.locationConfig,
      pricingConfig: pricingConfig ?? this.pricingConfig,
      participantConfig: participantConfig ?? this.participantConfig,
      deadlineConfig: deadlineConfig ?? this.deadlineConfig,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  /// 表单验证
  bool get isValid {
    return selectedType != null &&
           title.trim().isNotEmpty &&
           content.trim().isNotEmpty &&
           timeConfig.isComplete &&
           locationConfig.isComplete &&
           pricingConfig.isComplete &&
           participantConfig.isComplete &&
           deadlineConfig.isComplete &&
           fieldErrors.isEmpty;
  }

  /// 获取字段错误信息
  String? getFieldError(String fieldName) => fieldErrors[fieldName];

  /// 是否有字段错误
  bool hasFieldError(String fieldName) => fieldErrors.containsKey(fieldName);
}

// ============== 4. SERVICES ==============
/// 🔧 表单验证服务
class FormValidationService {
  static Map<String, String> validateForm(CreateTeamFormState state) {
    final errors = <String, String>{};

    // 验证活动类型
    if (state.selectedType == null) {
      errors['type'] = '请选择活动类型';
    }

    // 验证标题
    if (state.title.trim().isEmpty) {
      errors['title'] = '请填写活动标题';
    } else if (state.title.length > _CreateTeamEnhancedConstants.titleMaxLength) {
      errors['title'] = '标题不能超过${_CreateTeamEnhancedConstants.titleMaxLength}个字符';
    }

    // 验证内容
    if (state.content.trim().isEmpty) {
      errors['content'] = '请填写活动内容';
    } else if (state.content.length > _CreateTeamEnhancedConstants.contentMaxLength) {
      errors['content'] = '内容不能超过${_CreateTeamEnhancedConstants.contentMaxLength}个字符';
    }

    // 验证时间配置
    if (!state.timeConfig.isComplete) {
      errors['time'] = '请设置活动时间';
    } else if (state.timeConfig.activityDate != null && 
               state.timeConfig.activityDate!.isBefore(DateTime.now().subtract(const Duration(hours: 1)))) {
      errors['time'] = '活动时间不能是过去时间';
    }

    // 验证地点配置
    if (!state.locationConfig.isComplete) {
      errors['location'] = '请设置活动地点';
    }

    // 验证定价配置
    if (!state.pricingConfig.isComplete) {
      errors['pricing'] = '请设置活动定价';
    } else if (state.pricingConfig.price != null && state.pricingConfig.price! < 0) {
      errors['pricing'] = '价格不能为负数';
    }

    // 验证人数配置
    if (!state.participantConfig.isComplete) {
      errors['participants'] = '请设置参与人数';
    } else {
      final max = state.participantConfig.maxParticipants!;
      final min = state.participantConfig.minParticipants ?? 1;
      if (max < min) {
        errors['participants'] = '最大人数不能小于最小人数';
      }
      if (max > 50) {
        errors['participants'] = '最大人数不能超过50人';
      }
    }

    // 验证截止时间配置
    if (!state.deadlineConfig.isComplete) {
      errors['deadline'] = '请设置报名截止时间';
    } else {
      final deadline = state.deadlineConfig.deadline!;
      final activityTime = state.timeConfig.activityDate;
      
      if (deadline.isBefore(DateTime.now())) {
        errors['deadline'] = '截止时间不能是过去时间';
      } else if (activityTime != null && deadline.isAfter(activityTime)) {
        errors['deadline'] = '截止时间不能晚于活动时间';
      }
    }

    return errors;
  }

  /// 敏感词检测
  static bool containsSensitiveWords(String content) {
    final sensitiveWords = ['敏感词1', '敏感词2']; // 这里可以配置敏感词列表
    final lowerContent = content.toLowerCase();
    return sensitiveWords.any((word) => lowerContent.contains(word.toLowerCase()));
  }

  /// 内容过滤
  static String filterContent(String content) {
    // 简单的内容过滤，实际项目中可能需要更复杂的逻辑
    return content.replaceAll(RegExp(r'[^\w\s\u4e00-\u9fa5，。！？、；：""''（）【】]'), '');
  }
}

// ============== 5. CONTROLLERS ==============
/// 🧠 发布组局控制器
class _CreateTeamEnhancedController extends ValueNotifier<CreateTeamFormState> {
  late ITeamService _teamService;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _parametersController = TextEditingController();

  _CreateTeamEnhancedController() : super(const CreateTeamFormState()) {
    _initialize();
  }

  /// 初始化
  Future<void> _initialize() async {
    _teamService = TeamServiceFactory.getInstance();
    
    // 设置文本控制器监听
    _titleController.addListener(_onTitleChanged);
    _contentController.addListener(_onContentChanged);
    _parametersController.addListener(_onParametersChanged);
  }

  /// 标题变化处理
  void _onTitleChanged() {
    value = value.copyWith(title: _titleController.text);
    _validateField('title');
  }

  /// 内容变化处理
  void _onContentChanged() {
    value = value.copyWith(content: _contentController.text);
    _validateField('content');
  }

  /// 参数变化处理
  void _onParametersChanged() {
    value = value.copyWith(parameters: _parametersController.text);
  }

  /// 选择活动类型
  void selectActivityType(EnhancedActivityType type) {
    value = value.copyWith(selectedType: type);
    _validateField('type');
    developer.log('选择活动类型: ${type.displayName}');
  }

  /// 设置时间配置
  void setTimeConfiguration(TimeConfiguration config) {
    value = value.copyWith(timeConfig: config);
    _validateField('time');
    developer.log('设置时间配置: ${config.displayText}');
  }

  /// 设置地点配置
  void setLocationConfiguration(LocationConfiguration config) {
    value = value.copyWith(locationConfig: config);
    _validateField('location');
    developer.log('设置地点配置: ${config.displayText}');
  }

  /// 设置定价配置
  void setPricingConfiguration(PricingConfiguration config) {
    value = value.copyWith(pricingConfig: config);
    _validateField('pricing');
    developer.log('设置定价配置: ${config.displayText}');
  }

  /// 设置人数配置
  void setParticipantConfiguration(ParticipantConfiguration config) {
    value = value.copyWith(participantConfig: config);
    _validateField('participants');
    developer.log('设置人数配置: ${config.displayText}');
  }

  /// 设置截止时间配置
  void setDeadlineConfiguration(DeadlineConfiguration config) {
    value = value.copyWith(deadlineConfig: config);
    _validateField('deadline');
    developer.log('设置截止时间配置: ${config.displayText}');
  }

  /// 单字段验证
  void _validateField(String fieldName) {
    final errors = Map<String, String>.from(value.fieldErrors);
    final newErrors = FormValidationService.validateForm(value);
    
    if (newErrors.containsKey(fieldName)) {
      errors[fieldName] = newErrors[fieldName]!;
    } else {
      errors.remove(fieldName);
    }
    
    value = value.copyWith(fieldErrors: errors);
  }

  /// 全表单验证
  bool validateAll() {
    final errors = FormValidationService.validateForm(value);
    value = value.copyWith(fieldErrors: errors);
    return errors.isEmpty;
  }

  /// 提交表单
  Future<bool> submitForm() async {
    if (value.isSubmitting) return false;

    try {
      value = value.copyWith(isSubmitting: true, errorMessage: null);

      // 全表单验证
      if (!validateAll()) {
        value = value.copyWith(isSubmitting: false);
        return false;
      }

      // 敏感词检测
      if (FormValidationService.containsSensitiveWords(value.title) ||
          FormValidationService.containsSensitiveWords(value.content)) {
        value = value.copyWith(
          isSubmitting: false,
          errorMessage: '内容包含敏感词，请修改后重试',
        );
        return false;
      }

      // 构建活动数据
      final activity = _buildTeamActivity();

      // 提交到服务
      await _teamService.createTeamActivity(activity);

      developer.log('组局发布成功');
      return true;

    } catch (e) {
      value = value.copyWith(
        isSubmitting: false,
        errorMessage: '发布失败：$e',
      );
      developer.log('组局发布失败: $e');
      return false;
    }
  }

  /// 构建团队活动数据
  TeamActivity _buildTeamActivity() {
    final state = value;
    
    // 构建活动时间
    DateTime? activityTime;
    if (state.timeConfig.activityDate != null && state.timeConfig.startTime != null) {
      final date = state.timeConfig.activityDate!;
      final time = state.timeConfig.startTime!;
      activityTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }

    // 构建截止时间
    DateTime? deadline = state.deadlineConfig.deadline;

    return TeamActivity(
      id: '', // 服务端会生成ID
      title: state.title.trim(),
      description: state.content.trim(),
      type: state.selectedType!.type,
      host: TeamHost(
        id: 'current_user', // 当前用户ID
        nickname: '当前用户', // 当前用户昵称
        isOnline: true,
        isVerified: false,
        tags: [],
        rating: 0.0,
        completedTeams: 0,
      ),
      participants: [],
      activityTime: activityTime ?? DateTime.now().add(const Duration(hours: 2)),
      registrationDeadline: deadline ?? DateTime.now().add(const Duration(hours: 1)),
      location: state.locationConfig.address ?? '',
      distance: state.locationConfig.distance ?? 0.0,
      pricePerHour: state.pricingConfig.price?.toInt() ?? 0,
      maxParticipants: state.participantConfig.maxParticipants ?? 1,
      status: TeamStatus.recruiting,
      createdAt: DateTime.now(),
    );
  }

  /// 清理资源
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _parametersController.dispose();
    super.dispose();
  }

  // Getters for text controllers
  TextEditingController get titleController => _titleController;
  TextEditingController get contentController => _contentController;
  TextEditingController get parametersController => _parametersController;
}

// ============== 6. WIDGETS ==============
/// 🧩 UI组件定义

/// 🔝 发布页面导航栏
class _CreateTeamAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  const _CreateTeamAppBar({
    this.onCancel,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _CreateTeamEnhancedConstants.cardWhite,
      elevation: 0,
      leading: TextButton(
        onPressed: onCancel,
        child: Text(
          '取消',
          style: TextStyle(
            color: _CreateTeamEnhancedConstants.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      title: Text(
        _CreateTeamEnhancedConstants.pageTitle,
        style: TextStyle(
          color: _CreateTeamEnhancedConstants.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        if (onSave != null)
          TextButton(
            onPressed: onSave,
            child: Text(
              '保存',
              style: TextStyle(
                color: _CreateTeamEnhancedConstants.primaryPurple,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 🎯 活动类型选择网格
class _ActivityTypeGrid extends StatelessWidget {
  final EnhancedActivityType? selectedType;
  final ValueChanged<EnhancedActivityType> onTypeSelected;
  final String? errorText;

  const _ActivityTypeGrid({
    required this.selectedType,
    required this.onTypeSelected,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _CreateTeamEnhancedConstants.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.category_outlined,
                size: 20,
                color: _CreateTeamEnhancedConstants.primaryPurple,
              ),
              const SizedBox(width: 8),
              Text(
                '选择活动类型',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _CreateTeamEnhancedConstants.textPrimary,
                ),
              ),
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 16,
                  color: _CreateTeamEnhancedConstants.errorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 类型网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: EnhancedActivityType.allTypes.length,
            itemBuilder: (context, index) {
              final type = EnhancedActivityType.allTypes[index];
              final isSelected = selectedType == type;
              
              return GestureDetector(
                onTap: () => onTypeSelected(type),
                child: AnimatedContainer(
                  duration: _CreateTeamEnhancedConstants.quickAnimationDuration,
                  decoration: BoxDecoration(
                    color: type.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? _CreateTeamEnhancedConstants.primaryPurple
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: _CreateTeamEnhancedConstants.primaryPurple.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 选中指示器
                      if (isSelected)
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: _CreateTeamEnhancedConstants.primaryPurple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      
                      // 图标
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          type.iconData,
                          size: 24,
                          color: type.iconColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // 类型名称
                      Text(
                        type.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: type.iconColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // 错误提示
          if (errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              errorText!,
              style: TextStyle(
                fontSize: 12,
                color: _CreateTeamEnhancedConstants.errorRed,
              ),
            ),
          ],
          
          // 选择提示
          if (selectedType == null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _CreateTeamEnhancedConstants.backgroundGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: _CreateTeamEnhancedConstants.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '请选择一个活动类型来开始发布组局',
                      style: TextStyle(
                        fontSize: 12,
                        color: _CreateTeamEnhancedConstants.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 📝 表单输入卡片
class _FormInputCard extends StatelessWidget {
  final String title;
  final bool isRequired;
  final Widget child;
  final String? errorText;

  const _FormInputCard({
    required this.title,
    this.isRequired = false,
    required this.child,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _CreateTeamEnhancedConstants.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: errorText != null ? Border.all(
          color: _CreateTeamEnhancedConstants.errorRed.withOpacity(0.3),
          width: 1,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _CreateTeamEnhancedConstants.textPrimary,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 16,
                    color: _CreateTeamEnhancedConstants.errorRed,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 输入内容
          child,
          
          // 错误提示
          if (errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              errorText!,
              style: TextStyle(
                fontSize: 12,
                color: _CreateTeamEnhancedConstants.errorRed,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ✍️ 标题输入组件
class _TitleInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const _TitleInputField({
    required this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          maxLength: _CreateTeamEnhancedConstants.titleMaxLength,
          decoration: InputDecoration(
            hintText: '给你的活动起个吸引人的标题...',
            hintStyle: TextStyle(
              color: _CreateTeamEnhancedConstants.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _CreateTeamEnhancedConstants.borderGray,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _CreateTeamEnhancedConstants.primaryPurple,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _CreateTeamEnhancedConstants.errorRed,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
            counterStyle: TextStyle(
              color: _CreateTeamEnhancedConstants.textSecondary,
              fontSize: 12,
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            color: _CreateTeamEnhancedConstants.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// 📄 内容输入组件
class _ContentInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const _ContentInputField({
    required this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          maxLength: _CreateTeamEnhancedConstants.contentMaxLength,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '详细描述你的活动安排、注意事项等...',
            hintStyle: TextStyle(
              color: _CreateTeamEnhancedConstants.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _CreateTeamEnhancedConstants.borderGray,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _CreateTeamEnhancedConstants.primaryPurple,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _CreateTeamEnhancedConstants.errorRed,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
            counterStyle: TextStyle(
              color: _CreateTeamEnhancedConstants.textSecondary,
              fontSize: 12,
            ),
          ),
          style: TextStyle(
            fontSize: 14,
            color: _CreateTeamEnhancedConstants.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// 📋 约定项设置卡片
class _CovenantSettingsCard extends StatelessWidget {
  final TimeConfiguration timeConfig;
  final LocationConfiguration locationConfig;
  final PricingConfiguration pricingConfig;
  final ParticipantConfiguration participantConfig;
  final DeadlineConfiguration deadlineConfig;
  final ValueChanged<TimeConfiguration> onTimeChanged;
  final ValueChanged<LocationConfiguration> onLocationChanged;
  final ValueChanged<PricingConfiguration> onPricingChanged;
  final ValueChanged<ParticipantConfiguration> onParticipantChanged;
  final ValueChanged<DeadlineConfiguration> onDeadlineChanged;
  final Map<String, String> fieldErrors;

  const _CovenantSettingsCard({
    required this.timeConfig,
    required this.locationConfig,
    required this.pricingConfig,
    required this.participantConfig,
    required this.deadlineConfig,
    required this.onTimeChanged,
    required this.onLocationChanged,
    required this.onPricingChanged,
    required this.onParticipantChanged,
    required this.onDeadlineChanged,
    required this.fieldErrors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _CreateTeamEnhancedConstants.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.settings_outlined,
                size: 20,
                color: _CreateTeamEnhancedConstants.primaryPurple,
              ),
              const SizedBox(width: 8),
              Text(
                '约定项设置',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _CreateTeamEnhancedConstants.textPrimary,
                ),
              ),
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 16,
                  color: _CreateTeamEnhancedConstants.errorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 设置项列表
          _buildSettingItem(
            icon: Icons.schedule,
            title: '活动时间',
            value: timeConfig.displayText,
            isComplete: timeConfig.isComplete,
            onTap: () => _showTimePickerDialog(context),
            errorText: fieldErrors['time'],
          ),
          const SizedBox(height: 16),
          
          _buildSettingItem(
            icon: Icons.location_on,
            title: '活动地点',
            value: locationConfig.displayText,
            isComplete: locationConfig.isComplete,
            onTap: () => _showLocationPickerDialog(context),
            errorText: fieldErrors['location'],
          ),
          const SizedBox(height: 16),
          
          _buildSettingItem(
            icon: Icons.monetization_on,
            title: '活动定价',
            value: pricingConfig.displayText,
            isComplete: pricingConfig.isComplete,
            onTap: () => _showPricingConfigDialog(context),
            errorText: fieldErrors['pricing'],
          ),
          const SizedBox(height: 16),
          
          _buildSettingItem(
            icon: Icons.group,
            title: '参与人数',
            value: participantConfig.displayText,
            isComplete: participantConfig.isComplete,
            onTap: () => _showParticipantConfigDialog(context),
            errorText: fieldErrors['participants'],
          ),
          const SizedBox(height: 16),
          
          _buildSettingItem(
            icon: Icons.timer,
            title: '报名截止',
            value: deadlineConfig.displayText,
            isComplete: deadlineConfig.isComplete,
            onTap: () => _showDeadlinePickerDialog(context),
            errorText: fieldErrors['deadline'],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String value,
    required bool isComplete,
    required VoidCallback onTap,
    String? errorText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _CreateTeamEnhancedConstants.backgroundGray,
          borderRadius: BorderRadius.circular(12),
          border: errorText != null ? Border.all(
            color: _CreateTeamEnhancedConstants.errorRed.withOpacity(0.3),
            width: 1,
          ) : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isComplete 
                        ? _CreateTeamEnhancedConstants.successGreen.withOpacity(0.1)
                        : _CreateTeamEnhancedConstants.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isComplete 
                        ? _CreateTeamEnhancedConstants.successGreen
                        : _CreateTeamEnhancedConstants.primaryPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _CreateTeamEnhancedConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 13,
                          color: isComplete 
                              ? _CreateTeamEnhancedConstants.textPrimary
                              : _CreateTeamEnhancedConstants.textSecondary,
                          fontWeight: isComplete ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: _CreateTeamEnhancedConstants.textSecondary,
                ),
              ],
            ),
            if (errorText != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 14,
                    color: _CreateTeamEnhancedConstants.errorRed,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      errorText,
                      style: TextStyle(
                        fontSize: 12,
                        color: _CreateTeamEnhancedConstants.errorRed,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 显示时间选择对话框
  void _showTimePickerDialog(BuildContext context) async {
    final result = await CustomTimePickerDialog.show(context, timeConfig);
    if (result != null) {
      onTimeChanged(result);
    }
  }

  /// 显示地点选择对话框
  void _showLocationPickerDialog(BuildContext context) async {
    final result = await LocationPickerDialog.show(context, locationConfig);
    if (result != null) {
      onLocationChanged(result);
    }
  }

  /// 显示定价配置对话框
  void _showPricingConfigDialog(BuildContext context) async {
    final result = await PricingConfigDialog.show(context, pricingConfig);
    if (result != null) {
      onPricingChanged(result);
    }
  }

  /// 显示人数配置对话框
  void _showParticipantConfigDialog(BuildContext context) async {
    final result = await ParticipantConfigDialog.show(context, participantConfig);
    if (result != null) {
      onParticipantChanged(result);
    }
  }

  /// 显示截止时间选择对话框
  void _showDeadlinePickerDialog(BuildContext context) async {
    final result = await DeadlinePickerDialog.show(
      context, 
      deadlineConfig,
      activityTime: timeConfig.activityDate,
    );
    if (result != null) {
      onDeadlineChanged(result);
    }
  }
}

/// 🔻 发布按钮组件
class _PublishButton extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PublishButton({
    required this.isEnabled,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: BoxDecoration(
        color: _CreateTeamEnhancedConstants.cardWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isEnabled && !isLoading ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled 
                  ? _CreateTeamEnhancedConstants.primaryPurple 
                  : Colors.grey[300],
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.grey[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    isEnabled ? '立即发布' : '请完善信息',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ============== 7. PAGES ==============
/// 📱 发布组局页面(增强版)
class CreateTeamPageEnhanced extends StatefulWidget {
  const CreateTeamPageEnhanced({super.key});

  @override
  State<CreateTeamPageEnhanced> createState() => _CreateTeamPageEnhancedState();
}

class _CreateTeamPageEnhancedState extends State<CreateTeamPageEnhanced> {
  late final _CreateTeamEnhancedController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _CreateTeamEnhancedController();
    
    // 监听状态变化
    _controller.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final state = _controller.value;
    
    // 处理错误消息
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: _CreateTeamEnhancedConstants.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CreateTeamEnhancedConstants.backgroundGray,
      appBar: _CreateTeamAppBar(
        onCancel: _handleCancel,
        onSave: _handleSave,
      ),
      body: ValueListenableBuilder<CreateTeamFormState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          return Column(
            children: [
              // 主要内容区域
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      
                      // 活动类型选择
                      _ActivityTypeGrid(
                        selectedType: state.selectedType,
                        onTypeSelected: _controller.selectActivityType,
                        errorText: state.getFieldError('type'),
                      ),
                      
                      // 标题输入
                      _FormInputCard(
                        title: '活动标题',
                        isRequired: true,
                        errorText: state.getFieldError('title'),
                        child: _TitleInputField(
                          controller: _controller.titleController,
                          errorText: state.getFieldError('title'),
                        ),
                      ),
                      
                      // 内容输入
                      _FormInputCard(
                        title: '活动内容',
                        isRequired: true,
                        errorText: state.getFieldError('content'),
                        child: _ContentInputField(
                          controller: _controller.contentController,
                          errorText: state.getFieldError('content'),
                        ),
                      ),
                      
                      // 系数项设置（可选）
                      _FormInputCard(
                        title: '系数项设置',
                        isRequired: false,
                        child: TextField(
                          controller: _controller.parametersController,
                          maxLength: _CreateTeamEnhancedConstants.parametersMaxLength,
                          decoration: InputDecoration(
                            hintText: '设置活动相关参数（可选）...',
                            hintStyle: TextStyle(
                              color: _CreateTeamEnhancedConstants.textSecondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _CreateTeamEnhancedConstants.borderGray,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _CreateTeamEnhancedConstants.primaryPurple,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: _CreateTeamEnhancedConstants.textPrimary,
                          ),
                        ),
                      ),
                      
                      // 约定项设置
                      _CovenantSettingsCard(
                        timeConfig: state.timeConfig,
                        locationConfig: state.locationConfig,
                        pricingConfig: state.pricingConfig,
                        participantConfig: state.participantConfig,
                        deadlineConfig: state.deadlineConfig,
                        onTimeChanged: _controller.setTimeConfiguration,
                        onLocationChanged: _controller.setLocationConfiguration,
                        onPricingChanged: _controller.setPricingConfiguration,
                        onParticipantChanged: _controller.setParticipantConfiguration,
                        onDeadlineChanged: _controller.setDeadlineConfiguration,
                        fieldErrors: state.fieldErrors,
                      ),
                      
                      // 发布规则提示
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _CreateTeamEnhancedConstants.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: _CreateTeamEnhancedConstants.primaryPurple,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '发布规则',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _CreateTeamEnhancedConstants.primaryPurple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• 发布组局，平台会收取一定手续费\n'
                              '• 组局双方达成一致后，发起方默认承担组织责任\n'
                              '• 请确保活动时间和地点的准确性\n'
                              '• 组局完成后，如有纠纷将进行第三方仲裁',
                              style: TextStyle(
                                fontSize: 12,
                                color: _CreateTeamEnhancedConstants.primaryPurple,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 100), // 为底部按钮留出空间
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<CreateTeamFormState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          return _PublishButton(
            isEnabled: state.isValid,
            isLoading: state.isSubmitting,
            onPressed: _handlePublish,
          );
        },
      ),
    );
  }

  /// 处理取消
  void _handleCancel() {
    // TODO: 显示确认取消对话框
    Navigator.pop(context);
  }

  /// 处理保存草稿
  void _handleSave() {
    // TODO: 实现保存草稿功能
    developer.log('保存草稿');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('草稿保存成功'),
        backgroundColor: _CreateTeamEnhancedConstants.successGreen,
      ),
    );
  }

  /// 处理发布
  void _handlePublish() async {
    final success = await _controller.submitForm();
    
    if (success && mounted) {
      // TODO: 跳转到组局详情页或支付确认页
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('组局发布成功！'),
          backgroundColor: _CreateTeamEnhancedConstants.successGreen,
        ),
      );
      Navigator.pop(context, true);
    }
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - CreateTeamPageEnhanced: 发布组局页面增强版（public class）
///
/// 私有类（不会被导出）：
/// - _CreateTeamEnhancedController: 发布组局控制器
/// - _CreateTeamAppBar: 发布页面导航栏
/// - _ActivityTypeGrid: 活动类型选择网格
/// - _FormInputCard: 表单输入卡片
/// - _TitleInputField: 标题输入组件
/// - _ContentInputField: 内容输入组件
/// - _CovenantSettingsCard: 约定项设置卡片
/// - _PublishButton: 发布按钮组件
/// - _CreateTeamPageEnhancedState: 页面状态类
/// - _CreateTeamEnhancedConstants: 页面私有常量
/// - EnhancedActivityType: 增强版活动类型配置
/// - TimeConfiguration: 时间配置模型
/// - LocationConfiguration: 地点配置模型
/// - PricingConfiguration: 定价配置模型
/// - ParticipantConfiguration: 人数配置模型
/// - DeadlineConfiguration: 截止时间配置模型
/// - CreateTeamFormState: 发布组局表单状态模型
/// - FormValidationService: 表单验证服务
///
/// 使用方式：
/// ```dart
/// import 'create_team_page_enhanced.dart';
/// 
/// // 在路由中使用
/// MaterialPageRoute(builder: (context) => const CreateTeamPageEnhanced())
/// ```
