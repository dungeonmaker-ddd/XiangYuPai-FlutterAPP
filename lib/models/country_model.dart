/// 🌍 国家/地区数据模型
/// 包含国家名称、区号、首字母等信息
class CountryModel {
  final String name;           // 国家/地区名称
  final String code;           // 区号 (+86, +1, 等)
  final String englishName;    // 英文名称
  final String firstLetter;    // 首字母 (用于分组)
  final String flag;           // 国旗 emoji (可选)

  const CountryModel({
    required this.name,
    required this.code,
    required this.englishName,
    required this.firstLetter,
    this.flag = '',
  });

  @override
  String toString() => '$name $code';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// 🌏 预定义国家/地区数据
class CountryData {
  static const List<CountryModel> countries = [
    // 中国大陆及地区 (多个区号选项)
    CountryModel(
      name: '中国大陆',
      code: '+86',
      englishName: 'China Mainland',
      firstLetter: 'Z',
      flag: '🇨🇳',
    ),
    CountryModel(
      name: '中国大陆',
      code: '+852',
      englishName: 'Hong Kong',
      firstLetter: 'Z',
      flag: '🇭🇰',
    ),
    CountryModel(
      name: '中国大陆',
      code: '+853',
      englishName: 'Macao',
      firstLetter: 'Z',
      flag: '🇲🇴',
    ),
    CountryModel(
      name: '中国大陆',
      code: '+886',
      englishName: 'Taiwan',
      firstLetter: 'Z',
      flag: '🇹🇼',
    ),
    
    // 澳大利亚
    CountryModel(
      name: '澳大利亚',
      code: '+61',
      englishName: 'Australia',
      firstLetter: 'A',
      flag: '🇦🇺',
    ),
    
    // 韩国
    CountryModel(
      name: '韩国',
      code: '+82',
      englishName: 'South Korea',
      firstLetter: 'H',
      flag: '🇰🇷',
    ),
    
    // 泰国
    CountryModel(
      name: '泰国',
      code: '+66',
      englishName: 'Thailand',
      firstLetter: 'T',
      flag: '🇹🇭',
    ),
    
    // 其他常用国家
    CountryModel(
      name: '美国',
      code: '+1',
      englishName: 'United States',
      firstLetter: 'M',
      flag: '🇺🇸',
    ),
    CountryModel(
      name: '英国',
      code: '+44',
      englishName: 'United Kingdom',
      firstLetter: 'Y',
      flag: '🇬🇧',
    ),
    CountryModel(
      name: '日本',
      code: '+81',
      englishName: 'Japan',
      firstLetter: 'R',
      flag: '🇯🇵',
    ),
    CountryModel(
      name: '新加坡',
      code: '+65',
      englishName: 'Singapore',
      firstLetter: 'X',
      flag: '🇸🇬',
    ),
    CountryModel(
      name: '马来西亚',
      code: '+60',
      englishName: 'Malaysia',
      firstLetter: 'M',
      flag: '🇲🇾',
    ),
    CountryModel(
      name: '印尼',
      code: '+62',
      englishName: 'Indonesia',
      firstLetter: 'Y',
      flag: '🇮🇩',
    ),
    CountryModel(
      name: '菲律宾',
      code: '+63',
      englishName: 'Philippines',
      firstLetter: 'F',
      flag: '🇵🇭',
    ),
    CountryModel(
      name: '越南',
      code: '+84',
      englishName: 'Vietnam',
      firstLetter: 'Y',
      flag: '🇻🇳',
    ),
  ];

  /// 🔍 获取按首字母分组的国家列表
  /// 中国大陆的四个区号优先显示在最上面
  static Map<String, List<CountryModel>> getGroupedCountries() {
    final Map<String, List<CountryModel>> grouped = {};
    
    // 分离中国大陆和其他国家
    final chinaCountries = <CountryModel>[];
    final otherCountries = <CountryModel>[];
    
    for (final country in countries) {
      if (country.name == '中国大陆') {
        chinaCountries.add(country);
      } else {
        otherCountries.add(country);
      }
    }
    
    // 中国大陆按区号排序 (+86, +852, +853, +886)
    chinaCountries.sort((a, b) {
      const order = ['+86', '+852', '+853', '+886'];
      return order.indexOf(a.code).compareTo(order.indexOf(b.code));
    });
    
    // 添加中国大陆分组
    if (chinaCountries.isNotEmpty) {
      grouped['*'] = chinaCountries;
    }
    
    // 处理其他国家按字母分组
    for (final country in otherCountries) {
      final letter = country.firstLetter;
      if (!grouped.containsKey(letter)) {
        grouped[letter] = [];
      }
      grouped[letter]!.add(country);
    }
    
    // 对其他国家的分组进行排序
    final otherKeys = grouped.keys.where((key) => key != '*').toList()..sort();
    
    // 构建最终的排序结果：中国大陆 + 按字母排序的其他国家
    final Map<String, List<CountryModel>> sortedGrouped = {};
    
    // 首先添加中国大陆
    if (grouped.containsKey('*')) {
      sortedGrouped['*'] = grouped['*']!;
    }
    
    // 然后添加其他国家
    for (final key in otherKeys) {
      sortedGrouped[key] = grouped[key]!;
    }
    
    return sortedGrouped;
  }

  /// 🔍 搜索国家
  static List<CountryModel> searchCountries(String query) {
    if (query.isEmpty) return countries;
    
    final lowerQuery = query.toLowerCase();
    return countries.where((country) {
      return country.name.toLowerCase().contains(lowerQuery) ||
             country.englishName.toLowerCase().contains(lowerQuery) ||
             country.code.contains(query);
    }).toList();
  }

  /// 🎯 根据区号查找国家
  static CountryModel? findByCode(String code) {
    try {
      return countries.firstWhere((country) => country.code == code);
    } catch (e) {
      return null;
    }
  }

  /// 📱 获取区号对应的手机号长度
  static int getPhoneLengthByCode(String code) {
    switch (code) {
      case '+86':  // 中国大陆
      case '+853': // 澳门
      case '+81':  // 日本
      case '+82':  // 韩国
        return 11;
      case '+852': // 香港
        return 8;
      case '+886': // 台湾
        return 9;
      case '+1':   // 美国/加拿大
      case '+44':  // 英国
        return 10;
      case '+65':  // 新加坡
        return 8;
      case '+60':  // 马来西亚
        return 9;
      case '+61':  // 澳大利亚
        return 9;
      case '+66':  // 泰国
        return 9;
      case '+62':  // 印尼
        return 10;
      case '+63':  // 菲律宾
        return 10;
      case '+84':  // 越南
        return 9;
      default:
        return 10; // 默认长度
    }
  }
}
