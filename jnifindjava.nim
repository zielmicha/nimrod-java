
proc findJava*: string =
  "/usr/lib/jvm/java-6-openjdk-amd64"

proc findJavaLib*: string =
  findJava() & "/jre/lib/amd64/server/libjvm.so"

proc findJavaInclude*: string =
  findJava() & "/include/"

const libjava* = findJavaLib()
