import 'dart:ffi';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:ffi/ffi.dart';

import 'JObjectPool.dart';
import 'class.dart';

class JObject extends Class{
  Pointer _ptr;

  //init target class
  JObject(String className) : super(className) {
    _ptr = nativeCreateClass(super.classUtf8());
    JObjectPool.sInstance.retain(this);
  }

  dynamic invoke(String methodName, List args) {
    final methodNamePtr = Utf8.toUtf8(methodName);
    final methodSignaturePtr = Utf8.toUtf8(methodSignature);

    Pointer<Pointer<Void>> pointers;
    if (args != null) {
      pointers = allocate<Pointer<Void>>(count: args.length + 1);
      for (var i = 0; i < args.length; i++) {
        var arg = args[i];
        if (arg == null) {
          throw 'One of args list is null';
        }
        TypeDecoding argType = argumentSignatureDecoding(methodSignature, i);
        storeValueToPointer(arg, pointers.elementAt(i), argType);
      }
      pointers.elementAt(args.length).value = nullptr;
    }
    Pointer<Void> invokeMethodRet =
        nativeInvoke(_ptr, methodNamePtr, pointers, methodSignaturePtr);
        return null;
  }

  release() {
    if (JObjectPool.sInstance.release(this)) {
      nativeReleaseClass(_ptr);
    }
  }

  @override
  int compareTo(other) {
    if (other is JObject && other._ptr == _ptr) {
      return 0;
    }
    return 1;
  }
}
