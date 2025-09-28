// 📍 地区选择页面 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计

// ============== 1. IMPORTS ==============
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'home_models.dart';
import 'home_services.dart';

// ============== 2. CONSTANTS ==============
// 常量使用 home_models.dart 中的 HomeConstants

// ============== 3. MODELS ==============
// 模型在 home_models.dart 中定义

// ============== 4. SERVICES ==============
// 服务在 home_services.dart 中定义

// ============== 5. CONTROLLERS ==============
/// 🌍 地区选择控制器
class _LocationPickerController extends ValueNotifier<LocationPickerState> {
  _LocationPickerController() : super(const LocationPickerState()) {
    _initialize();
  }

  final ScrollController scrollController = ScrollController();
  final Map<String, GlobalKey> letterKeys = {};

  /// 初始化数据
  Future<void> _initialize() async {
    try {
      value = value.copyWith(isLoading: true, errorMessage: null);

      // 并发加载数据
      final results = await Future.wait([
        LocationService.getCurrentLocation(),
        LocationService.getHotCities(),
        LocationService.getAllRegions(),
      ]);

      final currentLocation = results[0] as LocationRegionModel?;
      final hotCities = results[1] as List<LocationRegionModel>;
      final regionsByLetter = results[2] as Map<String, List<LocationRegionModel>>;

      // 初始化字母导航键
      for (final letter in regionsByLetter.keys) {
        letterKeys[letter] = GlobalKey();
      }

      value = value.copyWith(
        isLoading: false,
        currentLocation: currentLocation,
        hotCities: hotCities,
        regionsByLetter: regionsByLetter,
        recentLocations: currentLocation != null ? [currentLocation] : [],
      );
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '加载失败，请重试',
      );
      developer.log('地区选择初始化失败: $e');
    }
  }

  /// 搜索地区
  Future<void> searchRegions(String keyword) async {
    try {
      value = value.copyWith(searchKeyword: keyword);

      if (keyword.isEmpty) {
        value = value.copyWith(searchResults: []);
        return;
      }

      final results = await LocationService.searchRegions(keyword);
      value = value.copyWith(searchResults: results);
    } catch (e) {
      developer.log('搜索地区失败: $e');
    }
  }

  /// 选择地区
  void selectRegion(LocationRegionModel region) {
    // 更新最近访问记录
    final updatedRecentLocations = List<LocationRegionModel>.from(value.recentLocations);
    updatedRecentLocations.removeWhere((item) => item.regionId == region.regionId);
    updatedRecentLocations.insert(0, region.copyWith(lastVisited: DateTime.now()));
    
    // 只保留最近5个
    if (updatedRecentLocations.length > 5) {
      updatedRecentLocations.removeRange(5, updatedRecentLocations.length);
    }

    value = value.copyWith(
      currentLocation: region,
      recentLocations: updatedRecentLocations,
    );

    developer.log('选择地区: ${region.name}');
  }

  /// 跳转到指定字母分组
  void jumpToLetter(String letter) {
    final key = letterKeys[letter];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

// ============== 6. WIDGETS ==============
// UI组件将在页面类中定义为私有方法

// ============== 7. PAGES ==============
/// 📍 地区选择页面
class LocationPickerPage extends StatefulWidget {
  final LocationRegionModel? currentLocation;
  final ValueChanged<LocationRegionModel>? onLocationSelected;

  const LocationPickerPage({
    super.key,
    this.currentLocation,
    this.onLocationSelected,
  });

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late final _LocationPickerController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = _LocationPickerController();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _controller.searchRegions(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 透明状态栏
      statusBarIconBrightness: Brightness.dark, // 深色图标
      statusBarBrightness: Brightness.light, // iOS状态栏亮度
    ));
    
    return Scaffold(
      backgroundColor: const Color(HomeConstants.homeBackgroundColor),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '定位',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<LocationPickerState>(
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(HomeConstants.primaryPurple)),
          ),
          SizedBox(height: 16),
          Text(
            '正在加载地区数据...',
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
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _controller.dispose();
              setState(() {
                _controller = _LocationPickerController();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(HomeConstants.primaryPurple),
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(LocationPickerState state) {
    return Stack(
      children: [
        CustomScrollView(
          controller: _controller.scrollController,
          slivers: [
            // 搜索栏
            SliverToBoxAdapter(child: _buildSearchBar()),

            // 最近访问/当前定位
            if (state.currentLocation != null || state.recentLocations.isNotEmpty)
              SliverToBoxAdapter(child: _buildRecentSection(state)),

            // 热门城市
            if (state.hotCities.isNotEmpty)
              SliverToBoxAdapter(child: _buildHotCitiesSection(state)),

            // 搜索结果或地区列表
            if (state.searchKeyword != null && state.searchKeyword!.isNotEmpty)
              _buildSearchResults(state)
            else
              _buildRegionsList(state),
          ],
        ),

        // 右侧字母导航
        if (state.searchKeyword == null || state.searchKeyword!.isEmpty)
          _buildLetterNavigation(state),
      ],
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[500], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索城市名称',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
              },
              child: Icon(Icons.clear, color: Colors.grey[500], size: 18),
            ),
        ],
      ),
    );
  }

  /// 构建最近访问区域
  Widget _buildRecentSection(LocationPickerState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '定位 / 最近访问',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          if (state.currentLocation != null)
            _buildCurrentLocationCard(state.currentLocation!),
          if (state.recentLocations.isNotEmpty)
            ...state.recentLocations.map((location) => 
              _buildLocationItem(location, isRecent: true)
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// 构建当前定位卡片
  Widget _buildCurrentLocationCard(LocationRegionModel location) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(HomeConstants.primaryPurple).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(HomeConstants.primaryPurple).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(HomeConstants.primaryPurple),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  '当前定位',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(HomeConstants.primaryPurple),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _selectLocation(location),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(HomeConstants.primaryPurple),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                '选择',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建热门城市区域
  Widget _buildHotCitiesSection(LocationPickerState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              '热门城市',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildHotCitiesGrid(state.hotCities),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 构建热门城市网格
  Widget _buildHotCitiesGrid(List<LocationRegionModel> hotCities) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: hotCities.length,
      itemBuilder: (context, index) {
        final city = hotCities[index];
        return GestureDetector(
          onTap: () => _selectLocation(city),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!, width: 0.5),
            ),
            child: Center(
              child: Text(
                city.name,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults(LocationPickerState state) {
    if (state.searchResults.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                '未找到匹配的城市',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final region = state.searchResults[index];
          return _buildLocationItem(region);
        },
        childCount: state.searchResults.length,
      ),
    );
  }

  /// 构建地区列表
  Widget _buildRegionsList(LocationPickerState state) {
    final letters = state.regionsByLetter.keys.toList()..sort();
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final letter = letters[index];
          final regions = state.regionsByLetter[letter]!;
          
          return Container(
            key: _controller.letterKeys[letter],
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 字母标题
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey[100],
                  child: Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(HomeConstants.primaryPurple),
                    ),
                  ),
                ),
                // 地区列表
                ...regions.map((region) => _buildLocationItem(region)),
              ],
            ),
          );
        },
        childCount: letters.length,
      ),
    );
  }

  /// 构建位置条目
  Widget _buildLocationItem(LocationRegionModel location, {bool isRecent = false}) {
    return GestureDetector(
      onTap: () => _selectLocation(location),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            if (isRecent) ...[
              Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                location.name,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
            if (location.isHot)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '热',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建字母导航
  Widget _buildLetterNavigation(LocationPickerState state) {
    final letters = state.regionsByLetter.keys.toList()..sort();
    
    return Positioned(
      right: 8,
      top: 0,
      bottom: 0,
      child: Container(
        width: 24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: letters.map((letter) {
            return GestureDetector(
              onTap: () => _controller.jumpToLetter(letter),
              child: Container(
                height: 20,
                width: 20,
                margin: const EdgeInsets.symmetric(vertical: 1),
                child: Center(
                  child: Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(HomeConstants.primaryPurple),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 选择位置
  void _selectLocation(LocationRegionModel location) {
    _controller.selectRegion(location);
    widget.onLocationSelected?.call(location);
    
    // 延迟一下再返回，让用户看到选择效果
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        Navigator.pop(context, location);
      }
    });
  }
}

// ============== 8. EXPORTS ==============
// 导出页面供其他文件使用
// 无需显式导出，Dart会自动导出公共类
