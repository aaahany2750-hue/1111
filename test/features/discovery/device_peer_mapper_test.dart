import 'package:flutter_test/flutter_test.dart';
import 'package:flashtransfer/features/discovery/data/mappers/device_peer_mapper.dart';

void main() {
  test('maps native Wi-Fi Direct peer payload into DevicePeer', () {
    const DevicePeerMapper mapper = DevicePeerMapper();

    final peer = mapper.fromNativeMap(<String, dynamic>{
      'name': 'Pixel 9',
      'address': '02:00:00:00:00:01',
      'status': 3,
      'isGroupOwner': true,
    });

    expect(peer.name, 'Pixel 9');
    expect(peer.address, '02:00:00:00:00:01');
    expect(peer.status, 3);
    expect(peer.isGroupOwner, isTrue);
    expect(peer.connectionStatus.name, 'available');
  });
}
