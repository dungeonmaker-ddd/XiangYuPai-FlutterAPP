/// 📍 定位选择页面
/// 仿照图片中的设计，提供城市选择功能
library location_picker_page;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/location_model.dart';
import '../config/home_config.dart';

class LocationPickerPage extends StatefulWidget {
  final LocationModel? selectedLocation;
  final String title;

  const LocationPickerPage({
    super.key,
    this.selectedLocation,
    this.title = '定位',
  });

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  List<LocationModel> _filteredCities = [];
  Map<String, List<LocationModel>> _groupedCities = {};
  bool _isSearching = false;
  LocationModel? _currentLocation;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.selectedLocation ?? LocationData.findById('shenzhen');
    _groupedCities = LocationData.getGroupedCities();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _filteredCities = LocationData.searchCities(query);
      }
    });
  }

  void _selectLocation(LocationModel location) {
    // 触觉反馈
    HapticFeedback.selectionClick();
    
    Navigator.of(context).pop(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCurrentLocationSection(),
          _buildHotCitiesSection(),
          _buildAlphabetCitiesSection(),
        ],
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// 构建当前定位区域
  Widget _buildCurrentLocationSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 定位/最近访问标题
          Row(
            children: [
              Text(
                '定位 / 最近访问',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // 右侧字母索引预览
              _buildAlphabetPreview(),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 当前定位按钮
          GestureDetector(
            onTap: () {
              if (_currentLocation != null) {
                _selectLocation(_currentLocation!);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Color(HomeConfig.primaryPurple),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _currentLocation?.name ?? '深圳',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建字母索引预览
  Widget _buildAlphabetPreview() {
    return SizedBox(
      width: 20,
      child: Column(
        children: LocationData.getAlphabetIndex().take(10).map((letter) {
          return GestureDetector(
            onTap: () => _scrollToLetter(letter),
            child: Container(
              height: 16,
              alignment: Alignment.center,
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建热门城市区域
  Widget _buildHotCitiesSection() {
    final hotCities = LocationData.getHotCities();
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: Color(0xFFE5E5E5)),
          
          const SizedBox(height: 16),
          
          Text(
            '热门城市',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 热门城市网格 (2行4列)
          _buildCityGrid(hotCities),
          
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// 构建城市网格
  Widget _buildCityGrid(List<LocationModel> cities) {
    // 只显示前8个热门城市，分成2行
    final displayCities = cities.take(8).toList();
    
    return Column(
      children: [
        // 第一行
        Row(
          children: displayCities.take(4).map((city) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildCityButton(city),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 8),
        
        // 第二行
        Row(
          children: displayCities.skip(4).take(4).map((city) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildCityButton(city),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建城市按钮
  Widget _buildCityButton(LocationModel city) {
    final isSelected = _currentLocation?.locationId == city.locationId;
    
    return GestureDetector(
      onTap: () => _selectLocation(city),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Color(HomeConfig.primaryPurple).withValues(alpha: 0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(18),
          border: isSelected 
              ? Border.all(color: Color(HomeConfig.primaryPurple), width: 1)
              : null,
        ),
        child: Text(
          city.name,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Color(HomeConfig.primaryPurple) : Colors.black87,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 构建字母城市区域
  Widget _buildAlphabetCitiesSection() {
    if (_isSearching) {
      return _buildSearchResults();
    }
    
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Row(
          children: [
            // 主列表区域
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 分隔线
                  const SliverToBoxAdapter(
                    child: Divider(height: 1, color: Color(0xFFE5E5E5)),
                  ),
                  
                  // 字母分组城市列表
                  ..._buildAlphabetSections(),
                ],
              ),
            ),
            
            // 右侧字母索引
            _buildAlphabetIndex(),
          ],
        ),
      ),
    );
  }

  /// 构建字母分组区域
  List<Widget> _buildAlphabetSections() {
    final letters = _groupedCities.keys.toList()..sort();
    final List<Widget> sections = [];
    
    for (final letter in letters) {
      final cities = _groupedCities[letter]!;
      
      // 字母标题
      sections.add(
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[50],
            child: Text(
              letter,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      );
      
      // 城市列表
      sections.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final city = cities[index];
              return _buildCityListItem(city);
            },
            childCount: cities.length,
          ),
        ),
      );
    }
    
    return sections;
  }

  /// 构建城市列表项
  Widget _buildCityListItem(LocationModel city) {
    final isSelected = _currentLocation?.locationId == city.locationId;
    
    return GestureDetector(
      onTap: () => _selectLocation(city),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(HomeConfig.primaryPurple).withValues(alpha: 0.05) : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                city.name,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Color(HomeConfig.primaryPurple) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: Color(HomeConfig.primaryPurple),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults() {
    if (_filteredCities.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '没有找到相关城市',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _filteredCities.length,
        itemBuilder: (context, index) {
          return _buildCityListItem(_filteredCities[index]);
        },
      ),
    );
  }

  /// 构建右侧字母索引
  Widget _buildAlphabetIndex() {
    final letters = LocationData.getAlphabetIndex();
    
    return Container(
      width: 24,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: letters.map((letter) {
          return GestureDetector(
            onTap: () => _scrollToLetter(letter),
            child: Container(
              height: 20,
              alignment: Alignment.center,
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(HomeConfig.primaryPurple),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 滚动到指定字母
  void _scrollToLetter(String letter) {
    // 触觉反馈
    HapticFeedback.lightImpact();
    
    // TODO: 实现精确滚动到指定字母位置
    // 这里暂时显示提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('滚动到 $letter'),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100),
      ),
    );
  }
}
