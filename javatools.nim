import jtypedefs
import java
import macros
import jnicommon
import strutils

export java.newJVM
export java.defaultJVM

macro importJava*(name: string): stmt =
  let name = name.strVal
  parseStmt("""
when not defined(jtypedefs):
  import jtypedefs
import wrapper_$1""" % classnameToId(name))

proc `$`*(obj: java_lang_String): string =
  let asInstance = JInstance(obj)
  copyStringUTF8(asInstance.jvm, asInstance.obj)
