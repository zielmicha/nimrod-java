{.noForward: true.}
import strutils
import sequtils
import javap
import jnisig

proc classnameToId(name: string): string =
  name.replace('/', '_')

proc generateForClass(target: string) =
  generateJavaClass(target)
  for decl, sig in target.javap:
    if decl.kind == javaMethod:
      generateJavaMethod(target, decl, sig)

proc generateJavaClass(target: string) =
  let mangled = target.classnameToId
  echo "type $1* = distinct JInstance" % [mangled]
  # This needs to be thread-local var, as JNI env is single threaded.
  # However, this means that threads may leak memory.
  echo "var cls_$1 {.threadvar.}" % [mangled, target]
  echo "proc GetJClass*(TypeDesc[$1]): TJClass =" % [mangled]
  echo "  if cls_$1 == nil:" % [mangled]
  echo "    cls_$1 = defaultJVM.FindClass(\"$2\")" % [mangled, target]
  echo "  return cls_$1" % [mangled]

proc generateJavaMethod(target: string,
                        decl: TThingInfo, sig: string) =
  #echo "#", decl, " sig: ", sig
  let mangled = target.classnameToId
  let (argSig, retSig) = parseCall(sig)
  let argDef = javaToNimArgs(argSig)
  let retDef = javaToNimType(retSig)
  let javaCastArgs = javaCastArgs(argSig)
  let returnMethod = javaReturnMethod(retSig)
  let returnsVoid = returnMethod == "void"
  if decl.isStatic:
    echo "proc $1*(jself: TypeDesc[$2], $3): $4 =" % [
      decl.name, mangled, argDef, retDef]
    echo "  let class = GetJClass($1)" % [mangled]
    echo "  let env = class.env"
    echo "  env.PushLocalFrame(env, 16)"
    # TODO: call GetMethodID only once for each method
    echo "  let method = env.GetStaticMethodID(env, System, \"$1\", \"$2\")" % [decl.name, sig]
    echo "  $1env.CallStatic$2Method(env, class, method, $3)" % [
      if returnsVoid: "" else: "let ret = ",
      returnMethod, javaCastArgs]
    if not returnsVoid:
      echo "  result = $2($1)" % [javaCastResult(retSig, "ret"), mangled]
    echo "  env.PopLocalFrame(env)"

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

when isMainModule:
  generateForClass("java/lang/String")
