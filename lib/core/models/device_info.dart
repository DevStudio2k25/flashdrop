/// Device information model
class DeviceInfo {
  final String id;
  final String name;
  final String ipAddress;
  final String platform; // 'android' or 'windows'
  final int port;
  final String? otherIp; // Secondary IP (e.g. mobile data 10.x.x.x)

  const DeviceInfo({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.platform,
    required this.port,
    this.otherIp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'ipAddress': ipAddress,
    'platform': platform,
    'port': port,
    'otherIp': otherIp,
  };

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
    id: json['id'] as String,
    name: json['name'] as String,
    ipAddress: json['ipAddress'] as String,
    platform: json['platform'] as String,
    port: json['port'] as int,
    otherIp: json['otherIp'] as String?,
  );

  @override
  String toString() => 'DeviceInfo($name, $ipAddress:$port, $platform)';
}
