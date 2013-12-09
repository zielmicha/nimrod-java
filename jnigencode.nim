import strutils
import sequtils
import javap
import jnisig

proc classnameToId*(name: string): string
proc mangleProcName(name: string): string

proc javaReturnMethod(t: PJNIType): string
proc javaCastArgs(t: seq[PJNIType]): string
proc javaCastResult(def: PJNIType, name: string): string
proc javaToNimArgs(t: seq[PJNIType]): string
proc javaToNimType(t: PJNIType): string

template addln(data: string): stmt =
  result.add(data)
  result.add("\n")

proc generateJavaClass*(target: string): string =
  result = ""
  let mangled = target.classnameToId
  addln "type $1* = distinct JInstance" % [mangled]
  # This needs to be thread-local var, as JNI env is single threaded.
  # However, this means that threads may leak memory.
  addln "var cls_$1* {.threadvar.}: TJClass" % [mangled, target]
  # just a marker for compile-time dispatch
  addln "type $1_statictype* = distinct int" % [mangled]
  addln "var $1_static*: $1_statictype" % [mangled]

proc generateJavaMethod*(target: string,
                         decl: TThingInfo,
                         usedTypes: var seq[PJNIType]): string =
  result = ""
  let sig = decl.sig
  let mangled = target.classnameToId
  let (argSig, retSig) = parseCall(sig)
  usedTypes.add(retSig)
  for arg in argSig:
    usedTypes.add(arg)
  let argDef = javaToNimArgs(argSig)
  let retDef = javaToNimType(retSig)
  let javaCastArgs = javaCastArgs(argSig)
  let returnMethod = javaReturnMethod(retSig)
  let returnsVoid = returnMethod == "Void"
  if decl.isStatic:
    addln "proc $1*(jself: $2_statictype, $3): $4 =" % [
      mangleProcName(decl.name), mangled, argDef, retDef]
    addln "  if cls_$1.class == nil:" % [mangled]
    addln "    cls_$1 = FindClass(defaultJVM, \"$2\")" % [mangled, target]
    addln "  let class = cls_$1" % [mangled]
    addln "  let env = class.env"
    addln "  discard env.PushLocalFrame(env, 16)"
    # TODO: call GetMethodID only once for each method
    addln "  let methodid = env.GetStaticMethodID(env, class.class, \"$1\", \"$2\")" % [
      decl.name, sig]
    addln "  $1env.CallStatic$2Method(env, class.class, methodid, $3)" % [
      if returnsVoid: "" else: "let ret = ",
      returnMethod, javaCastArgs]
    if not returnsVoid:
      addln "  result = $1" % [javaCastResult(retSig, "ret")]
    addln "  discard env.PopLocalFrame(env, nil)"

proc generateClassThings*(info: TClassInfo,
                          usedTypes: var seq[PJNIType]): string =
  result = ""
  for thing in info.things:
    if not thing.isPublic:
      continue
    if thing.kind == javaMethod:
      addln generateJavaMethod(info.name, thing, usedTypes)

proc classnameToId(name: string): string =
  name.replace('/', '_').replace('$', '_').replace("__", "")

const nimrodKeywords = ["addr", "and", "as", "asm", "atomic", "bind", "block", "break", "case", "cast", "const", "continue", "converter", "discard", "distinct", "div", "do", "elif", "else", "end", "enum", "except", "export", "finally", "for", "from", "generic", "if", "import", "in", "include", "interface", "is", "isnot", "iterator", "lambda", "let", "macro", "method", "mixin", "mod", "nil", "not", "notin", "object", "of", "or", "out", "proc", "ptr", "raise", "ref", "return", "shared", "shl", "shr", "static", "template", "try", "tuple", "type", "var", "when", "while", "with", "without", "xor", "yield"]

proc mangleProcName(name: string): string =
  if name in nimrodKeywords:
    return "j" & name
  else:
    return name

proc javaReturnMethod(t: PJNIType): string =
  case t.kind:
    of jniprimitive: return t.typeName.capitalize
    else: return "Object"

proc javaCastArgs(t: seq[PJNIType]): string =
  var result: seq[string] = @[]
  var i = 0
  for arg in t:
    i += 1
    let name = ("arg$1" % $i)
    case arg.kind
    of jniprimitive:
      result.add("j$1($2)" % [arg.typeName, name])
    of jniobject:
      result.add("JInstance($1).obj" % name)
    of jniarray:
      result.add("seqToJArray(defaultJVM, $1)" % [name])
  result.join(", ")

proc javaCastResult(def: PJNIType, name: string): string =
  case def.kind
    of jniprimitive:
      result = name
    of jniobject:
      result = "$2(packJObject(defaultJVM, $1))" % [name, def.className.classnameToId]
    of jniarray:
      result = "jarrayToSeq(defaultJVM, $1)" % [name]

proc javaToNimArgs(t: seq[PJNIType]): string =
  var result: seq[string] = @[]
  var i = 0
  for arg in t:
    i += 1
    result.add("arg$1: $2" % [$i, javaToNimType(arg)])
  result.join(", ")

proc javaToNimType(t: PJNIType): string =
  case t.kind
  of jniprimitive:
    case t.typeName
      of "double", "float", "char":
        return "jni.j" & t.typeName
      else:
        return "jni_md.j" & t.typeName
  of jniobject:
    return t.className.classnameToId
  of jniarray:
    return "seq[$1]" % [javaToNimType(t.elementType)]
