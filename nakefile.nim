import nake
import jnigen
import times

proc measureTime(description: string, e: auto) =
  let start = epochTime()
  e()
  let elapsed = epochTime() - start
  echo description, " took ", int(elapsed * 1000), "ms"

task "test", "Build java.lang bindings as a test.":
  var builder: PBuilder = jnigen.makeBuilder("build/jnigen")
  # Use notBuilt, so JAR won't be scanned on each build
  # To force rebuild remove build/jnigen/build_marker
  if builder.notBuilt():
    measureTime "addJAR+generate":
      builder.addJAR("/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/rt.jar",
        prefixes=["java/lang"])
      builder.generate()

  let cmd = "nimrod c " & builder.compileFlags() & " examples/highleveltest"
  measureTime "nimrod c":
    shell(cmd)

  measureTime "run":
    shell("examples/highleveltest")

task "test-javap", "Run javap.nim.":
  shell("nimrod c " & compileFlags() & " -d:useLibzipSrc -r javap")
