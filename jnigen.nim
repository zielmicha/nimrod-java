import javap
import jnigencode
import sets
import strutils

type
  PBuilder* = ref TBuilder
  TBuilder = object
    classes: seq[TClassInfo]
    classnames: TSet[string]

proc makeBuilder*: PBuilder =
  new(result)
  result.classes = @[]
  result.classnames = initSet[string]()

proc normalizeStyle(s: string): string =
  s.toLower.replace("_", "")

proc addJAR*(builder: PBuilder, path: string, prefixes: openarray[string]) =
  for classname in listJAR(path, prefixes=prefixes):
    let info = invokeJavap(classname)
    if not info.isPublic:
      continue
    # we need this check, because in Java libraries there are oddities such as
    # classes ServiceMode and Service.Mode, which are translated to same ident.
    let mangled = classnameToId(info.name).normalizeStyle
    # or even worse - hyphens in class names
    if not validIdentifier(mangled): # uh-oh
      continue
    if mangled notin builder.classnames:
      builder.classnames.incl(mangled)
      builder.classes.add(info)

proc genClassDecl(builder: PBuilder): string =
  result = "# $1 classes\nimport jni, java\n" % [$builder.classes.len]
  for class in builder.classes:
    add result, generateJavaClass(class.name)

when isMainModule:
  var builder: PBuilder = makeBuilder()
  builder.addJAR("/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/rt.jar",
    prefixes=["java/lang/"])
  builder.genClassDecl().echo
