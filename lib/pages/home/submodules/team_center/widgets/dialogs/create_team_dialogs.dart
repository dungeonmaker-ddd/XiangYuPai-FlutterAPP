// 🎯 发布组局选择器对话框 - 实现约定项的详细配置选择器
// 基于架构设计文档的时间、地点、定价、人数、截止时间选择器

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Dart核心库
import 'dart:developer' as developer;

// 项目内部文件
import '../../pages/create/create_team_page_enhanced.dart'; // 增强版页面配置模型
import '../../models/join_models.dart'; // 报名相关模型（包含PaymentMethod）

// ============== 2. CONSTANTS ==============
/// 🎨 选择器对话框常量
class _DialogConstants {
  const _DialogConstants._();

  // 颜色配置
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color backgroundGray = Color(0xFFF5F5F7);
  static const Color cardWhite = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color successGreen = Color(0xFF10B981);

  // 动画配置
  static const Duration animationDuration = Duration(milliseconds: 300);

  // 对话框配置
  static const double dialogBorderRadius = 20.0;
  static const double dialogPadding = 24.0;
}

// ============== 3. WIDGETS ==============
/// 🧩 选择器对话框组件

/// 🕐 时间选择对话框
class CustomTimePickerDialog extends StatefulWidget {
  final TimeConfiguration initialConfig;
  final ValueChanged<TimeConfiguration> onConfigChanged;

  const CustomTimePickerDialog({
    super.key,
    required this.initialConfig,
    required this.onConfigChanged,
  });

  @override
  State<CustomTimePickerDialog> createState() => _CustomTimePickerDialogState();

  /// 显示时间选择对话框
  static Future<TimeConfiguration?> show(
    BuildContext context,
    TimeConfiguration initialConfig,
  ) async {
    return showDialog<TimeConfiguration>(
      context: context,
      builder: (context) => CustomTimePickerDialog(
        initialConfig: initialConfig,
        onConfigChanged: (config) => Navigator.pop(context, config),
      ),
    );
  }
}

class _CustomTimePickerDialogState extends State<CustomTimePickerDialog> {
  late TimeConfiguration _config;
  late PageController _pageController;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: _DialogConstants.cardWhite,
          borderRadius: BorderRadius.circular(
            _DialogConstants.dialogBorderRadius,
          ),
        ),
        child: Column(
          children: [
            // 头部标题栏
            _buildHeader(),

            // 步骤指示器
            _buildStepIndicator(),

            // 内容区域
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildDatePickerStep(),
                  _buildTimePickerStep(),
                  _buildDurationStep(),
                ],
              ),
            ),

            // 底部按钮
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _DialogConstants.borderGray, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: _DialogConstants.primaryPurple, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '设置活动时间',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _DialogConstants.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: _DialogConstants.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _DialogConstants.dialogPadding,
      ),
      child: Row(
        children: [
          _buildStepItem(0, '日期', Icons.calendar_today),
          Expanded(child: _buildStepConnector(0)),
          _buildStepItem(1, '时间', Icons.access_time),
          Expanded(child: _buildStepConnector(1)),
          _buildStepItem(2, '时长', Icons.timer),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String title, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _isStepCompleted(step);

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted || isActive
                ? _DialogConstants.primaryPurple
                : _DialogConstants.borderGray,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isCompleted || isActive
                ? Colors.white
                : _DialogConstants.textSecondary,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isCompleted || isActive
                ? _DialogConstants.primaryPurple
                : _DialogConstants.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = _isStepCompleted(step + 1);

    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isCompleted
            ? _DialogConstants.primaryPurple
            : _DialogConstants.borderGray,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  bool _isStepCompleted(int step) {
    switch (step) {
      case 0:
        return _config.activityDate != null;
      case 1:
        return _config.startTime != null;
      case 2:
        return _config.endTime != null || _config.duration != null;
      default:
        return false;
    }
  }

  Widget _buildDatePickerStep() {
    return Padding(
      padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择活动日期',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _DialogConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: CalendarDatePicker(
              initialDate:
                  _config.activityDate ??
                  DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
              onDateChanged: (date) {
                setState(() {
                  _config = _config.copyWith(activityDate: date);
                });
              },
            ),
          ),

          if (_config.activityDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _DialogConstants.successGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: _DialogConstants.successGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '已选择：${_config.activityDate!.month}月${_config.activityDate!.day}日',
                    style: TextStyle(
                      fontSize: 14,
                      color: _DialogConstants.successGreen,
                      fontWeight: FontWeight.w600,
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

  Widget _buildTimePickerStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择开始时间',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _DialogConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // 快速时间选择
            _buildQuickTimeOptions(),

            const SizedBox(height: 20),

            // 自定义时间选择
            Text(
              '或自定义时间',
              style: TextStyle(
                fontSize: 14,
                color: _DialogConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: _config.startTime != null
                    ? DateTime.now().copyWith(
                        hour: _config.startTime!.hour,
                        minute: _config.startTime!.minute,
                      )
                    : DateTime.now().add(const Duration(hours: 2)),
                onDateTimeChanged: (dateTime) {
                  setState(() {
                    _config = _config.copyWith(
                      startTime: TimeOfDay.fromDateTime(dateTime),
                    );
                  });
                },
              ),
            ),

            if (_config.startTime != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _DialogConstants.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: _DialogConstants.successGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '开始时间：${_config.startTime!.hour.toString().padLeft(2, '0')}:${_config.startTime!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _DialogConstants.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTimeOptions() {
    final quickOptions = [
      (
        '上午',
        [
          TimeOfDay(hour: 9, minute: 0),
          TimeOfDay(hour: 10, minute: 0),
          TimeOfDay(hour: 11, minute: 0),
        ],
      ),
      (
        '下午',
        [
          TimeOfDay(hour: 14, minute: 0),
          TimeOfDay(hour: 15, minute: 0),
          TimeOfDay(hour: 16, minute: 0),
        ],
      ),
      (
        '晚上',
        [
          TimeOfDay(hour: 18, minute: 0),
          TimeOfDay(hour: 19, minute: 0),
          TimeOfDay(hour: 20, minute: 0),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速选择',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _DialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        ...quickOptions.map((group) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.$1,
                style: TextStyle(
                  fontSize: 12,
                  color: _DialogConstants.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: group.$2.map((time) {
                  final isSelected = _config.startTime == time;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _config = _config.copyWith(startTime: time);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _DialogConstants.primaryPurple
                            : _DialogConstants.backgroundGray,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? _DialogConstants.primaryPurple
                              : _DialogConstants.borderGray,
                        ),
                      ),
                      child: Text(
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white
                              : _DialogConstants.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDurationStep() {
    return Padding(
      padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '设置活动时长',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _DialogConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // 快速时长选择
          _buildQuickDurationOptions(),

          const SizedBox(height: 20),

          // 自定义结束时间
          Text(
            '或设置结束时间',
            style: TextStyle(
              fontSize: 14,
              color: _DialogConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: _config.endTime != null
                  ? DateTime.now().copyWith(
                      hour: _config.endTime!.hour,
                      minute: _config.endTime!.minute,
                    )
                  : DateTime.now().add(const Duration(hours: 4)),
              onDateTimeChanged: (dateTime) {
                setState(() {
                  _config = _config.copyWith(
                    endTime: TimeOfDay.fromDateTime(dateTime),
                    duration: null, // 清除时长设置
                  );
                });
              },
            ),
          ),

          if (_config.endTime != null || _config.duration != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _DialogConstants.successGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: _DialogConstants.successGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _config.endTime != null
                          ? '结束时间：${_config.endTime!.hour.toString().padLeft(2, '0')}:${_config.endTime!.minute.toString().padLeft(2, '0')}'
                          : '活动时长：${_config.duration!.inHours}小时',
                      style: TextStyle(
                        fontSize: 14,
                        color: _DialogConstants.successGreen,
                        fontWeight: FontWeight.w600,
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

  Widget _buildQuickDurationOptions() {
    final quickDurations = [
      Duration(hours: 1),
      Duration(hours: 2),
      Duration(hours: 3),
      Duration(hours: 4),
      Duration(hours: 6),
      Duration(hours: 8),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '常用时长',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _DialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: quickDurations.map((duration) {
            final isSelected = _config.duration == duration;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _config = _config.copyWith(
                    duration: duration,
                    endTime: null, // 清除结束时间设置
                  );
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _DialogConstants.primaryPurple
                      : _DialogConstants.backgroundGray,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? _DialogConstants.primaryPurple
                        : _DialogConstants.borderGray,
                  ),
                ),
                child: Text(
                  '${duration.inHours}小时',
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? Colors.white
                        : _DialogConstants.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _DialogConstants.borderGray, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _DialogConstants.primaryPurple,
                  side: BorderSide(color: _DialogConstants.primaryPurple),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('上一步'),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 12),

          Expanded(
            child: ElevatedButton(
              onPressed: _canGoToNextStep() ? _goToNextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _DialogConstants.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(_currentStep == 2 ? '确认' : '下一步'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canGoToNextStep() {
    switch (_currentStep) {
      case 0:
        return _config.activityDate != null;
      case 1:
        return _config.startTime != null;
      case 2:
        return _config.endTime != null || _config.duration != null;
      default:
        return false;
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: _DialogConstants.animationDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: _DialogConstants.animationDuration,
        curve: Curves.easeInOut,
      );
    } else {
      // 完成配置
      widget.onConfigChanged(_config);
    }
  }
}

/// 📍 地点选择对话框
class LocationPickerDialog extends StatefulWidget {
  final LocationConfiguration initialConfig;
  final ValueChanged<LocationConfiguration> onConfigChanged;

  const LocationPickerDialog({
    super.key,
    required this.initialConfig,
    required this.onConfigChanged,
  });

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();

  /// 显示地点选择对话框
  static Future<LocationConfiguration?> show(
    BuildContext context,
    LocationConfiguration initialConfig,
  ) async {
    return showDialog<LocationConfiguration>(
      context: context,
      builder: (context) => LocationPickerDialog(
        initialConfig: initialConfig,
        onConfigChanged: (config) => Navigator.pop(context, config),
      ),
    );
  }
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  late LocationConfiguration _config;
  final _searchController = TextEditingController();
  final _detailController = TextEditingController();
  bool _isSearching = false;
  List<String> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig;
    _searchController.text = _config.address ?? '';
    _detailController.text = _config.detailAddress ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: _DialogConstants.cardWhite,
          borderRadius: BorderRadius.circular(
            _DialogConstants.dialogBorderRadius,
          ),
        ),
        child: Column(
          children: [
            // 头部标题栏
            _buildHeader(),

            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 当前位置按钮
                    _buildCurrentLocationButton(),

                    const SizedBox(height: 20),

                    // 地址搜索
                    _buildAddressSearch(),

                    const SizedBox(height: 20),

                    // 详细地址
                    _buildDetailAddress(),

                    const SizedBox(height: 20),

                    // 常用地点
                    _buildCommonLocations(),
                  ],
                ),
              ),
            ),

            // 底部按钮
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _DialogConstants.borderGray, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: _DialogConstants.primaryPurple,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '选择活动地点',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _DialogConstants.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: _DialogConstants.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationButton() {
    return Container(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _useCurrentLocation,
        icon: Icon(Icons.my_location, color: _DialogConstants.primaryPurple),
        label: Text(
          '使用当前位置',
          style: TextStyle(
            color: _DialogConstants.primaryPurple,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _DialogConstants.primaryPurple),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildAddressSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '搜索地址',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _DialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '输入地址进行搜索...',
            prefixIcon: Icon(
              Icons.search,
              color: _DialogConstants.textSecondary,
            ),
            suffixIcon: _isSearching
                ? Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.all(14),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _DialogConstants.primaryPurple,
                      ),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _DialogConstants.borderGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _DialogConstants.primaryPurple,
                width: 2,
              ),
            ),
          ),
          onChanged: _searchAddress,
        ),

        // 搜索结果
        if (_searchResults.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: _DialogConstants.borderGray),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: _searchResults.map((result) {
                return ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: _DialogConstants.textSecondary,
                  ),
                  title: Text(result),
                  onTap: () => _selectSearchResult(result),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '详细地址（可选）',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _DialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _detailController,
          decoration: InputDecoration(
            hintText: '楼层、房间号等详细信息...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _DialogConstants.borderGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _DialogConstants.primaryPurple,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _config = _config.copyWith(detailAddress: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildCommonLocations() {
    final commonLocations = [
      '北京市朝阳区三里屯',
      '北京市海淀区中关村',
      '北京市东城区王府井',
      '北京市西城区西单',
      '北京市丰台区丽泽商务区',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '常用地点',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _DialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        ...commonLocations.map((location) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                Icons.location_on_outlined,
                color: _DialogConstants.textSecondary,
              ),
              title: Text(location),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: _DialogConstants.textSecondary,
              ),
              onTap: () => _selectCommonLocation(location),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: _DialogConstants.borderGray),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBottomButtons() {
    final isValid = _config.address != null && _config.address!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _DialogConstants.borderGray, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: _DialogConstants.textSecondary,
                side: BorderSide(color: _DialogConstants.borderGray),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('取消'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isValid ? _confirmSelection : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _DialogConstants.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('确认'),
            ),
          ),
        ],
      ),
    );
  }

  void _useCurrentLocation() async {
    // TODO: 实现GPS定位
    developer.log('使用当前位置');

    // 模拟定位
    setState(() {
      _config = _config.copyWith(
        address: '北京市朝阳区三里屯SOHO',
        detailAddress: '3号楼15层',
        latitude: 39.9389,
        longitude: 116.4467,
        distance: 0.0,
      );
      _searchController.text = _config.address!;
      _detailController.text = _config.detailAddress!;
    });
  }

  void _searchAddress(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    // TODO: 实现真实的地址搜索
    developer.log('搜索地址: $query');

    // 模拟搜索结果
    setState(() {
      _isSearching = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [
            '$query - 详细地址1',
            '$query - 详细地址2',
            '$query - 详细地址3',
          ];
        });
      }
    });
  }

  void _selectSearchResult(String result) {
    setState(() {
      _config = _config.copyWith(
        address: result,
        latitude: 39.9 + (result.hashCode % 100) / 1000,
        longitude: 116.4 + (result.hashCode % 100) / 1000,
        distance: (result.hashCode % 50) / 10,
      );
      _searchController.text = result;
      _searchResults.clear();
    });
  }

  void _selectCommonLocation(String location) {
    setState(() {
      _config = _config.copyWith(
        address: location,
        latitude: 39.9 + (location.hashCode % 100) / 1000,
        longitude: 116.4 + (location.hashCode % 100) / 1000,
        distance: (location.hashCode % 50) / 10,
      );
      _searchController.text = location;
    });
  }

  void _confirmSelection() {
    widget.onConfigChanged(_config);
  }
}

/// 💰 定价配置对话框
class PricingConfigDialog extends StatefulWidget {
  final PricingConfiguration initialConfig;
  final ValueChanged<PricingConfiguration> onConfigChanged;

  const PricingConfigDialog({
    super.key,
    required this.initialConfig,
    required this.onConfigChanged,
  });

  @override
  State<PricingConfigDialog> createState() => _PricingConfigDialogState();

  /// 显示定价配置对话框
  static Future<PricingConfiguration?> show(
    BuildContext context,
    PricingConfiguration initialConfig,
  ) async {
    return showDialog<PricingConfiguration>(
      context: context,
      builder: (context) => PricingConfigDialog(
        initialConfig: initialConfig,
        onConfigChanged: (config) => Navigator.pop(context, config),
      ),
    );
  }
}

class _PricingConfigDialogState extends State<PricingConfigDialog> {
  late PricingConfiguration _config;
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig;
    if (_config.price != null) {
      _priceController.text = _config.price!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: _DialogConstants.cardWhite,
          borderRadius: BorderRadius.circular(
            _DialogConstants.dialogBorderRadius,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部标题栏
            _buildHeader(),

            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 价格输入
                    _buildPriceInput(),

                    const SizedBox(height: 20),

                    // 计费方式选择
                    _buildPricingMethodSelection(),

                    const SizedBox(height: 20),

                    // 支付方式选择
                    _buildPaymentMethodSelection(),

                    const SizedBox(height: 20),

                    // 价格预览
                    _buildPricePreview(),
                  ],
                ),
              ),
            ),

            // 底部按钮
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _DialogConstants.borderGray, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.monetization_on,
            color: _DialogConstants.primaryPurple,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '设置活动定价',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _DialogConstants.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: _DialogConstants.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '设置价格',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _DialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '输入价格',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _DialogConstants.borderGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _DialogConstants.primaryPurple,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  final price = double.tryParse(value);
                  setState(() {
                    _config = _config.copyWith(price: price);
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _config.priceUnit ?? '金币',
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _DialogConstants.borderGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _DialogConstants.primaryPurple,
                      width: 2,
                    ),
                  ),
                ),
                items: ['金币', '元'].map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (unit) {
                  setState(() {
                    _config = _config.copyWith(priceUnit: unit);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '计费方式',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _DialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        ...PricingMethod.values.map((method) {
          final isSelected = _config.method == method;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _config = _config.copyWith(method: method);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _DialogConstants.primaryPurple.withValues(alpha: 0.1)
                      : _DialogConstants.backgroundGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? _DialogConstants.primaryPurple
                        : _DialogConstants.borderGray,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _DialogConstants.primaryPurple
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? _DialogConstants.primaryPurple
                              : _DialogConstants.borderGray,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        method.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? _DialogConstants.primaryPurple
                              : _DialogConstants.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '支付方式',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _DialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        ...PaymentMethod.values.map((method) {
          final isSelected = _config.paymentMethod == method;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _config = _config.copyWith(paymentMethod: method);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _DialogConstants.primaryPurple.withValues(alpha: 0.1)
                      : _DialogConstants.backgroundGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? _DialogConstants.primaryPurple
                        : _DialogConstants.borderGray,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _DialogConstants.primaryPurple
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? _DialogConstants.primaryPurple
                              : _DialogConstants.borderGray,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        method.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? _DialogConstants.primaryPurple
                              : _DialogConstants.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPricePreview() {
    if (!_config.isComplete) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DialogConstants.successGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: _DialogConstants.successGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '价格预览',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _DialogConstants.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            _config.displayText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _DialogConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            '支付方式：${_config.paymentMethod?.displayName ?? "未设置"}',
            style: TextStyle(
              fontSize: 12,
              color: _DialogConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    final isValid = _config.isComplete;

    return Container(
      padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _DialogConstants.borderGray, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: _DialogConstants.textSecondary,
                side: BorderSide(color: _DialogConstants.borderGray),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('取消'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isValid ? _confirmConfiguration : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _DialogConstants.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('确认'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmConfiguration() {
    widget.onConfigChanged(_config);
  }
}

/// 👥 人数配置对话框
class ParticipantConfigDialog extends StatefulWidget {
  final ParticipantConfiguration initialConfig;
  final ValueChanged<ParticipantConfiguration> onConfigChanged;

  const ParticipantConfigDialog({
    super.key,
    required this.initialConfig,
    required this.onConfigChanged,
  });

  @override
  State<ParticipantConfigDialog> createState() =>
      _ParticipantConfigDialogState();

  /// 显示人数配置对话框
  static Future<ParticipantConfiguration?> show(
    BuildContext context,
    ParticipantConfiguration initialConfig,
  ) async {
    return showDialog<ParticipantConfiguration>(
      context: context,
      builder: (context) => ParticipantConfigDialog(
        initialConfig: initialConfig,
        onConfigChanged: (config) => Navigator.pop(context, config),
      ),
    );
  }
}

class _ParticipantConfigDialogState extends State<ParticipantConfigDialog> {
  late ParticipantConfiguration _config;

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: _DialogConstants.cardWhite,
          borderRadius: BorderRadius.circular(
            _DialogConstants.dialogBorderRadius,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部标题栏
            _buildHeader(),

            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 人数设置
                    _buildParticipantCountSection(),

                    const SizedBox(height: 20),

                    // 性别比例设置
                    _buildGenderRatioSection(),

                    const SizedBox(height: 20),

                    // 年龄限制设置
                    _buildAgeRangeSection(),

                    const SizedBox(height: 20),

                    // 配置预览
                    _buildConfigPreview(),
                  ],
                ),
              ),
            ),

            // 底部按钮
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _DialogConstants.borderGray, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.group, color: _DialogConstants.primaryPurple, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '设置参与人数',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _DialogConstants.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: _DialogConstants.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '人数限制',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _DialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // 快速人数选择
        Text(
          '常用人数',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _DialogConstants.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [2, 3, 4, 5, 6, 8, 10].map((count) {
            final isSelected = _config.maxParticipants == count;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _config = _config.copyWith(
                    maxParticipants: count,
                    minParticipants: count <= 3 ? 2 : 3,
                  );
                });
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? _DialogConstants.primaryPurple
                      : _DialogConstants.backgroundGray,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? _DialogConstants.primaryPurple
                        : _DialogConstants.borderGray,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : _DialogConstants.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // 自定义人数范围
        Text(
          '自定义范围',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _DialogConstants.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最少人数',
                    style: TextStyle(
                      fontSize: 12,
                      color: _DialogConstants.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 48,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            final current = _config.minParticipants ?? 1;
                            if (current > 1) {
                              setState(() {
                                _config = _config.copyWith(
                                  minParticipants: current - 1,
                                );
                              });
                            }
                          },
                          icon: Icon(Icons.remove_circle_outline),
                          color: _DialogConstants.textSecondary,
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '${_config.minParticipants ?? 1}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _DialogConstants.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final current = _config.minParticipants ?? 1;
                            final max = _config.maxParticipants ?? 10;
                            if (current < max) {
                              setState(() {
                                _config = _config.copyWith(
                                  minParticipants: current + 1,
                                );
                              });
                            }
                          },
                          icon: Icon(Icons.add_circle_outline),
                          color: _DialogConstants.primaryPurple,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最多人数',
                    style: TextStyle(
                      fontSize: 12,
                      color: _DialogConstants.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 48,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            final current = _config.maxParticipants ?? 2;
                            final min = _config.minParticipants ?? 1;
                            if (current > min) {
                              setState(() {
                                _config = _config.copyWith(
                                  maxParticipants: current - 1,
                                );
                              });
                            }
                          },
                          icon: Icon(Icons.remove_circle_outline),
                          color: _DialogConstants.textSecondary,
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '${_config.maxParticipants ?? 2}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _DialogConstants.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final current = _config.maxParticipants ?? 2;
                            if (current < 50) {
                              setState(() {
                                _config = _config.copyWith(
                                  maxParticipants: current + 1,
                                );
                              });
                            }
                          },
                          icon: Icon(Icons.add_circle_outline),
                          color: _DialogConstants.primaryPurple,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderRatioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '性别要求',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _DialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        ...GenderRatio.values.map((ratio) {
          final isSelected = _config.genderRatio == ratio;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _config = _config.copyWith(genderRatio: ratio);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _DialogConstants.primaryPurple.withValues(alpha: 0.1)
                      : _DialogConstants.backgroundGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? _DialogConstants.primaryPurple
                        : _DialogConstants.borderGray,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _DialogConstants.primaryPurple
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? _DialogConstants.primaryPurple
                              : _DialogConstants.borderGray,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check, size: 10, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      ratio.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? _DialogConstants.primaryPurple
                            : _DialogConstants.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAgeRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '年龄要求',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _DialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        ...AgeRange.values.map((range) {
          final isSelected = _config.ageRange == range;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _config = _config.copyWith(ageRange: range);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _DialogConstants.primaryPurple.withValues(alpha: 0.1)
                      : _DialogConstants.backgroundGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? _DialogConstants.primaryPurple
                        : _DialogConstants.borderGray,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _DialogConstants.primaryPurple
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? _DialogConstants.primaryPurple
                              : _DialogConstants.borderGray,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check, size: 10, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      range.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? _DialogConstants.primaryPurple
                            : _DialogConstants.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildConfigPreview() {
    if (!_config.isComplete) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DialogConstants.successGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: _DialogConstants.successGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '配置预览',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _DialogConstants.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            _config.displayText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _DialogConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    final isValid = _config.isComplete;

    return Container(
      padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _DialogConstants.borderGray, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: _DialogConstants.textSecondary,
                side: BorderSide(color: _DialogConstants.borderGray),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('取消'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isValid ? _confirmConfiguration : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _DialogConstants.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('确认'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmConfiguration() {
    widget.onConfigChanged(_config);
  }
}

/// ⏰ 截止时间选择对话框
class DeadlinePickerDialog extends StatefulWidget {
  final DeadlineConfiguration initialConfig;
  final DateTime? activityTime;
  final ValueChanged<DeadlineConfiguration> onConfigChanged;

  const DeadlinePickerDialog({
    super.key,
    required this.initialConfig,
    required this.onConfigChanged,
    this.activityTime,
  });

  @override
  State<DeadlinePickerDialog> createState() => _DeadlinePickerDialogState();

  /// 显示截止时间选择对话框
  static Future<DeadlineConfiguration?> show(
    BuildContext context,
    DeadlineConfiguration initialConfig, {
    DateTime? activityTime,
  }) async {
    return showDialog<DeadlineConfiguration>(
      context: context,
      builder: (context) => DeadlinePickerDialog(
        initialConfig: initialConfig,
        activityTime: activityTime,
        onConfigChanged: (config) => Navigator.pop(context, config),
      ),
    );
  }
}

class _DeadlinePickerDialogState extends State<DeadlinePickerDialog> {
  late DeadlineConfiguration _config;

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: _DialogConstants.cardWhite,
          borderRadius: BorderRadius.circular(
            _DialogConstants.dialogBorderRadius,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部标题栏
            _buildHeader(),

            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 快速选择
                    _buildQuickDeadlineOptions(),

                    const SizedBox(height: 20),

                    // 自定义时间
                    _buildCustomTimeSelection(),

                    const SizedBox(height: 20),

                    // 预览
                    _buildDeadlinePreview(),
                  ],
                ),
              ),
            ),

            // 底部按钮
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _DialogConstants.borderGray, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: _DialogConstants.primaryPurple, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '设置报名截止时间',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _DialogConstants.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: _DialogConstants.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDeadlineOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速选择',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _DialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        ...QuickDeadline.values.map((option) {
          final isSelected = _config.quickOption == option;
          final deadline = _calculateQuickDeadline(option);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _config = _config.copyWith(
                    quickOption: option,
                    deadline: deadline,
                  );
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _DialogConstants.primaryPurple.withOpacity(0.1)
                      : _DialogConstants.backgroundGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? _DialogConstants.primaryPurple
                        : _DialogConstants.borderGray,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _DialogConstants.primaryPurple
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? _DialogConstants.primaryPurple
                              : _DialogConstants.borderGray,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? _DialogConstants.primaryPurple
                                  : _DialogConstants.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(deadline),
                            style: TextStyle(
                              fontSize: 12,
                              color: _DialogConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCustomTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '自定义时间',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _DialogConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          height: 200,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.dateAndTime,
            initialDateTime:
                _config.deadline ??
                DateTime.now().add(const Duration(hours: 6)),
            minimumDate: DateTime.now(),
            maximumDate:
                widget.activityTime ??
                DateTime.now().add(const Duration(days: 30)),
            onDateTimeChanged: (dateTime) {
              setState(() {
                _config = _config.copyWith(
                  deadline: dateTime,
                  quickOption: null, // 清除快速选择
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlinePreview() {
    if (!_config.isComplete) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DialogConstants.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: _DialogConstants.successGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '截止时间预览',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _DialogConstants.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            _formatDateTime(_config.deadline!),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _DialogConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            _config.displayText,
            style: TextStyle(
              fontSize: 12,
              color: _DialogConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    final isValid = _config.isComplete;

    return Container(
      padding: const EdgeInsets.all(_DialogConstants.dialogPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _DialogConstants.borderGray, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: _DialogConstants.textSecondary,
                side: BorderSide(color: _DialogConstants.borderGray),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('取消'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isValid ? _confirmConfiguration : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _DialogConstants.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('确认'),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _calculateQuickDeadline(QuickDeadline option) {
    final activityTime =
        widget.activityTime ?? DateTime.now().add(const Duration(hours: 12));
    return activityTime.subtract(option.duration);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _confirmConfiguration() {
    widget.onConfigChanged(_config);
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
///
/// 本文件自动导出的公共类：
/// - CustomTimePickerDialog: 时间选择对话框（public class）
/// - LocationPickerDialog: 地点选择对话框（public class）
/// - PricingConfigDialog: 定价配置对话框（public class）
/// - ParticipantConfigDialog: 人数配置对话框（public class）
/// - DeadlinePickerDialog: 截止时间选择对话框（public class）
///
/// 使用方式：
/// ```dart
/// import 'create_team_dialogs.dart';
///
/// // 显示时间选择对话框
/// final timeConfig = await TimePickerDialog.show(context, initialConfig);
///
/// // 显示地点选择对话框
/// final locationConfig = await LocationPickerDialog.show(context, initialConfig);
///
/// // 显示定价配置对话框
/// final pricingConfig = await PricingConfigDialog.show(context, initialConfig);
/// ```
