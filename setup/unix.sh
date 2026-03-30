#!/bin/sh
echo "### STARTING ULTIMATE SETUP ###"

haxelib setup .haxelib

# 1. Zurück zu den Funkin/Psych-Git-Versionen (für totalMemoryNumber etc.)
haxelib git openfl https://github.com/FunkinCrew/openfl.git c4fa1dcfc384f07bb537e08cae671f9507fe49e6 --quiet --skip-dependencies
haxelib git lime https://github.com/Psych-Slice/lime-pslice.git c6ed780a33cfc07d3fd2fd7325c1428236bc4b61 --quiet

# 2. DER PATCH (Das Skalpell): Repariert den constructor-Fehler in der Bibliothek
# Wir ändern "super(appMeta);" zu "super();", damit es kompiliert
sed -i 's/super(appMeta);/super();/g' .haxelib/openfl/git/src/openfl/display/Application.hx

# 3. Alle anderen Bibliotheken
haxelib git flixel https://github.com/Psych-Slice/p-slice-1.0-flixel.git 9b1192a23fcfb456123efa14c63c8506ded20e5e --quiet --skip-dependencies
haxelib git flxanimate https://github.com/Psych-Slice/FlxAnimate.git 82a720663f9ed6328d91a727c2b17501d91e3b11 --skip-dependencies
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90 --skip-dependencies
haxelib git hxcpp https://github.com/Psych-Slice/hxcpp.git 65b851f749a10c1df34f2ef55836bdec67ee81c2 --quiet --skip-dependencies

haxelib install flixel-addons 3.3.2 --quiet --skip-dependencies
haxelib install flixel-tools 1.5.1 --quiet --skip-dependencies
haxelib install hscript-iris 1.1.3 --quiet --skip-dependencies
haxelib install tjson 1.4.0 --quiet --skip-dependencies
haxelib install hxdiscord_rpc 1.2.4 --quiet --skip-dependencies
haxelib install hxvlc 1.9.2 --quiet --skip-dependencies

# grig.audio Fix
curl -L "https://gitlab.com/haxe-grig/grig.audio/-/archive/cbf91e2180fd2e374924fe74844086aab7891666/grig.audio.zip" -o grig_audio.zip
haxelib install grig_audio.zip --quiet

haxelib git hxCodec https://github.com/polybiusproxy/hxCodec.git 0a51aed0d9523d22a83e453ce7b593ec7fed4742 --skip-dependencies
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit 1906c4a96f6bb6df66562b3f24c62f4c5bba14a7 --skip-dependencies

echo "### SETUP FINISHED AND PATCHED ###"
