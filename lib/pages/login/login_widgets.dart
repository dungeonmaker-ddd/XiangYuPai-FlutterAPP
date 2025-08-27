import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/country_model.dart';
import '../../widgets/country_selector.dart';

/// 📱 登录相关输入组件
/// 
/// 包含以下组件：
/// - PhoneInputWidget: 手机号输入组件，支持国家/地区选择
/// - PasswordInputWidget: 密码输入组件，支持显示/隐藏切换
/// 
/// 更新日期: 2024
/// 
/// 使用示例:
/// ```dart
/// PhoneInputWidget(
///   controller: _phoneController,
///   selectedCountry: _selectedCountry,
///   onCountryChanged: (country) {
///     setState(() => _selectedCountry = country);
///   },
/// )
/// ```

/// 📱 手机号输入组件
/// 
/// 功能特点：
/// • 🌍 支持多国家/地区区号选择
/// • 🔍 智能搜索国家/地区
/// • 📱 自动适配不同区号的手机号长度
/// • 🎨 现代化UI设计
/// • ⚡ 快速选择常用国家
class PhoneInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final CountryModel? selectedCountry;
  final ValueChanged<CountryModel> onCountryChanged;
  final String? hintText;
  
  const PhoneInputWidget({
    super.key,
    required this.controller,
    this.selectedCountry,
    required this.onCountryChanged,
    this.hintText,
  });

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  /// 获取当前区号对应的手机号长度
  int get _requiredPhoneLength {
    if (widget.selectedCountry == null) return 11;
    return CountryData.getPhoneLengthByCode(widget.selectedCountry!.code);
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
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
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔒 密码输入组件
/// 包含密码输入和显示/隐藏切换功能
class PasswordInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final VoidCallback? onChanged;
  
  const PasswordInputWidget({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
  });

  @override
  State<PasswordInputWidget> createState() => _PasswordInputWidgetState();
}

class _PasswordInputWidgetState extends State<PasswordInputWidget> {
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.onChanged != null) {
      widget.controller.addListener(widget.onChanged!);
    }
  }

  @override
  void dispose() {
    if (widget.onChanged != null) {
      widget.controller.removeListener(widget.onChanged!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: widget.hintText ?? '请输入6-20位密码',
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
        ),
        border: InputBorder.none,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible 
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
    );
  }
}
