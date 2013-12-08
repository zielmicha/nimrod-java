import wrapper_java_lang_System
import jtypedefs
import java

defaultJVM = newJVM()

let result = currentTimeMillis(java_lang_System_static)
let year = (float(result) / 1000 / 3600 / 24 / 365.2) + 1970.0
echo "Current year is: ", year.int
