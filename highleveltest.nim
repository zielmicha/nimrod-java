import wrapper_java_lang_System
import wrapper_java_lang_String
import wrapper_java_lang_Thread
import wrapper_java_lang_Class
import jtypedefs
import java

defaultJVM = newJVM()

let result = java_lang_System_static.currentTimeMillis()
let year = (float(result) / 1000 / 3600 / 24 / 365.2) + 1970.0
echo "Current year is: ", year.int

java_lang_Thread_static.dumpStack()
echo "sleep start"
java_lang_Thread_static.sleep(1000)
echo "sleep end"

let r = java_lang_Thread_static.getAllStackTraces()

#java_lang_Thread_static.setDefaultUncaughtExceptionHandler()

#discard valueOf(java_lang_System_Static, java_lang_Object(nil))
#discard forName(java_lang_Class_Static, java_lang_String(nil))
