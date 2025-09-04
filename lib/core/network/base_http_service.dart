/// 🌐 基础HTTP服务
/// 封装所有HTTP请求的通用逻辑

import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_models.dart';
import 'api_interceptors.dart';

/// 🔧 HTTP请求方法枚举
enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE'),
  head('HEAD'),
  options('OPTIONS');
  
  const HttpMethod(this.value);
  final String value;
}

/// 🌐 基础HTTP服务类
class BaseHttpService {
  final http.Client _client;
  final List<ApiInterceptor> _interceptors = [];
  
  /// 构造函数
  BaseHttpService({
    http.Client? client,
  }) : _client = client ?? http.Client() {
    _initializeInterceptors();
  }
  
  // ============== 拦截器管理 ==============
  
  /// 初始化默认拦截器
  void _initializeInterceptors() {
    // 请求日志拦截器
    if (ApiConfig.enableRequestLogging) {
      addInterceptor(LoggingInterceptor());
    }
    
    // 认证拦截器
    addInterceptor(AuthInterceptor());
    
    // 错误处理拦截器
    addInterceptor(ErrorInterceptor());
    
    // 重试拦截器
    addInterceptor(RetryInterceptor());
  }
  
  /// 添加拦截器
  void addInterceptor(ApiInterceptor interceptor) {
    _interceptors.add(interceptor);
  }
  
  /// 移除拦截器
  void removeInterceptor(ApiInterceptor interceptor) {
    _interceptors.remove(interceptor);
  }
  
  /// 清空拦截器
  void clearInterceptors() {
    _interceptors.clear();
  }
  
  // ============== 通用请求方法 ==============
  
  /// 🚀 通用请求方法
  Future<ApiResponse<T>> request<T>(
    String url, {
    HttpMethod method = HttpMethod.get,
    Map<String, dynamic>? data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    Duration? timeout,
    bool enableRetry = true,
    bool enableCache = false,
    String? cacheKey,
  }) async {
    try {
      // 构建请求对象
      final request = ApiRequest(
        url: url,
        method: method,
        data: data,
        queryParameters: queryParameters,
        headers: {...ApiConfig.defaultHeaders, ...?headers},
        timeout: timeout ?? ApiConfig.receiveTimeout,
        enableRetry: enableRetry,
        enableCache: enableCache,
        cacheKey: cacheKey,
      );
      
      // 执行请求前拦截器
      ApiRequest processedRequest = request;
      for (final interceptor in _interceptors) {
        processedRequest = await interceptor.onRequest(processedRequest);
      }
      
      // 执行HTTP请求
      final response = await _executeRequest(processedRequest);
      
      // 执行响应后拦截器
      ApiResponse<T> processedResponse = response;
      for (final interceptor in _interceptors) {
        processedResponse = await interceptor.onResponse<T>(processedResponse);
      }
      
      return processedResponse;
      
    } catch (e) {
      // 执行错误拦截器
      ApiException exception = e is ApiException 
          ? e 
          : ApiException(code: -1, message: e.toString());
          
      for (final interceptor in _interceptors) {
        exception = await interceptor.onError(exception);
      }
      
      throw exception;
    }
  }
  
  /// 执行HTTP请求
  Future<ApiResponse<T>> _executeRequest<T>(ApiRequest request) async {
    final uri = _buildUri(request.url, request.queryParameters);
    http.Response httpResponse;
    
    try {
      // 根据请求方法执行相应的HTTP请求
      switch (request.method) {
        case HttpMethod.get:
          httpResponse = await _client.get(uri, headers: request.headers)
              .timeout(request.timeout);
          break;
          
        case HttpMethod.post:
          httpResponse = await _client.post(
            uri,
            headers: request.headers,
            body: request.data != null ? jsonEncode(request.data) : null,
          ).timeout(request.timeout);
          break;
          
        case HttpMethod.put:
          httpResponse = await _client.put(
            uri,
            headers: request.headers,
            body: request.data != null ? jsonEncode(request.data) : null,
          ).timeout(request.timeout);
          break;
          
        case HttpMethod.patch:
          httpResponse = await _client.patch(
            uri,
            headers: request.headers,
            body: request.data != null ? jsonEncode(request.data) : null,
          ).timeout(request.timeout);
          break;
          
        case HttpMethod.delete:
          httpResponse = await _client.delete(uri, headers: request.headers)
              .timeout(request.timeout);
          break;
          
        case HttpMethod.head:
          httpResponse = await _client.head(uri, headers: request.headers)
              .timeout(request.timeout);
          break;
          
        case HttpMethod.options:
          // http包不直接支持OPTIONS，使用Request
          final httpRequest = http.Request('OPTIONS', uri);
          httpRequest.headers.addAll(request.headers);
          final streamedResponse = await _client.send(httpRequest);
          httpResponse = await http.Response.fromStream(streamedResponse);
          break;
      }
      
      // 解析响应
      return _parseResponse<T>(httpResponse, request.fromJson);
      
    } on SocketException catch (e) {
      throw ApiException(
        code: -1,
        message: '网络连接失败: ${e.message}',
        type: ApiExceptionType.network,
      );
    } on HttpException catch (e) {
      throw ApiException(
        code: -1,
        message: 'HTTP错误: ${e.message}',
        type: ApiExceptionType.http,
      );
    } on FormatException catch (e) {
      throw ApiException(
        code: -1,
        message: '数据格式错误: ${e.message}',
        type: ApiExceptionType.parse,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: -1,
        message: '请求失败: ${e.toString()}',
        type: ApiExceptionType.unknown,
      );
    }
  }
  
  /// 解析HTTP响应
  ApiResponse<T> _parseResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      // 检查HTTP状态码
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          code: response.statusCode,
          message: _getHttpErrorMessage(response.statusCode),
          type: ApiExceptionType.http,
        );
      }
      
      // 解析JSON响应
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      
      // 构建API响应对象
      return ApiResponse<T>.fromJson(jsonData, fromJson);
      
    } on FormatException catch (e) {
      throw ApiException(
        code: response.statusCode,
        message: '响应数据格式错误: ${e.message}',
        type: ApiExceptionType.parse,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: response.statusCode,
        message: '响应解析失败: ${e.toString()}',
        type: ApiExceptionType.parse,
      );
    }
  }
  
  // ============== 便捷方法 ==============
  
  /// GET请求
  Future<ApiResponse<T>> get<T>(
    String url, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    Duration? timeout,
  }) {
    return request<T>(
      url,
      method: HttpMethod.get,
      queryParameters: queryParameters,
      headers: headers,
      fromJson: fromJson,
      timeout: timeout,
    );
  }
  
  /// POST请求
  Future<ApiResponse<T>> post<T>(
    String url, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    Duration? timeout,
  }) {
    return request<T>(
      url,
      method: HttpMethod.post,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      fromJson: fromJson,
      timeout: timeout,
    );
  }
  
  /// PUT请求
  Future<ApiResponse<T>> put<T>(
    String url, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    Duration? timeout,
  }) {
    return request<T>(
      url,
      method: HttpMethod.put,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      fromJson: fromJson,
      timeout: timeout,
    );
  }
  
  /// PATCH请求
  Future<ApiResponse<T>> patch<T>(
    String url, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    Duration? timeout,
  }) {
    return request<T>(
      url,
      method: HttpMethod.patch,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      fromJson: fromJson,
      timeout: timeout,
    );
  }
  
  /// DELETE请求
  Future<ApiResponse<T>> delete<T>(
    String url, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    Duration? timeout,
  }) {
    return request<T>(
      url,
      method: HttpMethod.delete,
      queryParameters: queryParameters,
      headers: headers,
      fromJson: fromJson,
      timeout: timeout,
    );
  }
  
  // ============== 文件上传下载 ==============
  
  /// 上传文件
  Future<ApiResponse<T>> uploadFile<T>(
    String url,
    String filePath, {
    String fieldName = 'file',
    Map<String, String>? fields,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      
      // 添加文件
      final file = await http.MultipartFile.fromPath(fieldName, filePath);
      request.files.add(file);
      
      // 添加其他字段
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      // 添加请求头
      request.headers.addAll({
        ...ApiConfig.defaultHeaders,
        ...?headers,
      });
      
      // 发送请求
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      
      return _parseResponse<T>(response, fromJson);
      
    } catch (e) {
      throw ApiException(
        code: -1,
        message: '文件上传失败: ${e.toString()}',
        type: ApiExceptionType.upload,
      );
    }
  }
  
  /// 下载文件
  Future<List<int>> downloadFile(
    String url, {
    Map<String, String>? headers,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final request = http.Request('GET', Uri.parse(url));
      request.headers.addAll({
        ...ApiConfig.defaultHeaders,
        ...?headers,
      });
      
      final streamedResponse = await _client.send(request);
      
      if (streamedResponse.statusCode < 200 || streamedResponse.statusCode >= 300) {
        throw ApiException(
          code: streamedResponse.statusCode,
          message: _getHttpErrorMessage(streamedResponse.statusCode),
          type: ApiExceptionType.http,
        );
      }
      
      final List<int> bytes = [];
      final int? contentLength = streamedResponse.contentLength;
      int received = 0;
      
      await for (final chunk in streamedResponse.stream) {
        bytes.addAll(chunk);
        received += chunk.length;
        
        if (contentLength != null && onProgress != null) {
          onProgress(received, contentLength);
        }
      }
      
      return bytes;
      
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        code: -1,
        message: '文件下载失败: ${e.toString()}',
        type: ApiExceptionType.download,
      );
    }
  }
  
  // ============== 工具方法 ==============
  
  /// 构建URI
  Uri _buildUri(String url, Map<String, String>? queryParameters) {
    final uri = Uri.parse(url);
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...queryParameters,
      },
    );
  }
  
  /// 获取HTTP错误消息
  String _getHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '身份验证失败';
      case 403:
        return '访问被拒绝';
      case 404:
        return '请求的资源不存在';
      case 405:
        return '请求方法不允许';
      case 408:
        return '请求超时';
      case 409:
        return '请求冲突';
      case 422:
        return '请求参数验证失败';
      case 429:
        return '请求过于频繁，请稍后再试';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务暂时不可用';
      case 504:
        return '网关超时';
      default:
        return '网络请求失败 (状态码: $statusCode)';
    }
  }
  
  /// 释放资源
  void dispose() {
    _client.close();
    _interceptors.clear();
  }
}

/// 🏭 HTTP服务工厂
class HttpServiceFactory {
  static BaseHttpService? _instance;
  
  /// 获取HTTP服务实例（单例模式）
  static BaseHttpService getInstance() {
    return _instance ??= BaseHttpService();
  }
  
  /// 重置实例（主要用于测试）
  static void reset() {
    _instance?.dispose();
    _instance = null;
  }
}
