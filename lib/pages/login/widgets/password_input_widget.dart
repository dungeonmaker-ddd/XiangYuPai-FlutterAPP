import 'package:flutter/material.dart';

/// 🔒 密码输入组件
/// 包含密码输入和显示/隐藏切换功能
class PasswordInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final VoidCallback? onChanged;
  final int? maxLength;
  
  const PasswordInputWidget({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.maxLength,
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
      maxLength: widget.maxLength,
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
        counterText: '', // 隐藏字符计数器
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
