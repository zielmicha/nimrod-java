import strutils
import sequtils
import javap
import jnisig
import jnicommon

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
  addln "type $1_statictype* = object" % [mangled]
  addln "  fakefield: int"
  addln "var $1_static*: $1_statictype" % [mangled]

proc generateClassConverter*(src: string, dst: string): string =
  "converter jconvert_from_$1_to_$2*(x: $1): $2 = $2(JInstance(x))\n" % [classnameToId(src), classnameToId(dst)]

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
  let isStatic = decl.isStatic
  let dispatchType = if isStatic: mangled & "_statictype"
                     else: mangled
  addln "proc $1*(jself: $2, $3): $4 =" % [
    mangleProcName(decl.name), dispatchType, argDef, retDef]

  addln "  if cls_$1.class == nil:" % [mangled]
  addln "    cls_$1 = FindClass(defaultJVM, \"$2\")" % [mangled, target]
  addln "  let class = cls_$1" % [mangled]
  addln "  let env = class.env"
  addln "  discard env.PushLocalFrame(env, 16)"
  # TODO: call GetMethodID only once for each method
  let staticWord = if isStatic: "Static" else: ""
  addln "  let methodid = env.Get$3MethodID(env, class.class, \"$1\", \"$2\")" % [
    decl.name, sig, staticWord]
  addln "  $1env.Call$4$2Method(env, $5, methodid, $3)" % [
    if returnsVoid: "" else: "let ret = ",
    returnMethod, javaCastArgs, staticWord,
    if isStatic: "class.class" else: "JInstance(jself).obj"]
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
      result = "jarrayToSeq[$2](defaultJVM, $1)" % [name, javaToNimType(def.elementType)]

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
