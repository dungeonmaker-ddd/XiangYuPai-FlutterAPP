/// 🔄 API拦截器系统
/// 提供请求、响应、错误处理等拦截功能

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'api_models.dart';

// ============== 拦截器基类 ==============

/// 🔄 API拦截器抽象基类
abstract class ApiInterceptor {
  /// 请求拦截器
  Future<ApiRequest> onRequest(ApiRequest request) async => request;
  
  /// 响应拦截器
  Future<ApiResponse<T>> onResponse<T>(ApiResponse<T> response) async => response;
  
  /// 错误拦截器
  Future<ApiException> onError(ApiException error) async => error;
}

// ============== 日志拦截器 ==============

/// 📝 日志拦截器
class LoggingInterceptor extends ApiInterceptor {
  final LogLevel logLevel;
  final bool logHeaders;
  final bool logBody;
  final bool logResponse;
  
  const LoggingInterceptor({
    this.logLevel = LogLevel.debug,
    this.logHeaders = true,
    this.logBody = true,
    this.logResponse = true,
  });
  
  @override
  Future<ApiRequest> onRequest(ApiRequest request) async {
    if (!_shouldLog()) return request;
    
    final buffer = StringBuffer();
    buffer.writeln('🚀 ============== API请求 ==============');
    buffer.writeln('📍 URL: ${request.method.value} ${request.url}');
    buffer.writeln('⏰ 时间: ${_formatTime(request.timestamp)}');
    buffer.writeln('🆔 请求ID: ${request.requestId}');
    
    if (logHeaders && request.headers.isNotEmpty) {
      buffer.writeln('📋 请求头:');
      request.headers.forEach((key, value) {
        // 隐藏敏感信息
        final displayValue = _isSensitiveHeader(key) ? '***' : value;
        buffer.writeln('   $key: $displayValue');
      });
    }
    
    if (request.queryParameters != null && request.queryParameters!.isNotEmpty) {
      buffer.writeln('🔍 查询参数:');
      request.queryParameters!.forEach((key, value) {
        buffer.writeln('   $key: $value');
      });
    }
    
    if (logBody && request.data != null) {
      buffer.writeln('📦 请求体:');
      buffer.writeln('   ${_formatJson(request.data)}');
    }
    
    buffer.writeln('=====================================');
    developer.log(buffer.toString(), name: 'API_REQUEST');
    
    return request;
  }
  
  @override
  Future<ApiResponse<T>> onResponse<T>(ApiResponse<T> response) async {
    if (!_shouldLog() || !logResponse) return response;
    
    final buffer = StringBuffer();
    buffer.writeln('📡 ============== API响应 ==============');
    buffer.writeln('📊 状态码: ${response.code}');
    buffer.writeln('💬 消息: ${response.message}');
    buffer.writeln('⏰ 时间: ${_formatTime(response.timestamp)}');
    buffer.writeln('🆔 请求ID: ${response.requestId ?? 'N/A'}');
    
    if (logBody && response.data != null) {
      buffer.writeln('📦 响应数据:');
      buffer.writeln('   ${_formatJson(response.data)}');
    }
    
    buffer.writeln('=====================================');
    developer.log(buffer.toString(), name: 'API_RESPONSE');
    
    return response;
  }
  
  @override
  Future<ApiException> onError(ApiException error) async {
    if (!_shouldLog()) return error;
    
    final buffer = StringBuffer();
    buffer.writeln('❌ ============== API错误 ==============');
    buffer.writeln('🚨 类型: ${error.type.displayName}');
    buffer.writeln('📊 错误码: ${error.code}');
    buffer.writeln('💬 错误消息: ${error.message}');
    buffer.writeln('⏰ 时间: ${_formatTime(error.timestamp)}');
    
    if (error.request != null) {
      buffer.writeln('📍 请求: ${error.request!.method.value} ${error.request!.url}');
    }
    
    if (error.details != null) {
      buffer.writeln('📋 详细信息:');
      buffer.writeln('   ${_formatJson(error.details)}');
    }
    
    if (error.stackTrace != null && logLevel == LogLevel.verbose) {
      buffer.writeln('📚 堆栈跟踪:');
      buffer.writeln('   ${error.stackTrace}');
    }
    
    buffer.writeln('=====================================');
    developer.log(buffer.toString(), name: 'API_ERROR');
    
    return error;
  }
  
  bool _shouldLog() {
    return ApiConfig.isDebugMode && 
           (ApiConfig.logLevel.index >= logLevel.index);
  }
  
  bool _isSensitiveHeader(String key) {
    final sensitiveHeaders = ['authorization', 'cookie', 'x-api-key'];
    return sensitiveHeaders.contains(key.toLowerCase());
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}'
           '.${time.millisecond.toString().padLeft(3, '0')}';
  }
  
  String _formatJson(dynamic data) {
    try {
      if (data is String) return data;
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      return data.toString();
    }
  }
}

// ============== 认证拦截器 ==============

/// 🔐 认证拦截器
class AuthInterceptor extends ApiInterceptor {
  SharedPreferences? _prefs;
  
  @override
  Future<ApiRequest> onRequest(ApiRequest request) async {
    // 获取存储的访问令牌
    final token = await _getAccessToken();
    
    if (token != null && token.isNotEmpty) {
      // 检查令牌是否即将过期
      if (await _shouldRefreshToken()) {
        await _refreshToken();
      }
      
      // 添加认证头
      final updatedHeaders = {
        ...request.headers,
        'Authorization': 'Bearer $token',
      };
      
      return request.copyWith(headers: updatedHeaders);
    }
    
    return request;
  }
  
  @override
  Future<ApiException> onError(ApiException error) async {
    // 处理认证失败的情况
    if (error.code == 401) {
      // 尝试刷新令牌
      final refreshSuccess = await _refreshToken();
      
      if (refreshSuccess && error.request != null) {
        // 令牌刷新成功，可以重试请求
        return error.copyWith(
          type: ApiExceptionType.auth,
          message: '认证已刷新，请重试',
        );
      } else {
        // 刷新失败，清除本地认证信息
        await _clearAuthInfo();
        return error.copyWith(
          type: ApiExceptionType.auth,
          message: '身份验证过期，请重新登录',
        );
      }
    }
    
    return error;
  }
  
  Future<String?> _getAccessToken() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(ApiConfig.accessTokenKey);
  }
  
  Future<String?> _getRefreshToken() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(ApiConfig.refreshTokenKey);
  }
  
  Future<bool> _shouldRefreshToken() async {
    // 这里可以实现更复杂的令牌过期检查逻辑
    // 例如检查JWT令牌的过期时间
    return false; // 简化实现
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }
      
      // 这里应该调用刷新令牌的API
      // 由于循环依赖问题，这里只是示例
      developer.log('🔄 正在刷新访问令牌...', name: 'AUTH_INTERCEPTOR');
      
      // 模拟刷新成功
      return true;
      
    } catch (e) {
      developer.log('❌ 刷新令牌失败: $e', name: 'AUTH_INTERCEPTOR');
      return false;
    }
  }
  
  Future<void> _clearAuthInfo() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(ApiConfig.accessTokenKey);
    await _prefs!.remove(ApiConfig.refreshTokenKey);
    await _prefs!.remove(ApiConfig.userInfoKey);
    developer.log('🧹 已清除本地认证信息', name: 'AUTH_INTERCEPTOR');
  }
}

// ============== 重试拦截器 ==============

/// 🔄 重试拦截器
class RetryInterceptor extends ApiInterceptor {
  final int maxRetries;
  final Duration retryDelay;
  final List<int> retryStatusCodes;
  
  const RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.retryStatusCodes = const [500, 502, 503, 504],
  });
  
  @override
  Future<ApiException> onError(ApiException error) async {
    // 检查是否可以重试
    if (!_shouldRetry(error)) {
      return error;
    }
    
    // 获取当前重试次数
    final currentRetries = error.details is Map 
        ? (error.details as Map)['retryCount'] as int? ?? 0 
        : 0;
    
    if (currentRetries >= maxRetries) {
      return error.copyWith(
        message: '${error.message} (已重试${currentRetries}次)',
      );
    }
    
    // 延迟后重试
    await Future.delayed(retryDelay * (currentRetries + 1));
    
    developer.log(
      '🔄 正在重试请求 (${currentRetries + 1}/$maxRetries): ${error.request?.url}',
      name: 'RETRY_INTERCEPTOR',
    );
    
    // 标记重试次数
    final updatedDetails = error.details is Map 
        ? {...(error.details as Map), 'retryCount': currentRetries + 1}
        : {'retryCount': currentRetries + 1};
    
    return error.copyWith(
      details: updatedDetails,
      message: '正在重试请求 (${currentRetries + 1}/$maxRetries)',
    );
  }
  
  bool _shouldRetry(ApiException error) {
    // 检查是否为可重试的错误
    if (!error.canRetry) return false;
    
    // 检查HTTP状态码
    if (error.isHttpError && !retryStatusCodes.contains(error.code)) {
      return false;
    }
    
    // 检查请求是否支持重试
    if (error.request?.enableRetry == false) {
      return false;
    }
    
    return true;
  }
}

// ============== 缓存拦截器 ==============

/// 💾 缓存拦截器
class CacheInterceptor extends ApiInterceptor {
  final Map<String, _CacheEntry> _cache = {};
  final Duration defaultCacheTime;
  final int maxCacheSize;
  
  CacheInterceptor({
    this.defaultCacheTime = const Duration(minutes: 5),
    this.maxCacheSize = 100,
  });
  
  @override
  Future<ApiRequest> onRequest(ApiRequest request) async {
    // 只对GET请求启用缓存
    if (request.method != HttpMethod.get || !request.enableCache) {
      return request;
    }
    
    final cacheKey = request.cacheKey ?? _generateCacheKey(request);
    final cachedEntry = _cache[cacheKey];
    
    if (cachedEntry != null && !cachedEntry.isExpired) {
      developer.log('💾 使用缓存数据: $cacheKey', name: 'CACHE_INTERCEPTOR');
      
      // 这里需要特殊处理，因为我们需要返回缓存的响应而不是继续请求
      // 在实际实现中，这可能需要修改拦截器架构
    }
    
    return request;
  }
  
  @override
  Future<ApiResponse<T>> onResponse<T>(ApiResponse<T> response) async {
    // 缓存成功的响应
    if (response.isSuccess && response.requestId != null) {
      final request = _findRequestById(response.requestId!);
      
      if (request?.enableCache == true && request?.method == HttpMethod.get) {
        final cacheKey = request!.cacheKey ?? _generateCacheKey(request);
        
        // 清理过期缓存
        _cleanExpiredCache();
        
        // 如果缓存已满，移除最旧的条目
        if (_cache.length >= maxCacheSize) {
          _removeOldestCache();
        }
        
        _cache[cacheKey] = _CacheEntry(
          data: response,
          timestamp: DateTime.now(),
          expiry: DateTime.now().add(defaultCacheTime),
        );
        
        developer.log('💾 缓存响应数据: $cacheKey', name: 'CACHE_INTERCEPTOR');
      }
    }
    
    return response;
  }
  
  String _generateCacheKey(ApiRequest request) {
    final buffer = StringBuffer();
    buffer.write(request.url);
    
    if (request.queryParameters != null) {
      final sortedParams = request.queryParameters!.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      
      for (final param in sortedParams) {
        buffer.write('&${param.key}=${param.value}');
      }
    }
    
    return buffer.toString().hashCode.toString();
  }
  
  ApiRequest? _findRequestById(String requestId) {
    // 在实际实现中，这里需要维护请求ID到请求对象的映射
    return null;
  }
  
  void _cleanExpiredCache() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }
  
  void _removeOldestCache() {
    if (_cache.isEmpty) return;
    
    String? oldestKey;
    DateTime? oldestTime;
    
    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.timestamp.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value.timestamp;
      }
    }
    
    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }
  
  /// 清空所有缓存
  void clearCache() {
    _cache.clear();
    developer.log('🧹 已清空所有缓存', name: 'CACHE_INTERCEPTOR');
  }
  
  /// 清空指定缓存
  void clearCacheByKey(String key) {
    _cache.remove(key);
    developer.log('🧹 已清空缓存: $key', name: 'CACHE_INTERCEPTOR');
  }
}

/// 💾 缓存条目
class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final DateTime expiry;
  
  const _CacheEntry({
    required this.data,
    required this.timestamp,
    required this.expiry,
  });
  
  bool get isExpired => DateTime.now().isAfter(expiry);
}

// ============== 性能监控拦截器 ==============

/// 📊 性能监控拦截器
class PerformanceInterceptor extends ApiInterceptor {
  final Map<String, DateTime> _requestStartTimes = {};
  
  @override
  Future<ApiRequest> onRequest(ApiRequest request) async {
    _requestStartTimes[request.requestId] = DateTime.now();
    return request;
  }
  
  @override
  Future<ApiResponse<T>> onResponse<T>(ApiResponse<T> response) async {
    _logPerformance(response.requestId, 'SUCCESS');
    return response;
  }
  
  @override
  Future<ApiException> onError(ApiException error) async {
    _logPerformance(error.request?.requestId, 'ERROR');
    return error;
  }
  
  void _logPerformance(String? requestId, String status) {
    if (requestId == null) return;
    
    final startTime = _requestStartTimes.remove(requestId);
    if (startTime == null) return;
    
    final duration = DateTime.now().difference(startTime);
    
    if (ApiConfig.isDebugMode) {
      developer.log(
        '⏱️ 请求性能 [$status]: ${duration.inMilliseconds}ms (ID: $requestId)',
        name: 'PERFORMANCE',
      );
    }
  }
}
