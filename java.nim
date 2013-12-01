import jni
import jni_md
import macros

type
  TJVM* = Tuple[jvm: ptr JavaVM, env: ptr JNIEnv]
  TJClass* = Tuple[env: ptr JNIEnv, class: jclass, name: string]

proc discardzero(x: int) =
  assert x == 0

proc newJVM*(classpath: string = ""): TJVM =
  var jvm: ptr JavaVM
  var env: ptr JNIEnv

  var vmArgs: JavaVMInitArgs
  var option: JavaVMOption
  option.optionString = "-Djava.class.path=" & classpath

  vmArgs.version = jint(JNI_VERSION_1_6)
  vmArgs.nOptions = 1
  vmArgs.options = addr(option)
  vmArgs.ignoreUnrecognized = true

  discardzero JNI_CreateJavaVM(addr(jvm), cast[ptr pointer](addr(env)), addr(vmArgs))
  return (jvm, env)

proc findClass(jvm: TJVM, name: string): TJClass =
  let class = jvm.env.FindClass(jvm.env, name)
  assert class != nil
  return (jvm.env, class, name)

proc `$`(class: TJClass): string =
  "JavaClass " & class.name
