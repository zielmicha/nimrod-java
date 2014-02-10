import jtypedefs
import java
import macros
import jnicommon
import strutils

export java.newJVM
export java.defaultJVM

macro importJava*(name: string): stmt =
  let name = name.strVal
  let nameFragments = name.split({'/', '.'})
  let shortName = nameFragments[nameFragments.len-1].mangleProcName
  parseStmt("""
when not defined(jtypedefs):
  import jtypedefs
import wrapper_$1
when not defined($2):
  type $2 = $1
when not defined($2_static):
  template $2_static: $1_statictype = $1_static
""" % [classnameToId(name), shortName])

proc `$`*(obj: java_lang_String): string =
  let asInstance = JInstance(obj)
  copyStringUTF8(asInstance.jvm, asInstance.obj)
