// ============== 话题选择页面 ==============
/// 
/// 这是一个临时的话题选择页面，用于发布动态时选择话题
/// 
import 'package:flutter/material.dart';
import '../models/publish_models.dart';

class TopicSelectorPage extends StatefulWidget {
  const TopicSelectorPage({super.key});

  @override
  State<TopicSelectorPage> createState() => _TopicSelectorPageState();
}

class _TopicSelectorPageState extends State<TopicSelectorPage> {
  final List<TopicModel> _selectedTopics = [];
  
  // 模拟话题数据
  final List<TopicModel> _allTopics = [
    TopicModel(id: '1', name: '美食', displayName: '美食', category: '生活', isHot: true, createdAt: DateTime.now()),
    TopicModel(id: '2', name: '旅行', displayName: '旅行', category: '生活', isHot: true, createdAt: DateTime.now()),
    TopicModel(id: '3', name: '摄影', displayName: '摄影', category: '兴趣', isHot: false, createdAt: DateTime.now()),
    TopicModel(id: '4', name: '健身', displayName: '健身', category: '健康', isHot: true, createdAt: DateTime.now()),
    TopicModel(id: '5', name: '读书', displayName: '读书', category: '学习', isHot: false, createdAt: DateTime.now()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择话题'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _selectedTopics);
            },
            child: const Text('确定'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _allTopics.length,
        itemBuilder: (context, index) {
          final topic = _allTopics[index];
          final isSelected = _selectedTopics.contains(topic);
          
          return ListTile(
            leading: Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            title: Text('#${topic.name}'),
            subtitle: Text(topic.category ?? '未分类'),
            trailing: topic.isHot ? const Icon(Icons.whatshot, color: Colors.red, size: 16) : null,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedTopics.remove(topic);
                } else {
                  _selectedTopics.add(topic);
                }
              });
            },
          );
        },
      ),
    );
  }
}
