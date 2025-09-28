// 🎯 组局报名模型 - 基于报名流程架构设计的数据模型
// 支持私信沟通和直接报名支付两种参与方式

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';

// Dart核心库
import 'dart:developer' as developer;

// 项目内部文件
import 'team_models.dart'; // 基础团队模型

// ============== 2. CONSTANTS ==============
/// 🎨 报名流程常量
class JoinFlowConstants {
  const JoinFlowConstants._();
  
  // 报名状态超时时间
  static const Duration waitingTimeout = Duration(hours: 24);
  static const Duration paymentTimeout = Duration(minutes: 15);
  
  // 支付相关常量
  static const int platformServiceFeeRate = 5; // 平台服务费率 5%
  static const int minPaymentAmount = 10; // 最小支付金额 10金币
  static const int maxPaymentAmount = 10000; // 最大支付金额 10000金币
  
  // 通知设置
  static const List<String> notificationMethods = ['推送通知', '短信', '邮件'];
  static const List<Duration> reminderIntervals = [
    Duration(hours: 1),
    Duration(hours: 6),
    Duration(hours: 24),
  ];
}

// ============== 3. MODELS ==============
/// 📋 报名状态枚举
enum JoinRequestStatus {
  draft('草稿', '正在填写'),
  submitted('已提交', '等待处理'),
  waiting('等待选择', '等待发起者确认'),
  approved('报名成功', '已被选中'),
  rejected('报名失败', '未被选中'),
  cancelled('已取消', '用户取消'),
  expired('已过期', '超时失效'),
  paid('已支付', '支付完成'),
  refunded('已退款', '款项已退还');

  const JoinRequestStatus(this.displayName, this.description);
  final String displayName;
  final String description;

  /// 是否为最终状态
  bool get isFinalStatus => [approved, rejected, cancelled, expired, refunded].contains(this);

  /// 是否为成功状态
  bool get isSuccessStatus => this == approved;

  /// 是否为失败状态
  bool get isFailureStatus => [rejected, cancelled, expired].contains(this);

  /// 状态颜色
  Color get statusColor {
    switch (this) {
      case draft:
      case submitted:
        return Colors.grey;
      case waiting:
        return Colors.orange;
      case approved:
      case paid:
        return Colors.green;
      case rejected:
      case cancelled:
      case expired:
        return Colors.red;
      case refunded:
        return Colors.blue;
    }
  }

  /// 状态图标
  IconData get statusIcon {
    switch (this) {
      case draft:
        return Icons.edit_outlined;
      case submitted:
        return Icons.send_outlined;
      case waiting:
        return Icons.hourglass_empty;
      case approved:
        return Icons.check_circle;
      case rejected:
        return Icons.cancel;
      case cancelled:
        return Icons.close;
      case expired:
        return Icons.timer_off;
      case paid:
        return Icons.payment;
      case refunded:
        return Icons.money_off;
    }
  }
}

/// 💳 支付方式枚举
enum PaymentMethod {
  coins('金币支付', Icons.monetization_on, '使用平台金币支付'),
  wechat('微信支付', Icons.wechat, '微信快捷支付'),
  alipay('支付宝', Icons.payment, '支付宝快捷支付'),
  bankCard('银行卡', Icons.credit_card, '银行卡支付');

  const PaymentMethod(this.displayName, this.icon, this.description);
  final String displayName;
  final IconData icon;
  final String description;
}

/// 📱 通知方式枚举
enum NotificationMethod {
  push('推送通知', Icons.notifications, '应用内推送'),
  sms('短信通知', Icons.sms, '手机短信'),
  email('邮件通知', Icons.email, '电子邮件');

  const NotificationMethod(this.displayName, this.icon, this.description);
  final String displayName;
  final IconData icon;
  final String description;
}

/// 🚫 失败原因枚举
enum FailureReason {
  timeout('报名超时', '报名截止时间已过'),
  capacityFull('人数已满', '活动人数已达上限'),
  conditionsNotMet('条件不符', '不符合参与条件'),
  insufficientBalance('余额不足', '账户余额不足'),
  rejectedByHost('发起者拒绝', '发起者选择了其他人'),
  accountIssue('账户异常', '账户状态异常'),
  systemError('系统错误', '系统处理错误'),
  paymentFailed('支付失败', '支付过程中发生错误'),
  cancelled('用户取消', '用户主动取消报名');

  const FailureReason(this.displayName, this.description);
  final String displayName;
  final String description;

  /// 获取解决建议
  String get suggestion {
    switch (this) {
      case timeout:
        return '请关注其他活动或设置类似活动提醒';
      case capacityFull:
        return '可以加入候补名单或寻找类似活动';
      case conditionsNotMet:
        return '请完善个人资料或提升账户等级';
      case insufficientBalance:
        return '请充值后重新尝试报名';
      case rejectedByHost:
        return '可以私信询问原因或寻找其他活动';
      case accountIssue:
        return '请联系客服处理账户问题';
      case systemError:
        return '请重试或联系客服';
      case paymentFailed:
        return '请检查支付方式或重新支付';
      case cancelled:
        return '您可以重新报名参与';
    }
  }

  /// 是否可以重试
  bool get canRetry {
    return [insufficientBalance, paymentFailed, systemError].contains(this);
  }

  /// 获取状态图标
  IconData get statusIcon {
    switch (this) {
      case timeout:
        return Icons.access_time;
      case capacityFull:
        return Icons.people;
      case conditionsNotMet:
        return Icons.warning;
      case insufficientBalance:
        return Icons.account_balance_wallet;
      case rejectedByHost:
        return Icons.person_off;
      case accountIssue:
        return Icons.account_circle;
      case systemError:
        return Icons.error;
      case paymentFailed:
        return Icons.payment;
      case cancelled:
        return Icons.cancel;
    }
  }
}

/// 📋 报名请求模型
class JoinRequest {
  final String id;
  final String activityId;
  final String userId;
  final String userNickname;
  final String userAvatar;
  final JoinRequestStatus status;
  final PaymentMethod? paymentMethod;
  final int? paymentAmount;
  final String? paymentTransactionId;
  final FailureReason? failureReason;
  final String? userMessage;
  final String? hostReply;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? paidAt;
  final DateTime? confirmedAt;
  final DateTime? expiredAt;
  final Map<String, dynamic> metadata;

  const JoinRequest({
    required this.id,
    required this.activityId,
    required this.userId,
    required this.userNickname,
    required this.userAvatar,
    required this.status,
    this.paymentMethod,
    this.paymentAmount,
    this.paymentTransactionId,
    this.failureReason,
    this.userMessage,
    this.hostReply,
    required this.createdAt,
    this.updatedAt,
    this.paidAt,
    this.confirmedAt,
    this.expiredAt,
    this.metadata = const {},
  });

  JoinRequest copyWith({
    String? id,
    String? activityId,
    String? userId,
    String? userNickname,
    String? userAvatar,
    JoinRequestStatus? status,
    PaymentMethod? paymentMethod,
    int? paymentAmount,
    String? paymentTransactionId,
    FailureReason? failureReason,
    String? userMessage,
    String? hostReply,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
    DateTime? confirmedAt,
    DateTime? expiredAt,
    Map<String, dynamic>? metadata,
  }) {
    return JoinRequest(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      userId: userId ?? this.userId,
      userNickname: userNickname ?? this.userNickname,
      userAvatar: userAvatar ?? this.userAvatar,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      failureReason: failureReason ?? this.failureReason,
      userMessage: userMessage ?? this.userMessage,
      hostReply: hostReply ?? this.hostReply,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidAt: paidAt ?? this.paidAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      expiredAt: expiredAt ?? this.expiredAt,
      metadata: metadata ?? this.metadata,
    );
  }

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    return JoinRequest(
      id: json['id'] as String,
      activityId: json['activityId'] as String,
      userId: json['userId'] as String,
      userNickname: json['userNickname'] as String,
      userAvatar: json['userAvatar'] as String,
      status: JoinRequestStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => JoinRequestStatus.draft,
      ),
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (m) => m.name == json['paymentMethod'],
              orElse: () => PaymentMethod.coins,
            )
          : null,
      paymentAmount: json['paymentAmount'] as int?,
      paymentTransactionId: json['paymentTransactionId'] as String?,
      failureReason: json['failureReason'] != null
          ? FailureReason.values.firstWhere(
              (r) => r.name == json['failureReason'],
              orElse: () => FailureReason.systemError,
            )
          : null,
      userMessage: json['userMessage'] as String?,
      hostReply: json['hostReply'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      expiredAt: json['expiredAt'] != null
          ? DateTime.parse(json['expiredAt'] as String)
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityId': activityId,
      'userId': userId,
      'userNickname': userNickname,
      'userAvatar': userAvatar,
      'status': status.name,
      'paymentMethod': paymentMethod?.name,
      'paymentAmount': paymentAmount,
      'paymentTransactionId': paymentTransactionId,
      'failureReason': failureReason?.name,
      'userMessage': userMessage,
      'hostReply': hostReply,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'expiredAt': expiredAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// 是否已过期
  bool get isExpired {
    if (expiredAt == null) return false;
    return DateTime.now().isAfter(expiredAt!);
  }

  /// 剩余时间
  Duration? get remainingTime {
    if (expiredAt == null) return null;
    final remaining = expiredAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// 等待时长
  Duration get waitingDuration {
    final referenceTime = updatedAt ?? createdAt;
    return DateTime.now().difference(referenceTime);
  }
}

/// 💳 支付信息模型
class PaymentInfo {
  final String activityId;
  final String activityTitle;
  final String hostNickname;
  final String hostAvatar;
  final int baseAmount;
  final int serviceFee;
  final int discountAmount;
  final int totalAmount;
  final PaymentMethod paymentMethod;
  final int userBalance;
  final bool hasEnoughBalance;
  final List<String> termsAndConditions;

  const PaymentInfo({
    required this.activityId,
    required this.activityTitle,
    required this.hostNickname,
    required this.hostAvatar,
    required this.baseAmount,
    required this.serviceFee,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.userBalance,
    required this.hasEnoughBalance,
    required this.termsAndConditions,
  });

  /// 计算支付信息
  factory PaymentInfo.calculate({
    required String activityId,
    required String activityTitle,
    required String hostNickname,
    required String hostAvatar,
    required int baseAmount,
    required PaymentMethod paymentMethod,
    required int userBalance,
    int discountAmount = 0,
  }) {
    final serviceFee = (baseAmount * JoinFlowConstants.platformServiceFeeRate / 100).round();
    final totalAmount = baseAmount + serviceFee - discountAmount;
    final hasEnoughBalance = paymentMethod == PaymentMethod.coins 
        ? userBalance >= totalAmount 
        : true;

    return PaymentInfo(
      activityId: activityId,
      activityTitle: activityTitle,
      hostNickname: hostNickname,
      hostAvatar: hostAvatar,
      baseAmount: baseAmount,
      serviceFee: serviceFee,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      userBalance: userBalance,
      hasEnoughBalance: hasEnoughBalance,
      termsAndConditions: [
        '我同意支付以下费用，该金额含服务费',
        '支付完成后将等待发起者确认',
        '如报名失败，费用将自动退还',
        '平台提供支付安全保障',
      ],
    );
  }

  /// 费用明细
  List<PaymentBreakdown> get breakdown {
    return [
      PaymentBreakdown('报名费用', baseAmount),
      PaymentBreakdown('平台服务费', serviceFee),
      if (discountAmount > 0) PaymentBreakdown('优惠减免', -discountAmount),
      PaymentBreakdown('总计金额', totalAmount, isTotal: true),
    ];
  }
}

/// 💰 费用明细项
class PaymentBreakdown {
  final String name;
  final int amount;
  final bool isTotal;

  const PaymentBreakdown(this.name, this.amount, {this.isTotal = false});

  String get displayAmount {
    final prefix = amount >= 0 ? '' : '-';
    return '$prefix${amount.abs()}金币';
  }
}

/// 🔔 通知配置模型
class NotificationConfig {
  final bool enablePush;
  final bool enableSms;
  final bool enableEmail;
  final List<Duration> reminderIntervals;
  final bool enableActivityReminder;
  final bool enableStatusChange;

  const NotificationConfig({
    this.enablePush = true,
    this.enableSms = false,
    this.enableEmail = false,
    this.reminderIntervals = const [Duration(hours: 1)],
    this.enableActivityReminder = true,
    this.enableStatusChange = true,
  });

  NotificationConfig copyWith({
    bool? enablePush,
    bool? enableSms,
    bool? enableEmail,
    List<Duration>? reminderIntervals,
    bool? enableActivityReminder,
    bool? enableStatusChange,
  }) {
    return NotificationConfig(
      enablePush: enablePush ?? this.enablePush,
      enableSms: enableSms ?? this.enableSms,
      enableEmail: enableEmail ?? this.enableEmail,
      reminderIntervals: reminderIntervals ?? this.reminderIntervals,
      enableActivityReminder: enableActivityReminder ?? this.enableActivityReminder,
      enableStatusChange: enableStatusChange ?? this.enableStatusChange,
    );
  }

  List<NotificationMethod> get enabledMethods {
    final methods = <NotificationMethod>[];
    if (enablePush) methods.add(NotificationMethod.push);
    if (enableSms) methods.add(NotificationMethod.sms);
    if (enableEmail) methods.add(NotificationMethod.email);
    return methods;
  }
}

/// 📊 参与者统计信息
class ParticipantStats {
  final int totalApplicants;
  final int waitingCount;
  final int approvedCount;
  final int rejectedCount;
  final double maleRatio;
  final double femaleRatio;
  final Map<String, int> ageGroups;
  final List<JoinRequest> recentJoins;

  const ParticipantStats({
    required this.totalApplicants,
    required this.waitingCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.maleRatio,
    required this.femaleRatio,
    required this.ageGroups,
    required this.recentJoins,
  });

  /// 状态分布
  Map<JoinRequestStatus, int> get statusDistribution {
    return {
      JoinRequestStatus.waiting: waitingCount,
      JoinRequestStatus.approved: approvedCount,
      JoinRequestStatus.rejected: rejectedCount,
    };
  }

  /// 是否有等待中的申请
  bool get hasWaitingApplicants => waitingCount > 0;

  /// 申请热度描述
  String get popularityDescription {
    if (totalApplicants >= 50) return '非常热门';
    if (totalApplicants >= 20) return '热门活动';
    if (totalApplicants >= 10) return '受欢迎';
    if (totalApplicants >= 5) return '有人关注';
    return '刚刚发布';
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - JoinRequest: 报名请求模型（public class）
/// - PaymentInfo: 支付信息模型（public class）
/// - PaymentBreakdown: 费用明细项（public class）
/// - NotificationConfig: 通知配置模型（public class）
/// - ParticipantStats: 参与者统计信息（public class）
/// - JoinRequestStatus: 报名状态枚举（public enum）
/// - PaymentMethod: 支付方式枚举（public enum）
/// - NotificationMethod: 通知方式枚举（public enum）
/// - FailureReason: 失败原因枚举（public enum）
/// - JoinFlowConstants: 报名流程常量（public class）
///
/// 使用方式：
/// ```dart
/// import 'join_models.dart';
/// 
/// // 创建报名请求
/// final joinRequest = JoinRequest(...);
/// 
/// // 计算支付信息
/// final paymentInfo = PaymentInfo.calculate(...);
/// ```
