// ============== 地点选择页面 ==============
/// 
/// 这是一个临时的地点选择页面，用于发布动态时选择地理位置
/// 
import 'package:flutter/material.dart';
import '../models/publish_models.dart';

// 为了向后兼容，创建类型别名
typedef LocationPickerPage = DiscoveryLocationPickerPage;

class DiscoveryLocationPickerPage extends StatefulWidget {
  const DiscoveryLocationPickerPage({super.key});

  @override
  State<DiscoveryLocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<DiscoveryLocationPickerPage> {
  LocationModel? _selectedLocation;
  
  // 模拟地点数据
  final List<LocationModel> _nearbyLocations = [
    LocationModel(
      id: '1',
      name: '星巴克咖啡',
      address: '北京市朝阳区建国门外大街1号',
      latitude: 39.9042,
      longitude: 116.4074,
      type: LocationType.poi,
      createdAt: DateTime.now(),
    ),
    LocationModel(
      id: '2', 
      name: '三里屯太古里',
      address: '北京市朝阳区三里屯路19号',
      latitude: 39.9370,
      longitude: 116.4472,
      type: LocationType.poi,
      createdAt: DateTime.now(),
    ),
    LocationModel(
      id: '3',
      name: '朝阳公园',
      address: '北京市朝阳区朝阳公园南路1号',
      latitude: 39.9336,
      longitude: 116.4736,
      type: LocationType.poi,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择位置'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _selectedLocation);
            },
            child: const Text('确定'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 当前位置按钮
          ListTile(
            leading: const Icon(Icons.my_location, color: Colors.blue),
            title: const Text('使用当前位置'),
            subtitle: const Text('获取GPS定位'),
            onTap: () {
              setState(() {
                _selectedLocation = LocationModel(
                  id: 'current',
                  name: '当前位置',
                  address: '正在获取位置信息...',
                  latitude: 39.9042,
                  longitude: 116.4074,
                  type: LocationType.gps,
                  createdAt: DateTime.now(),
                );
              });
            },
          ),
          const Divider(),
          
          // 附近地点列表
          Expanded(
            child: ListView.builder(
              itemCount: _nearbyLocations.length,
              itemBuilder: (context, index) {
                final location = _nearbyLocations[index];
                final isSelected = _selectedLocation?.id == location.id;
                
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.place,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  title: Text(location.name),
                  subtitle: Text(location.address ?? ''),
                  onTap: () {
                    setState(() {
                      _selectedLocation = location;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
