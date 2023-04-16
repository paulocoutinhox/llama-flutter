import 'dart:core';
import 'dart:ffi' as ffi;

import "package:ffi/ffi.dart";

class StrHelper {
  static ffi.Pointer<ffi.Pointer<ffi.Char>> strListToPointer(
    List<String> strings,
  ) {
    final pointerList = strings.map((str) => str.toNativeUtf8()).toList();

    final arrayPointer = malloc.allocate<ffi.Pointer<ffi.Char>>(
      pointerList.length,
    );

    for (int i = 0; i < pointerList.length; i++) {
      arrayPointer[i] = pointerList[i].cast<ffi.Char>();
    }

    return arrayPointer;
  }
}
