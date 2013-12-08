import javap
import jnigencode
import jnisig
import jnifindjava
import sets
import strutils
import tables
import os

type
  PBuilder* = ref TBuilder
  TBuilder = object
    classes: seq[TClassInfo]
    fullClasses: TSet[string]
    classStubs: TSet[string]
    classGeneratedCode*: TTable[string, string]

proc makeBuilder*: PBuilder =
  new(result)
  result.classes = @[]
  result.fullClasses = initSet[string]()
  result.classStubs = initSet[string]()
  result.classGeneratedCode = initTable[string, string]()

proc normalizeStyle(s: string): string =
  s.toLower.replace("_", "")

proc addJAR*(builder: PBuilder, path: string, prefixes: openarray[string]) =
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
      usedTypes.add(jnisig.parseOne("L$1;" % classname))
      if info.isPublic:
        let code = generateClassThings(info, usedTypes)
        builder.classGeneratedCode[classname] = code

  # also add missing types
  for t in usedTypes:
    if t.kind == jniobject:
      builder.classStubs.incl(t.classname)

proc genClassDecl(builder: PBuilder): string =
  result = "# $1 classes\n" % [$builder.classStubs.len]
  for name in builder.classStubs:
    add result, generateJavaClass(name)

const
  typedefs_header = "import jni_md, jni, java\n"
  class_header = "import jni_md, jni, java, jtypedefs\n"

proc generate*(builder: PBuilder, target: string) =
  writeFile(target / "jtypedefs.nim", typedefs_header & builder.genClassDecl())
  for classname, data in builder.classGeneratedCode.pairs():
    writeFile(target / ("wrapper_" & classnameToId(classname) & ".nim"), class_header & data)

proc compileFlags*(): string =
  return "--cincludes:$1 --verbosity:0 --parallelBuild:1 --warning[SmallLshouldNotBeUsed]=off --threads:on" % [findJavaInclude()]

when isMainModule:
  var builder: PBuilder = makeBuilder()
  builder.addJAR("/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/rt.jar",
    prefixes=["java/lang"])
  builder.generate("target")
