// 🎯 组局报名服务 - 基于报名流程架构设计的服务层
// 支持报名条件检查、支付处理、状态管理的完整服务

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';

// Dart核心库
import 'dart:async';
import 'dart:developer' as developer;

// 项目内部文件
import '../models/team_models.dart';    // 基础团队模型
import '../models/join_models.dart';    // 报名模型
import '../utils/constants.dart';       // 常量定义

// ============== 2. CONSTANTS ==============
/// 🎨 报名服务常量
class JoinServiceConstants {
  const JoinServiceConstants._();
  
  // API端点
  static const String joinEndpoint = '/api/teams/join';
  static const String paymentEndpoint = '/api/payment/process';
  static const String statusEndpoint = '/api/teams/join/status';
  
  // 模拟数据配置
  static const bool useSimulatedData = true;
  static const Duration simulatedDelay = Duration(milliseconds: 1500);
  
  // 业务规则
  static const int maxConcurrentJoins = 5; // 最大同时报名数量
  static const Duration joinCooldown = Duration(minutes: 5); // 报名冷却时间
}

// ============== 3. SERVICES ==============
/// 📋 报名条件检查结果
class JoinEligibilityResult {
  final bool isEligible;
  final List<String> failedConditions;
  final FailureReason? failureReason;
  final String? suggestion;

  const JoinEligibilityResult({
    required this.isEligible,
    required this.failedConditions,
    this.failureReason,
    this.suggestion,
  });

  factory JoinEligibilityResult.success() {
    return const JoinEligibilityResult(
      isEligible: true,
      failedConditions: [],
    );
  }

  factory JoinEligibilityResult.failure({
    required List<String> conditions,
    required FailureReason reason,
    String? suggestion,
  }) {
    return JoinEligibilityResult(
      isEligible: false,
      failedConditions: conditions,
      failureReason: reason,
      suggestion: suggestion ?? reason.suggestion,
    );
  }
}

/// 💳 支付处理结果
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  final FailureReason? failureReason;

  const PaymentResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
    this.failureReason,
  });

  factory PaymentResult.success(String transactionId) {
    return PaymentResult(
      success: true,
      transactionId: transactionId,
    );
  }

  factory PaymentResult.failure({
    required String errorMessage,
    required FailureReason reason,
  }) {
    return PaymentResult(
      success: false,
      errorMessage: errorMessage,
      failureReason: reason,
    );
  }
}

/// 🔧 报名服务接口
abstract class IJoinService {
  // 报名条件检查
  Future<JoinEligibilityResult> checkJoinEligibility(String activityId, String userId);
  
  // 获取支付信息
  Future<PaymentInfo> getPaymentInfo(String activityId, PaymentMethod paymentMethod);
  
  // 处理支付
  Future<PaymentResult> processPayment(PaymentInfo paymentInfo, String userId);
  
  // 提交报名申请
  Future<JoinRequest> submitJoinRequest({
    required String activityId,
    required String userId,
    String? userMessage,
    PaymentMethod? paymentMethod,
    String? transactionId,
  });
  
  // 获取报名状态
  Future<JoinRequest?> getJoinRequest(String activityId, String userId);
  
  // 更新报名状态
  Future<JoinRequest> updateJoinStatus(String requestId, JoinRequestStatus status, {
    String? hostReply,
    FailureReason? failureReason,
  });
  
  // 取消报名
  Future<bool> cancelJoinRequest(String requestId);
  
  // 获取活动的所有报名申请
  Future<List<JoinRequest>> getActivityJoinRequests(String activityId);
  
  // 获取用户的报名历史
  Future<List<JoinRequest>> getUserJoinHistory(String userId, {int limit = 20});
  
  // 获取参与者统计
  Future<ParticipantStats> getParticipantStats(String activityId);
  
  // 监听状态变化
  Stream<JoinRequest> watchJoinStatus(String requestId);
}

/// 🛠️ 报名服务实现
class JoinService implements IJoinService {
  static JoinService? _instance;
  
  JoinService._();
  
  factory JoinService.getInstance() {
    _instance ??= JoinService._();
    return _instance!;
  }

  // 模拟用户数据
  final Map<String, dynamic> _mockUserData = {
    'current_user': {
      'id': 'user_001',
      'nickname': '用户昵称123',
      'avatar': 'https://avatar.example.com/user_001.jpg',
      'balance': 500, // 金币余额
      'level': 5,
      'isVerified': true,
      'joinedCount': 12,
      'successRate': 0.85,
    },
  };

  // 模拟活动数据
  final Map<String, Map<String, dynamic>> _mockActivities = {
    'activity_001': {
      'id': 'activity_001',
      'title': '英雄联盟5V5排位',
      'basePrice': 200,
      'maxParticipants': 5,
      'currentParticipants': 2,
      'registrationDeadline': DateTime.now().add(Duration(hours: 12)),
      'activityTime': DateTime.now().add(Duration(days: 1)),
      'host': {
        'id': 'host_001',
        'nickname': '发起者昵称',
        'avatar': 'https://avatar.example.com/host_001.jpg',
      },
      'requirements': {
        'minLevel': 3,
        'ageRange': [18, 35],
        'genderRatio': null,
      },
    },
  };

  // 模拟报名数据
  final Map<String, JoinRequest> _mockJoinRequests = {};

  @override
  Future<JoinEligibilityResult> checkJoinEligibility(String activityId, String userId) async {
    await _simulateDelay();
    
    try {
      final user = _mockUserData['current_user'];
      final activity = _mockActivities[activityId];
      
      if (activity == null) {
        return JoinEligibilityResult.failure(
          conditions: ['活动不存在'],
          reason: FailureReason.systemError,
        );
      }

      final failedConditions = <String>[];
      FailureReason? failureReason;

      // 检查活动状态
      final registrationDeadline = activity['registrationDeadline'] as DateTime;
      if (DateTime.now().isAfter(registrationDeadline)) {
        failedConditions.add('报名已截止');
        failureReason = FailureReason.timeout;
      }

      // 检查人数限制
      final maxParticipants = activity['maxParticipants'] as int;
      final currentParticipants = activity['currentParticipants'] as int;
      if (currentParticipants >= maxParticipants) {
        failedConditions.add('活动人数已满');
        failureReason = FailureReason.capacityFull;
      }

      // 检查用户等级
      final requirements = activity['requirements'] as Map<String, dynamic>;
      final minLevel = requirements['minLevel'] as int;
      final userLevel = user['level'] as int;
      if (userLevel < minLevel) {
        failedConditions.add('用户等级不足（需要等级$minLevel，当前等级$userLevel）');
        failureReason = FailureReason.conditionsNotMet;
      }

      // 检查是否已报名
      final existingRequest = await getJoinRequest(activityId, userId);
      if (existingRequest != null && !existingRequest.status.isFinalStatus) {
        failedConditions.add('已经报名此活动');
        failureReason = FailureReason.systemError;
      }

      // 检查余额
      final basePrice = activity['basePrice'] as int;
      final userBalance = user['balance'] as int;
      final paymentInfo = await getPaymentInfo(activityId, PaymentMethod.coins);
      if (userBalance < paymentInfo.totalAmount) {
        failedConditions.add('金币余额不足');
        failureReason = FailureReason.insufficientBalance;
      }

      if (failedConditions.isEmpty) {
        return JoinEligibilityResult.success();
      } else {
        return JoinEligibilityResult.failure(
          conditions: failedConditions,
          reason: failureReason!,
        );
      }

    } catch (e) {
      developer.log('检查报名条件失败: $e');
      return JoinEligibilityResult.failure(
        conditions: ['系统错误'],
        reason: FailureReason.systemError,
      );
    }
  }

  @override
  Future<PaymentInfo> getPaymentInfo(String activityId, PaymentMethod paymentMethod) async {
    await _simulateDelay();
    
    try {
      final activity = _mockActivities[activityId]!;
      final user = _mockUserData['current_user']!;
      final host = activity['host'] as Map<String, dynamic>;

      return PaymentInfo.calculate(
        activityId: activityId,
        activityTitle: activity['title'] as String,
        hostNickname: host['nickname'] as String,
        hostAvatar: host['avatar'] as String,
        baseAmount: activity['basePrice'] as int,
        paymentMethod: paymentMethod,
        userBalance: user['balance'] as int,
        discountAmount: 0, // 可以根据用户等级或优惠券计算
      );

    } catch (e) {
      developer.log('获取支付信息失败: $e');
      rethrow;
    }
  }

  @override
  Future<PaymentResult> processPayment(PaymentInfo paymentInfo, String userId) async {
    await _simulateDelay();
    
    try {
      final user = _mockUserData['current_user']!;
      
      // 模拟不同支付方式的处理
      switch (paymentInfo.paymentMethod) {
        case PaymentMethod.coins:
          // 金币支付
          final userBalance = user['balance'] as int;
          if (userBalance < paymentInfo.totalAmount) {
            return PaymentResult.failure(
              errorMessage: '金币余额不足',
              reason: FailureReason.insufficientBalance,
            );
          }
          
          // 模拟扣款
          user['balance'] = userBalance - paymentInfo.totalAmount;
          break;
          
        case PaymentMethod.wechat:
        case PaymentMethod.alipay:
        case PaymentMethod.bankCard:
          // 其他支付方式的模拟（这里简化为总是成功）
          break;
      }

      // 生成交易ID
      final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';
      
      developer.log('支付成功: $transactionId, 金额: ${paymentInfo.totalAmount}');
      
      return PaymentResult.success(transactionId);

    } catch (e) {
      developer.log('支付处理失败: $e');
      return PaymentResult.failure(
        errorMessage: '支付处理失败: $e',
        reason: FailureReason.paymentFailed,
      );
    }
  }

  @override
  Future<JoinRequest> submitJoinRequest({
    required String activityId,
    required String userId,
    String? userMessage,
    PaymentMethod? paymentMethod,
    String? transactionId,
  }) async {
    await _simulateDelay();
    
    try {
      final user = _mockUserData['current_user']!;
      final activity = _mockActivities[activityId]!;
      
      final requestId = 'join_${DateTime.now().millisecondsSinceEpoch}';
      
      final joinRequest = JoinRequest(
        id: requestId,
        activityId: activityId,
        userId: userId,
        userNickname: user['nickname'] as String,
        userAvatar: user['avatar'] as String,
        status: transactionId != null 
            ? JoinRequestStatus.waiting 
            : JoinRequestStatus.submitted,
        paymentMethod: paymentMethod,
        paymentAmount: paymentMethod != null ? activity['basePrice'] as int : null,
        paymentTransactionId: transactionId,
        userMessage: userMessage,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        paidAt: transactionId != null ? DateTime.now() : null,
        expiredAt: DateTime.now().add(JoinFlowConstants.waitingTimeout),
      );

      _mockJoinRequests[requestId] = joinRequest;
      
      developer.log('提交报名申请成功: $requestId');
      
      return joinRequest;

    } catch (e) {
      developer.log('提交报名申请失败: $e');
      rethrow;
    }
  }

  @override
  Future<JoinRequest?> getJoinRequest(String activityId, String userId) async {
    await _simulateDelay();
    
    try {
      // 查找用户在指定活动的报名申请
      for (final request in _mockJoinRequests.values) {
        if (request.activityId == activityId && request.userId == userId) {
          return request;
        }
      }
      return null;

    } catch (e) {
      developer.log('获取报名申请失败: $e');
      return null;
    }
  }

  @override
  Future<JoinRequest> updateJoinStatus(String requestId, JoinRequestStatus status, {
    String? hostReply,
    FailureReason? failureReason,
  }) async {
    await _simulateDelay();
    
    try {
      final request = _mockJoinRequests[requestId];
      if (request == null) {
        throw Exception('报名申请不存在');
      }

      final updatedRequest = request.copyWith(
        status: status,
        hostReply: hostReply,
        failureReason: failureReason,
        updatedAt: DateTime.now(),
        confirmedAt: status == JoinRequestStatus.approved ? DateTime.now() : null,
      );

      _mockJoinRequests[requestId] = updatedRequest;
      
      developer.log('更新报名状态成功: $requestId -> ${status.displayName}');
      
      return updatedRequest;

    } catch (e) {
      developer.log('更新报名状态失败: $e');
      rethrow;
    }
  }

  @override
  Future<bool> cancelJoinRequest(String requestId) async {
    await _simulateDelay();
    
    try {
      final request = _mockJoinRequests[requestId];
      if (request == null) {
        return false;
      }

      // 如果已支付，需要退款
      if (request.paymentTransactionId != null) {
        await _processRefund(request);
      }

      await updateJoinStatus(requestId, JoinRequestStatus.cancelled);
      
      developer.log('取消报名成功: $requestId');
      
      return true;

    } catch (e) {
      developer.log('取消报名失败: $e');
      return false;
    }
  }

  @override
  Future<List<JoinRequest>> getActivityJoinRequests(String activityId) async {
    await _simulateDelay();
    
    try {
      final requests = _mockJoinRequests.values
          .where((r) => r.activityId == activityId)
          .toList();
      
      // 按创建时间排序
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return requests;

    } catch (e) {
      developer.log('获取活动报名申请失败: $e');
      return [];
    }
  }

  @override
  Future<List<JoinRequest>> getUserJoinHistory(String userId, {int limit = 20}) async {
    await _simulateDelay();
    
    try {
      final requests = _mockJoinRequests.values
          .where((r) => r.userId == userId)
          .toList();
      
      // 按创建时间排序并限制数量
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return requests.take(limit).toList();

    } catch (e) {
      developer.log('获取用户报名历史失败: $e');
      return [];
    }
  }

  @override
  Future<ParticipantStats> getParticipantStats(String activityId) async {
    await _simulateDelay();
    
    try {
      final requests = await getActivityJoinRequests(activityId);
      
      final totalApplicants = requests.length;
      final waitingCount = requests.where((r) => r.status == JoinRequestStatus.waiting).length;
      final approvedCount = requests.where((r) => r.status == JoinRequestStatus.approved).length;
      final rejectedCount = requests.where((r) => r.status == JoinRequestStatus.rejected).length;
      
      // 模拟性别比例和年龄分组
      const maleRatio = 0.6;
      const femaleRatio = 0.4;
      
      final ageGroups = {
        '18-25岁': totalApplicants * 0.4,
        '26-35岁': totalApplicants * 0.5,
        '36-45岁': totalApplicants * 0.1,
      }.map((k, v) => MapEntry(k, v.round()));
      
      final recentJoins = requests.take(5).toList();
      
      return ParticipantStats(
        totalApplicants: totalApplicants,
        waitingCount: waitingCount,
        approvedCount: approvedCount,
        rejectedCount: rejectedCount,
        maleRatio: maleRatio,
        femaleRatio: femaleRatio,
        ageGroups: ageGroups,
        recentJoins: recentJoins,
      );

    } catch (e) {
      developer.log('获取参与者统计失败: $e');
      rethrow;
    }
  }

  @override
  Stream<JoinRequest> watchJoinStatus(String requestId) {
    // 实际项目中这里会使用WebSocket或Server-Sent Events
    // 这里使用Timer模拟状态变化
    late StreamController<JoinRequest> controller;
    Timer? timer;
    
    controller = StreamController<JoinRequest>(
      onListen: () {
        // 模拟状态变化
        timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
          final request = _mockJoinRequests[requestId];
          if (request != null) {
            controller.add(request);
            
            // 模拟状态自动变化（仅用于演示）
            if (request.status == JoinRequestStatus.waiting) {
              // 30%概率变为成功，20%概率变为失败
              final random = DateTime.now().millisecond % 100;
              if (random < 30) {
                final updated = await updateJoinStatus(requestId, JoinRequestStatus.approved);
                controller.add(updated);
              } else if (random < 50) {
                final updated = await updateJoinStatus(
                  requestId, 
                  JoinRequestStatus.rejected,
                  failureReason: FailureReason.rejectedByHost,
                );
                controller.add(updated);
              }
            }
          }
        });
      },
      onCancel: () {
        timer?.cancel();
      },
    );
    
    return controller.stream;
  }

  /// 处理退款
  Future<void> _processRefund(JoinRequest request) async {
    try {
      if (request.paymentMethod == PaymentMethod.coins && request.paymentAmount != null) {
        final user = _mockUserData['current_user']!;
        final currentBalance = user['balance'] as int;
        user['balance'] = currentBalance + request.paymentAmount!;
        
        developer.log('退款成功: ${request.paymentAmount}金币');
      }
    } catch (e) {
      developer.log('退款失败: $e');
    }
  }

  /// 模拟延迟
  Future<void> _simulateDelay() async {
    if (JoinServiceConstants.useSimulatedData) {
      await Future.delayed(JoinServiceConstants.simulatedDelay);
    }
  }
}

/// 🏭 报名服务工厂
class JoinServiceFactory {
  static IJoinService getInstance() {
    return JoinService.getInstance();
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - IJoinService: 报名服务接口（public abstract class）
/// - JoinService: 报名服务实现（public class）
/// - JoinServiceFactory: 报名服务工厂（public class）
/// - JoinEligibilityResult: 报名条件检查结果（public class）
/// - PaymentResult: 支付处理结果（public class）
/// - JoinServiceConstants: 报名服务常量（public class）
///
/// 使用方式：
/// ```dart
/// import 'join_services.dart';
/// 
/// // 获取服务实例
/// final joinService = JoinServiceFactory.getInstance();
/// 
/// // 检查报名条件
/// final eligibility = await joinService.checkJoinEligibility(activityId, userId);
/// 
/// // 处理支付
/// final paymentResult = await joinService.processPayment(paymentInfo, userId);
/// ```
