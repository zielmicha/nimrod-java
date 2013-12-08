import jni
import jni_md
import macros

type
  TJVM* = Tuple[jvm: ptr JavaVM, env: ptr JNIEnv]
  TJClass* = Tuple[env: ptr JNIEnv, class: jclass, name: string]
  TJInstance = object
    obj*: jobject
    jvm*: TJVM
  JInstance* = ref TJInstance

var defaultJVM* {.threadvar.}: TJVM

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

proc destruct(instance: JInstance) =
  echo "Destroying Java!"

proc findClass*(jvm: TJVM, name: string): TJClass =
  let class = jvm.env.FindClass(jvm.env, name)
  assert class != nil
  return (jvm.env, class, name)

proc newInstanceRaw(): JInstance =
  new(result, destruct)

proc packJObject*(jvm: TJVM, obj: jobject): JInstance =
  ## Given local or global jobject, create global reference for it,
  ## and pack it into JInstance, so it can be safely managed
  let env = jvm.env
  # pin obj as global reference
  let globalRef = env.NewGlobalRef(env, obj)
  result = newInstanceRaw()
  result.obj = globalRef
  result.jvm = jvm

proc seqToJArray*[T](jvm: TJVM, s: seq[T]): jobject =
  assert False

proc jarrayToSeq*(jvm: TJVM, s: jobject): auto =
  assert False

proc `$`(class: TJClass): string =
  "JavaClass " & class.name

when isMainModule:
  defaultJVM = newJVM()
  let strclass = findClass(defaultJVM, "java.lang.String")
  var v = newInstanceRaw()
  v.repr.echo
  v = nil
  GC_fullCollect()
