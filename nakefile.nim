import nake
import jnigen

task "test", "Build java.lang bindings as a test.":
  var builder: PBuilder = jnigen.makeBuilder()
  builder.addJAR("/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/rt.jar",
    prefixes=["java/lang"])
  builder.generate("nimcache" / "jnitarget")

  let cmd = "nimrod c " & compileFlags() & " --path:nimcache/jnitarget -r highleveltest"
  cmd.echo
  shell(cmd)

#https://gist.github.com/zielmicha/0a5739a1b77af0f7d5d5
