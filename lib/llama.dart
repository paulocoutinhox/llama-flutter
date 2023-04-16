import 'dart:async';
import 'dart:core';
import 'dart:ffi' as ffi;
import 'dart:io' as io;
import 'dart:io';

import 'package:aichat/str_helper.dart';
import 'package:flutter/foundation.dart';

import 'generated_bindings.dart' as gb;

class LLaMA {
  static final streamController = StreamController<String>();
  static ServerSocket? _serverSocket;
  static final _library = _getLibrary();

  static void startServer() async {
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 5567);
    _serverSocket?.listen((client) {
      _handleConnection(client);
    });
  }

  static void dispose() {
    _serverSocket?.close();
  }

  static void call(List<String> params) {
    params.insert(0, "main");

    final nl = gb.NativeLibrary(_library);

    var argv = StrHelper.strListToPointer(params);

    nl.llama_main(params.length, argv);

    print("Call: $argv");
  }

  static void _handleConnection(Socket client) {
    /*
    print(
      'Connection from'
      ' ${client.remoteAddress.address}:${client.remotePort}',
    );
    */

    // listen for events from the client
    client.listen(
      // handle data from the client
      (Uint8List data) async {
        final message = String.fromCharCodes(data);
        streamController.add(message);
      },

      // handle errors
      onError: (error) {
        //print('Socket Error:$error');
        client.close();
      },

      // handle the client closing the connection
      onDone: () {
        //print('Socket: Client left');
        client.close();
      },
    );
  }

  static ffi.DynamicLibrary _getLibrary() {
    if (io.Platform.isAndroid) {
      return ffi.DynamicLibrary.open('libmain.so');
    } else if (io.Platform.isLinux) {
      return ffi.DynamicLibrary.open('libmain.so');
    } else if (io.Platform.isWindows) {
      return ffi.DynamicLibrary.open('libmain.dll');
    } else if (io.Platform.isIOS) {
      return ffi.DynamicLibrary.process();
    } else if (io.Platform.isMacOS) {
      return ffi.DynamicLibrary.open('libmain.dylib');
    } else {
      throw Exception('Unsupported platform');
    }
  }
}
