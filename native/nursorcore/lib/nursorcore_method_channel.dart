import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'nursorcore_platform_interface.dart';

/// An implementation of [NursorcorePlatform] that uses method channels.
class MethodChannelNursorcore extends NursorcorePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nursorcore');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
