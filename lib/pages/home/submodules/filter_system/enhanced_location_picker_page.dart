// 🌍 增强版区域选择页面 - 基于原型图的单文件架构实现
// 3×3网格布局，"全深圳"默认选中，符合UI原型图设计

// ============== 1. IMPORTS ==============
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

// ============== 2. CONSTANTS ==============
/// 🎨 区域选择页面私有常量
class _RegionPickerConstants {
  const _RegionPickerConstants._();
  
  // 布局配置
  static const int gridColumns = 3;
  static const double gridSpacing = 12.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonHeight = 44.0;
  
  // 深圳区域数据（基于原型图）
  static const List<String> shenzhenDistricts = [
    '全深圳',   // 默认选中
    '南山区',
    '宝安区',
    '南山区',   // 原型图中的重复区域
    '南山区',
    '宝安区',
    '南山区',
    '南山区',
    '宝安区',
  ];
  
  // 颜色配置
  static const int selectedColor = 0xFF8B5CF6;    // 紫色选中
  static const int unselectedColor = 0xFFF5F5F5;  // 灰色未选中
  static const int borderColor = 0xFFE5E7EB;      // 边框颜色
}

// ============== 3. MODELS ==============
/// 📋 区域选择状态模型
class RegionPickerState {
  final bool isLoading;
  final String? errorMessage;
  final String selectedRegion;
  final List<String> availableRegions;
  
  const RegionPickerState({
    this.isLoading = false,
    this.errorMessage,
    this.selectedRegion = '全深圳',  // 默认选中全深圳
    this.availableRegions = _RegionPickerConstants.shenzhenDistricts,
  });
  
  RegionPickerState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? selectedRegion,
    List<String>? availableRegions,
  }) {
    return RegionPickerState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      availableRegions: availableRegions ?? this.availableRegions,
    );
  }
}

// ============== 4. SERVICES ==============
/// 🔧 区域选择服务（模拟数据）
class _RegionPickerService {
  /// 获取深圳区域列表
  static Future<List<String>> getShenzhenRegions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _RegionPickerConstants.shenzhenDistricts;
  }
  
  /// 保存选中区域到本地存储
  static Future<void> saveSelectedRegion(String region) async {
    await Future.delayed(const Duration(milliseconds: 200));
    developer.log('保存选中区域: $region');
  }
}

// ============== 5. CONTROLLERS ==============
/// 🧠 区域选择控制器
class _RegionPickerController extends ValueNotifier<RegionPickerState> {
  _RegionPickerController() : super(const RegionPickerState()) {
    _initialize();
  }
  
  /// 初始化数据
  Future<void> _initialize() async {
    try {
      value = value.copyWith(isLoading: true, errorMessage: null);
      
      final regions = await _RegionPickerService.getShenzhenRegions();
      
      value = value.copyWith(
        isLoading: false,
        availableRegions: regions,
      );
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '加载区域数据失败，请重试',
      );
      developer.log('区域选择初始化失败: $e');
    }
  }
  
  /// 选择区域
  Future<void> selectRegion(String region) async {
    if (value.selectedRegion == region) return;
    
    try {
      value = value.copyWith(selectedRegion: region);
      await _RegionPickerService.saveSelectedRegion(region);
      developer.log('选择区域: $region');
    } catch (e) {
      developer.log('保存区域选择失败: $e');
    }
  }
  
  /// 重置为默认选择
  void resetToDefault() {
    value = value.copyWith(selectedRegion: '全深圳');
  }
}

// ============== 6. WIDGETS ==============
/// 🏙️ 区域选择按钮组件
class _RegionButton extends StatelessWidget {
  final String regionName;
  final bool isSelected;
  final VoidCallback? onTap;
  
  const _RegionButton({
    required this.regionName,
    required this.isSelected,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: _RegionPickerConstants.buttonHeight,
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(_RegionPickerConstants.selectedColor)
              : const Color(_RegionPickerConstants.unselectedColor),
          borderRadius: BorderRadius.circular(_RegionPickerConstants.cardBorderRadius),
          border: Border.all(
            color: isSelected 
                ? const Color(_RegionPickerConstants.selectedColor)
                : const Color(_RegionPickerConstants.borderColor),
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(_RegionPickerConstants.selectedColor).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Center(
          child: Text(
            regionName,
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

// ============== 7. PAGES ==============
/// 🌍 增强版区域选择页面
class EnhancedLocationPickerPage extends StatefulWidget {
  final String? initialRegion;
  final ValueChanged<String>? onRegionSelected;
  
  const EnhancedLocationPickerPage({
    super.key,
    this.initialRegion,
    this.onRegionSelected,
  });
  
  @override
  State<EnhancedLocationPickerPage> createState() => _EnhancedLocationPickerPageState();
}

class _EnhancedLocationPickerPageState extends State<EnhancedLocationPickerPage> {
  late final _RegionPickerController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = _RegionPickerController();
    
    // 如果有初始区域，设置为选中状态
    if (widget.initialRegion != null) {
      _controller.value = _controller.value.copyWith(
        selectedRegion: widget.initialRegion!,
      );
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // 设置状态栏样式（深色图标适配白色背景）
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
          '区域',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: ValueListenableBuilder<RegionPickerState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.isLoading) {
            return _buildLoadingView();
          }
          
          if (state.errorMessage != null) {
            return _buildErrorView(state.errorMessage!);
          }
          
          return _buildMainContent(state);
        },
      ),
    );
  }
  
  /// 构建加载视图
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(_RegionPickerConstants.selectedColor),
            ),
          ),
          SizedBox(height: 16),
          Text(
            '正在加载区域数据...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
  
  /// 构建错误视图
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _controller._initialize(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(_RegionPickerConstants.selectedColor),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
  
  /// 构建主要内容
  Widget _buildMainContent(RegionPickerState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _RegionPickerConstants.gridColumns,
          childAspectRatio: 2.5,  // 宽高比，控制按钮形状
          crossAxisSpacing: _RegionPickerConstants.gridSpacing,
          mainAxisSpacing: _RegionPickerConstants.gridSpacing,
        ),
        itemCount: state.availableRegions.length,
        itemBuilder: (context, index) {
          final region = state.availableRegions[index];
          final isSelected = region == state.selectedRegion;
          
          return _RegionButton(
            regionName: region,
            isSelected: isSelected,
            onTap: () => _handleRegionTap(region),
          );
        },
      ),
    );
  }
  
  /// 处理区域点击
  void _handleRegionTap(String region) {
    _controller.selectRegion(region);
    
    // 提供触觉反馈
    HapticFeedback.lightImpact();
    
    // 立即返回选择结果（符合原型图的交互）
    widget.onRegionSelected?.call(region);
    
    // 短暂延迟后自动返回，让用户看到选择效果
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pop(context, region);
      }
    });
  }
}

// ============== 8. EXPORTS ==============
// 导出供外部使用的类
