type
  jboolean* = bool
  jbyte* {.importc, header: "jni_md.h".} = int8
  jshort* {.importc, header: "jni_md.h".} = int16
  jint* {.importc, header: "jni_md.h".} = int32
  jlong* {.importc, header: "jni_md.h".} = int64
  jvoid* = void

type
  # fake declaration - don't use
  va_list* = distinct pointer
