// 🎨 XiangYuPai 色彩系统
// 统一的品牌色彩规范

import 'package:flutter/material.dart';

// ============== 主品牌色 ==============
/// 🟣 主要品牌色彩系统
class XYPColors {
  // 私有构造函数，防止实例化
  const XYPColors._();

  // ============== 主色调 ==============
  /// 🟣 紫色系 - 主品牌色
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryLight = Color(0xFFA855F7);
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color primarySurface = Color(0xFFF3E8FF);
  
  /// 🔵 蓝色系 - 辅助色
  static const Color secondary = Color(0xFF3B82F6);
  static const Color secondaryLight = Color(0xFF60A5FA);
  static const Color secondaryDark = Color(0xFF2563EB);
  static const Color secondarySurface = Color(0xFFEFF6FF);

  // ============== 功能色彩 ==============
  /// ✅ 成功状态
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  static const Color successSurface = Color(0xFFECFDF5);

  /// ⚠️ 警告状态
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFFFBEB);

  /// ❌ 错误状态
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFFFEF2F2);

  /// ℹ️ 信息状态
  static const Color info = Color(0xFF06B6D4);
  static const Color infoLight = Color(0xFF22D3EE);
  static const Color infoDark = Color(0xFF0891B2);
  static const Color infoSurface = Color(0xFFECFEFF);

  // ============== 中性色彩 ==============
  /// ⚫ 黑色系
  static const Color black = Color(0xFF000000);
  static const Color black900 = Color(0xFF111827);
  static const Color black800 = Color(0xFF1F2937);
  static const Color black700 = Color(0xFF374151);
  static const Color black600 = Color(0xFF4B5563);

  /// ⚪ 灰色系
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey50 = Color(0xFFF9FAFB);

  /// ⚪ 白色系
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteSmoke = Color(0xFFFAFAFA);

  // ============== 特殊色彩 ==============
  /// 🌈 渐变色组合
  static const List<Color> primaryGradient = [primary, primaryLight];
  static const List<Color> secondaryGradient = [secondary, secondaryLight];
  static const List<Color> sunsetGradient = [Color(0xFFFF6B35), Color(0xFFF7931E)];
  static const List<Color> oceanGradient = [Color(0xFF667eea), Color(0xFF764ba2)];

  /// 🎮 游戏类型色彩
  static const Color gameRed = Color(0xFFE53E3E);
  static const Color gameBlue = Color(0xFF3182CE);
  static const Color gameGreen = Color(0xFF38A169);
  static const Color gameOrange = Color(0xFFDD6B20);
  static const Color gamePurple = Color(0xFF805AD5);

  /// 🏆 等级色彩
  static const Color rankBronze = Color(0xFFCD7F32);
  static const Color rankSilver = Color(0xFFC0C0C0);
  static const Color rankGold = Color(0xFFFFD700);
  static const Color rankPlatinum = Color(0xFFE5E4E2);
  static const Color rankDiamond = Color(0xFFB9F2FF);
  static const Color rankMaster = Color(0xFFFF6B6B);

  // ============== 背景色彩 ==============
  /// 🏠 页面背景
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF8FAFC);
  static const Color backgroundTertiary = Color(0xFFF1F5F9);

  /// 📱 卡片背景
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardElevated = Color(0xFFFBFBFB);

  /// 🌙 暗色模式
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);

  // ============== 文字色彩 ==============
  /// 📝 文字层次
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
  static const Color textInverse = Color(0xFFFFFFFF);

  /// 🔗 链接色彩
  static const Color linkDefault = Color(0xFF3B82F6);
  static const Color linkHover = Color(0xFF2563EB);
  static const Color linkVisited = Color(0xFF7C3AED);

  // ============== 边框色彩 ==============
  /// 📐 边框系统
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF9CA3AF);
  static const Color borderFocus = primary;

  // ============== 阴影色彩 ==============
  /// 🌫️ 阴影系统
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x1F000000);
  static const Color shadowColored = Color(0x1A8B5CF6);
}

// ============== 色彩扩展方法 ==============
extension XYPColorExtensions on Color {
  /// 获取颜色的十六进制字符串
  String get hexString {
    return '#${value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  /// 获取颜色的RGB值
  Map<String, int> get rgbValues {
    return {
      'r': red,
      'g': green,
      'b': blue,
    };
  }

  /// 获取颜色的HSL值
  HSLColor get hslColor {
    return HSLColor.fromColor(this);
  }

  /// 创建颜色的淡化版本
  Color withLightness(double lightness) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness(lightness).toColor();
  }

  /// 创建颜色的饱和度版本
  Color withSaturation(double saturation) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withSaturation(saturation).toColor();
  }
}

// ============== 主题色彩配置 ==============
/// 🎨 XiangYuPai ColorScheme
class XYPColorScheme {
  static ColorScheme get light => const ColorScheme.light(
    primary: XYPColors.primary,
    primaryContainer: XYPColors.primarySurface,
    secondary: XYPColors.secondary,
    secondaryContainer: XYPColors.secondarySurface,
    surface: XYPColors.backgroundPrimary,
    background: XYPColors.backgroundSecondary,
    error: XYPColors.error,
    onPrimary: XYPColors.white,
    onSecondary: XYPColors.white,
    onSurface: XYPColors.textPrimary,
    onBackground: XYPColors.textPrimary,
    onError: XYPColors.white,
    brightness: Brightness.light,
  );

  static ColorScheme get dark => const ColorScheme.dark(
    primary: XYPColors.primaryLight,
    primaryContainer: XYPColors.primaryDark,
    secondary: XYPColors.secondaryLight,
    secondaryContainer: XYPColors.secondaryDark,
    surface: XYPColors.darkSurface,
    background: XYPColors.darkBackground,
    error: XYPColors.errorLight,
    onPrimary: XYPColors.black,
    onSecondary: XYPColors.black,
    onSurface: XYPColors.white,
    onBackground: XYPColors.white,
    onError: XYPColors.black,
    brightness: Brightness.dark,
  );
}

// ============== 使用示例 ==============
/// 
/// 色彩系统使用示例：
/// 
/// ```dart
/// // 使用主品牌色
/// Container(
///   color: XYPColors.primary,
///   child: Text(
///     'Hello XiangYuPai',
///     style: TextStyle(color: XYPColors.textInverse),
///   ),
/// )
/// 
/// // 使用渐变色
/// Container(
///   decoration: BoxDecoration(
///     gradient: LinearGradient(
///       colors: XYPColors.primaryGradient,
///     ),
///   ),
/// )
/// 
/// // 使用功能色彩
/// Icon(
///   Icons.check,
///   color: XYPColors.success,
/// )
/// ```
