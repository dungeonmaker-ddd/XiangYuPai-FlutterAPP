import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/country_model.dart';

/// 🌍 国家/地区选择底部抽屉
/// 从下往上弹出的卡片样式，占据4/5屏幕高度
class CountryBottomSheet extends StatefulWidget {
  final CountryModel? selectedCountry;
  final String title;

  const CountryBottomSheet({
    super.key,
    this.selectedCountry,
    this.title = '选择国家和地区',
  });

  /// 🚀 显示底部抽屉的静态方法
  static Future<CountryModel?> show(
    BuildContext context, {
    CountryModel? selectedCountry,
    String title = '选择国家和地区',
  }) {
    return showModalBottomSheet<CountryModel>(
      context: context,
      isScrollControlled: true, // 允许自定义高度
      backgroundColor: Colors.transparent, // 透明背景
      builder: (context) => CountryBottomSheet(
        selectedCountry: selectedCountry,
        title: title,
      ),
    );
  }

  @override
  State<CountryBottomSheet> createState() => _CountryBottomSheetState();
}

class _CountryBottomSheetState extends State<CountryBottomSheet>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<CountryModel> _filteredCountries = CountryData.countries;
  Map<String, List<CountryModel>> _groupedCountries = {};
  bool _isSearching = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _groupedCountries = CountryData.getGroupedCountries();
    _searchController.addListener(_onSearchChanged);

    // 初始化动画
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // 开始动画
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredCountries = CountryData.searchCountries(query);
    });
  }

  void _selectCountry(CountryModel country) async {
    // 触觉反馈
    HapticFeedback.selectionClick();
    
    // 关闭动画
    await _animationController.reverse();
    
    if (mounted) {
      Navigator.of(context).pop(country);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = screenHeight * 0.8; // 4/5 屏幕高度
    const offsetHeight = 40.0; // 稍微上移，减少偏移距离

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(top: offsetHeight), // 稍微上移
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                height: bottomSheetHeight - offsetHeight, // 相应调整高度
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildHandle(),
                    _buildHeader(),
                    _buildSearchBar(),
                    _buildCountryList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🎯 顶部拖拽手柄
  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// 📋 头部标题
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              await _animationController.reverse();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            icon: Icon(
              Icons.close,
              color: Colors.grey[600],
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[100],
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔍 搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
          border: _searchFocusNode.hasFocus
              ? Border.all(color: Colors.purple.withOpacity(0.3), width: 2)
              : null,
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: '搜索国家或地区',
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[500],
              size: 22,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[500],
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          onChanged: (value) {
            setState(() {}); // 触发suffixIcon更新
          },
        ),
      ),
    );
  }

  /// 📋 国家列表
  Widget _buildCountryList() {
    if (_isSearching) {
      return _buildSearchResults();
    } else {
      return _buildGroupedList();
    }
  }

  /// 🔍 搜索结果
  Widget _buildSearchResults() {
    if (_filteredCountries.isEmpty) {
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
                '没有找到相关结果',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '请尝试其他关键词',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filteredCountries.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[100],
        ),
        itemBuilder: (context, index) {
          final country = _filteredCountries[index];
          return _buildCountryItem(country);
        },
      ),
    );
  }

  /// 📋 分组列表
  Widget _buildGroupedList() {
    final letters = _groupedCountries.keys.toList();

    return Expanded(
      child: Row(
        children: [
          // 主列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _calculateTotalItems(),
              itemBuilder: (context, index) {
                return _buildGroupedItem(index);
              },
            ),
          ),

          // 右侧字母索引
          _buildAlphabetIndex(letters),
        ],
      ),
    );
  }

  int _calculateTotalItems() {
    int total = 0;
    for (final entry in _groupedCountries.entries) {
      final letter = entry.key;
      final countries = entry.value;
      
      // 对于"*"分组（中国大陆），不计算标题
      if (letter != '*') {
        total += 1; // 字母标题
      }
      total += countries.length; // 国家列表
    }
    return total;
  }

  Widget _buildGroupedItem(int index) {
    int currentIndex = 0;

    for (final entry in _groupedCountries.entries) {
      final letter = entry.key;
      final countries = entry.value;

      // 对于"*"分组（中国大陆），跳过标题直接显示国家
      if (letter != '*') {
        // 检查是否是字母标题
        if (currentIndex == index) {
          return _buildSectionHeader(letter);
        }
        currentIndex++;
      }

      // 检查是否是这个组中的国家
      for (int i = 0; i < countries.length; i++) {
        if (currentIndex == index) {
          return Column(
            children: [
              _buildCountryItem(countries[i]),
              if (i < countries.length - 1)
                Divider(height: 1, color: Colors.grey[100]),
            ],
          );
        }
        currentIndex++;
      }
    }

    return const SizedBox.shrink();
  }

  /// 📑 分组标题
  Widget _buildSectionHeader(String letter) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6), // 进一步减少垂直间距
      alignment: Alignment.centerLeft,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// 🌍 国家项目
  Widget _buildCountryItem(CountryModel country) {
    final isSelected = widget.selectedCountry?.code == country.code;

    return InkWell(
      onTap: () => _selectCountry(country),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10), // 进一步减少垂直间距
        child: Row(
          children: [
            // 国旗
            if (country.flag.isNotEmpty) ...[
              Container(
                width: 32,
                height: 24,
                alignment: Alignment.center,
                child: Text(
                  country.flag,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 16),
            ] else ...[
              const SizedBox(width: 48),
            ],

            // 国家信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.purple : Colors.black87,
                    ),
                  ),
                  if (country.englishName != country.name)
                    Text(
                      country.englishName,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.purple.withOpacity(0.7) : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),

            // 区号
            Text(
              country.code,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.purple : Colors.grey[700],
              ),
            ),

            const SizedBox(width: 8),

            // 选中标识
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.purple,
                      size: 20,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// 🔤 字母索引
  Widget _buildAlphabetIndex(List<String> letters) {
    return Container(
      width: 20,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 居中对齐
        mainAxisSize: MainAxisSize.min, // 最小尺寸
        children: letters.map((letter) {
          // 为中国大陆分组显示特殊标识
          final displayText = letter;
          final fontSize = letter == '*' ? 14.0 : 11.0; // 稍微减小字体
          
          return GestureDetector(
            onTap: () => _scrollToLetter(letter),
            child: Container(
              width: 20,
              height: 18, // 更紧凑的高度
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(vertical: 1), // 最小间距
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: letter == '*' ? Colors.red[600] : Colors.purple[600],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _scrollToLetter(String letter) {
    // 触觉反馈
    HapticFeedback.lightImpact();
    
    // 这里可以实现滚动到对应字母的功能
    // 由于计算比较复杂，暂时省略具体实现
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('滚动到 $letter'),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100),
      ),
    );
  }
}
