import javatools
import os
import posix
import strutils

importJava "java.lang.System"
defaultJVM = newJVM()

var oneKilobyte = ""
for i in 1..1000: oneKilobyte.add(" ")

for j in 1..100:
  discard execShellCmd("cat /proc/$1/status | grep VmRSS" % [$getpid()])
  for i in 1..100000:
    let jval = stringToJavaString(oneKilobyte)
