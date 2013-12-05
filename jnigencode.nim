import strutils
import sequtils
import javap
import jnisig

proc classnameToId(name: string): string

proc javaReturnMethod(t: PJNIType): string
proc javaCastArgs(t: seq[PJNIType]): string
proc javaCastResult(def: PJNIType, name: string): string
proc javaToNimArgs(t: seq[PJNIType]): string
proc javaToNimType(t: PJNIType): string

proc generateJavaClass(target: string): string =
  result = ""
  let mangled = target.classnameToId
  add result, "type $1* = distinct JInstance" % [mangled]
  # This needs to be thread-local var, as JNI env is single threaded.
  # However, this means that threads may leak memory.
  add result, "var cls_$1 {.threadvar.}" % [mangled, target]
  add result, "proc GetJClass*(TypeDesc[$1]): TJClass =" % [mangled]
  add result,  "  if cls_$1 == nil:" % [mangled]
  add result, "    cls_$1 = defaultJVM.FindClass(\"$2\")" % [mangled, target]
  add result, "  return cls_$1" % [mangled]

proc generateJavaMethod(target: string,
                        decl: TThingInfo, sig: string): string =
  result = ""
  let mangled = target.classnameToId
  let (argSig, retSig) = parseCall(sig)
  let argDef = javaToNimArgs(argSig)
  let retDef = javaToNimType(retSig)
  let javaCastArgs = javaCastArgs(argSig)
  let returnMethod = javaReturnMethod(retSig)
  let returnsVoid = returnMethod == "void"
  if decl.isStatic:
    add result, "proc $1*(jself: TypeDesc[$2], $3): $4 =" % [
      decl.name, mangled, argDef, retDef]
    add result, "  let class = GetJClass($1)" % [mangled]
    add result, "  let env = class.env"
    add result, "  env.PushLocalFrame(env, 16)"
    # TODO: call GetMethodID only once for each method
    add result, "  let method = env.GetStaticMethodID(env, System, \"$1\", \"$2\")" % [
      decl.name, sig]
    add result, "  $1env.CallStatic$2Method(env, class, method, $3)" % [
      if returnsVoid: "" else: "let ret = ",
      returnMethod, javaCastArgs]
    if not returnsVoid:
      add result, "  result = $2($1)" % [javaCastResult(retSig, "ret"), mangled]
    add result, "  env.PopLocalFrame(env)"

proc classnameToId(name: string): string =
  name.replace('/', '_').replace('$', '_')

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
      result = "packJObject($1)" % [name]
    of jniarray:
      result = "jarrayToSeq($1)" % [name]

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
    return t.typeName
  of jniobject:
    return t.className.classnameToId
  of jniarray:
    return "seq[$1]" % [javaToNimType(t.elementType)]
