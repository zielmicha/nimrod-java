import javatools
importJava "java.lang.System"

# initialize new JVM
defaultJVM = newJVM()

let currtime = System_static.currentTimeMillis()
echo "Current time in milliseconds is: ", $currtime
