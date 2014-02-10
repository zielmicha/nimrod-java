import jnigen, jnifindjava, os
var builder: PBuilder = jnigen.makeBuilder("../build/jnigen")
builder.addJAR(findJava() & "/jre/lib/rt.jar",
   prefixes=["java/lang"])
builder.generate()

discard execShellCmd("nimrod c " & builder.compileFlags() & " yourcode")
