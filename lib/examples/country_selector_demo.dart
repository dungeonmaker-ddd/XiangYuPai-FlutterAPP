import 'package:flutter/material.dart';
import '../models/country_model.dart';
import '../pages/login/login_widgets.dart';
import '../widgets/country_selector.dart';
import '../widgets/country_bottom_sheet.dart';

/// 🌍 区号选择组件演示页面
/// 展示如何使用新的国家选择器组件
class CountrySelectorDemo extends StatefulWidget {
  const CountrySelectorDemo({super.key});

  @override
  State<CountrySelectorDemo> createState() => _CountrySelectorDemoState();
}

class _CountrySelectorDemoState extends State<CountrySelectorDemo> {
  final _phoneController = TextEditingController();
  CountryModel? _selectedCountry;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '区号选择器演示',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📱 手机号输入',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                '点击区号部分可以打开国家/地区选择页面，支持搜索和按字母分组浏览。',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 新版手机号输入组件
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '增强版组件',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      PhoneInputWidget(
                        controller: _phoneController,
                        selectedCountry: _selectedCountry,
                        onCountryChanged: (country) {
                          setState(() {
                            _selectedCountry = country;
                            // 清空手机号以重新输入
                            _phoneController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 底部抽屉模式演示
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '底部抽屉模式',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await CountryBottomSheet.show(
                            context,
                            selectedCountry: _selectedCountry,
                          );
                          if (result != null) {
                            setState(() {
                              _selectedCountry = result;
                              _phoneController.clear();
                            });
                          }
                        },
                        icon: const Icon(Icons.public),
                        label: const Text('打开底部抽屉选择器'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 显示当前选中的信息
              if (_selectedCountry != null) ...[
                Card(
                  color: Colors.purple.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🌍 当前选择',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            if (_selectedCountry!.flag.isNotEmpty) ...[
                              Text(
                                _selectedCountry!.flag,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                            ],
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedCountry!.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${_selectedCountry!.englishName} (${_selectedCountry!.code})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '手机号长度: ${CountryData.getPhoneLengthByCode(_selectedCountry!.code)}位',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // 功能特点说明
              _buildFeatureList(),
              
              const Spacer(),
              
              // 测试按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _phoneController.text.length >= 8 ? _testValidation : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '测试验证',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✨ 功能特点',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            
            const SizedBox(height: 12),
            
            ...[
              '🔍 支持搜索国家/地区',
              '🌍 显示国旗和英文名称',
              '📋 按字母分组显示',
              '📱 自动适配手机号长度',
              '⚡ 快速选择常用国家',
              '🎨 底部抽屉模式 (占4/5屏幕)',
              '✨ 平滑动画效果',
              '📲 触觉反馈体验',
            ].map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                feature,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  void _testValidation() {
    final phone = _phoneController.text.trim();
    final country = _selectedCountry ?? CountryData.findByCode('+86')!;
    final expectedLength = CountryData.getPhoneLengthByCode(country.code);
    
    String message;
    Color backgroundColor;
    
    if (phone.length == expectedLength) {
      message = '✅ 手机号格式正确！\n${country.name} ${country.code} $phone';
      backgroundColor = Colors.green;
    } else {
      message = '❌ 手机号长度不正确\n应为${expectedLength}位，当前${phone.length}位';
      backgroundColor = Colors.red;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
