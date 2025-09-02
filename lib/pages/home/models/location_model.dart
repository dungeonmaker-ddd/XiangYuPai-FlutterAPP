/// 📍 位置数据模型
/// 定位相关的数据结构
library location_model;

class LocationModel {
  /// 位置ID
  final String locationId;
  
  /// 位置名称
  final String name;
  
  /// 位置类型（city: 城市, district: 区域, province: 省份）
  final LocationType type;
  
  /// 父级位置ID
  final String? parentId;
  
  /// 热门程度（影响排序）
  final int popularity;
  
  /// 首字母（用于分组）
  final String firstLetter;
  
  /// 是否为热门城市
  final bool isHot;
  
  /// 经纬度信息
  final LatLng? coordinates;

  const LocationModel({
    required this.locationId,
    required this.name,
    required this.type,
    this.parentId,
    this.popularity = 0,
    required this.firstLetter,
    this.isHot = false,
    this.coordinates,
  });

  /// 工厂方法：从JSON创建
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      locationId: json['location_id'] as String,
      name: json['name'] as String,
      type: LocationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LocationType.city,
      ),
      parentId: json['parent_id'] as String?,
      popularity: json['popularity'] as int? ?? 0,
      firstLetter: json['first_letter'] as String,
      isHot: json['is_hot'] as bool? ?? false,
      coordinates: json['coordinates'] != null
          ? LatLng.fromJson(json['coordinates'] as Map<String, dynamic>)
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'name': name,
      'type': type.name,
      'parent_id': parentId,
      'popularity': popularity,
      'first_letter': firstLetter,
      'is_hot': isHot,
      'coordinates': coordinates?.toJson(),
    };
  }

  /// 复制并修改部分属性
  LocationModel copyWith({
    String? locationId,
    String? name,
    LocationType? type,
    String? parentId,
    int? popularity,
    String? firstLetter,
    bool? isHot,
    LatLng? coordinates,
  }) {
    return LocationModel(
      locationId: locationId ?? this.locationId,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      popularity: popularity ?? this.popularity,
      firstLetter: firstLetter ?? this.firstLetter,
      isHot: isHot ?? this.isHot,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  @override
  String toString() => 'LocationModel(locationId: $locationId, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          locationId == other.locationId;

  @override
  int get hashCode => locationId.hashCode;
}

/// 📍 位置类型枚举
enum LocationType {
  province,  // 省份
  city,      // 城市
  district,  // 区域
}

/// 🌐 经纬度模型
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng({
    required this.latitude,
    required this.longitude,
  });

  factory LatLng.fromJson(Map<String, dynamic> json) {
    return LatLng(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() => 'LatLng(lat: $latitude, lng: $longitude)';
}

/// 📍 位置数据源
class LocationData {
  /// 热门城市列表
  static const List<LocationModel> hotCities = [
    LocationModel(
      locationId: 'shenzhen',
      name: '深圳',
      type: LocationType.city,
      popularity: 100,
      firstLetter: 'S',
      isHot: true,
      coordinates: LatLng(latitude: 22.5431, longitude: 114.0579),
    ),
    LocationModel(
      locationId: 'hangzhou',
      name: '杭州',
      type: LocationType.city,
      popularity: 90,
      firstLetter: 'H',
      isHot: true,
      coordinates: LatLng(latitude: 30.2741, longitude: 120.1551),
    ),
    LocationModel(
      locationId: 'beijing',
      name: '北京',
      type: LocationType.city,
      popularity: 95,
      firstLetter: 'B',
      isHot: true,
      coordinates: LatLng(latitude: 39.9042, longitude: 116.4074),
    ),
    LocationModel(
      locationId: 'shanghai',
      name: '上海',
      type: LocationType.city,
      popularity: 93,
      firstLetter: 'S',
      isHot: true,
      coordinates: LatLng(latitude: 31.2304, longitude: 121.4737),
    ),
    LocationModel(
      locationId: 'guangzhou',
      name: '广州',
      type: LocationType.city,
      popularity: 85,
      firstLetter: 'G',
      isHot: true,
    ),
    LocationModel(
      locationId: 'chengdu',
      name: '成都',
      type: LocationType.city,
      popularity: 80,
      firstLetter: 'C',
      isHot: true,
    ),
    LocationModel(
      locationId: 'wuhan',
      name: '武汉',
      type: LocationType.city,
      popularity: 75,
      firstLetter: 'W',
      isHot: true,
    ),
    LocationModel(
      locationId: 'xian',
      name: '西安',
      type: LocationType.city,
      popularity: 70,
      firstLetter: 'X',
      isHot: true,
    ),
  ];

  /// 所有城市列表（包含更多城市）
  static const List<LocationModel> allCities = [
    // 热门城市
    ...hotCities,
    
    // A字母开头的城市
    LocationModel(
      locationId: 'aba_tibetan_qiang',
      name: '阿坝藏族羌族自治州',
      type: LocationType.city,
      popularity: 10,
      firstLetter: 'A',
    ),
    LocationModel(
      locationId: 'akesu',
      name: '阿克苏地区',
      type: LocationType.city,
      popularity: 15,
      firstLetter: 'A',
    ),
    LocationModel(
      locationId: 'anshan',
      name: '鞍山',
      type: LocationType.city,
      popularity: 25,
      firstLetter: 'A',
    ),
    LocationModel(
      locationId: 'anyang',
      name: '安阳',
      type: LocationType.city,
      popularity: 20,
      firstLetter: 'A',
    ),
    
    // B字母开头的城市
    LocationModel(
      locationId: 'baoding',
      name: '保定',
      type: LocationType.city,
      popularity: 30,
      firstLetter: 'B',
    ),
    LocationModel(
      locationId: 'bengbu',
      name: '蚌埠',
      type: LocationType.city,
      popularity: 25,
      firstLetter: 'B',
    ),
    
    // C字母开头的城市
    LocationModel(
      locationId: 'changsha',
      name: '长沙',
      type: LocationType.city,
      popularity: 65,
      firstLetter: 'C',
    ),
    LocationModel(
      locationId: 'chongqing',
      name: '重庆',
      type: LocationType.city,
      popularity: 70,
      firstLetter: 'C',
    ),
    
    // D字母开头的城市
    LocationModel(
      locationId: 'dalian',
      name: '大连',
      type: LocationType.city,
      popularity: 55,
      firstLetter: 'D',
    ),
    LocationModel(
      locationId: 'dongguan',
      name: '东莞',
      type: LocationType.city,
      popularity: 50,
      firstLetter: 'D',
    ),
    
    // 更多城市可以继续添加...
  ];

  /// 获取热门城市
  static List<LocationModel> getHotCities() {
    final cities = List<LocationModel>.from(hotCities);
    cities.sort((a, b) => b.popularity.compareTo(a.popularity));
    return cities;
  }

  /// 获取按字母分组的城市
  static Map<String, List<LocationModel>> getGroupedCities() {
    final Map<String, List<LocationModel>> grouped = {};
    
    for (final city in allCities) {
      final letter = city.firstLetter;
      if (!grouped.containsKey(letter)) {
        grouped[letter] = <LocationModel>[];
      }
      grouped[letter]!.add(city);
    }
    
    // 对每个分组内的城市按热门程度排序
    grouped.forEach((key, cities) {
      cities.sort((a, b) => b.popularity.compareTo(a.popularity));
    });
    
    return grouped;
  }

  /// 搜索城市
  static List<LocationModel> searchCities(String query) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    final results = allCities.where((city) {
      return city.name.toLowerCase().contains(lowerQuery) ||
             city.firstLetter.toLowerCase().contains(lowerQuery);
    }).toList();
    
    results.sort((a, b) => b.popularity.compareTo(a.popularity));
    return results;
  }

  /// 根据ID查找城市
  static LocationModel? findById(String locationId) {
    try {
      return allCities.firstWhere((city) => city.locationId == locationId);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有字母索引
  static List<String> getAlphabetIndex() {
    final letters = allCities.map((city) => city.firstLetter).toSet().toList();
    letters.sort();
    return letters;
  }
}
