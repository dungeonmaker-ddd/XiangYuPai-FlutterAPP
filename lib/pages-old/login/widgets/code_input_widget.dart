import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🔢 验证码输入组件
/// 提供6位数字验证码输入功能，支持自动完成和粘贴
class CodeInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onCompleted;
  final VoidCallback? onChanged;
  
  const CodeInputWidget({
    super.key,
    required this.controller,
    this.onCompleted,
    this.onChanged,
  });

  @override
  State<CodeInputWidget> createState() => _CodeInputWidgetState();
}

class _CodeInputWidgetState extends State<CodeInputWidget> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  
  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(6, (index) => FocusNode());
    _controllers = List.generate(6, (index) => TextEditingController());
    
    // 监听主控制器变化
    widget.controller.addListener(_updateFromMainController);
  }
  
  @override
  void dispose() {
    widget.controller.removeListener(_updateFromMainController);
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  void _updateFromMainController() {
    final text = widget.controller.text;
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = i < text.length ? text[i] : '';
    }
    widget.onChanged?.call();
  }
  
  void _updateMainController() {
    final text = _controllers.map((c) => c.text).join();
    widget.controller.text = text;
    
    if (text.length == 6) {
      widget.onCompleted?.call();
    }
    widget.onChanged?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 6位验证码输入框
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45,
              height: 55,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: _controllers[index].text.isNotEmpty
                          ? Colors.purple
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    // 自动跳转到下一个输入框
                    _focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    // 删除时跳转到上一个输入框
                    _focusNodes[index - 1].requestFocus();
                  }
                  _updateMainController();
                },
                onTap: () {
                  // 点击时选中内容
                  _controllers[index].selection = TextSelection.fromPosition(
                    TextPosition(offset: _controllers[index].text.length),
                  );
                },
              ),
            );
          }),
        ),
        
        // 隐藏的完整输入框，用于粘贴功能
        Opacity(
          opacity: 0,
          child: TextField(
            controller: widget.controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            autofocus: true,
          ),
        ),
      ],
    );
  }
}
