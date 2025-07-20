import 'package:flutter_test/flutter_test.dart';
import 'package:nursorcore/nursorcore.dart';
import 'package:nursorcore/nursorcore_platform_interface.dart';
import 'package:nursorcore/nursorcore_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNursorcorePlatform
    with MockPlatformInterfaceMixin
    implements NursorcorePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NursorcorePlatform initialPlatform = NursorcorePlatform.instance;

  test('$MethodChannelNursorcore is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNursorcore>());
  });

  test('getPlatformVersion', () async {
    Nursorcore nursorcorePlugin = Nursorcore();
    MockNursorcorePlatform fakePlatform = MockNursorcorePlatform();
    NursorcorePlatform.instance = fakePlatform;

    expect(await nursorcorePlugin.getPlatformVersion(), '42');
  });
}
