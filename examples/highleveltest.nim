import javatools
importJava "java.lang.System"
importJava "java.lang.String"
importJava "java.lang.Thread"
importJava "java.lang.Class"
importJava "java.lang.Object"

defaultJVM = newJVM()

let result = System_static.currentTimeMillis()
let year = (float(result) / 1000 / 3600 / 24 / 365.2) + 1970.0
echo "Current year is: ", year.int

Thread_static.dumpStack()
echo "sleep start"
Thread_static.sleep(300)
echo "sleep end"

let r = Thread_static.getAllStackTraces()

let mystr = valueOf(String_static, false)
echo mystr.hashCode
let containResult = mystr.startsWith(mystr)
echo containResult

echo mystr

# test converters
mystr.notifyAll()
echo "notifiedAll!"
