// 🔧 筛选条件页面 - 基于原型图的单文件架构实现
// 8个筛选维度：年龄、性别、状态、类型、技能、价格、位置、标签

// ============== 1. IMPORTS ==============
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

// ============== 2. CONSTANTS ==============
/// 🎨 筛选页面私有常量
class _FilterConstants {
  const _FilterConstants._();
  
  // 颜色配置
  static const int primaryColor = 0xFF8B5CF6;     // 紫色主题
  static const int selectedColor = 0xFF8B5CF6;    // 选中状态
  static const int unselectedColor = 0xFFF5F5F5;  // 未选中背景
  static const int borderColor = 0xFFE5E7EB;      // 边框颜色
  
  // 布局配置
  static const double sectionSpacing = 24.0;
  static const double itemSpacing = 12.0;
  static const double borderRadius = 12.0;
  static const double tagHeight = 36.0;
  
  // 筛选数据配置
  static const Map<String, List<String>> filterData = {
    'gender': ['全部', '男', '女'],
    'status': ['在线', '近三天活跃', '近七天活跃'],
    'type': ['线上', '线下'],
    'skills': ['尊贵铂金', '永恒钻石', '至尊星耀', '最强王者', '荣耀王者', '英雄联盟'],
    'price': ['4-9币', '10-19币', '20币以上'],
    'position': ['打野', '上路', '中路', '下路', '辅助'],
    'tags': ['荣耀王者', '大神认证', '巅峰赛', '带粉上分', '官方认证', '声优陪玩'],
  };
}

// ============== 3. MODELS ==============
/// 📋 筛选条件模型
class FilterCriteria {
  final RangeValues ageRange;
  final String gender;
  final String status;
  final String type;
  final List<String> skills;
  final String price;
  final List<String> positions;
  final List<String> tags;
  
  const FilterCriteria({
    this.ageRange = const RangeValues(18, 99),
    this.gender = '全部',
    this.status = '在线',
    this.type = '线上',
    this.skills = const [],
    this.price = '',
    this.positions = const [],
    this.tags = const [],
  });
  
  FilterCriteria copyWith({
    RangeValues? ageRange,
    String? gender,
    String? status,
    String? type,
    List<String>? skills,
    String? price,
    List<String>? positions,
    List<String>? tags,
  }) {
    return FilterCriteria(
      ageRange: ageRange ?? this.ageRange,
      gender: gender ?? this.gender,
      status: status ?? this.status,
      type: type ?? this.type,
      skills: skills ?? this.skills,
      price: price ?? this.price,
      positions: positions ?? this.positions,
      tags: tags ?? this.tags,
    );
  }
  
  /// 获取筛选结果统计（模拟）
  int get estimatedUserCount {
    int baseCount = 1000;
    
    // 根据筛选条件调整用户数量
    if (gender != '全部') baseCount = (baseCount * 0.5).round();
    if (status == '在线') baseCount = (baseCount * 0.3).round();
    if (skills.isNotEmpty) baseCount = (baseCount * 0.7).round();
    if (price.isNotEmpty) baseCount = (baseCount * 0.6).round();
    if (positions.isNotEmpty) baseCount = (baseCount * 0.4).round();
    if (tags.isNotEmpty) baseCount = (baseCount * 0.5).round();
    
    return baseCount.clamp(10, 1000);
  }
  
  /// 检查是否有活跃筛选条件
  bool get hasActiveFilters {
    return gender != '全部' ||
           status != '在线' ||
           type != '线上' ||
           skills.isNotEmpty ||
           price.isNotEmpty ||
           positions.isNotEmpty ||
           tags.isNotEmpty ||
           ageRange.start != 18 ||
           ageRange.end != 99;
  }
}

/// 📊 筛选页面状态模型
class FilterPageState {
  final bool isLoading;
  final String? errorMessage;
  final FilterCriteria criteria;
  
  const FilterPageState({
    this.isLoading = false,
    this.errorMessage,
    this.criteria = const FilterCriteria(),
  });
  
  FilterPageState copyWith({
    bool? isLoading,
    String? errorMessage,
    FilterCriteria? criteria,
  }) {
    return FilterPageState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      criteria: criteria ?? this.criteria,
    );
  }
}

// ============== 4. SERVICES ==============
/// 🔧 筛选服务
class _FilterService {
  /// 保存筛选条件
  static Future<void> saveFilterCriteria(FilterCriteria criteria) async {
    await Future.delayed(const Duration(milliseconds: 200));
    developer.log('保存筛选条件: ${criteria.estimatedUserCount}人符合条件');
  }
  
  /// 获取默认筛选条件
  static Future<FilterCriteria> getDefaultCriteria() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return const FilterCriteria();
  }
}

// ============== 5. CONTROLLERS ==============
/// 🧠 筛选页面控制器
class _FilterController extends ValueNotifier<FilterPageState> {
  _FilterController([FilterCriteria? initialCriteria]) 
      : super(FilterPageState(criteria: initialCriteria ?? const FilterCriteria()));
  
  /// 更新年龄范围
  void updateAgeRange(RangeValues ageRange) {
    final newCriteria = value.criteria.copyWith(ageRange: ageRange);
    value = value.copyWith(criteria: newCriteria);
  }
  
  /// 更新性别
  void updateGender(String gender) {
    final newCriteria = value.criteria.copyWith(gender: gender);
    value = value.copyWith(criteria: newCriteria);
  }
  
  /// 更新状态
  void updateStatus(String status) {
    final newCriteria = value.criteria.copyWith(status: status);
    value = value.copyWith(criteria: newCriteria);
  }
  
  /// 更新类型
  void updateType(String type) {
    final newCriteria = value.criteria.copyWith(type: type);
    value = value.copyWith(criteria: newCriteria);
  }
  
  /// 切换技能选择
  void toggleSkill(String skill) {
    final currentSkills = List<String>.from(value.criteria.skills);
    if (currentSkills.contains(skill)) {
      currentSkills.remove(skill);
    } else {
      currentSkills.add(skill);
    }
    final newCriteria = value.criteria.copyWith(skills: currentSkills);
    value = value.copyWith(criteria: newCriteria);
  }
  
  /// 更新价格
  void updatePrice(String price) {
    final newCriteria = value.criteria.copyWith(price: price);
    value = value.copyWith(criteria: newCriteria);
  }
  
  /// 切换位置选择
  void togglePosition(String position) {
    final currentPositions = List<String>.from(value.criteria.positions);
    if (currentPositions.contains(position)) {
      currentPositions.remove(position);
    } else {
      currentPositions.add(position);
    }
    final newCriteria = value.criteria.copyWith(positions: currentPositions);
    value = value.copyWith(criteria: newCriteria);
  }
  
  /// 切换标签选择
  void toggleTag(String tag) {
    final currentTags = List<String>.from(value.criteria.tags);
    if (currentTags.contains(tag)) {
      currentTags.remove(tag);
    } else {
      currentTags.add(tag);
    }
    final newCriteria = value.criteria.copyWith(tags: currentTags);
    value = value.copyWith(criteria: newCriteria);
  }
  
  /// 重置所有筛选条件
  Future<void> resetFilters() async {
    try {
      value = value.copyWith(isLoading: true);
      final defaultCriteria = await _FilterService.getDefaultCriteria();
      value = value.copyWith(
        isLoading: false,
        criteria: defaultCriteria,
      );
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '重置失败，请重试',
      );
    }
  }
  
  /// 应用筛选条件
  Future<void> applyFilters() async {
    try {
      value = value.copyWith(isLoading: true);
      await _FilterService.saveFilterCriteria(value.criteria);
      value = value.copyWith(isLoading: false);
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '应用筛选失败，请重试',
      );
    }
  }
}

// ============== 6. WIDGETS ==============
/// 🏷️ 筛选标签组件
class _FilterTag extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;
  
  const _FilterTag({
    required this.text,
    required this.isSelected,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: _FilterConstants.tagHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(_FilterConstants.selectedColor)
              : const Color(_FilterConstants.unselectedColor),
          borderRadius: BorderRadius.circular(_FilterConstants.borderRadius),
          border: Border.all(
            color: isSelected 
                ? const Color(_FilterConstants.selectedColor)
                : const Color(_FilterConstants.borderColor),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

/// 📊 筛选区段组件
class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;
  
  const _FilterSection({
    required this.title,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

// ============== 7. PAGES ==============
/// 🔧 筛选条件页面
class FilterPage extends StatefulWidget {
  final FilterCriteria? initialCriteria;
  final ValueChanged<FilterCriteria>? onFiltersApplied;
  
  const FilterPage({
    super.key,
    this.initialCriteria,
    this.onFiltersApplied,
  });
  
  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late final _FilterController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = _FilterController(widget.initialCriteria);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '筛选',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _controller.resetFilters(),
            child: const Text(
              '重置',
              style: TextStyle(
                color: Color(_FilterConstants.primaryColor),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: ValueListenableBuilder<FilterPageState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          return Column(
            children: [
              // 筛选内容区域
              Expanded(
                child: _buildFilterContent(state),
              ),
              
              // 底部操作栏
              _buildBottomActions(state),
            ],
          );
        },
      ),
    );
  }
  
  /// 构建筛选内容
  Widget _buildFilterContent(FilterPageState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 年龄筛选
          _buildAgeSection(state.criteria),
          const SizedBox(height: _FilterConstants.sectionSpacing),
          
          // 性别筛选
          _buildGenderSection(state.criteria),
          const SizedBox(height: _FilterConstants.sectionSpacing),
          
          // 状态筛选
          _buildStatusSection(state.criteria),
          const SizedBox(height: _FilterConstants.sectionSpacing),
          
          // 类型筛选
          _buildTypeSection(state.criteria),
          const SizedBox(height: _FilterConstants.sectionSpacing),
          
          // 技能筛选
          _buildSkillsSection(state.criteria),
          const SizedBox(height: _FilterConstants.sectionSpacing),
          
          // 价格筛选
          _buildPriceSection(state.criteria),
          const SizedBox(height: _FilterConstants.sectionSpacing),
          
          // 位置筛选
          _buildPositionSection(state.criteria),
          const SizedBox(height: _FilterConstants.sectionSpacing),
          
          // 标签筛选
          _buildTagsSection(state.criteria),
          
          // 底部占位
          const SizedBox(height: 100),
        ],
      ),
    );
  }
  
  /// 构建年龄筛选区段
  Widget _buildAgeSection(FilterCriteria criteria) {
    return _FilterSection(
      title: '年龄',
      child: Column(
        children: [
          // 年龄显示和滑动条
          Row(
            children: [
              Text(
                '${criteria.ageRange.start.round()}岁',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(_FilterConstants.primaryColor),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(_FilterConstants.primaryColor),
                    inactiveTrackColor: const Color(_FilterConstants.borderColor),
                    thumbColor: const Color(_FilterConstants.primaryColor),
                    overlayColor: const Color(_FilterConstants.primaryColor).withOpacity(0.2),
                    valueIndicatorColor: const Color(_FilterConstants.primaryColor),
                  ),
                  child: RangeSlider(
                    values: criteria.ageRange,
                    min: 18,
                    max: 99,
                    divisions: 81,
                    labels: RangeLabels(
                      '${criteria.ageRange.start.round()}岁',
                      criteria.ageRange.end.round() == 99 ? '不限' : '${criteria.ageRange.end.round()}岁',
                    ),
                    onChanged: (values) => _controller.updateAgeRange(values),
                  ),
                ),
              ),
              Text(
                criteria.ageRange.end.round() == 99 ? '不限' : '${criteria.ageRange.end.round()}岁',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(_FilterConstants.primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 构建性别筛选区段
  Widget _buildGenderSection(FilterCriteria criteria) {
    return _FilterSection(
      title: '性别',
      child: Row(
        children: _FilterConstants.filterData['gender']!.map((gender) {
          final isSelected = criteria.gender == gender;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _FilterTag(
                text: gender,
                isSelected: isSelected,
                onTap: () => _controller.updateGender(gender),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  /// 构建状态筛选区段
  Widget _buildStatusSection(FilterCriteria criteria) {
    return _FilterSection(
      title: '状态',
      child: Row(
        children: _FilterConstants.filterData['status']!.map((status) {
          final isSelected = criteria.status == status;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _FilterTag(
                text: status,
                isSelected: isSelected,
                onTap: () => _controller.updateStatus(status),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  /// 构建类型筛选区段
  Widget _buildTypeSection(FilterCriteria criteria) {
    return _FilterSection(
      title: '类型',
      child: Row(
        children: _FilterConstants.filterData['type']!.map((type) {
          final isSelected = criteria.type == type;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _FilterTag(
                text: type,
                isSelected: isSelected,
                onTap: () => _controller.updateType(type),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  /// 构建技能筛选区段
  Widget _buildSkillsSection(FilterCriteria criteria) {
    return _FilterSection(
      title: '技能',
      child: Wrap(
        spacing: _FilterConstants.itemSpacing,
        runSpacing: _FilterConstants.itemSpacing,
        children: _FilterConstants.filterData['skills']!.map((skill) {
          final isSelected = criteria.skills.contains(skill);
          return _FilterTag(
            text: skill,
            isSelected: isSelected,
            onTap: () => _controller.toggleSkill(skill),
          );
        }).toList(),
      ),
    );
  }
  
  /// 构建价格筛选区段
  Widget _buildPriceSection(FilterCriteria criteria) {
    return _FilterSection(
      title: '价格',
      child: Row(
        children: _FilterConstants.filterData['price']!.map((price) {
          final isSelected = criteria.price == price;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _FilterTag(
                text: price,
                isSelected: isSelected,
                onTap: () => _controller.updatePrice(isSelected ? '' : price),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  /// 构建位置筛选区段
  Widget _buildPositionSection(FilterCriteria criteria) {
    return _FilterSection(
      title: '位置',
      child: Wrap(
        spacing: _FilterConstants.itemSpacing,
        runSpacing: _FilterConstants.itemSpacing,
        children: _FilterConstants.filterData['position']!.map((position) {
          final isSelected = criteria.positions.contains(position);
          return _FilterTag(
            text: position,
            isSelected: isSelected,
            onTap: () => _controller.togglePosition(position),
          );
        }).toList(),
      ),
    );
  }
  
  /// 构建标签筛选区段
  Widget _buildTagsSection(FilterCriteria criteria) {
    return _FilterSection(
      title: '标签',
      child: Wrap(
        spacing: _FilterConstants.itemSpacing,
        runSpacing: _FilterConstants.itemSpacing,
        children: _FilterConstants.filterData['tags']!.map((tag) {
          final isSelected = criteria.tags.contains(tag);
          return _FilterTag(
            text: tag,
            isSelected: isSelected,
            onTap: () => _controller.toggleTag(tag),
          );
        }).toList(),
      ),
    );
  }
  
  /// 构建底部操作栏
  Widget _buildBottomActions(FilterPageState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 重置按钮
              Expanded(
                child: OutlinedButton(
                  onPressed: state.isLoading ? null : () => _controller.resetFilters(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(_FilterConstants.primaryColor),
                    side: const BorderSide(
                      color: Color(_FilterConstants.primaryColor),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('重置'),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 完成按钮
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : () => _handleApplyFilters(state.criteria),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(_FilterConstants.primaryColor),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          '完成 (${state.criteria.estimatedUserCount})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 处理应用筛选
  Future<void> _handleApplyFilters(FilterCriteria criteria) async {
    await _controller.applyFilters();
    
    // 提供触觉反馈
    HapticFeedback.lightImpact();
    
    // 回调给父页面
    widget.onFiltersApplied?.call(criteria);
    
    // 返回结果
    if (mounted) {
      Navigator.pop(context, criteria);
    }
  }
}

// ============== 8. EXPORTS ==============
// 导出筛选相关类供外部使用
