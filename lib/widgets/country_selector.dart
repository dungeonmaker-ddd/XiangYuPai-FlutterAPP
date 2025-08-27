import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/country_model.dart';
import 'country_bottom_sheet.dart';

/// 🌍 国家/地区选择页面
/// 提供搜索和选择功能，参考图片样式设计
class CountrySelectorPage extends StatefulWidget {
  final CountryModel? selectedCountry;
  final String title;

  const CountrySelectorPage({
    super.key,
    this.selectedCountry,
    this.title = '选择国家和地区',
  });

  @override
  State<CountrySelectorPage> createState() => _CountrySelectorPageState();
}

class _CountrySelectorPageState extends State<CountrySelectorPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<CountryModel> _filteredCountries = CountryData.countries;
  Map<String, List<CountryModel>> _groupedCountries = {};
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _groupedCountries = CountryData.getGroupedCountries();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredCountries = CountryData.searchCountries(query);
    });
  }

  void _selectCountry(CountryModel country) {
    Navigator.of(context).pop(country);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCountryList(),
        ],
      ),
    );
  }

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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(22),
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
              size: 20,
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
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildCountryList() {
    if (_isSearching) {
      return _buildSearchResults();
    } else {
      return _buildGroupedList();
    }
  }

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
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _filteredCountries.length,
        itemBuilder: (context, index) {
          final country = _filteredCountries[index];
          return _buildCountryItem(country);
        },
      ),
    );
  }

  Widget _buildGroupedList() {
    final letters = _groupedCountries.keys.toList();
    
    return Expanded(
      child: Row(
        children: [
          // 主列表
          Expanded(
            child: ListView.builder(
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
    for (final countries in _groupedCountries.values) {
      total += 1; // 字母标题
      total += countries.length; // 国家列表
    }
    return total;
  }

  Widget _buildGroupedItem(int index) {
    int currentIndex = 0;
    
    for (final entry in _groupedCountries.entries) {
      final letter = entry.key;
      final countries = entry.value;
      
      // 检查是否是字母标题
      if (currentIndex == index) {
        return _buildSectionHeader(letter);
      }
      currentIndex++;
      
      // 检查是否是这个组中的国家
      for (int i = 0; i < countries.length; i++) {
        if (currentIndex == index) {
          return _buildCountryItem(countries[i]);
        }
        currentIndex++;
      }
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildSectionHeader(String letter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildCountryItem(CountryModel country) {
    final isSelected = widget.selectedCountry?.code == country.code;
    
    return InkWell(
      onTap: () => _selectCountry(country),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.withOpacity(0.1) : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.grey[100]!, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // 国旗 (如果有)
            if (country.flag.isNotEmpty) ...[
              Text(
                country.flag,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
            ],
            
            // 国家名称
            Expanded(
              child: Text(
                country.name,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.purple : Colors.black,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            
            // 区号
            Text(
              country.code,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.purple : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            
            // 选中标识
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check,
                color: Colors.purple,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlphabetIndex(List<String> letters) {
    return Container(
      width: 24,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: letters.map((letter) {
          return GestureDetector(
            onTap: () => _scrollToLetter(letter),
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.purple[400],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _scrollToLetter(String letter) {
    // 这里可以实现滚动到对应字母的功能
    // 由于计算比较复杂，暂时省略具体实现
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('滚动到 $letter'),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }
}

/// 🎯 国家选择按钮组件
/// 用于在表单中显示当前选中的国家并触发选择
class CountrySelectorButton extends StatelessWidget {
  final CountryModel? selectedCountry;
  final VoidCallback? onTap;
  final String? placeholder;
  final bool useBottomSheet; // 是否使用底部抽屉模式
  final ValueChanged<CountryModel>? onCountryChanged; // 选择回调

  const CountrySelectorButton({
    super.key,
    this.selectedCountry,
    this.onTap,
    this.placeholder,
    this.useBottomSheet = true, // 默认使用底部抽屉
    this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (useBottomSheet && onCountryChanged != null) {
          // 使用底部抽屉模式
          final result = await CountryBottomSheet.show(
            context,
            selectedCountry: selectedCountry,
          );
          if (result != null) {
            onCountryChanged!(result);
          }
        } else if (onTap != null) {
          // 使用自定义回调
          onTap!();
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 显示区号（不显示国旗）
            if (selectedCountry != null) ...[
              Text(
                selectedCountry!.code,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Text(
                placeholder ?? '+86',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
            
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
