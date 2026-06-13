enum DeviceConnectionStatus {
  connected,
  invited,
  failed,
  available,
  unavailable,
  unknown;

  static DeviceConnectionStatus fromWifiP2pStatus(int status) {
    return switch (status) {
      0 => connected,
      1 => invited,
      2 => failed,
      3 => available,
      4 => unavailable,
      _ => unknown,
    };
  }
}

class DevicePeer {
  const DevicePeer({
    required this.name,
    required this.address,
    required this.status,
    this.isGroupOwner = false,
    this.lastSeen,
  });

  final String name;
  final String address;
  final int status;
  final bool isGroupOwner;
  final DateTime? lastSeen;

  DeviceConnectionStatus get connectionStatus => DeviceConnectionStatus.fromWifiP2pStatus(status);

  factory DevicePeer.fromMap(Map<String, dynamic> map) {
    return DevicePeer(
      name: map['name'] as String? ?? 'Android Device',
      address: map['address'] as String? ?? '',
      status: map['status'] as int? ?? -1,
      isGroupOwner: map['isGroupOwner'] as bool? ?? false,
      lastSeen: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'address': address,
      'status': status,
      'isGroupOwner': isGroupOwner,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }
}
