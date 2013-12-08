
proc findJava*: string =
  "/usr/lib/jvm/java-6-openjdk-amd64/jre/lib/amd64/jamvm/libjvm.so"

const libjava* = findJava()

proc findJavaInclude*: string =
  "/usr/lib/jvm/java-6-openjdk-amd64/include/"
