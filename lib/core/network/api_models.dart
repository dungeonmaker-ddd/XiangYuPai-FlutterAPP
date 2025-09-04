/// 📊 API通用数据模型
/// 定义请求、响应、异常等通用数据结构

import 'base_http_service.dart';

// ============== API请求模型 ==============

/// 🚀 API请求模型
class ApiRequest {
  /// 请求URL
  final String url;
  
  /// 请求方法
  final HttpMethod method;
  
  /// 请求数据
  final Map<String, dynamic>? data;
  
  /// 查询参数
  final Map<String, String>? queryParameters;
  
  /// 请求头
  final Map<String, String> headers;
  
  /// 超时时间
  final Duration timeout;
  
  /// 是否启用重试
  final bool enableRetry;
  
  /// 是否启用缓存
  final bool enableCache;
  
  /// 缓存键
  final String? cacheKey;
  
  /// 数据转换函数
  final dynamic Function(dynamic)? fromJson;
  
  /// 请求时间戳
  final DateTime timestamp;
  
  /// 请求ID
  final String requestId;
  
  const ApiRequest({
    required this.url,
    required this.method,
    this.data,
    this.queryParameters,
    required this.headers,
    required this.timeout,
    this.enableRetry = true,
    this.enableCache = false,
    this.cacheKey,
    this.fromJson,
    DateTime? timestamp,
    String? requestId,
  }) : timestamp = timestamp ?? DateTime.now(),
       requestId = requestId ?? '';
  
  /// 复制并修改请求
  ApiRequest copyWith({
    String? url,
    HttpMethod? method,
    Map<String, dynamic>? data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
    bool? enableRetry,
    bool? enableCache,
    String? cacheKey,
    dynamic Function(dynamic)? fromJson,
  }) {
    return ApiRequest(
      url: url ?? this.url,
      method: method ?? this.method,
      data: data ?? this.data,
      queryParameters: queryParameters ?? this.queryParameters,
      headers: headers ?? this.headers,
      timeout: timeout ?? this.timeout,
      enableRetry: enableRetry ?? this.enableRetry,
      enableCache: enableCache ?? this.enableCache,
      cacheKey: cacheKey ?? this.cacheKey,
      fromJson: fromJson ?? this.fromJson,
      timestamp: timestamp,
      requestId: requestId,
    );
  }
  
  @override
  String toString() {
    return 'ApiRequest(${method.value} $url)';
  }
}

// ============== API响应模型 ==============

/// 📡 API响应模型
class ApiResponse<T> {
  /// 状态码
  final int code;
  
  /// 响应消息
  final String message;
  
  /// 响应数据
  final T? data;
  
  /// 响应时间戳
  final DateTime timestamp;
  
  /// 请求ID
  final String? requestId;
  
  /// 额外信息
  final Map<String, dynamic>? extra;
  
  const ApiResponse({
    required this.code,
    required this.message,
    this.data,
    DateTime? timestamp,
    this.requestId,
    this.extra,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// 是否成功
  bool get isSuccess => code >= 200 && code < 300;
  
  /// 是否失败
  bool get isFailure => !isSuccess;
  
  /// 从JSON创建响应对象
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    return ApiResponse<T>(
      code: json['code'] as int? ?? json['status'] as int? ?? 200,
      message: json['message'] as String? ?? json['msg'] as String? ?? 'Success',
      data: json['data'] != null && fromJson != null 
          ? fromJson(json['data']) 
          : json['data'] as T?,
      timestamp: json['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
          : DateTime.now(),
      requestId: json['requestId'] as String?,
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'requestId': requestId,
      'extra': extra,
    };
  }
  
  /// 复制并修改响应
  ApiResponse<R> copyWith<R>({
    int? code,
    String? message,
    R? data,
    DateTime? timestamp,
    String? requestId,
    Map<String, dynamic>? extra,
  }) {
    return ApiResponse<R>(
      code: code ?? this.code,
      message: message ?? this.message,
      data: data ?? this.data as R?,
      timestamp: timestamp ?? this.timestamp,
      requestId: requestId ?? this.requestId,
      extra: extra ?? this.extra,
    );
  }
  
  @override
  String toString() {
    return 'ApiResponse(code: $code, message: $message, data: $data)';
  }
}

// ============== API异常模型 ==============

/// 🚨 API异常类型
enum ApiExceptionType {
  /// 网络异常
  network('网络异常'),
  
  /// HTTP异常
  http('HTTP异常'),
  
  /// 解析异常
  parse('解析异常'),
  
  /// 业务异常
  business('业务异常'),
  
  /// 认证异常
  auth('认证异常'),
  
  /// 超时异常
  timeout('超时异常'),
  
  /// 上传异常
  upload('上传异常'),
  
  /// 下载异常
  download('下载异常'),
  
  /// 缓存异常
  cache('缓存异常'),
  
  /// 未知异常
  unknown('未知异常');
  
  const ApiExceptionType(this.displayName);
  final String displayName;
}

/// 🚨 API异常模型
class ApiException implements Exception {
  /// 错误码
  final int code;
  
  /// 错误消息
  final String message;
  
  /// 异常类型
  final ApiExceptionType type;
  
  /// 详细错误信息
  final dynamic details;
  
  /// 堆栈跟踪
  final StackTrace? stackTrace;
  
  /// 请求信息
  final ApiRequest? request;
  
  /// 响应信息
  final ApiResponse? response;
  
  /// 时间戳
  final DateTime timestamp;
  
  const ApiException({
    required this.code,
    required this.message,
    this.type = ApiExceptionType.unknown,
    this.details,
    this.stackTrace,
    this.request,
    this.response,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// 是否为网络异常
  bool get isNetworkError => type == ApiExceptionType.network;
  
  /// 是否为HTTP异常
  bool get isHttpError => type == ApiExceptionType.http;
  
  /// 是否为解析异常
  bool get isParseError => type == ApiExceptionType.parse;
  
  /// 是否为业务异常
  bool get isBusinessError => type == ApiExceptionType.business;
  
  /// 是否为认证异常
  bool get isAuthError => type == ApiExceptionType.auth;
  
  /// 是否为超时异常
  bool get isTimeoutError => type == ApiExceptionType.timeout;
  
  /// 是否可重试
  bool get canRetry {
    return isNetworkError || 
           isTimeoutError || 
           (isHttpError && [500, 502, 503, 504].contains(code));
  }
  
  /// 从HTTP响应创建异常
  factory ApiException.fromResponse(
    ApiResponse response, {
    ApiExceptionType? type,
    ApiRequest? request,
  }) {
    return ApiException(
      code: response.code,
      message: response.message,
      type: type ?? ApiExceptionType.business,
      details: response.data,
      request: request,
      response: response,
      timestamp: response.timestamp,
    );
  }
  
  /// 复制并修改异常
  ApiException copyWith({
    int? code,
    String? message,
    ApiExceptionType? type,
    dynamic details,
    StackTrace? stackTrace,
    ApiRequest? request,
    ApiResponse? response,
  }) {
    return ApiException(
      code: code ?? this.code,
      message: message ?? this.message,
      type: type ?? this.type,
      details: details ?? this.details,
      stackTrace: stackTrace ?? this.stackTrace,
      request: request ?? this.request,
      response: response ?? this.response,
      timestamp: timestamp,
    );
  }
  
  @override
  String toString() {
    return 'ApiException(${type.displayName}): $code - $message';
  }
}

// ============== 分页数据模型 ==============

/// 📄 分页请求参数
class PageRequest {
  /// 当前页码（从1开始）
  final int page;
  
  /// 每页数量
  final int size;
  
  /// 排序字段
  final String? sortBy;
  
  /// 排序方向 (asc/desc)
  final String? sortOrder;
  
  /// 搜索关键词
  final String? keyword;
  
  /// 过滤条件
  final Map<String, dynamic>? filters;
  
  const PageRequest({
    this.page = 1,
    this.size = 20,
    this.sortBy,
    this.sortOrder,
    this.keyword,
    this.filters,
  });
  
  /// 转换为查询参数
  Map<String, String> toQueryParameters() {
    final params = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    
    if (sortBy != null) params['sortBy'] = sortBy!;
    if (sortOrder != null) params['sortOrder'] = sortOrder!;
    if (keyword != null && keyword!.isNotEmpty) params['keyword'] = keyword!;
    
    // 添加过滤条件
    if (filters != null) {
      filters!.forEach((key, value) {
        if (value != null) {
          params['filter_$key'] = value.toString();
        }
      });
    }
    
    return params;
  }
  
  @override
  String toString() {
    return 'PageRequest(page: $page, size: $size, sortBy: $sortBy)';
  }
}

/// 📄 分页响应数据
class PageResponse<T> {
  /// 当前页数据
  final List<T> items;
  
  /// 当前页码
  final int page;
  
  /// 每页数量
  final int size;
  
  /// 总数量
  final int total;
  
  /// 总页数
  final int totalPages;
  
  /// 是否有下一页
  final bool hasNext;
  
  /// 是否有上一页
  final bool hasPrevious;
  
  const PageResponse({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });
  
  /// 从JSON创建分页响应
  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonItem,
  ) {
    final List<dynamic> itemsJson = json['items'] as List<dynamic>? ?? 
                                   json['data'] as List<dynamic>? ?? 
                                   json['list'] as List<dynamic>? ?? [];
    
    final items = itemsJson.map((item) => fromJsonItem(item)).toList();
    final page = json['page'] as int? ?? json['current'] as int? ?? 1;
    final size = json['size'] as int? ?? json['pageSize'] as int? ?? items.length;
    final total = json['total'] as int? ?? json['totalElements'] as int? ?? items.length;
    final totalPages = json['totalPages'] as int? ?? (total / size).ceil();
    
    return PageResponse<T>(
      items: items,
      page: page,
      size: size,
      total: total,
      totalPages: totalPages,
      hasNext: page < totalPages,
      hasPrevious: page > 1,
    );
  }
  
  /// 是否为空
  bool get isEmpty => items.isEmpty;
  
  /// 是否非空
  bool get isNotEmpty => items.isNotEmpty;
  
  @override
  String toString() {
    return 'PageResponse(page: $page/$totalPages, items: ${items.length}, total: $total)';
  }
}
