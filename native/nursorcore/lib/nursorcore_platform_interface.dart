import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'nursorcore_method_channel.dart';

abstract class NursorcorePlatform extends PlatformInterface {
  /// Constructs a NursorcorePlatform.
  NursorcorePlatform() : super(token: _token);

  static final Object _token = Object();

  static NursorcorePlatform _instance = MethodChannelNursorcore();

  /// The default instance of [NursorcorePlatform] to use.
  ///
  /// Defaults to [MethodChannelNursorcore].
  static NursorcorePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NursorcorePlatform] when
  /// they register themselves.
  static set instance(NursorcorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
