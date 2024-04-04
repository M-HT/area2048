#!/bin/sh

#FLAGS="-fversion=USE_GLES -fversion=PANDORA -frelease -c -O2 -pipe"
FLAGS="-fversion=USE_GLES -fversion=PANDORA -frelease -fno-section-anchors -c -O2 -Wall -pipe"

rm EGLPort/*.o*
rm import/*.o*
rm src/*.o*

cd EGLPort
$PNDSDK/bin/pandora-gcc -c -O2 -DPANDORA -DUSE_EGL_SDL -DUSE_GLES1 -I$PNDSDK/usr/include -I$PNDSDK/usr/include/SDL eglport.c
cd ..

cd import
$PNDSDK/bin/pandora-gdc $FLAGS *.d
rm opengl.o* openglu.o*
cd ..

cd src
$PNDSDK/bin/pandora-gdc $FLAGS -I../import *.d
cd ..

#$PNDSDK/bin/pandora-gdc -o AREA2048 -s EGLPort/*.o* import/*.o* src/*.o* lib/arm/libbulletml_d.a -Wl,-rpath-link,$PNDSDK/usr/lib -L$PNDSDK/usr/lib -lGLES_CM -lSDL_mixer -lmad -lSDL -lts -lEGL -lstdc++
$PNDSDK/bin/pandora-gdc -o AREA2048 -s -Wl,-rpath-link,$PNDSDK/usr/lib -L$PNDSDK/usr/lib -lGLES_CM -lSDL_mixer -lmad -lSDL -lts -lEGL -lbulletml_d -L./lib/arm EGLPort/*.o* import/*.o* src/*.o*
