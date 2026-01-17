import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myid/enums.dart';
import 'package:myid/myid.dart';
import 'package:myid/myid_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _error;
  MyIdResult? _result;

  Future<void> init() async {
    String? error;
    MyIdResult? result;

    try {
      const sessionId = 'your_session_id';
      const clientHash = 'your_client_hash';
      const clientHashId = 'your_client_hash_id';

      final myIdResult = await MyIdClient.start(
          config: MyIdConfig(
            // PROVIDE CLIENT_ID, CLIENT_HASH and CLIENT_HASH_ID. YOU'VE GOT FROM YOUR BACKEND
            sessionId: sessionId,
            clientHash: clientHash,
            clientHashId: clientHashId,
            environment: MyIdEnvironment.PRODUCTION,
            entryType: MyIdEntryType.IDENTIFICATION,
          ),
          iosAppearance: const MyIdIOSAppearance());

      error = null;
      result = myIdResult;
    } catch (e) {
      error = e.toString();
      result = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _error = error;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MyID Sample'),
        ),
        body: Center(
          child: Column(
            children: [
              MaterialButton(
                onPressed: init,
                child: const Text('Start SDK'),
              ),
              Text(_result?.code ?? _error ?? 'Failure'),
            ],
          ),
        ),
      ),
    );
  }
}