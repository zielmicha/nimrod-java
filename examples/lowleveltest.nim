import jni
import jni_md

var jvm: ptr JavaVM
var env: ptr JNIEnv

var vmArgs: JavaVMInitArgs
var option: JavaVMOption
option.optionString = "-Djava.class.path=."

vmArgs.version = jint(JNI_VERSION_1_6)
vmArgs.nOptions = 1
vmArgs.options = addr(option)
vmArgs.ignoreUnrecognized = true

template discardzero(x: expr): expr =
  let result = x
  assert result == 0

discardzero JNI_CreateJavaVM(addr(jvm), cast[ptr pointer](addr(env)), addr(vmArgs))

let System = env.FindClass(env, "java/lang/System")
assert System != nil
let currentTimeMillis = env.GetStaticMethodID(env, System, "currentTimeMillis", "()J")
assert currentTimeMillis != nil
let result = env.CallStaticLongMethod(env, System, currentTimeMillis)
let year = (float(result) / 1000 / 3600 / 24 / 365.2) + 1970.0
echo "Current year is: ", year.int

discardzero jvm.DestroyJavaVM(jvm)
