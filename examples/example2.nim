import javatools
importJava "java.lang.System"
importJava "java.util.Vector"

# initialize new JVM
defaultJVM = newJVM()

let currtime = System_static.currentTimeMillis()
echo "Current time in milliseconds is: ", $currtime

var myVector = Vector_static.newInstance()
echo ($(myVector.java_lang_Object))
# add vector to itself!
discard myVector.add(java_lang_Object(myVector))
let myVectorAgain = myVector.get(0)

let f = stringToJavaString("foobar")
echo "here you have java string: ", f
