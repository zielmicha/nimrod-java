FLAGS='--cincludes:/usr/lib/jvm/java-6-openjdk-amd64/include/' '--verbosity:0' '--parallelBuild:1' '--warning[SmallLshouldNotBeUsed]=off' '--threads:on'


lowleveltest:
	nimrod c $(FLAGS) lowleveltest.nim
	./lowleveltest

.PHONY: lowleveltest

jni.nim: jni_modified.h
	c2nim jni_modified.h '--out:jni.nim'
	grep -v 'deadCodeElim' jni.nim > jni_tmp.nim
	mv jni_tmp.nim jni.nim
