/// 🎯 API管理器
/// 统一管理所有API调用，提供简洁的接口

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'api_models.dart';
import 'base_http_service.dart';
import 'api_interceptors.dart';

/// 🎯 API管理器 - 单例模式
class ApiManager {
  static ApiManager? _instance;
  late final BaseHttpService _httpService;
  SharedPreferences? _prefs;
  
  /// 私有构造函数
  ApiManager._() {
    _httpService = BaseHttpService();
    _initialize();
  }
  
  /// 获取单例实例
  static ApiManager get instance {
    return _instance ??= ApiManager._();
  }
  
  /// 重置实例（主要用于测试）
  static void reset() {
    _instance?._httpService.dispose();
    _instance = null;
  }
  
  /// 初始化
  void _initialize() {
    if (ApiConfig.isDebugMode) {
      ApiConfigExtension.printConfig();
    }
  }
  
  // ============== 认证相关API ==============
  
  /// 📱 发送短信验证码
  Future<ApiResponse<SmsCodeResponse>> sendSmsCode({
    required String mobile,
    String clientType = 'app',
  }) async {
    try {
      final response = await _httpService.post<SmsCodeResponse>(
        ApiConfig.getAuthUrl('sendSms'),
        data: {
          'mobile': mobile,
          'clientType': clientType,
        },
        fromJson: (json) => SmsCodeResponse.fromJson(json as Map<String, dynamic>),
      );
      
      return response;
    } catch (e) {
      throw _handleError(e, '发送验证码失败');
    }
  }
  
  /// 🔐 验证短信验证码并登录
  Future<ApiResponse<LoginResponse>> verifySmsCode({
    required String mobile,
    required String code,
    String clientType = 'app',
  }) async {
    try {
      final response = await _httpService.post<LoginResponse>(
        ApiConfig.getAuthUrl('verifySms'),
        data: {
          'mobile': mobile,
          'code': code,
          'clientType': clientType,
        },
        fromJson: (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
      );
      
      // 保存认证信息
      if (response.isSuccess && response.data != null) {
        await _saveAuthInfo(response.data!);
      }
      
      return response;
    } catch (e) {
      throw _handleError(e, '验证码登录失败');
    }
  }
  
  /// 🔄 刷新访问令牌
  Future<ApiResponse<LoginResponse>> refreshToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw const ApiException(
          code: 401,
          message: '刷新令牌不存在，请重新登录',
          type: ApiExceptionType.auth,
        );
      }
      
      final response = await _httpService.post<LoginResponse>(
        ApiConfig.getAuthUrl('refresh'),
        headers: {
          'Authorization': 'Bearer $refreshToken',
        },
        fromJson: (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
      );
      
      // 更新认证信息
      if (response.isSuccess && response.data != null) {
        await _saveAuthInfo(response.data!);
      }
      
      return response;
    } catch (e) {
      // 刷新失败，清除本地认证信息
      await _clearAuthInfo();
      throw _handleError(e, '刷新令牌失败');
    }
  }
  
  /// 🚪 登出
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _httpService.post<void>(
        ApiConfig.getAuthUrl('logout'),
      );
      
      // 清除本地认证信息
      await _clearAuthInfo();
      
      return response;
    } catch (e) {
      // 即使登出失败，也清除本地信息
      await _clearAuthInfo();
      throw _handleError(e, '登出失败');
    }
  }
  
  /// 👤 获取用户信息
  Future<ApiResponse<UserProfile>> getUserProfile() async {
    try {
      final response = await _httpService.get<UserProfile>(
        ApiConfig.getUserUrl('profile'),
        fromJson: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
      );
      
      return response;
    } catch (e) {
      throw _handleError(e, '获取用户信息失败');
    }
  }
  
  /// ✏️ 更新用户信息
  Future<ApiResponse<UserProfile>> updateUserProfile({
    String? nickname,
    String? avatarUrl,
    Map<String, dynamic>? extra,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (nickname != null) data['nickname'] = nickname;
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
      if (extra != null) data.addAll(extra);
      
      final response = await _httpService.put<UserProfile>(
        ApiConfig.getUserUrl('updateProfile'),
        data: data,
        fromJson: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
      );
      
      return response;
    } catch (e) {
      throw _handleError(e, '更新用户信息失败');
    }
  }
  
  // ============== 首页相关API ==============
  
  /// 🏷️ 获取分类列表
  Future<ApiResponse<List<Category>>> getCategories({
    bool enableCache = true,
  }) async {
    try {
      final response = await _httpService.get<List<Category>>(
        ApiConfig.getHomeUrl('categories'),
        enableCache: enableCache,
        fromJson: (json) {
          final List<dynamic> items = json as List<dynamic>;
          return items.map((item) => Category.fromJson(item as Map<String, dynamic>)).toList();
        },
      );
      
      return response;
    } catch (e) {
      throw _handleError(e, '获取分类列表失败');
    }
  }
  
  /// 🎯 获取推荐内容
  Future<ApiResponse<PageResponse<Recommendation>>> getRecommendations({
    int page = 1,
    int size = 20,
    String? category,
    bool enableCache = true,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };
      if (category != null) queryParams['category'] = category;
      
      final response = await _httpService.get<PageResponse<Recommendation>>(
        ApiConfig.getHomeUrl('recommendations'),
        queryParameters: queryParams,
        enableCache: enableCache,
        fromJson: (json) => PageResponse.fromJson(
          json as Map<String, dynamic>,
          (item) => Recommendation.fromJson(item as Map<String, dynamic>),
        ),
      );
      
      return response;
    } catch (e) {
      throw _handleError(e, '获取推荐内容失败');
    }
  }
  
  /// 📍 获取附近内容
  Future<ApiResponse<PageResponse<NearbyItem>>> getNearbyItems({
    required double latitude,
    required double longitude,
    double radius = 5.0, // 默认5公里
    int page = 1,
    int size = 20,
    String? category,
  }) async {
    try {
      final queryParams = <String, String>{
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'radius': radius.toString(),
        'page': page.toString(),
        'size': size.toString(),
      };
      if (category != null) queryParams['category'] = category;
      
      final response = await _httpService.get<PageResponse<NearbyItem>>(
        ApiConfig.getHomeUrl('nearby'),
        queryParameters: queryParams,
        fromJson: (json) => PageResponse.fromJson(
          json as Map<String, dynamic>,
          (item) => NearbyItem.fromJson(item as Map<String, dynamic>),
        ),
      );
      
      return response;
    } catch (e) {
      throw _handleError(e, '获取附近内容失败');
    }
  }
  
  /// 🔍 搜索内容
  Future<ApiResponse<PageResponse<SearchResult>>> search({
    required String keyword,
    int page = 1,
    int size = 20,
    String? category,
    String? sortBy,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = <String, String>{
        'keyword': keyword,
        'page': page.toString(),
        'size': size.toString(),
      };
      
      if (category != null) queryParams['category'] = category;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      
      // 添加过滤条件
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) {
            queryParams['filter_$key'] = value.toString();
          }
        });
      }
      
      final response = await _httpService.get<PageResponse<SearchResult>>(
        ApiConfig.getHomeUrl('search'),
        queryParameters: queryParams,
        fromJson: (json) => PageResponse.fromJson(
          json as Map<String, dynamic>,
          (item) => SearchResult.fromJson(item as Map<String, dynamic>),
        ),
      );
      
      return response;
    } catch (e) {
      throw _handleError(e, '搜索失败');
    }
  }
  
  // ============== 文件上传下载 ==============
  
  /// 📤 上传文件
  Future<ApiResponse<UploadResult>> uploadFile({
    required String filePath,
    String fieldName = 'file',
    String category = 'general',
    Map<String, String>? extra,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final fields = <String, String>{
        'category': category,
      };
      if (extra != null) fields.addAll(extra);
      
      final response = await _httpService.uploadFile<UploadResult>(
        ApiConfig.getApiUrl('/upload'),
        filePath,
        fieldName: fieldName,
        fields: fields,
        onProgress: onProgress,
        fromJson: (json) => UploadResult.fromJson(json as Map<String, dynamic>),
      );
      
      return response;
    } catch (e) {
      throw _handleError(e, '文件上传失败');
    }
  }
  
  /// 📥 下载文件
  Future<List<int>> downloadFile({
    required String url,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      return await _httpService.downloadFile(
        url,
        onProgress: onProgress,
      );
    } catch (e) {
      throw _handleError(e, '文件下载失败');
    }
  }
  
  // ============== 通用请求方法 ==============
  
  /// 🚀 通用GET请求
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    bool enableCache = false,
    Duration? timeout,
  }) async {
    try {
      return await _httpService.get<T>(
        ApiConfig.getApiUrl(endpoint),
        queryParameters: queryParameters,
        headers: headers,
        fromJson: fromJson,
        timeout: timeout,
      );
    } catch (e) {
      throw _handleError(e, 'GET请求失败');
    }
  }
  
  /// 🚀 通用POST请求
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    Duration? timeout,
  }) async {
    try {
      return await _httpService.post<T>(
        ApiConfig.getApiUrl(endpoint),
        data: data,
        queryParameters: queryParameters,
        headers: headers,
        fromJson: fromJson,
        timeout: timeout,
      );
    } catch (e) {
      throw _handleError(e, 'POST请求失败');
    }
  }
  
  /// 🚀 通用PUT请求
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    Duration? timeout,
  }) async {
    try {
      return await _httpService.put<T>(
        ApiConfig.getApiUrl(endpoint),
        data: data,
        queryParameters: queryParameters,
        headers: headers,
        fromJson: fromJson,
        timeout: timeout,
      );
    } catch (e) {
      throw _handleError(e, 'PUT请求失败');
    }
  }
  
  /// 🚀 通用DELETE请求
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    Duration? timeout,
  }) async {
    try {
      return await _httpService.delete<T>(
        ApiConfig.getApiUrl(endpoint),
        queryParameters: queryParameters,
        headers: headers,
        fromJson: fromJson,
        timeout: timeout,
      );
    } catch (e) {
      throw _handleError(e, 'DELETE请求失败');
    }
  }
  
  // ============== 认证信息管理 ==============
  
  /// 保存认证信息
  Future<void> _saveAuthInfo(LoginResponse loginData) async {
    _prefs ??= await SharedPreferences.getInstance();
    
    await _prefs!.setString(ApiConfig.accessTokenKey, loginData.accessToken);
    await _prefs!.setString(ApiConfig.refreshTokenKey, loginData.refreshToken);
    
    if (loginData.userInfo != null) {
      await _prefs!.setString(
        ApiConfig.userInfoKey,
        jsonEncode(loginData.userInfo!.toJson()),
      );
    }
    
    developer.log('✅ 认证信息已保存', name: 'API_MANAGER');
  }
  
  /// 获取访问令牌
  Future<String?> _getAccessToken() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(ApiConfig.accessTokenKey);
  }
  
  /// 获取刷新令牌
  Future<String?> _getRefreshToken() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(ApiConfig.refreshTokenKey);
  }
  
  /// 获取用户信息
  Future<UserInfo?> getUserInfo() async {
    _prefs ??= await SharedPreferences.getInstance();
    final userInfoJson = _prefs!.getString(ApiConfig.userInfoKey);
    
    if (userInfoJson != null && userInfoJson.isNotEmpty) {
      try {
        final Map<String, dynamic> json = jsonDecode(userInfoJson);
        return UserInfo.fromJson(json);
      } catch (e) {
        developer.log('❌ 解析用户信息失败: $e', name: 'API_MANAGER');
      }
    }
    
    return null;
  }
  
  /// 清除认证信息
  Future<void> _clearAuthInfo() async {
    _prefs ??= await SharedPreferences.getInstance();
    
    await _prefs!.remove(ApiConfig.accessTokenKey);
    await _prefs!.remove(ApiConfig.refreshTokenKey);
    await _prefs!.remove(ApiConfig.userInfoKey);
    
    developer.log('🧹 认证信息已清除', name: 'API_MANAGER');
  }
  
  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await _getAccessToken();
    return token != null && token.isNotEmpty;
  }
  
  // ============== 错误处理 ==============
  
  /// 统一错误处理
  ApiException _handleError(dynamic error, String defaultMessage) {
    if (error is ApiException) {
      return error;
    }
    
    developer.log('❌ API错误: $error', name: 'API_MANAGER');
    
    return ApiException(
      code: -1,
      message: defaultMessage,
      details: error.toString(),
      type: ApiExceptionType.unknown,
    );
  }
  
  /// 释放资源
  void dispose() {
    _httpService.dispose();
  }
}

// ============== 数据模型定义 ==============
// 这里定义一些示例数据模型，实际项目中应该根据API规范定义

/// 📱 短信验证码响应
class SmsCodeResponse {
  final String mobile;
  final String message;
  final DateTime sentAt;
  final int expiresIn;
  final int nextSendIn;
  
  const SmsCodeResponse({
    required this.mobile,
    required this.message,
    required this.sentAt,
    required this.expiresIn,
    required this.nextSendIn,
  });
  
  factory SmsCodeResponse.fromJson(Map<String, dynamic> json) {
    return SmsCodeResponse(
      mobile: json['mobile'] as String,
      message: json['message'] as String,
      sentAt: DateTime.fromMillisecondsSinceEpoch(json['sentAt'] as int),
      expiresIn: json['expiresIn'] as int,
      nextSendIn: json['nextSendIn'] as int,
    );
  }
}

/// 🔐 登录响应
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserInfo? userInfo;
  
  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    this.userInfo,
  });
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresIn: json['expiresIn'] as int,
      userInfo: json['userInfo'] != null 
          ? UserInfo.fromJson(json['userInfo'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 👤 用户信息
class UserInfo {
  final String userId;
  final String mobile;
  final String? nickname;
  final String? avatarUrl;
  
  const UserInfo({
    required this.userId,
    required this.mobile,
    this.nickname,
    this.avatarUrl,
  });
  
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId'] as String,
      mobile: json['mobile'] as String,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'mobile': mobile,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
    };
  }
}

/// 👤 用户详细信息
class UserProfile extends UserInfo {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? settings;
  
  const UserProfile({
    required super.userId,
    required super.mobile,
    super.nickname,
    super.avatarUrl,
    this.createdAt,
    this.updatedAt,
    this.settings,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      mobile: json['mobile'] as String,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }
}

/// 🏷️ 分类
class Category {
  final String id;
  final String name;
  final String? icon;
  final String? description;
  final int sortOrder;
  
  const Category({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    required this.sortOrder,
  });
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      sortOrder: json['sortOrder'] as int,
    );
  }
}

/// 🎯 推荐内容
class Recommendation {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String category;
  final double rating;
  final int viewCount;
  
  const Recommendation({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.category,
    required this.rating,
    required this.viewCount,
  });
  
  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      viewCount: json['viewCount'] as int,
    );
  }
}

/// 📍 附近内容
class NearbyItem {
  final String id;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final double distance;
  final String? address;
  
  const NearbyItem({
    required this.id,
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.distance,
    this.address,
  });
  
  factory NearbyItem.fromJson(Map<String, dynamic> json) {
    return NearbyItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      address: json['address'] as String?,
    );
  }
}

/// 🔍 搜索结果
class SearchResult {
  final String id;
  final String title;
  final String? description;
  final String type;
  final String? imageUrl;
  final double relevance;
  
  const SearchResult({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.imageUrl,
    required this.relevance,
  });
  
  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      imageUrl: json['imageUrl'] as String?,
      relevance: (json['relevance'] as num).toDouble(),
    );
  }
}

/// 📤 上传结果
class UploadResult {
  final String fileId;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String mimeType;
  
  const UploadResult({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.mimeType,
  });
  
  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      fileId: json['fileId'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      fileSize: json['fileSize'] as int,
      mimeType: json['mimeType'] as String,
    );
  }
}
