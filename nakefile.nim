import nake
import jnigen

task "test", "Build java.lang bindings as a test.":
  var builder: PBuilder = jnigen.makeBuilder()
  builder.addJAR("/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/rt.jar",
    prefixes=["java/lang"])
  builder.generate("nimcache" / "jnitarget")

  shell("nimrod c", compileFlags(), " --path:nimcache/jnitarget -r highleveltest")
