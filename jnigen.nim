import javap
import jnigencode
import jnisig
import jnifindjava
import jnicommon
import sets
import strutils
import tables
import os
import osproc

type
  PBuilder* = ref TBuilder
  TBuilder = object
    classes: seq[TClassInfo]
    fullClasses: TSet[string]
    classStubs: TSet[string]
    classGeneratedCode*: TTable[string, string]
    convertables: seq[Tuple[src: string, dst: string]]
    target: string

proc makeBuilder*(target: string): PBuilder =
  new(result)
  result.target = target
  result.classes = @[]
  result.convertables = @[]
  result.fullClasses = initSet[string]()
  result.classStubs = initSet[string]()
  result.classGeneratedCode = initTable[string, string]()

proc normalizeStyle(s: string): string =
  s.toLower.replace("_", "")

proc normalizeJavaName(s: string): string =
  s.replace(".", "/")

proc normJniSig(name: string): PJNIType =
  ## Return JNI signature of class named `name` (name using either . or /)
  name.normalizeJavaName.jnisigFromClassname

proc addJAR*(builder: PBuilder, path: string, prefixes: openarray[string]) =
  ## Load classes with names starting with any of `prefixes` to a builder.
  ## Type definitions for these classes and classes mentioned by them
  ## will be added to jtypedefs.nim. However only for matched classes,
  ## method wrappers will be generated in wrapper_`classname`.nim files.
  let jarmd5 = getFileMD5(path)
  var usedTypes: seq[PJNIType] = @[]
  for classname in listJAR(path, prefixes=prefixes):
    let info = invokeJavap(classname, jarpath=path, jarmd5=jarmd5)
    if not info.isPublic:
      continue
    # we need this check, because in Java libraries there are oddities such as
    # classes ServiceMode and Service.Mode, which are translated to same ident.
    let mangled = classnameToId(info.name).normalizeStyle
    # or even worse - hyphens in class names
    if not validIdentifier(mangled): # uh-oh
      continue
    if mangled notin builder.fullClasses:
      builder.fullClasses.incl(mangled)
      builder.classes.add(info)
      usedTypes.add(jnisigFromClassname(classname))
      if info.isPublic:
        let code = generateClassThings(info, usedTypes)
        builder.classGeneratedCode[classname] = code
      if info.extends != nil:
        builder.convertables.add((classname, info.extends))
        usedTypes.add(normJniSig(info.extends))
      for implement in info.implements:
        builder.convertables.add((classname, implement))
        usedTypes.add(normJniSig(implement))

  # also add missing types
  for t in usedTypes:
    if t.kind == jniobject:
      builder.classStubs.incl(t.classname)

proc genClassDecl(builder: PBuilder): string =
  result = "# $1 classes\n" % [$builder.classStubs.len]
  for name in builder.classStubs:
    add result, generateJavaClass(name)

proc genConverters(builder: PBuilder): string =
  result = "# converters!\n"
  for conv in builder.convertables:
    result.add generateClassConverter(conv.src, conv.dst)

const
  pragmas = "{.warnings:off.}\n"
  typedefs_header = "import jni_md, jni, java\n" & pragmas
  class_header = "import jni_md, jni, java, jtypedefs\n" & pragmas

proc generate*(builder: PBuilder) =
  let target = builder.target
  createDir(target)
  writeFile(target / "jtypedefs.nim", typedefs_header &
                                      builder.genClassDecl() &
                                      builder.genConverters())
  for classname, data in builder.classGeneratedCode.pairs():
    writeFile(target / ("wrapper_" & classnameToId(classname) & ".nim"), class_header & data)
  writeFile(target / "build_marker", "ok")

proc notBuilt*(builder: PBuilder): bool =
  not existsFile(builder.target / "build_marker")

proc compileFlags*(): string =
  return "--cincludes:$1 --verbosity:0 --parallelBuild:1 --threads:on --warning[SmallLshouldNotBeUsed]=off" % [findJavaInclude()]

proc compileFlags*(builder: PBuilder): string =
  result = compileFlags()
  result &= " --path=" & builder.target.quoteShell()
  result &= " --path=" & currentSourcePath().parentDir.quoteShell()
  result.echo

when isMainModule:
  var builder: PBuilder = makeBuilder()
  builder.addJAR("/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/rt.jar",
    prefixes=["java/lang"])
  builder.generate("target")
