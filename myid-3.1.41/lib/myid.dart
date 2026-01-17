import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:convert';

import 'myid_config.dart';

class MyIdClient {
  static const MethodChannel _channel = MethodChannel('myid_uz');
  static const JsonDecoder _jsonDecoder = JsonDecoder();
  static const JsonEncoder _jsonEncoder = JsonEncoder();

  static Future<MyIdResult> start({
    required MyIdConfig config,
    MyIdIOSAppearance iosAppearance = const MyIdIOSAppearance(),
  }) async {
    final confingJson = config.toJson();
    final result = await _channel.invokeMethod('startSdk', {
      "config": confingJson,
      "appearance": iosAppearance.toJson(),
    });
    return MyIdResult.fromJson(
      _jsonDecoder.convert(
        _jsonEncoder.convert(result),
      ),
    );
  }
}