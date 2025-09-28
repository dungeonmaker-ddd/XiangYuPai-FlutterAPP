import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/country_model.dart';
import 'country_selector.dart';

/// 📱 手机号输入组件
/// 
/// 功能特点：
/// • 🌍 支持多国家/地区区号选择
/// • 🔍 智能搜索国家/地区
/// • 📱 自动适配不同区号的手机号长度
/// • 🎨 现代化UI设计
/// • ⚡ 快速选择常用国家
/// • 🎯 增强验证逻辑 (支持按国家定制)
/// • 🔄 内置状态变化监听
/// • ⚠️ 可选的验证视觉反馈
class PhoneInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final CountryModel? selectedCountry;
  final ValueChanged<CountryModel> onCountryChanged;
  final String? hintText;
  final VoidCallback? onChanged; // 状态变化回调
  final bool enableValidation; // 是否启用验证
  final bool showValidationHint; // 是否显示验证提示
  
  const PhoneInputWidget({
    super.key,
    required this.controller,
    this.selectedCountry,
    required this.onCountryChanged,
    this.hintText,
    this.onChanged,
    this.enableValidation = true,
    this.showValidationHint = false,
  });

  /// 静态方法：验证手机号是否有效
  /// 用于外部调用验证逻辑
  static bool isPhoneValid({
    required String phone,
    required CountryModel? selectedCountry,
  }) {
    if (phone.trim().isEmpty) return false;
    
    final country = selectedCountry ?? CountryData.findByCode('+86')!;
    final requiredLength = CountryData.getPhoneLengthByCode(country.code);
    
    // 针对中国大陆的特殊验证规则
    if (country.code == '+86') {
      return phone.length == requiredLength && RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
    }
    
    // 其他国家只验证长度和数字
    return phone.length == requiredLength && RegExp(r'^\d+$').hasMatch(phone);
  }

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  /// 获取当前区号对应的手机号长度
  int get _requiredPhoneLength {
    if (widget.selectedCountry == null) return 11;
    return CountryData.getPhoneLengthByCode(widget.selectedCountry!.code);
  }

  /// 获取当前选中的国家，默认为中国大陆
  CountryModel get _currentCountry {
    return widget.selectedCountry ?? CountryData.findByCode('+86')!;
  }

  /// 增强的手机号验证 - 支持按国家定制验证规则
  bool get isPhoneValid {
    if (!widget.enableValidation) return true;
    
    final phone = widget.controller.text.trim();
    if (phone.isEmpty) return false;
    
    final requiredLength = _requiredPhoneLength;
    
    // 针对中国大陆的特殊验证规则
    if (_currentCountry.code == '+86') {
      return phone.length == requiredLength && RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
    }
    
    // 其他国家只验证长度和数字
    return phone.length == requiredLength && RegExp(r'^\d+$').hasMatch(phone);
  }

  @override
  void initState() {
    super.initState();
    // 自动添加状态变化监听器
    if (widget.onChanged != null) {
      widget.controller.addListener(widget.onChanged!);
    }
  }

  @override
  void dispose() {
    // 清理监听器
    if (widget.onChanged != null) {
      widget.controller.removeListener(widget.onChanged!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              // 区号选择按钮
              CountrySelectorButton(
                selectedCountry: widget.selectedCountry,
                onCountryChanged: (country) {
                  widget.onCountryChanged(country);
                  // 清空手机号以重新输入
                  widget.controller.clear();
                },
                placeholder: '+86',
                useBottomSheet: true, // 使用底部抽屉模式
              ),
              
              // 手机号输入框 - 占据剩余空间
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // 只允许数字
                    LengthLimitingTextInputFormatter(_requiredPhoneLength), // 限制长度
                  ],
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? '请输入${_requiredPhoneLength}位手机号',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  onChanged: (value) {
                    // 触发内部状态更新以刷新验证状态
                    if (widget.enableValidation) {
                      setState(() {});
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        
        // 验证提示信息（可选）
        if (widget.showValidationHint && widget.enableValidation && widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16),
            child: Text(
              isPhoneValid ? '✅ 手机号格式正确' : '❌ 请输入正确的手机号格式',
              style: TextStyle(
                fontSize: 12,
                color: isPhoneValid ? Colors.green[600] : Colors.red[600],
              ),
            ),
          ),
      ],
    );
  }
}
