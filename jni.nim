#
#  Copyright (c) 1996, 2006, Oracle and/or its affiliates. All rights reserved.
#  DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
# 
#  This code is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License version 2 only, as
#  published by the Free Software Foundation.  Oracle designates this
#  particular file as subject to the "Classpath" exception as provided
#  by Oracle in the LICENSE file that accompanied this code.
# 
#  This code is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#  version 2 for more details (a copy is included in the LICENSE file that
#  accompanied this code).
# 
#  You should have received a copy of the GNU General Public License version
#  2 along with this work; if not, write to the Free Software Foundation,
#  Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
# 
#  Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
#  or visit www.oracle.com if you need additional information or have any
#  questions.
# 
#
#  We used part of Netscape's Java Runtime Interface (JRI) as the starting
#  point of our design and implementation.
# 
#*****************************************************************************
#  Java Runtime Interface
#  Copyright (c) 1996 Netscape Communications Corporation. All rights reserved.
# ***************************************************************************

import 
  "jnifindjava"

import 
  "jni_md"

when not(defined(JNI_TYPES_ALREADY_DEFINED_IN_JNI_MD_H)): 
  type 
    jchar* = cushort
    jshort* = cshort
    jfloat* = cfloat
    jdouble* = cdouble
    jsize* = jint
    jobject* = pointer
    jclass* = jobject
    jthrowable* = jobject
    jstring* = jobject
    jarray* = jobject
    jbooleanArray* = jarray
    jbyteArray* = jarray
    jcharArray* = jarray
    jshortArray* = jarray
    jintArray* = jarray
    jlongArray* = jarray
    jfloatArray* = jarray
    jdoubleArray* = jarray
    jobjectArray* = jarray
    jweak* = jobject
    jvalue* {.pure, final.} = object 
      z*: jboolean

    jfieldID* = pointer
    jmethodID* = pointer
  # Return values from jobjectRefType 
  type 
    jobjectRefType* {.size: sizeof(cint).} = enum 
      JNIInvalidRefType = 0, JNILocalRefType = 1, JNIGlobalRefType = 2, 
      JNIWeakGlobalRefType = 3
#
#  jboolean constants
# 

const 
  JNI_FALSE* = 0
  JNI_TRUE* = 1

#
#  possible return values for JNI functions.
# 

const 
  JNI_OK* = 0                 # success 
  JNI_ERR* = (- 1)            # unknown error 
  JNI_EDETACHED* = (- 2)      # thread detached from the VM 
  JNI_EVERSION* = (- 3)       # JNI version error 
  JNI_ENOMEM* = (- 4)         # not enough memory 
  JNI_EEXIST* = (- 5)         # VM already created 
  JNI_EINVAL* = (- 6)         # invalid arguments 

#
#  used in ReleaseScalarArrayElements
# 

const 
  JNI_COMMIT* = 1
  JNI_ABORT* = 2

#
#  used in RegisterNatives to describe native method name, signature,
#  and function pointer.
# 

type 
  JNINativeMethod* {.pure, final.} = object 
    name*: cstring
    signature*: cstring
    fnPtr*: pointer


#
#  JNI Native Method Interface.
# 

type 
  JNIEnv_u* {.pure, final.} = object 
  

#
#  JNI Invocation Interface.
# 

type 
  JavaVM_u* {.pure, final.} = object 
  
  JNINativeInterface_u* {.pure, final.} = object 
    reserved0*: pointer
    reserved1*: pointer
    reserved2*: pointer
    reserved3*: pointer
    GetVersion*: proc (env: ptr JNIEnv): jint {.cdecl.}
    DefineClass*: proc (env: ptr JNIEnv; name: cstring; loader: jobject; 
                        buf: ptr jbyte; len: jsize): jclass {.cdecl.}
    FindClass*: proc (env: ptr JNIEnv; name: cstring): jclass {.cdecl.}
    FromReflectedMethod*: proc (env: ptr JNIEnv; methodU: jobject): jmethodID {.
        cdecl.}
    FromReflectedField*: proc (env: ptr JNIEnv; field: jobject): jfieldID {.
        cdecl.}
    ToReflectedMethod*: proc (env: ptr JNIEnv; cls: jclass; methodID: jmethodID; 
                              isStatic: jboolean): jobject {.cdecl.}
    GetSuperclass*: proc (env: ptr JNIEnv; sub: jclass): jclass {.cdecl.}
    IsAssignableFrom*: proc (env: ptr JNIEnv; sub: jclass; sup: jclass): jboolean {.
        cdecl.}
    ToReflectedField*: proc (env: ptr JNIEnv; cls: jclass; fieldID: jfieldID; 
                             isStatic: jboolean): jobject {.cdecl.}
    Throw*: proc (env: ptr JNIEnv; obj: jthrowable): jint {.cdecl.}
    ThrowNew*: proc (env: ptr JNIEnv; clazz: jclass; msg: cstring): jint {.cdecl.}
    ExceptionOccurred*: proc (env: ptr JNIEnv): jthrowable {.cdecl.}
    ExceptionDescribe*: proc (env: ptr JNIEnv) {.cdecl.}
    ExceptionClear*: proc (env: ptr JNIEnv) {.cdecl.}
    FatalError*: proc (env: ptr JNIEnv; msg: cstring) {.cdecl.}
    PushLocalFrame*: proc (env: ptr JNIEnv; capacity: jint): jint {.cdecl.}
    PopLocalFrame*: proc (env: ptr JNIEnv; result: jobject): jobject {.cdecl.}
    NewGlobalRef*: proc (env: ptr JNIEnv; lobj: jobject): jobject {.cdecl.}
    DeleteGlobalRef*: proc (env: ptr JNIEnv; gref: jobject) {.cdecl.}
    DeleteLocalRef*: proc (env: ptr JNIEnv; obj: jobject) {.cdecl.}
    IsSameObject*: proc (env: ptr JNIEnv; obj1: jobject; obj2: jobject): jboolean {.
        cdecl.}
    NewLocalRef*: proc (env: ptr JNIEnv; refU: jobject): jobject {.cdecl.}
    EnsureLocalCapacity*: proc (env: ptr JNIEnv; capacity: jint): jint {.cdecl.}
    AllocObject*: proc (env: ptr JNIEnv; clazz: jclass): jobject {.cdecl.}
    NewObject*: proc (env: ptr JNIEnv; clazz: jclass; methodID: jmethodID): jobject {.
        cdecl, varargs.}
    NewObjectV*: proc (env: ptr JNIEnv; clazz: jclass; methodID: jmethodID; 
                       args: va_list): jobject {.cdecl.}
    NewObjectA*: proc (env: ptr JNIEnv; clazz: jclass; methodID: jmethodID; 
                       args: ptr jvalue): jobject {.cdecl.}
    GetObjectClass*: proc (env: ptr JNIEnv; obj: jobject): jclass {.cdecl.}
    IsInstanceOf*: proc (env: ptr JNIEnv; obj: jobject; clazz: jclass): jboolean {.
        cdecl.}
    GetMethodID*: proc (env: ptr JNIEnv; clazz: jclass; name: cstring; 
                        sig: cstring): jmethodID {.cdecl.}
    CallObjectMethod*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID): jobject {.
        cdecl, varargs.}
    CallObjectMethodV*: proc (env: ptr JNIEnv; obj: jobject; 
                              methodID: jmethodID; args: va_list): jobject {.
        cdecl.}
    CallObjectMethodA*: proc (env: ptr JNIEnv; obj: jobject; 
                              methodID: jmethodID; args: ptr jvalue): jobject {.
        cdecl.}
    CallBooleanMethod*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID): jboolean {.
        cdecl, varargs.}
    CallBooleanMethodV*: proc (env: ptr JNIEnv; obj: jobject; 
                               methodID: jmethodID; args: va_list): jboolean {.
        cdecl.}
    CallBooleanMethodA*: proc (env: ptr JNIEnv; obj: jobject; 
                               methodID: jmethodID; args: ptr jvalue): jboolean {.
        cdecl.}
    CallByteMethod*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID): jbyte {.
        cdecl, varargs.}
    CallByteMethodV*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID; 
                            args: va_list): jbyte {.cdecl.}
    CallByteMethodA*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID; 
                            args: ptr jvalue): jbyte {.cdecl.}
    CallCharMethod*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID): jchar {.
        cdecl, varargs.}
    CallCharMethodV*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID; 
                            args: va_list): jchar {.cdecl.}
    CallCharMethodA*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID; 
                            args: ptr jvalue): jchar {.cdecl.}
    CallShortMethod*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID): jshort {.
        cdecl, varargs.}
    CallShortMethodV*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID; 
                             args: va_list): jshort {.cdecl.}
    CallShortMethodA*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID; 
                             args: ptr jvalue): jshort {.cdecl.}
    CallIntMethod*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID): jint {.
        cdecl, varargs.}
    CallIntMethodV*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID; 
                           args: va_list): jint {.cdecl.}
    CallIntMethodA*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID; 
                           args: ptr jvalue): jint {.cdecl.}
    CallLongMethod*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID): jlong {.
        cdecl, varargs.}
    CallLongMethodV*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID; 
                            args: va_list): jlong {.cdecl.}
    CallLongMethodA*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID; 
                            args: ptr jvalue): jlong {.cdecl.}
    CallFloatMethod*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID): jfloat {.
        cdecl, varargs.}
    CallFloatMethodV*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID; 
                             args: va_list): jfloat {.cdecl.}
    CallFloatMethodA*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID; 
                             args: ptr jvalue): jfloat {.cdecl.}
    CallDoubleMethod*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID): jdouble {.
        cdecl, varargs.}
    CallDoubleMethodV*: proc (env: ptr JNIEnv; obj: jobject; 
                              methodID: jmethodID; args: va_list): jdouble {.
        cdecl.}
    CallDoubleMethodA*: proc (env: ptr JNIEnv; obj: jobject; 
                              methodID: jmethodID; args: ptr jvalue): jdouble {.
        cdecl.}
    CallVoidMethod*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID) {.
        cdecl, varargs.}
    CallVoidMethodV*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID; 
                            args: va_list) {.cdecl.}
    CallVoidMethodA*: proc (env: ptr JNIEnv; obj: jobject; methodID: jmethodID; 
                            args: ptr jvalue) {.cdecl.}
    CallNonvirtualObjectMethod*: proc (env: ptr JNIEnv; obj: jobject; 
                                       clazz: jclass; methodID: jmethodID): jobject {.
        cdecl, varargs.}
    CallNonvirtualObjectMethodV*: proc (env: ptr JNIEnv; obj: jobject; 
                                        clazz: jclass; methodID: jmethodID; 
                                        args: va_list): jobject {.cdecl.}
    CallNonvirtualObjectMethodA*: proc (env: ptr JNIEnv; obj: jobject; 
                                        clazz: jclass; methodID: jmethodID; 
                                        args: ptr jvalue): jobject {.cdecl.}
    CallNonvirtualBooleanMethod*: proc (env: ptr JNIEnv; obj: jobject; 
                                        clazz: jclass; methodID: jmethodID): jboolean {.
        cdecl, varargs.}
    CallNonvirtualBooleanMethodV*: proc (env: ptr JNIEnv; obj: jobject; 
        clazz: jclass; methodID: jmethodID; args: va_list): jboolean {.cdecl.}
    CallNonvirtualBooleanMethodA*: proc (env: ptr JNIEnv; obj: jobject; 
        clazz: jclass; methodID: jmethodID; args: ptr jvalue): jboolean {.cdecl.}
    CallNonvirtualByteMethod*: proc (env: ptr JNIEnv; obj: jobject; 
                                     clazz: jclass; methodID: jmethodID): jbyte {.
        cdecl, varargs.}
    CallNonvirtualByteMethodV*: proc (env: ptr JNIEnv; obj: jobject; 
                                      clazz: jclass; methodID: jmethodID; 
                                      args: va_list): jbyte {.cdecl.}
    CallNonvirtualByteMethodA*: proc (env: ptr JNIEnv; obj: jobject; 
                                      clazz: jclass; methodID: jmethodID; 
                                      args: ptr jvalue): jbyte {.cdecl.}
    CallNonvirtualCharMethod*: proc (env: ptr JNIEnv; obj: jobject; 
                                     clazz: jclass; methodID: jmethodID): jchar {.
        cdecl, varargs.}
    CallNonvirtualCharMethodV*: proc (env: ptr JNIEnv; obj: jobject; 
                                      clazz: jclass; methodID: jmethodID; 
                                      args: va_list): jchar {.cdecl.}
    CallNonvirtualCharMethodA*: proc (env: ptr JNIEnv; obj: jobject; 
                                      clazz: jclass; methodID: jmethodID; 
                                      args: ptr jvalue): jchar {.cdecl.}
    CallNonvirtualShortMethod*: proc (env: ptr JNIEnv; obj: jobject; 
                                      clazz: jclass; methodID: jmethodID): jshort {.
        cdecl, varargs.}
    CallNonvirtualShortMethodV*: proc (env: ptr JNIEnv; obj: jobject; 
                                       clazz: jclass; methodID: jmethodID; 
                                       args: va_list): jshort {.cdecl.}
    CallNonvirtualShortMethodA*: proc (env: ptr JNIEnv; obj: jobject; 
                                       clazz: jclass; methodID: jmethodID; 
                                       args: ptr jvalue): jshort {.cdecl.}
    CallNonvirtualIntMethod*: proc (env: ptr JNIEnv; obj: jobject; 
                                    clazz: jclass; methodID: jmethodID): jint {.
        cdecl, varargs.}
    CallNonvirtualIntMethodV*: proc (env: ptr JNIEnv; obj: jobject; 
                                     clazz: jclass; methodID: jmethodID; 
                                     args: va_list): jint {.cdecl.}
    CallNonvirtualIntMethodA*: proc (env: ptr JNIEnv; obj: jobject; 
                                     clazz: jclass; methodID: jmethodID; 
                                     args: ptr jvalue): jint {.cdecl.}
    CallNonvirtualLongMethod*: proc (env: ptr JNIEnv; obj: jobject; 
                                     clazz: jclass; methodID: jmethodID): jlong {.
        cdecl, varargs.}
    CallNonvirtualLongMethodV*: proc (env: ptr JNIEnv; obj: jobject; 
                                      clazz: jclass; methodID: jmethodID; 
                                      args: va_list): jlong {.cdecl.}
    CallNonvirtualLongMethodA*: proc (env: ptr JNIEnv; obj: jobject; 
                                      clazz: jclass; methodID: jmethodID; 
                                      args: ptr jvalue): jlong {.cdecl.}
    CallNonvirtualFloatMethod*: proc (env: ptr JNIEnv; obj: jobject; 
                                      clazz: jclass; methodID: jmethodID): jfloat {.
        cdecl, varargs.}
    CallNonvirtualFloatMethodV*: proc (env: ptr JNIEnv; obj: jobject; 
                                       clazz: jclass; methodID: jmethodID; 
                                       args: va_list): jfloat {.cdecl.}
    CallNonvirtualFloatMethodA*: proc (env: ptr JNIEnv; obj: jobject; 
                                       clazz: jclass; methodID: jmethodID; 
                                       args: ptr jvalue): jfloat {.cdecl.}
    CallNonvirtualDoubleMethod*: proc (env: ptr JNIEnv; obj: jobject; 
                                       clazz: jclass; methodID: jmethodID): jdouble {.
        cdecl, varargs.}
    CallNonvirtualDoubleMethodV*: proc (env: ptr JNIEnv; obj: jobject; 
                                        clazz: jclass; methodID: jmethodID; 
                                        args: va_list): jdouble {.cdecl.}
    CallNonvirtualDoubleMethodA*: proc (env: ptr JNIEnv; obj: jobject; 
                                        clazz: jclass; methodID: jmethodID; 
                                        args: ptr jvalue): jdouble {.cdecl.}
    CallNonvirtualVoidMethod*: proc (env: ptr JNIEnv; obj: jobject; 
                                     clazz: jclass; methodID: jmethodID) {.
        cdecl, varargs.}
    CallNonvirtualVoidMethodV*: proc (env: ptr JNIEnv; obj: jobject; 
                                      clazz: jclass; methodID: jmethodID; 
                                      args: va_list) {.cdecl.}
    CallNonvirtualVoidMethodA*: proc (env: ptr JNIEnv; obj: jobject; 
                                      clazz: jclass; methodID: jmethodID; 
                                      args: ptr jvalue) {.cdecl.}
    GetFieldID*: proc (env: ptr JNIEnv; clazz: jclass; name: cstring; 
                       sig: cstring): jfieldID {.cdecl.}
    GetObjectField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID): jobject {.
        cdecl.}
    GetBooleanField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID): jboolean {.
        cdecl.}
    GetByteField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID): jbyte {.
        cdecl.}
    GetCharField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID): jchar {.
        cdecl.}
    GetShortField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID): jshort {.
        cdecl.}
    GetIntField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID): jint {.
        cdecl.}
    GetLongField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID): jlong {.
        cdecl.}
    GetFloatField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID): jfloat {.
        cdecl.}
    GetDoubleField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID): jdouble {.
        cdecl.}
    SetObjectField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID; 
                           val: jobject) {.cdecl.}
    SetBooleanField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID; 
                            val: jboolean) {.cdecl.}
    SetByteField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID; 
                         val: jbyte) {.cdecl.}
    SetCharField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID; 
                         val: jchar) {.cdecl.}
    SetShortField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID; 
                          val: jshort) {.cdecl.}
    SetIntField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID; 
                        val: jint) {.cdecl.}
    SetLongField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID; 
                         val: jlong) {.cdecl.}
    SetFloatField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID; 
                          val: jfloat) {.cdecl.}
    SetDoubleField*: proc (env: ptr JNIEnv; obj: jobject; fieldID: jfieldID; 
                           val: jdouble) {.cdecl.}
    GetStaticMethodID*: proc (env: ptr JNIEnv; clazz: jclass; name: cstring; 
                              sig: cstring): jmethodID {.cdecl.}
    CallStaticObjectMethod*: proc (env: ptr JNIEnv; clazz: jclass; 
                                   methodID: jmethodID): jobject {.cdecl, 
        varargs.}
    CallStaticObjectMethodV*: proc (env: ptr JNIEnv; clazz: jclass; 
                                    methodID: jmethodID; args: va_list): jobject {.
        cdecl.}
    CallStaticObjectMethodA*: proc (env: ptr JNIEnv; clazz: jclass; 
                                    methodID: jmethodID; args: ptr jvalue): jobject {.
        cdecl.}
    CallStaticBooleanMethod*: proc (env: ptr JNIEnv; clazz: jclass; 
                                    methodID: jmethodID): jboolean {.cdecl, 
        varargs.}
    CallStaticBooleanMethodV*: proc (env: ptr JNIEnv; clazz: jclass; 
                                     methodID: jmethodID; args: va_list): jboolean {.
        cdecl.}
    CallStaticBooleanMethodA*: proc (env: ptr JNIEnv; clazz: jclass; 
                                     methodID: jmethodID; args: ptr jvalue): jboolean {.
        cdecl.}
    CallStaticByteMethod*: proc (env: ptr JNIEnv; clazz: jclass; 
                                 methodID: jmethodID): jbyte {.cdecl, varargs.}
    CallStaticByteMethodV*: proc (env: ptr JNIEnv; clazz: jclass; 
                                  methodID: jmethodID; args: va_list): jbyte {.
        cdecl.}
    CallStaticByteMethodA*: proc (env: ptr JNIEnv; clazz: jclass; 
                                  methodID: jmethodID; args: ptr jvalue): jbyte {.
        cdecl.}
    CallStaticCharMethod*: proc (env: ptr JNIEnv; clazz: jclass; 
                                 methodID: jmethodID): jchar {.cdecl, varargs.}
    CallStaticCharMethodV*: proc (env: ptr JNIEnv; clazz: jclass; 
                                  methodID: jmethodID; args: va_list): jchar {.
        cdecl.}
    CallStaticCharMethodA*: proc (env: ptr JNIEnv; clazz: jclass; 
                                  methodID: jmethodID; args: ptr jvalue): jchar {.
        cdecl.}
    CallStaticShortMethod*: proc (env: ptr JNIEnv; clazz: jclass; 
                                  methodID: jmethodID): jshort {.cdecl, varargs.}
    CallStaticShortMethodV*: proc (env: ptr JNIEnv; clazz: jclass; 
                                   methodID: jmethodID; args: va_list): jshort {.
        cdecl.}
    CallStaticShortMethodA*: proc (env: ptr JNIEnv; clazz: jclass; 
                                   methodID: jmethodID; args: ptr jvalue): jshort {.
        cdecl.}
    CallStaticIntMethod*: proc (env: ptr JNIEnv; clazz: jclass; 
                                methodID: jmethodID): jint {.cdecl, varargs.}
    CallStaticIntMethodV*: proc (env: ptr JNIEnv; clazz: jclass; 
                                 methodID: jmethodID; args: va_list): jint {.
        cdecl.}
    CallStaticIntMethodA*: proc (env: ptr JNIEnv; clazz: jclass; 
                                 methodID: jmethodID; args: ptr jvalue): jint {.
        cdecl.}
    CallStaticLongMethod*: proc (env: ptr JNIEnv; clazz: jclass; 
                                 methodID: jmethodID): jlong {.cdecl, varargs.}
    CallStaticLongMethodV*: proc (env: ptr JNIEnv; clazz: jclass; 
                                  methodID: jmethodID; args: va_list): jlong {.
        cdecl.}
    CallStaticLongMethodA*: proc (env: ptr JNIEnv; clazz: jclass; 
                                  methodID: jmethodID; args: ptr jvalue): jlong {.
        cdecl.}
    CallStaticFloatMethod*: proc (env: ptr JNIEnv; clazz: jclass; 
                                  methodID: jmethodID): jfloat {.cdecl, varargs.}
    CallStaticFloatMethodV*: proc (env: ptr JNIEnv; clazz: jclass; 
                                   methodID: jmethodID; args: va_list): jfloat {.
        cdecl.}
    CallStaticFloatMethodA*: proc (env: ptr JNIEnv; clazz: jclass; 
                                   methodID: jmethodID; args: ptr jvalue): jfloat {.
        cdecl.}
    CallStaticDoubleMethod*: proc (env: ptr JNIEnv; clazz: jclass; 
                                   methodID: jmethodID): jdouble {.cdecl, 
        varargs.}
    CallStaticDoubleMethodV*: proc (env: ptr JNIEnv; clazz: jclass; 
                                    methodID: jmethodID; args: va_list): jdouble {.
        cdecl.}
    CallStaticDoubleMethodA*: proc (env: ptr JNIEnv; clazz: jclass; 
                                    methodID: jmethodID; args: ptr jvalue): jdouble {.
        cdecl.}
    CallStaticVoidMethod*: proc (env: ptr JNIEnv; cls: jclass; 
                                 methodID: jmethodID) {.cdecl, varargs.}
    CallStaticVoidMethodV*: proc (env: ptr JNIEnv; cls: jclass; 
                                  methodID: jmethodID; args: va_list) {.cdecl.}
    CallStaticVoidMethodA*: proc (env: ptr JNIEnv; cls: jclass; 
                                  methodID: jmethodID; args: ptr jvalue) {.cdecl.}
    GetStaticFieldID*: proc (env: ptr JNIEnv; clazz: jclass; name: cstring; 
                             sig: cstring): jfieldID {.cdecl.}
    GetStaticObjectField*: proc (env: ptr JNIEnv; clazz: jclass; 
                                 fieldID: jfieldID): jobject {.cdecl.}
    GetStaticBooleanField*: proc (env: ptr JNIEnv; clazz: jclass; 
                                  fieldID: jfieldID): jboolean {.cdecl.}
    GetStaticByteField*: proc (env: ptr JNIEnv; clazz: jclass; fieldID: jfieldID): jbyte {.
        cdecl.}
    GetStaticCharField*: proc (env: ptr JNIEnv; clazz: jclass; fieldID: jfieldID): jchar {.
        cdecl.}
    GetStaticShortField*: proc (env: ptr JNIEnv; clazz: jclass; 
                                fieldID: jfieldID): jshort {.cdecl.}
    GetStaticIntField*: proc (env: ptr JNIEnv; clazz: jclass; fieldID: jfieldID): jint {.
        cdecl.}
    GetStaticLongField*: proc (env: ptr JNIEnv; clazz: jclass; fieldID: jfieldID): jlong {.
        cdecl.}
    GetStaticFloatField*: proc (env: ptr JNIEnv; clazz: jclass; 
                                fieldID: jfieldID): jfloat {.cdecl.}
    GetStaticDoubleField*: proc (env: ptr JNIEnv; clazz: jclass; 
                                 fieldID: jfieldID): jdouble {.cdecl.}
    SetStaticObjectField*: proc (env: ptr JNIEnv; clazz: jclass; 
                                 fieldID: jfieldID; value: jobject) {.cdecl.}
    SetStaticBooleanField*: proc (env: ptr JNIEnv; clazz: jclass; 
                                  fieldID: jfieldID; value: jboolean) {.cdecl.}
    SetStaticByteField*: proc (env: ptr JNIEnv; clazz: jclass; 
                               fieldID: jfieldID; value: jbyte) {.cdecl.}
    SetStaticCharField*: proc (env: ptr JNIEnv; clazz: jclass; 
                               fieldID: jfieldID; value: jchar) {.cdecl.}
    SetStaticShortField*: proc (env: ptr JNIEnv; clazz: jclass; 
                                fieldID: jfieldID; value: jshort) {.cdecl.}
    SetStaticIntField*: proc (env: ptr JNIEnv; clazz: jclass; fieldID: jfieldID; 
                              value: jint) {.cdecl.}
    SetStaticLongField*: proc (env: ptr JNIEnv; clazz: jclass; 
                               fieldID: jfieldID; value: jlong) {.cdecl.}
    SetStaticFloatField*: proc (env: ptr JNIEnv; clazz: jclass; 
                                fieldID: jfieldID; value: jfloat) {.cdecl.}
    SetStaticDoubleField*: proc (env: ptr JNIEnv; clazz: jclass; 
                                 fieldID: jfieldID; value: jdouble) {.cdecl.}
    NewString*: proc (env: ptr JNIEnv; unicode: ptr jchar; len: jsize): jstring {.
        cdecl.}
    GetStringLength*: proc (env: ptr JNIEnv; str: jstring): jsize {.cdecl.}
    GetStringChars*: proc (env: ptr JNIEnv; str: jstring; isCopy: ptr jboolean): ptr jchar {.
        cdecl.}
    ReleaseStringChars*: proc (env: ptr JNIEnv; str: jstring; chars: ptr jchar) {.
        cdecl.}
    NewStringUTF*: proc (env: ptr JNIEnv; utf: cstring): jstring {.cdecl.}
    GetStringUTFLength*: proc (env: ptr JNIEnv; str: jstring): jsize {.cdecl.}
    GetStringUTFChars*: proc (env: ptr JNIEnv; str: jstring; 
                              isCopy: ptr jboolean): cstring {.cdecl.}
    ReleaseStringUTFChars*: proc (env: ptr JNIEnv; str: jstring; chars: cstring) {.
        cdecl.}
    GetArrayLength*: proc (env: ptr JNIEnv; array: jarray): jsize {.cdecl.}
    NewObjectArray*: proc (env: ptr JNIEnv; len: jsize; clazz: jclass; 
                           init: jobject): jobjectArray {.cdecl.}
    GetObjectArrayElement*: proc (env: ptr JNIEnv; array: jobjectArray; 
                                  index: jsize): jobject {.cdecl.}
    SetObjectArrayElement*: proc (env: ptr JNIEnv; array: jobjectArray; 
                                  index: jsize; val: jobject) {.cdecl.}
    NewBooleanArray*: proc (env: ptr JNIEnv; len: jsize): jbooleanArray {.cdecl.}
    NewByteArray*: proc (env: ptr JNIEnv; len: jsize): jbyteArray {.cdecl.}
    NewCharArray*: proc (env: ptr JNIEnv; len: jsize): jcharArray {.cdecl.}
    NewShortArray*: proc (env: ptr JNIEnv; len: jsize): jshortArray {.cdecl.}
    NewIntArray*: proc (env: ptr JNIEnv; len: jsize): jintArray {.cdecl.}
    NewLongArray*: proc (env: ptr JNIEnv; len: jsize): jlongArray {.cdecl.}
    NewFloatArray*: proc (env: ptr JNIEnv; len: jsize): jfloatArray {.cdecl.}
    NewDoubleArray*: proc (env: ptr JNIEnv; len: jsize): jdoubleArray {.cdecl.}
    GetBooleanArrayElements*: proc (env: ptr JNIEnv; array: jbooleanArray; 
                                    isCopy: ptr jboolean): ptr jboolean {.cdecl.}
    GetByteArrayElements*: proc (env: ptr JNIEnv; array: jbyteArray; 
                                 isCopy: ptr jboolean): ptr jbyte {.cdecl.}
    GetCharArrayElements*: proc (env: ptr JNIEnv; array: jcharArray; 
                                 isCopy: ptr jboolean): ptr jchar {.cdecl.}
    GetShortArrayElements*: proc (env: ptr JNIEnv; array: jshortArray; 
                                  isCopy: ptr jboolean): ptr jshort {.cdecl.}
    GetIntArrayElements*: proc (env: ptr JNIEnv; array: jintArray; 
                                isCopy: ptr jboolean): ptr jint {.cdecl.}
    GetLongArrayElements*: proc (env: ptr JNIEnv; array: jlongArray; 
                                 isCopy: ptr jboolean): ptr jlong {.cdecl.}
    GetFloatArrayElements*: proc (env: ptr JNIEnv; array: jfloatArray; 
                                  isCopy: ptr jboolean): ptr jfloat {.cdecl.}
    GetDoubleArrayElements*: proc (env: ptr JNIEnv; array: jdoubleArray; 
                                   isCopy: ptr jboolean): ptr jdouble {.cdecl.}
    ReleaseBooleanArrayElements*: proc (env: ptr JNIEnv; array: jbooleanArray; 
                                        elems: ptr jboolean; mode: jint) {.cdecl.}
    ReleaseByteArrayElements*: proc (env: ptr JNIEnv; array: jbyteArray; 
                                     elems: ptr jbyte; mode: jint) {.cdecl.}
    ReleaseCharArrayElements*: proc (env: ptr JNIEnv; array: jcharArray; 
                                     elems: ptr jchar; mode: jint) {.cdecl.}
    ReleaseShortArrayElements*: proc (env: ptr JNIEnv; array: jshortArray; 
                                      elems: ptr jshort; mode: jint) {.cdecl.}
    ReleaseIntArrayElements*: proc (env: ptr JNIEnv; array: jintArray; 
                                    elems: ptr jint; mode: jint) {.cdecl.}
    ReleaseLongArrayElements*: proc (env: ptr JNIEnv; array: jlongArray; 
                                     elems: ptr jlong; mode: jint) {.cdecl.}
    ReleaseFloatArrayElements*: proc (env: ptr JNIEnv; array: jfloatArray; 
                                      elems: ptr jfloat; mode: jint) {.cdecl.}
    ReleaseDoubleArrayElements*: proc (env: ptr JNIEnv; array: jdoubleArray; 
                                       elems: ptr jdouble; mode: jint) {.cdecl.}
    GetBooleanArrayRegion*: proc (env: ptr JNIEnv; array: jbooleanArray; 
                                  start: jsize; l: jsize; buf: ptr jboolean) {.
        cdecl.}
    GetByteArrayRegion*: proc (env: ptr JNIEnv; array: jbyteArray; start: jsize; 
                               len: jsize; buf: ptr jbyte) {.cdecl.}
    GetCharArrayRegion*: proc (env: ptr JNIEnv; array: jcharArray; start: jsize; 
                               len: jsize; buf: ptr jchar) {.cdecl.}
    GetShortArrayRegion*: proc (env: ptr JNIEnv; array: jshortArray; 
                                start: jsize; len: jsize; buf: ptr jshort) {.
        cdecl.}
    GetIntArrayRegion*: proc (env: ptr JNIEnv; array: jintArray; start: jsize; 
                              len: jsize; buf: ptr jint) {.cdecl.}
    GetLongArrayRegion*: proc (env: ptr JNIEnv; array: jlongArray; start: jsize; 
                               len: jsize; buf: ptr jlong) {.cdecl.}
    GetFloatArrayRegion*: proc (env: ptr JNIEnv; array: jfloatArray; 
                                start: jsize; len: jsize; buf: ptr jfloat) {.
        cdecl.}
    GetDoubleArrayRegion*: proc (env: ptr JNIEnv; array: jdoubleArray; 
                                 start: jsize; len: jsize; buf: ptr jdouble) {.
        cdecl.}
    SetBooleanArrayRegion*: proc (env: ptr JNIEnv; array: jbooleanArray; 
                                  start: jsize; l: jsize; buf: ptr jboolean) {.
        cdecl.}
    SetByteArrayRegion*: proc (env: ptr JNIEnv; array: jbyteArray; start: jsize; 
                               len: jsize; buf: ptr jbyte) {.cdecl.}
    SetCharArrayRegion*: proc (env: ptr JNIEnv; array: jcharArray; start: jsize; 
                               len: jsize; buf: ptr jchar) {.cdecl.}
    SetShortArrayRegion*: proc (env: ptr JNIEnv; array: jshortArray; 
                                start: jsize; len: jsize; buf: ptr jshort) {.
        cdecl.}
    SetIntArrayRegion*: proc (env: ptr JNIEnv; array: jintArray; start: jsize; 
                              len: jsize; buf: ptr jint) {.cdecl.}
    SetLongArrayRegion*: proc (env: ptr JNIEnv; array: jlongArray; start: jsize; 
                               len: jsize; buf: ptr jlong) {.cdecl.}
    SetFloatArrayRegion*: proc (env: ptr JNIEnv; array: jfloatArray; 
                                start: jsize; len: jsize; buf: ptr jfloat) {.
        cdecl.}
    SetDoubleArrayRegion*: proc (env: ptr JNIEnv; array: jdoubleArray; 
                                 start: jsize; len: jsize; buf: ptr jdouble) {.
        cdecl.}
    RegisterNatives*: proc (env: ptr JNIEnv; clazz: jclass; 
                            methods: ptr JNINativeMethod; nMethods: jint): jint {.
        cdecl.}
    UnregisterNatives*: proc (env: ptr JNIEnv; clazz: jclass): jint {.cdecl.}
    MonitorEnter*: proc (env: ptr JNIEnv; obj: jobject): jint {.cdecl.}
    MonitorExit*: proc (env: ptr JNIEnv; obj: jobject): jint {.cdecl.} #jint (JNICALL *GetJavaVM)
                                                                       #      (JNIEnv *env, JavaVM **vm);
    GetStringRegion*: proc (env: ptr JNIEnv; str: jstring; start: jsize; 
                            len: jsize; buf: ptr jchar) {.cdecl.}
    GetStringUTFRegion*: proc (env: ptr JNIEnv; str: jstring; start: jsize; 
                               len: jsize; buf: cstring) {.cdecl.}
    GetPrimitiveArrayCritical*: proc (env: ptr JNIEnv; array: jarray; 
                                      isCopy: ptr jboolean): pointer {.cdecl.}
    ReleasePrimitiveArrayCritical*: proc (env: ptr JNIEnv; array: jarray; 
        carray: pointer; mode: jint) {.cdecl.}
    GetStringCritical*: proc (env: ptr JNIEnv; string: jstring; 
                              isCopy: ptr jboolean): ptr jchar {.cdecl.}
    ReleaseStringCritical*: proc (env: ptr JNIEnv; string: jstring; 
                                  cstring: ptr jchar) {.cdecl.}
    NewWeakGlobalRef*: proc (env: ptr JNIEnv; obj: jobject): jweak {.cdecl.}
    DeleteWeakGlobalRef*: proc (env: ptr JNIEnv; refU: jweak) {.cdecl.}
    ExceptionCheck*: proc (env: ptr JNIEnv): jboolean {.cdecl.}
    NewDirectByteBuffer*: proc (env: ptr JNIEnv; address: pointer; 
                                capacity: jlong): jobject {.cdecl.}
    GetDirectBufferAddress*: proc (env: ptr JNIEnv; buf: jobject): pointer {.
        cdecl.}
    GetDirectBufferCapacity*: proc (env: ptr JNIEnv; buf: jobject): jlong {.
        cdecl.}               # New JNI 1.6 Features 
    GetObjectRefType*: proc (env: ptr JNIEnv; obj: jobject): jobjectRefType {.
        cdecl.}

  JNIEnv* = ptr JNINativeInterface_u

#
#  We use inlined functions for C++ so that programmers can write:
# 
#     env->FindClass("java/lang/String")
# 
#  in C++ rather than:
# 
#     (*env)->FindClass(env, "java/lang/String")
# 
#  in C.
# 

type 
  JNIEnv_uu* {.pure, final.} = object 
    functions*: ptr JNINativeInterface_u

  JavaVMOption* {.pure, final.} = object 
    optionString*: cstring
    extraInfo*: pointer

  JavaVMInitArgs* {.pure, final.} = object 
    version*: jint
    nOptions*: jint
    options*: ptr JavaVMOption
    ignoreUnrecognized*: jboolean

  JavaVMAttachArgs* {.pure, final.} = object 
    version*: jint
    name*: cstring
    group*: jobject


# These will be VM-specific. 

const 
  JDK1_2* = true
  JDK1_4* = true

# End VM-specific. 

type 
  JNIInvokeInterface_u* {.pure, final.} = object 
    reserved0*: pointer
    reserved1*: pointer
    reserved2*: pointer
    DestroyJavaVM*: proc (vm: ptr JavaVM): jint {.cdecl.}
    AttachCurrentThread*: proc (vm: ptr JavaVM; penv: ptr pointer; args: pointer): jint {.
        cdecl.}
    DetachCurrentThread*: proc (vm: ptr JavaVM): jint {.cdecl.}
    GetEnv*: proc (vm: ptr JavaVM; penv: ptr pointer; version: jint): jint {.
        cdecl.}
    AttachCurrentThreadAsDaemon*: proc (vm: ptr JavaVM; penv: ptr pointer; 
                                        args: pointer): jint {.cdecl.}

  JavaVM* = ptr JNIInvokeInterface_u
  JavaVM_uu* {.pure, final.} = object 
    functions*: ptr JNIInvokeInterface_u


proc JNI_GetDefaultJavaVMInitArgs*(args: pointer): jint {.cdecl, 
    importc: "JNI_GetDefaultJavaVMInitArgs", dynlib: libjava.}
proc JNI_CreateJavaVM*(pvm: ptr ptr JavaVM; penv: ptr pointer; args: pointer): jint {.
    cdecl, importc: "JNI_CreateJavaVM", dynlib: libjava.}
proc JNI_GetCreatedJavaVMs*(a2: ptr ptr JavaVM; a3: jsize; a4: ptr jsize): jint {.
    cdecl, importc: "JNI_GetCreatedJavaVMs", dynlib: libjava.}
# Defined by native libraries. 
#JNIEXPORT jint JNICALL
#  JNI_OnLoad(JavaVM *vm, void *reserved);
#
#JNIEXPORT void JNICALL
#JNI_OnUnload(JavaVM *vm, void *reserved);

const 
  JNI_VERSION_1_1* = 0x00010001
  JNI_VERSION_1_2* = 0x00010002
  JNI_VERSION_1_4* = 0x00010004
  JNI_VERSION_1_6* = 0x00010006
