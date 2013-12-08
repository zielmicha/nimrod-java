import osproc
import streams
import strutils
import tables
import re
import zipfiles
import os
import md5

type
  TThingKind* = enum
    javaMethod,
    javaField,
    javaConstructor
    javaSpecial
  TThingInfo* = object
    name*: string
    kind*: TThingKind
    isPublic*: bool
    isProtected*: bool
    isStatic*: bool
    sig*: string
  TClassInfo* = object
    name*: string
    isPublic*: bool
    things*: seq[TThingInfo]

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

proc parseClassInfo(line: string): TClassInfo =
  var rest = line
  result.isPublic = rest.maybeStripStart("public ")

proc `$`(info: TThingInfo): string =
  "JavaThing[type=$1, name=$2, static=$3]" % [$info.kind, info.name, $info.isStatic]

proc parseJavaDecl(line: string): TThingInfo =
  var rest = line[0..line.len - 2].strip()
  let throwsDeclLoc = rest.find("throws ")
  if throwsDeclLoc != -1:
    rest = rest[0..throwsDeclLoc-1].strip()
  result.isPublic = rest.maybeStripStart("public ")
  result.isProtected = rest.maybeStripStart("protected ")
  result.isStatic = rest.maybeStripStart("static ")
  discard rest.maybeStripStart("final ")
  discard rest.maybeStripStart("synchronized ")
  discard rest.maybeStripStart("native ")
  discard rest.maybeStripStart("strictfp ")

  result.kind = javaMethod
  if not rest.stripFirstWord():
    if rest != "{}":
      result.kind = javaConstructor
    else:
      result.kind = javaSpecial
    result.name = "<constructor>"
  else:
    let nameMatch = rest.matchLen(re"^(\w|\$)+")
    assert nameMatch != -1, "Failed to parse $1, rest: $2" % [line, rest]

    result.name = rest[0..nameMatch-1]
    rest = rest[nameMatch..rest.len-1]
    if rest == "":
      result.kind = javaField

proc parseSig(line): string =
  string(line).split(':')[1].strip

proc readAll(stream: PStream): string =
  result = ""
  const bufsize = 4096
  while true:
    var buff = stream.readStr(bufsize)
    if buff.len == 0:
      break
    result.add(buff)

proc startsWith(path: string, prefixes: openarray[string]): bool =
  for prefix in prefixes:
    if path.startsWith(prefix):
      return true
  return false

proc cachedRawJavap(name: string, jarpath: string, jarmd5: string): TFile =
  let path = "nimcache" / "javap" / getMD5(jarmd5 / name)
  var inFile: TFile
  if not inFile.open(path):
    echo "javap $1" % name
    let process = osproc.startProcess("javap", ".",
      ["-classpath", jarpath, "-s", name], options={poUseShell})
    finally: process.close
    let input = process.outputStream
    let data = readAll(input)
    let outFile = open(path, fmWrite)
    finally: outFile.close
    outFile.write(data)
    inFile = open(path)
  return inFile

proc getFileMD5*(path: string): string =
  var f = open(path)
  finally: f.close()
  return getMD5(readAll(f))

proc invokeJavap*(name: string, jarpath: string, jarmd5: string): TClassInfo =
  var input = cachedRawJavap(name, jarpath, jarmd5)
  finally: input.close
  var line: TaintedString = ""
  # discard 'Compiled from "Foobar.java"'
  discard input.readLine(line)
  # but only if file was compiled from source
  if line.startsWith("Compiled from"):
    discard input.readLine(line)
  result = parseClassInfo(line)
  result.things = @[]
  result.name = name
  while input.readLine(line):
    if line == "}":
      break
    # like: public boolean isEmpty();
    var javaDecl = parseJavaDecl(line)
    discard input.readLine(line)
    # "  Signature: jnisig"
    let sig = parseSig(line)
    javaDecl.sig = sig
    result.things.add(javaDecl)

iterator listJAR*(path: string, prefixes: openarray[string]): string {.inline.} =
  var archive: TZipArchive
  assert archive.open(path)
  finally: archive.close()
  for name in archive.walkFiles():
    if name.endsWith(".class") and name.startsWith(prefixes):
      yield name[0..name.len-7]

when isMainModule:
  var s: seq[string] = @[]

  var classN, thingN = 0
  for classname in listJAR("/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/rt.jar",
                           prefixes=["java/", "javax/"]):
    echo classname
    classN += 1
    let info = invokeJavap(classname)
    thingN += info.things.len
  echo "Processed $1 classes, $2 methods" % [$classN, $thingN]
