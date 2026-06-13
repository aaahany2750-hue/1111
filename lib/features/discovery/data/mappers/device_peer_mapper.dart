import '../../../../core/models/device_peer.dart';

class DevicePeerMapper {
  const DevicePeerMapper();

  DevicePeer fromNativeMap(Map<String, dynamic> map) {
    return DevicePeer(
      name: map['name'] as String? ?? 'Android Device',
      address: map['address'] as String? ?? '',
      status: (map['status'] as num? ?? -1).toInt(),
      isGroupOwner: map['isGroupOwner'] as bool? ?? false,
      lastSeen: DateTime.now(),
    );
  }

  List<DevicePeer> fromNativeList(List<dynamic> values) {
    return values.map((dynamic value) {
      return fromNativeMap(Map<String, dynamic>.from(value as Map<dynamic, dynamic>));
    }).toList(growable: false);
  }
}
