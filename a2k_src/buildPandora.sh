#!/bin/sh

#FLAGS="-fversion=PANDORA -frelease -c -O2 -Wall -pipe"
FLAGS="-fversion=PANDORA -frelease -fno-section-anchors -c -O2 -Wall -pipe"

rm import/*.o*
rm src/*.o*

cd import
$PNDSDK/bin/pandora-gdc $FLAGS *.d
rm openglu.o*
cd ..

cd src
$PNDSDK/bin/pandora-gdc $FLAGS -I../import *.d
cd ..

#$PNDSDK/bin/pandora-gdc -o AREA2048 -s import/*.o* src/*.o* lib/arm/libbulletml_d.a -Wl,-rpath-link,$PNDSDK/usr/lib -L$PNDSDK/usr/lib -lGL -lSDL_mixer -lmad -lSDL -lts -lstdc++
$PNDSDK/bin/pandora-gdc -o AREA2048 -s -Wl,-rpath-link,$PNDSDK/usr/lib -L$PNDSDK/usr/lib -lGL -lSDL_mixer -lmad -lSDL -lts -lbulletml_d -L./lib/arm import/*.o* src/*.o*
