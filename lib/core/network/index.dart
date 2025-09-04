/// 🌐 网络模块统一导出
/// 提供所有网络相关功能的统一入口

// 配置相关
export 'api_config.dart';

// 数据模型
export 'api_models.dart';

// 拦截器
export 'api_interceptors.dart';

// 基础服务
export 'base_http_service.dart';

// API管理器 (主要入口)
export 'api_manager.dart';

/// 🚀 快速开始指南
/// 
/// 1. 基本使用:
/// ```dart
/// import 'package:your_app/core/network/index.dart';
/// 
/// // 获取API管理器实例
/// final api = ApiManager.instance;
/// 
/// // 发送验证码
/// final response = await api.sendSmsCode(mobile: '13800138000');
/// if (response.isSuccess) {
///   print('验证码发送成功: ${response.data?.message}');
/// }
/// ```
/// 
/// 2. 自定义请求:
/// ```dart
/// // GET请求
/// final response = await api.get<List<String>>(
///   '/custom/endpoint',
///   fromJson: (json) => (json as List).cast<String>(),
/// );
/// 
/// // POST请求
/// final response = await api.post<Map<String, dynamic>>(
///   '/custom/endpoint',
///   data: {'key': 'value'},
/// );
/// ```
/// 
/// 3. 文件上传:
/// ```dart
/// final response = await api.uploadFile(
///   filePath: '/path/to/file.jpg',
///   category: 'avatar',
///   onProgress: (sent, total) {
///     print('上传进度: ${(sent / total * 100).toInt()}%');
///   },
/// );
/// ```
/// 
/// 4. 错误处理:
/// ```dart
/// try {
///   final response = await api.getUserProfile();
///   // 处理成功响应
/// } on ApiException catch (e) {
///   if (e.isAuthError) {
///     // 处理认证错误
///   } else if (e.isNetworkError) {
///     // 处理网络错误
///   }
///   print('API错误: ${e.message}');
/// }
/// ```
