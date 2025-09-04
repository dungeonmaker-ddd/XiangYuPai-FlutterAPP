/// 📚 API迁移示例
/// 展示如何从现有的auth_service迁移到新的通用API系统

import 'package:flutter/material.dart';
import 'index.dart';

/// 🔄 迁移前后对比示例
class ApiMigrationExample {
  
  // ============== 迁移前：使用原有的AuthService ==============
  
  /// ❌ 旧版本：复杂的服务调用
  static Future<void> oldWayLogin(String mobile, String code) async {
    /*
    // 原有的复杂调用方式
    final authService = AuthServiceFactory.getInstance();
    
    try {
      final request = SmsVerifyRequest(mobile: mobile, code: code);
      final response = await authService.verifySmsCode(request);
      
      if (response.isSuccess && response.data != null) {
        // 手动保存认证信息
        final loginData = response.data!;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', loginData.accessToken);
        await prefs.setString('refresh_token', loginData.refreshToken);
        // ... 更多手动处理
      } else {
        throw Exception(response.message);
      }
    } on ApiException catch (e) {
      // 手动错误处理
      throw Exception('登录失败: ${e.message}');
    }
    */
  }
  
  // ============== 迁移后：使用新的ApiManager ==============
  
  /// ✅ 新版本：简洁的API调用
  static Future<void> newWayLogin(String mobile, String code) async {
    try {
      // 一行代码完成登录，自动处理认证信息保存
      final response = await ApiManager.instance.verifySmsCode(
        mobile: mobile,
        code: code,
      );
      
      if (response.isSuccess) {
        print('登录成功: ${response.data?.userInfo?.nickname}');
        // 认证信息已自动保存，无需手动处理
      }
    } on ApiException catch (e) {
      // 统一的错误处理
      print('登录失败: ${e.message}');
      rethrow;
    }
  }
  
  /// 📱 完整的登录页面示例
  static Widget buildLoginPage() {
    return Scaffold(
      appBar: AppBar(title: const Text('新API系统登录')),
      body: const _LoginForm(),
    );
  }
}

/// 📱 登录表单组件
class _LoginForm extends StatefulWidget {
  const _LoginForm();
  
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _mobileController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 手机号输入
          TextField(
            controller: _mobileController,
            decoration: const InputDecoration(
              labelText: '手机号',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          
          // 验证码输入
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: '验证码',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendCode,
                child: const Text('发送验证码'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 错误信息显示
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          const SizedBox(height: 16),
          
          // 登录按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('登录'),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // API功能展示
          const _ApiFeatureDemo(),
        ],
      ),
    );
  }
  
  /// 发送验证码
  Future<void> _sendCode() async {
    if (_mobileController.text.trim().isEmpty) {
      _showError('请输入手机号');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 使用新的API系统发送验证码
      final response = await ApiManager.instance.sendSmsCode(
        mobile: _mobileController.text.trim(),
      );
      
      if (response.isSuccess) {
        _showSuccess('验证码发送成功');
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  /// 登录
  Future<void> _login() async {
    if (_mobileController.text.trim().isEmpty) {
      _showError('请输入手机号');
      return;
    }
    
    if (_codeController.text.trim().isEmpty) {
      _showError('请输入验证码');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // 使用新的API系统登录
      final response = await ApiManager.instance.verifySmsCode(
        mobile: _mobileController.text.trim(),
        code: _codeController.text.trim(),
      );
      
      if (response.isSuccess) {
        _showSuccess('登录成功！');
        // 这里可以导航到主页
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _showError(String message) {
    setState(() => _errorMessage = message);
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  @override
  void dispose() {
    _mobileController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}

/// 🎯 API功能演示组件
class _ApiFeatureDemo extends StatelessWidget {
  const _ApiFeatureDemo();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🚀 新API系统功能展示',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // 功能按钮列表
        _buildFeatureButton(
          '📱 获取用户信息',
          '演示如何获取当前用户的详细信息',
          () => _demoGetUserProfile(context),
        ),
        
        _buildFeatureButton(
          '🏷️ 获取分类列表',
          '演示如何获取首页分类数据（带缓存）',
          () => _demoGetCategories(context),
        ),
        
        _buildFeatureButton(
          '🎯 获取推荐内容',
          '演示如何获取分页推荐数据',
          () => _demoGetRecommendations(context),
        ),
        
        _buildFeatureButton(
          '🔍 搜索功能',
          '演示如何使用搜索API',
          () => _demoSearch(context),
        ),
        
        _buildFeatureButton(
          '📤 文件上传',
          '演示如何上传文件（需要文件选择）',
          () => _demoUpload(context),
        ),
      ],
    );
  }
  
  Widget _buildFeatureButton(String title, String subtitle, VoidCallback onTap) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
  
  /// 演示获取用户信息
  static Future<void> _demoGetUserProfile(BuildContext context) async {
    try {
      final response = await ApiManager.instance.getUserProfile();
      if (response.isSuccess && response.data != null) {
        _showDialog(context, '用户信息', '昵称: ${response.data!.nickname ?? "未设置"}');
      }
    } on ApiException catch (e) {
      _showDialog(context, '错误', e.message);
    }
  }
  
  /// 演示获取分类列表
  static Future<void> _demoGetCategories(BuildContext context) async {
    try {
      final response = await ApiManager.instance.getCategories(enableCache: true);
      if (response.isSuccess && response.data != null) {
        final count = response.data!.length;
        _showDialog(context, '分类列表', '获取到 $count 个分类');
      }
    } on ApiException catch (e) {
      _showDialog(context, '错误', e.message);
    }
  }
  
  /// 演示获取推荐内容
  static Future<void> _demoGetRecommendations(BuildContext context) async {
    try {
      final response = await ApiManager.instance.getRecommendations(
        page: 1,
        size: 10,
      );
      if (response.isSuccess && response.data != null) {
        final pageData = response.data!;
        _showDialog(context, '推荐内容', 
            '第${pageData.page}页，共${pageData.total}条数据');
      }
    } on ApiException catch (e) {
      _showDialog(context, '错误', e.message);
    }
  }
  
  /// 演示搜索功能
  static Future<void> _demoSearch(BuildContext context) async {
    try {
      final response = await ApiManager.instance.search(
        keyword: '测试',
        page: 1,
        size: 10,
      );
      if (response.isSuccess && response.data != null) {
        final pageData = response.data!;
        _showDialog(context, '搜索结果', 
            '找到${pageData.total}条相关结果');
      }
    } on ApiException catch (e) {
      _showDialog(context, '错误', e.message);
    }
  }
  
  /// 演示文件上传
  static Future<void> _demoUpload(BuildContext context) async {
    _showDialog(context, '文件上传', '请先选择文件，然后调用上传API');
  }
  
  static void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
