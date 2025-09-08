// 🔧 发现页面业务服务层 - 双列瀑布流版本
// 提供发现页面所需的所有业务逻辑和API调用
// 针对双列瀑布流布局优化的服务实现

// ============== 导入依赖 ==============
import 'dart:async';
import 'dart:math' as math;
import 'dart:developer' as developer;
import '../models/discovery_models.dart';
import '../models/content_detail_models.dart';

// ============== 服务类定义 ==============

/// 🔍 发现页面主服务类
class DiscoveryService {
  // 私有构造函数实现单例模式
  DiscoveryService._();
  static final DiscoveryService _instance = DiscoveryService._();
  factory DiscoveryService() => _instance;

  // 模拟数据缓存
  final Map<String, List<DiscoveryContent>> _contentCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);

  /// 获取关注用户内容
  Future<List<DiscoveryContent>> getFollowingContent({
    int page = 1,
    int limit = 20,
  }) async {
    final cacheKey = 'following_${page}_$limit';
    
    // 检查缓存
    if (_isValidCache(cacheKey)) {
      developer.log('从缓存获取关注内容: page=$page, limit=$limit');
      return _contentCache[cacheKey]!;
    }

    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 500 + math.Random().nextInt(500)));

    // 生成模拟数据
    final contents = _generateMockContents(
      tabType: TabType.following,
      page: page,
      limit: limit,
    );

    // 更新缓存
    _updateCache(cacheKey, contents);

    developer.log('获取关注内容成功: page=$page, count=${contents.length}');
    return contents;
  }

  /// 获取热门内容
  Future<List<DiscoveryContent>> getTrendingContent({
    int page = 1,
    int limit = 20,
  }) async {
    final cacheKey = 'trending_${page}_$limit';
    
    // 检查缓存
    if (_isValidCache(cacheKey)) {
      developer.log('从缓存获取热门内容: page=$page, limit=$limit');
      return _contentCache[cacheKey]!;
    }

    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 600 + math.Random().nextInt(400)));

    // 生成模拟数据
    final contents = _generateMockContents(
      tabType: TabType.trending,
      page: page,
      limit: limit,
    );

    // 更新缓存
    _updateCache(cacheKey, contents);

    developer.log('获取热门内容成功: page=$page, count=${contents.length}');
    return contents;
  }

  /// 获取同城内容
  Future<List<DiscoveryContent>> getNearbyContent({
    int page = 1,
    int limit = 20,
  }) async {
    final cacheKey = 'nearby_${page}_$limit';
    
    // 检查缓存
    if (_isValidCache(cacheKey)) {
      developer.log('从缓存获取同城内容: page=$page, limit=$limit');
      return _contentCache[cacheKey]!;
    }

    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 700 + math.Random().nextInt(300)));

    // 生成模拟数据
    final contents = _generateMockContents(
      tabType: TabType.nearby,
      page: page,
      limit: limit,
    );

    // 更新缓存
    _updateCache(cacheKey, contents);

    developer.log('获取同城内容成功: page=$page, count=${contents.length}');
    return contents;
  }

  /// 点赞内容
  Future<void> likeContent(String contentId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 200));

    developer.log('点赞内容: $contentId');
    
    // TODO: 实际实现中应该调用API
    // 这里可以更新本地缓存中的点赞状态
  }

  /// 评论内容
  Future<void> commentContent(String contentId, String comment) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    developer.log('评论内容: $contentId, comment: $comment');
    
    // TODO: 实际实现中应该调用API
  }

  /// 分享内容
  Future<void> shareContent(String contentId, String platform) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 250));

    developer.log('分享内容: $contentId, platform: $platform');
    
    // TODO: 实际实现中应该调用分享API
  }

  /// 关注用户
  Future<void> followUser(String userId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    developer.log('关注用户: $userId');
    
    // TODO: 实际实现中应该调用API
  }

  /// 清除缓存
  void clearCache() {
    _contentCache.clear();
    _cacheTimestamps.clear();
    developer.log('发现页面缓存已清除');
  }

  /// 检查缓存是否有效
  bool _isValidCache(String key) {
    if (!_contentCache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }
    
    final timestamp = _cacheTimestamps[key]!;
    final now = DateTime.now();
    return now.difference(timestamp) < _cacheExpiration;
  }

  /// 更新缓存
  void _updateCache(String key, List<DiscoveryContent> contents) {
    _contentCache[key] = contents;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// 生成模拟内容数据
  List<DiscoveryContent> _generateMockContents({
    required TabType tabType,
    required int page,
    required int limit,
  }) {
    final random = math.Random();
    final contents = <DiscoveryContent>[];
    
    // 计算起始ID（确保分页数据不重复）
    final startId = (page - 1) * limit;
    
    for (int i = 0; i < limit; i++) {
      final contentId = '${tabType.name}_${startId + i + 1}';
      final userId = 'user_${random.nextInt(1000) + 1}';
      
      // 生成用户信息
      final user = DiscoveryUser(
        id: userId,
        nickname: _generateRandomNickname(),
        avatar: 'https://example.com/avatar/$userId.jpg',
        avatarUrl: 'https://example.com/avatar/$userId.jpg',
        isVerified: random.nextBool() && random.nextInt(10) > 7, // 30%概率认证
        followerCount: random.nextInt(10000),
        followingCount: random.nextInt(1000),
        bio: random.nextBool() ? _generateRandomBio() : null,
        location: tabType == TabType.nearby ? _generateRandomLocation() : null,
        createdAt: DateTime.now().subtract(Duration(days: random.nextInt(365))),
      );

      // 生成内容类型（图片为主，符合瀑布流特性）
      ContentType contentType;
      final typeRand = random.nextInt(100);
      if (typeRand < 70) {
        contentType = ContentType.image; // 70%图片内容
      } else if (typeRand < 85) {
        contentType = ContentType.video; // 15%视频内容
      } else if (typeRand < 95) {
        contentType = ContentType.text; // 10%纯文字内容
      } else {
        contentType = ContentType.activity; // 5%活动内容
      }

      // 生成图片列表（瀑布流关键：包含尺寸信息）
      final images = <DiscoveryImage>[];
      if (contentType == ContentType.image) {
        final imageCount = _getRandomImageCount();
        for (int j = 0; j < imageCount; j++) {
          final imageId = '${contentId}_img_$j';
          final dimensions = _getRandomImageDimensions();
          images.add(DiscoveryImage(
            id: imageId,
            url: 'https://example.com/image/$imageId.jpg',
            thumbnailUrl: 'https://example.com/image/${imageId}_thumb.jpg',
            width: dimensions['width']!,
            height: dimensions['height']!,
            size: random.nextInt(5000000) + 100000, // 100KB-5MB
            createdAt: DateTime.now().subtract(Duration(minutes: random.nextInt(60))),
            uploadedAt: DateTime.now().subtract(Duration(minutes: random.nextInt(60))),
          ));
        }
      }

      // 生成文字内容
      final text = _generateRandomText(contentType);

      // 生成视频URL
      final videoUrl = contentType == ContentType.video 
          ? 'https://example.com/video/$contentId.mp4'
          : '';
      final videoThumbnailUrl = contentType == ContentType.video
          ? 'https://example.com/video/${contentId}_thumb.jpg'
          : '';

      // 生成互动数据（热门内容数据更高）
      final baseMultiplier = tabType == TabType.trending ? 5 : 1;
      final likeCount = random.nextInt(1000 * baseMultiplier);
      final commentCount = random.nextInt(100 * baseMultiplier);
      final shareCount = random.nextInt(50 * baseMultiplier);

      // 生成位置信息（同城内容必有位置）
      DiscoveryLocation? location;
      if (tabType == TabType.nearby) {
        location = _generateRandomLocationInfo();
      } else if (random.nextBool() && random.nextInt(10) > 7) {
        location = _generateRandomLocationInfo();
      }

      // 生成话题标签
      final topics = _generateRandomTopics();

      // 创建内容对象
      final content = DiscoveryContent(
        id: contentId,
        user: user,
        text: text,
        images: images,
        videoUrl: videoUrl,
        videoThumbnail: videoThumbnailUrl,
        videoThumbnailUrl: videoThumbnailUrl,
        type: contentType,
        createdAt: formatCreatedAt(DateTime.now().subtract(
          Duration(
            minutes: random.nextInt(60 * 24 * 7), // 最近一周内
          ),
        )),
        createdAtRaw: DateTime.now().subtract(
          Duration(
            minutes: random.nextInt(60 * 24 * 7), // 最近一周内
          ),
        ),
        likeCount: likeCount,
        commentCount: commentCount,
        shareCount: shareCount,
        isLiked: random.nextBool() && random.nextInt(10) > 8, // 20%概率已点赞
        isFavorited: random.nextBool() && random.nextInt(10) > 9, // 10%概率已收藏
        location: location,
        topics: topics,
      );

      contents.add(content);
    }

    return contents;
  }

  /// 获取随机图片数量（瀑布流优化：单图为主）
  int _getRandomImageCount() {
    final random = math.Random();
    final rand = random.nextInt(100);
    
    if (rand < 60) return 1; // 60%单图
    if (rand < 80) return 2; // 20%双图
    if (rand < 90) return 3; // 10%三图
    if (rand < 95) return 4; // 5%四图
    return random.nextInt(5) + 5; // 5%多图(5-9张)
  }

  /// 获取随机图片尺寸（瀑布流关键：多样化的宽高比）
  Map<String, int> _getRandomImageDimensions() {
    final random = math.Random();
    final aspectRatios = [
      {'width': 400, 'height': 400}, // 1:1 正方形
      {'width': 400, 'height': 300}, // 4:3 横图
      {'width': 300, 'height': 400}, // 3:4 竖图
      {'width': 400, 'height': 600}, // 2:3 长竖图
      {'width': 600, 'height': 400}, // 3:2 长横图
      {'width': 400, 'height': 500}, // 4:5 微长竖图
      {'width': 500, 'height': 400}, // 5:4 微长横图
      {'width': 400, 'height': 800}, // 1:2 超长竖图
      {'width': 800, 'height': 400}, // 2:1 超长横图
    ];
    
    return aspectRatios[random.nextInt(aspectRatios.length)];
  }

  /// 生成随机用户昵称
  String _generateRandomNickname() {
    final random = math.Random();
    final prefixes = ['可爱的', '阳光', '快乐', '温柔的', '活泼的', '神秘的', '优雅的'];
    final suffixes = ['小猫', '兔子', '星星', '月亮', '花朵', '彩虹', '微风', '阳光'];
    final numbers = random.nextBool() ? random.nextInt(999).toString() : '';
    
    return '${prefixes[random.nextInt(prefixes.length)]}${suffixes[random.nextInt(suffixes.length)]}$numbers';
  }

  /// 生成随机用户简介
  String _generateRandomBio() {
    final random = math.Random();
    final bios = [
      '热爱生活，享受每一天 ✨',
      '摄影爱好者 📸 | 旅行达人 ✈️',
      '美食探索者 🍜 分享生活中的美好',
      '90后 | 猫奴 🐱 | 咖啡控 ☕',
      '用心记录生活的点点滴滴',
      '愿所有美好都如期而至 🌸',
      '简单生活，快乐至上',
      '爱笑的人运气都不会太差 😊',
    ];
    
    return bios[random.nextInt(bios.length)];
  }

  /// 生成随机位置名称
  String _generateRandomLocation() {
    final random = math.Random();
    final locations = ['深圳', '北京', '上海', '广州', '杭州', '成都', '重庆', '南京'];
    return locations[random.nextInt(locations.length)];
  }

  /// 生成随机位置信息
  DiscoveryLocation _generateRandomLocationInfo() {
    final random = math.Random();
    final locations = [
      {'name': '南山科技园', 'city': '深圳', 'district': '南山区'},
      {'name': '西湖风景区', 'city': '杭州', 'district': '西湖区'},
      {'name': '外滩', 'city': '上海', 'district': '黄浦区'},
      {'name': '天安门广场', 'city': '北京', 'district': '东城区'},
      {'name': '广州塔', 'city': '广州', 'district': '海珠区'},
      {'name': '春熙路', 'city': '成都', 'district': '锦江区'},
      {'name': '解放碑', 'city': '重庆', 'district': '渝中区'},
      {'name': '夫子庙', 'city': '南京', 'district': '秦淮区'},
    ];
    
    final location = locations[random.nextInt(locations.length)];
    return DiscoveryLocation(
      id: 'loc_${random.nextInt(10000)}',
      name: location['name']!,
      address: '${location['city']}${location['district']}${location['name']}',
      latitude: 22.5 + random.nextDouble() * 10, // 模拟坐标
      longitude: 113.9 + random.nextDouble() * 10,
      category: location['district'],
      distance: random.nextDouble() * 5000, // 0-5km距离
      createdAt: DateTime.now(),
    );
  }

  /// 生成随机话题标签
  List<DiscoveryTopic> _generateRandomTopics() {
    final random = math.Random();
    final topicNames = [
      '日常生活', '美食分享', '旅行记录', '摄影', '时尚穿搭',
      '健身打卡', '读书笔记', '音乐推荐', '电影观后感', '宠物日常',
      '工作日常', '学习笔记', '手工制作', '烘焙记录', '植物日记',
    ];
    
    final topicCount = random.nextInt(3); // 0-2个话题
    final topics = <DiscoveryTopic>[];
    
    for (int i = 0; i < topicCount; i++) {
      final topicName = topicNames[random.nextInt(topicNames.length)];
      topics.add(DiscoveryTopic(
        id: 'topic_${topicName.hashCode}',
        name: topicName,
        contentCount: random.nextInt(10000),
        isHot: random.nextBool() && random.nextInt(10) > 7,
        createdAt: DateTime.now().subtract(Duration(days: random.nextInt(30))),
      ));
    }
    
    return topics;
  }

  /// 生成随机文字内容
  String _generateRandomText(ContentType contentType) {
    final random = math.Random();
    
    switch (contentType) {
      case ContentType.image:
        final imageCaptions = [
          '今天的天气真好，出来拍拍照 📸',
          '分享一下最近的生活状态',
          '这个角度拍出来还不错',
          '记录美好的一天 ✨',
          '随手一拍，意外的好看',
          '生活中的小确幸',
          '今日份的快乐',
          '用镜头记录生活的美好',
        ];
        return imageCaptions[random.nextInt(imageCaptions.length)];
        
      case ContentType.video:
        final videoCaptions = [
          '分享一段有趣的视频 🎬',
          '记录生活中的精彩瞬间',
          '这个视频太有意思了',
          '和大家分享一下',
          '今天拍的小视频',
          '生活需要仪式感',
          '记录当下的美好时光',
          '分享快乐，传递正能量',
        ];
        return videoCaptions[random.nextInt(videoCaptions.length)];
        
      case ContentType.text:
        final textContents = [
          '今天突然想到一个问题，为什么我们总是在寻找生活的意义呢？也许生活本身就是意义所在。',
          '最近读了一本很棒的书，里面有句话特别打动我："真正的成长不是学会如何避免痛苦，而是学会如何与痛苦共舞。"',
          '有时候觉得，最好的时光就是和朋友们在一起聊天，不需要做什么特别的事情，就这样简单地在一起就很快乐。',
          '今天在路上看到一个小朋友跌倒了，一个陌生人主动去扶他，这个世界还是很温暖的。',
          '突然想起小时候的梦想，虽然现在的生活和当初想象的不太一样，但也有它独特的美好。',
          '每天都在学习新的东西，感觉自己在慢慢变好，这种感觉真的很棒。',
        ];
        return textContents[random.nextInt(textContents.length)];
        
      case ContentType.activity:
        final activityTexts = [
          '这周末有个很有趣的活动，有兴趣的朋友一起来参加吧！',
          '组织一次户外徒步活动，欢迎大家报名参加 🥾',
          '读书分享会即将开始，期待与大家交流心得',
          '美食探店活动来啦，一起去发现城市里的美味',
          '摄影爱好者聚会，带上相机一起去捕捉美好',
          '周末电影观影会，经典影片重温',
        ];
        return activityTexts[random.nextInt(activityTexts.length)];
        
      case ContentType.mixed:
        final mixedTexts = [
          '今天分享一些生活中的点点滴滴 ✨',
          '记录美好时光，分享快乐心情',
          '生活就是这样，有图有真相',
          '用文字和图片记录当下的感受',
          '分享一些最近的生活感悟',
        ];
        return mixedTexts[random.nextInt(mixedTexts.length)];
    }
  }
}

/// 🎯 推荐算法服务
class RecommendationService {
  RecommendationService._();
  static final RecommendationService _instance = RecommendationService._();
  factory RecommendationService() => _instance;

  /// 获取个性化推荐内容
  Future<List<DiscoveryContent>> getPersonalizedRecommendations({
    required String userId,
    int limit = 10,
  }) async {
    // 模拟个性化推荐算法
    await Future.delayed(const Duration(milliseconds: 300));
    
    developer.log('获取用户 $userId 的个性化推荐，数量: $limit');
    
    // TODO: 实际实现中应该基于用户行为数据进行推荐
    return [];
  }

  /// 获取热门趋势内容
  Future<List<DiscoveryContent>> getTrendingRecommendations({
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    
    developer.log('获取热门趋势推荐，数量: $limit');
    
    // TODO: 实际实现中应该基于热度算法进行推荐
    return [];
  }
}

/// 📍 地理位置服务
class LocationService {
  LocationService._();
  static final LocationService _instance = LocationService._();
  factory LocationService() => _instance;

  /// 获取当前位置
  Future<DiscoveryLocation?> getCurrentLocation() async {
    // 模拟获取位置
    await Future.delayed(const Duration(seconds: 1));
    
    developer.log('获取当前位置');
    
    // 返回模拟位置
    return DiscoveryLocation(
      id: 'current_location',
      name: '南山科技园',
      address: '深圳市南山区科技园',
      latitude: 22.5364,
      longitude: 113.9436,
      category: '南山区',
      createdAt: DateTime.now(),
    );
  }

  /// 根据位置获取附近内容
  Future<List<DiscoveryContent>> getNearbyContentByLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    developer.log('获取位置 ($latitude, $longitude) 附近 ${radiusKm}km 内容，数量: $limit');
    
    // TODO: 实际实现中应该基于地理位置查询
    return [];
  }
}

/// 🤝 社交互动服务
class InteractionService {
  InteractionService._();
  static final InteractionService _instance = InteractionService._();
  factory InteractionService() => _instance;

  /// 点赞内容
  Future<bool> likeContent(String contentId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    developer.log('用户 $userId 点赞内容 $contentId');
    
    // 模拟点赞成功
    return true;
  }

  /// 取消点赞
  Future<bool> unlikeContent(String contentId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    developer.log('用户 $userId 取消点赞内容 $contentId');
    
    return true;
  }

  /// 评论内容
  Future<CommentModel?> commentContent({
    required String contentId,
    required String userId,
    required String comment,
    String? replyToUserId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    developer.log('用户 $userId 评论内容 $contentId: $comment');
    
    // TODO: 实际实现中应该调用评论API并返回评论对象
    return null;
  }

  /// 关注用户
  Future<bool> followUser(String userId, String targetUserId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    developer.log('用户 $userId 关注用户 $targetUserId');
    
    return true;
  }

  /// 取消关注
  Future<bool> unfollowUser(String userId, String targetUserId) async {
    await Future.delayed(const Duration(milliseconds: 350));
    
    developer.log('用户 $userId 取消关注用户 $targetUserId');
    
    return true;
  }

  /// 分享内容
  Future<bool> shareContent({
    required String contentId,
    required String userId,
    required String platform,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    
    developer.log('用户 $userId 在 $platform 分享内容 $contentId');
    
    return true;
  }

  /// 举报内容
  Future<bool> reportContent({
    required String contentId,
    required String userId,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    developer.log('用户 $userId 举报内容 $contentId，原因: $reason');
    
    return true;
  }
}