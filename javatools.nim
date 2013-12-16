import jtypedefs
import java

proc `$`*(obj: java_lang_String): string =
  let asInstance = JInstance(obj)
  copyStringUTF8(asInstance.jvm, asInstance.obj)
