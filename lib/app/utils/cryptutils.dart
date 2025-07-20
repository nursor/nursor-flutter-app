import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/ecb.dart';
import 'package:pointycastle/paddings/pkcs7.dart';

class AESCipher {
  late Uint8List _key;

  AESCipher(String key) {
    _key = Uint8List.fromList(utf8.encode(key.padRight(32).substring(0, 32)));
    if (_key.length != 32) {
      throw ArgumentError('Key must be 32 bytes after padding/truncating.');
    }
  }

  Uint8List encrypt(String data) {
    final paddedData = _padData(Uint8List.fromList(utf8.encode(data)));

    final cipher = ECBBlockCipher(AESEngine());
    cipher.init(true, KeyParameter(_key));

    final encryptedData = Uint8List(paddedData.length);
    var offset = 0;
    while (offset < paddedData.length) {
      offset += cipher.processBlock(paddedData, offset, encryptedData, offset);
    }
    
    return encryptedData;
  }

  String decrypt(Uint8List encryptedData) {
    final cipher = ECBBlockCipher(AESEngine());
    cipher.init(false, KeyParameter(_key));

    final decryptedData = Uint8List(encryptedData.length);
    var offset = 0;
    while (offset < encryptedData.length) {
      offset += cipher.processBlock(encryptedData, offset, decryptedData, offset);
    }
    
    final unpaddedData = _unpadData(decryptedData);
    return utf8.decode(unpaddedData);
  }

  Uint8List _padData(Uint8List data) {
    final blockSize = 16; // AES block size
    final paddingLength = blockSize - (data.length % blockSize);
    final paddedData = Uint8List(data.length + paddingLength);
    paddedData.setAll(0, data);
    
    // PKCS7 padding
    for (int i = data.length; i < paddedData.length; i++) {
      paddedData[i] = paddingLength;
    }
    
    return paddedData;
  }

  Uint8List _unpadData(Uint8List data) {
    final paddingLength = data[data.length - 1];
    return data.sublist(0, data.length - paddingLength);
  }
}

// Helper functions for demonstration,
// similar to how you might use os.urandom or bytes.fromhex in Python
String bytesToBase64(Uint8List bytes) {
  return base64Encode(bytes);
}

Uint8List base64ToBytes(String base64String) {
  return base64Decode(base64String);
}
