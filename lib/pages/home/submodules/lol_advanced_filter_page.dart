// 🔧 LOL高级筛选页面 - 单文件架构完整实现
// 全屏筛选弹窗，支持多维度筛选条件设置

// ============== 1. IMPORTS ==============
import 'package:flutter/material.dart';
import 'lol_service_filter_page.dart'; // 引用LOL筛选页面的模型

// ============== 2. CONSTANTS ==============
class _AdvancedFilterConstants {
  const _AdvancedFilterConstants._();
  
  static const int primaryPurple = 0xFF8B5CF6;
  static const int selectedColor = 0xFF8B5CF6;
  static const int unselectedColor = 0xFFF3F4F6;
  static const double tagBorderRadius = 12.0;
  static const double sectionSpacing = 24.0;
}

// ============== 3. MODELS ==============
// 复用 lol_service_filter_page.dart 中的 LOLFilterModel

// ============== 4. SERVICES ==============
// 无需额外服务，直接使用筛选逻辑

// ============== 5. CONTROLLERS ==============
/// 🔧 高级筛选控制器
class _AdvancedFilterController extends ValueNotifier<LOLFilterModel> {
  _AdvancedFilterController(LOLFilterModel initialFilter) : super(initialFilter);
  
  /// 更新状态筛选
  void updateStatus(String? status) {
    value = value.copyWith(statusFilter: status);
  }
  
  /// 更新大区筛选
  void updateRegion(String? region) {
    value = value.copyWith(regionFilter: region);
  }
  
  /// 更新段位筛选
  void updateRank(String? rank) {
    value = value.copyWith(rankFilter: rank);
  }
  
  /// 更新价格筛选
  void updatePrice(String? price) {
    value = value.copyWith(priceRange: price);
  }
  
  /// 更新位置筛选
  void updatePosition(String? position) {
    value = value.copyWith(positionFilter: position);
  }
  
  /// 更新标签筛选
  void updateTags(List<String> tags) {
    value = value.copyWith(selectedTags: tags);
  }
  
  /// 切换标签选中状态
  void toggleTag(String tag) {
    final currentTags = List<String>.from(value.selectedTags);
    if (currentTags.contains(tag)) {
      currentTags.remove(tag);
    } else {
      currentTags.add(tag);
    }
    updateTags(currentTags);
  }
  
  /// 更新同城筛选
  void updateLocal(bool isLocal) {
    value = value.copyWith(isLocal: isLocal);
  }
  
  /// 重置所有筛选条件
  void reset() {
    value = const LOLFilterModel(
      sortType: '智能排序', // 保持排序类型
      genderFilter: '不限时别', // 保持性别筛选
    );
  }
}

// ============== 6. WIDGETS ==============
/// 🏷️ 筛选标签组件
class _FilterTagWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterTagWidget({
    required this.text,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(_AdvancedFilterConstants.selectedColor)
              : const Color(_AdvancedFilterConstants.unselectedColor),
          borderRadius: BorderRadius.circular(_AdvancedFilterConstants.tagBorderRadius),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

/// 📊 筛选分组组件
class _FilterSectionWidget extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?>? onChanged;
  final bool allowMultiple;

  const _FilterSectionWidget({
    required this.title,
    required this.options,
    this.selectedOption,
    this.onChanged,
    this.allowMultiple = false,
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
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = selectedOption == option;
            return _FilterTagWidget(
              text: option,
              isSelected: isSelected,
              onTap: () {
                if (isSelected && !allowMultiple) {
                  onChanged?.call(null); // 取消选择
                } else {
                  onChanged?.call(option);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// 🏷️ 多选标签分组组件
class _MultiSelectFilterSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final List<String> selectedOptions;
  final ValueChanged<List<String>>? onChanged;

  const _MultiSelectFilterSection({
    required this.title,
    required this.options,
    this.selectedOptions = const [],
    this.onChanged,
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
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            return _FilterTagWidget(
              text: option,
              isSelected: isSelected,
              onTap: () {
                final newSelection = List<String>.from(selectedOptions);
                if (isSelected) {
                  newSelection.remove(option);
                } else {
                  newSelection.add(option);
                }
                onChanged?.call(newSelection);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ============== 7. PAGES ==============
/// 🔧 LOL高级筛选页面
class LOLAdvancedFilterPage extends StatefulWidget {
  final LOLFilterModel initialFilter;
  final ValueChanged<LOLFilterModel>? onFilterChanged;

  const LOLAdvancedFilterPage({
    super.key,
    required this.initialFilter,
    this.onFilterChanged,
  });

  @override
  State<LOLAdvancedFilterPage> createState() => _LOLAdvancedFilterPageState();
}

class _LOLAdvancedFilterPageState extends State<LOLAdvancedFilterPage> {
  late final _AdvancedFilterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _AdvancedFilterController(widget.initialFilter);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('筛选'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _handleReset,
            child: const Text(
              '重置',
              style: TextStyle(
                color: Color(_AdvancedFilterConstants.primaryPurple),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<LOLFilterModel>(
        valueListenable: _controller,
        builder: (context, filter, child) {
          return Column(
            children: [
              // 筛选内容区域
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 状态筛选
                      _FilterSectionWidget(
                        title: '状态',
                        options: const ['在线', '离线'],
                        selectedOption: filter.statusFilter,
                        onChanged: _controller.updateStatus,
                      ),
                      const SizedBox(height: _AdvancedFilterConstants.sectionSpacing),
                      
                      // 大区筛选
                      _FilterSectionWidget(
                        title: '大区',
                        options: const ['QQ区', '微信区'],
                        selectedOption: filter.regionFilter,
                        onChanged: _controller.updateRegion,
                      ),
                      const SizedBox(height: _AdvancedFilterConstants.sectionSpacing),
                      
                      // 段位筛选
                      _FilterSectionWidget(
                        title: '段位',
                        options: const ['青铜白金', '永恒钻石', '至尊星耀', '最强王者'],
                        selectedOption: filter.rankFilter,
                        onChanged: _controller.updateRank,
                      ),
                      const SizedBox(height: _AdvancedFilterConstants.sectionSpacing),
                      
                      // 价格筛选
                      _FilterSectionWidget(
                        title: '价格',
                        options: const ['4-9元', '10-19元', '20元以上'],
                        selectedOption: filter.priceRange,
                        onChanged: _controller.updatePrice,
                      ),
                      const SizedBox(height: _AdvancedFilterConstants.sectionSpacing),
                      
                      // 位置筛选
                      _FilterSectionWidget(
                        title: '位置',
                        options: const ['打野', '上路', '中路', '下路', '辅助', '全部'],
                        selectedOption: filter.positionFilter,
                        onChanged: _controller.updatePosition,
                      ),
                      const SizedBox(height: _AdvancedFilterConstants.sectionSpacing),
                      
                      // 标签筛选（多选）
                      _MultiSelectFilterSection(
                        title: '标签',
                        options: const ['英雄王者', '大神认证', '高质量', '专精上分', '暴力认证', '声音甜美'],
                        selectedOptions: filter.selectedTags,
                        onChanged: _controller.updateTags,
                      ),
                      const SizedBox(height: _AdvancedFilterConstants.sectionSpacing),
                      
                      // 所在地筛选
                      Row(
                        children: [
                          const Text(
                            '所在地',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _FilterTagWidget(
                            text: '同城',
                            isSelected: filter.isLocal,
                            onTap: () => _controller.updateLocal(!filter.isLocal),
                          ),
                        ],
                      ),
                      
                      // 底部占位
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              
              // 底部完成按钮
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _handleComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(_AdvancedFilterConstants.primaryPurple),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '完成',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 处理重置
  void _handleReset() {
    _controller.reset();
  }

  /// 处理完成
  void _handleComplete() {
    widget.onFilterChanged?.call(_controller.value);
    Navigator.pop(context, _controller.value);
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
