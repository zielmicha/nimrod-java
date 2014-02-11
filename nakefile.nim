import nake
import jnigen
import jnifindjava
import times

proc measureTime(description: string, e: auto) =
  let start = epochTime()
  e()
  let elapsed = epochTime() - start
  echo description, " took ", int(elapsed * 1000), "ms"

proc runExample(name: string) =
  var builder: PBuilder = jnigen.makeBuilder("build/jnigen")
  # Use notBuilt, so JAR won't be scanned on each build
  # To force rebuild remove build/jnigen/build_marker
  if builder.notBuilt():
    builder.addJAR(findJava() & "/jre/lib/rt.jar",
      prefixes=["java/lang"])
    builder.generate()

  let cmd = "nimrod c " & builder.compileFlags() & " examples/" & name
  shell(cmd)
  shell("examples/" & name)

task "test", "Run highleveltest example.":
  runExample("highleveltest")

for name in ["example2"]:
  task name, "Run " & name & " example.":
    runExample(name)

task "test-javap", "Run javap.nim.":
  shell("nimrod c " & compileFlags() & " -d:useLibzipSrc -r javap")
