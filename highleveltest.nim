import javatools
importJava "java.lang.System"
importJava "java.lang.String"
importJava "java.lang.Thread"
importJava "java.lang.Class"

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
