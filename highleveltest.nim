import wrapper_java_lang_System
import wrapper_java_lang_String
import wrapper_java_lang_Thread
import wrapper_java_lang_Class
import jtypedefs
import java
import javatools

defaultJVM = newJVM()

let result = java_lang_System_static.currentTimeMillis()
let year = (float(result) / 1000 / 3600 / 24 / 365.2) + 1970.0
echo "Current year is: ", year.int

java_lang_Thread_static.dumpStack()
echo "sleep start"
java_lang_Thread_static.sleep(300)
echo "sleep end"

let r = java_lang_Thread_static.getAllStackTraces()

let mystr = valueOf(java_lang_String_Static, false)
echo mystr.hashCode
let containResult = mystr.startsWith(mystr)
echo containResult

echo mystr
