/// 🧪 API测试页面
/// 用于本地开发时测试API连接

import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../config/auth_config.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final _phoneController = TextEditingController(text: '13800138000');
  final _codeController = TextEditingController(text: '123456');
  
  late final IAuthService _authService;
  String _testResult = '准备测试...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthServiceFactory.getInstance();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _testSendSms() async {
    setState(() {
      _isLoading = true;
      _testResult = '正在发送短信验证码...';
    });

    try {
      final request = SmsCodeRequest(
        mobile: _phoneController.text.trim(),
        clientType: AuthConfig.clientType,
      );

      developer.log('🧪 Testing SMS Send API...');
      final response = await _authService.sendSmsCode(request);
      
      setState(() {
        _testResult = '''
✅ 发送短信成功！
📱 脱敏手机号: ${response.data?.mobile}
💬 响应消息: ${response.data?.message}
⏰ 发送时间: ${response.data?.sentAt}
⏳ 有效期: ${response.data?.expiresIn}秒
🔄 重发间隔: ${response.data?.nextSendIn}秒
        ''';
      });
      
      developer.log('✅ SMS Send Test SUCCESS');
    } on ApiException catch (e) {
      setState(() {
        _testResult = '''
❌ 发送短信失败！
🔢 错误码: ${e.code}
💬 错误信息: ${e.message}
📄 详细数据: ${e.data}
        ''';
      });
      
      developer.log('❌ SMS Send Test FAILED: ${e.message}');
    } catch (e) {
      setState(() {
        _testResult = '''
💥 未知错误！
🐛 错误类型: ${e.runtimeType}
💬 错误信息: ${e.toString()}
        ''';
      });
      
      developer.log('💥 SMS Send Test ERROR: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testVerifySms() async {
    setState(() {
      _isLoading = true;
      _testResult = '正在验证短信验证码...';
    });

    try {
      final request = SmsVerifyRequest(
        mobile: _phoneController.text.trim(),
        code: _codeController.text.trim(),
        clientType: AuthConfig.clientType,
      );

      developer.log('🧪 Testing SMS Verify API...');
      final response = await _authService.verifySmsCode(request);
      
      setState(() {
        _testResult = '''
✅ 验证码验证成功！
🎫 访问令牌: ${response.data?.accessToken.substring(0, 20)}...
🔄 刷新令牌: ${response.data?.refreshToken.substring(0, 20)}...
⏰ 过期时间: ${response.data?.expiresIn}秒
👤 用户ID: ${response.data?.userInfo.userId}
📱 用户手机: ${response.data?.userInfo.mobile}
🏷️ 用户昵称: ${response.data?.userInfo.nickname ?? '无'}
        ''';
      });
      
      developer.log('✅ SMS Verify Test SUCCESS');
    } on ApiException catch (e) {
      setState(() {
        _testResult = '''
❌ 验证码验证失败！
🔢 错误码: ${e.code}
💬 错误信息: ${e.message}
📄 详细数据: ${e.data}
        ''';
      });
      
      developer.log('❌ SMS Verify Test FAILED: ${e.message}');
    } catch (e) {
      setState(() {
        _testResult = '''
💥 未知错误！
🐛 错误类型: ${e.runtimeType}
💬 错误信息: ${e.toString()}
        ''';
      });
      
      developer.log('💥 SMS Verify Test ERROR: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCurrentConfig() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔧 当前配置'),
        content: SingleChildScrollView(
          child: Text('''
🌍 环境: ${AuthConfig.currentEnvironment}
🔗 API地址: ${AuthConfig.baseUrl}
📱 客户端类型: ${AuthConfig.clientType}
🧪 使用Mock: ${AuthConfig.useMockService}
📊 启用日志: ${AuthConfig.enableApiLogging}
⏱️ 网络超时: ${AuthConfig.networkTimeout.inSeconds}秒
⏱️ 连接超时: ${AuthConfig.connectTimeout.inSeconds}秒

🔗 完整发送验证码URL:
${AuthConfig.getApiUrl(AuthConfig.sendSmsPath)}

🔗 完整验证验证码URL:
${AuthConfig.getApiUrl(AuthConfig.verifySmsPath)}
          '''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 API连接测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showCurrentConfig,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 当前配置信息
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📡 当前API地址',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AuthConfig.baseUrl,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🎭 服务模式: ${AuthConfig.useMockService ? "Mock服务" : "真实API"}',
                      style: TextStyle(
                        color: AuthConfig.useMockService ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 测试参数输入
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '📱 测试手机号',
                border: OutlineInputBorder(),
                hintText: '请输入手机号',
              ),
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: 12),
            
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: '🔢 测试验证码',
                border: OutlineInputBorder(),
                hintText: '请输入验证码',
              ),
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 20),
            
            // 测试按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testSendSms,
                    icon: const Icon(Icons.sms),
                    label: const Text('测试发送验证码'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testVerifySms,
                    icon: const Icon(Icons.verified),
                    label: const Text('测试验证登录'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 测试结果显示
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bug_report, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            '测试结果',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _testResult,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 提示信息
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💡 提示：测试前请确保后端服务正在运行并可访问。查看Flutter控制台可获取详细的网络请求日志。',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
