import osproc
import streams
import strutils
import tables
import re

type
  TClassInfo* = Tuple[name: string]
  TThingKind* = enum
    javaMethod,
    javaField,
    javaConstructor
    javaSpecial
  TThingInfo* = Tuple[
    name: string,
    kind: TThingKind,
    isPublic: bool,
    isProtected: bool,
    isStatic: bool
  ]

proc maybeStripStart(a: var string, start: string): bool =
  if a.startsWith(start):
    a = a[start.len..(a.len-1)]
    return true
  else:
    return false

proc stripFirstWord(a: var string): bool =
  let loc = a.find(" ")
  if loc == -1:
    return false
  else:
    a = a[loc+1..a.len-1]
    return true

proc rawJavap(name: string): auto =
  let p = osproc.startProcess("/usr/bin/javap", ".", ["-s", name])
  return p.outputStream

proc parseClassInfo(line: string): TClassInfo =
  nil

proc `$`(info: TThingInfo): string =
  "JavaThing[type=$1, name=$2, static=$3]" % [$info.kind, info.name, $info.isStatic]

proc parseJavaDecl(line: string): TThingInfo =
  var rest = line[0..line.len - 2]
  let isPublic = rest.maybeStripStart("public ")
  let isProtected = rest.maybeStripStart("protected ")
  let isStatic = rest.maybeStripStart("static ")
  discard rest.maybeStripStart("final ")

  var kind = javaMethod
  var name: string
  if not rest.stripFirstWord():
    if rest != "{}":
      kind = javaConstructor
    else:
      kind = javaSpecial
    name = "<constructor>"
  else:
    let nameMatch = rest.matchLen(re"^\w+")
    assert nameMatch != -1

    name = rest[0..nameMatch-1]
    rest = rest[nameMatch..rest.len-1]
    if rest == "":
      kind = javaField

  return (name, kind, isPublic, isProtected, isStatic)

proc parseSig(line): string =
  string(line).split(':')[1].strip

iterator javap*(name: string): Tuple[decl: TThingInfo, sig: string] =
  let input = rawJavap(name)
  var line: TaintedString = ""
  # discard 'Compiled from "Foobar.java"'
  discard input.readLine(line)
  #
  discard input.readLine(line)
  let classInfo = parseClassInfo(line)
  while input.readLine(line):
    if line == "}":
      break
    # like: public boolean isEmpty();
    let javaDecl = parseJavaDecl(line)
    discard input.readLine(line)
    # "  Signature: jnisig"
    let sig = parseSig(line)
    yield (javaDecl, sig)

when isMainModule:
  for decl, sig in javap("java.lang.String"):
    echo decl, " ", sig
