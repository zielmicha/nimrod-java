Example code:

    import javatools
    importJava "java.lang.System"

    # initialize new JVM
    defaultJVM = newJVM()

    let currtime = System_static.currentTimeMillis()
    echo "Current time in milliseconds is: ", $currtime

In order to use nimrod-java binding you need to create build script, which will scan JAR files
during compilation. This gives you compile time safety when interacting with Java classes.

Save the following to `build.nim` (for example):

    import jnigen, jnifindjava, os
    var builder: PBuilder = jnigen.makeBuilder("build/jnigen")
    builder.addJAR(findJava() & "/jre/lib/rt.jar",
      prefixes=["java/lang"])
    builder.generate()

    discard execShellCmd("nimrod c " & builder.compileFlags() & " yourcode")

And use these commands to build and run your code:

    nimrod c --path:pathToNimrodJava -d:useLibzipSrc -r build
    ./yourcode
