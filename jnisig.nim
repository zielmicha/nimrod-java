## Module for parsing JNI signatures like (Ljava/lang/CharSequence;)Z
import strutils
import tables

type TJNITypeKind* = enum
  jniprimitive, jniarray, jniobject

type
  PJNIType* = ref TJNIType
  TJNIType = object
    case kind*: TJNITypeKind
    of jniprimitive: typeName*: string
    of jniarray: elementType*: PJNIType
    of jniobject: className*: string

let jniPrimitives = {
  'Z': "boolean",
  'B': "byte",
  'C': "char",
  'D': "double",
  'F': "float",
  'I': "int",
  'J': "long",
  'S': "short",
  'V': "void",
}.toTable

proc splitCall(sig: string): tuple[args: string, ret: string] =
  assert sig[0] == '('
  let spl = sig[1..sig.len-1].split(')')
  assert spl.len == 2
  return (spl[0], spl[1])

proc parsePart(sig: var string): PJNIType =
  new(result)
  if sig.len == 0:
    return nil
  elif hasKey(jniPrimitives, sig[0]):
    result.kind = jniprimitive
    result.typeName = jniPrimitives[sig[0]]
    sig = sig.substr(1)
  elif sig[0] == '[':
    result.kind = jniarray
    sig = sig.substr(1)
    result.elementType = parsePart(sig)
  elif sig[0] == 'L':
    let nameEnd = sig.find(';', start=1)
    assert nameEnd != -1
    result.kind = jniobject
    result.className = sig[1..nameEnd-1]
    sig = sig[nameEnd+1..sig.len-1]
  else:
    assert False

proc parseOne*(sig: string): PJNIType =
  var sigMut = sig
  result = parsePart(sigMut)
  assert sigMut.len == 0

proc jnisigFromClassname*(name: string): PJNIType =
  return parseOne("L$1;" % name)

proc parseMany(sig: string): seq[PJNIType] =
  result = @[]
  var sigMut = sig
  while sigMut.len != 0:
    result.add(parsePart(sigMut))

proc parseCall*(sig: string): tuple[args: seq[PJNIType], ret: PJNIType] =
  let raw = splitCall(sig)
  result.args = parseMany(raw.args)
  result.ret = parseOne(raw.ret)

when isMainModule:
  "(Ljava/lang/CharSequence;I[ZI)Z".parseCall.repr.echo
