/// Device information model
class DeviceInfo {
  final String id;
  final String name;
  final String ipAddress;
  final String platform; // 'android' or 'windows'
  final int port;

  const DeviceInfo({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.platform,
    required this.port,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'ipAddress': ipAddress,
    'platform': platform,
    'port': port,
  };

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
    id: json['id'] as String,
    name: json['name'] as String,
    ipAddress: json['ipAddress'] as String,
    platform: json['platform'] as String,
    port: json['port'] as int,
  );

  @override
  String toString() => 'DeviceInfo($name, $ipAddress:$port, $platform)';
}
