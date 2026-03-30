#!/bin/sh
echo "### STARTING CLEAN SETUP ###"

# 1. Haxelib Pfad sicherstellen
haxelib setup .haxelib

# 2. Die stabilen Kern-Versionen installieren (KEIN GIT!)
# Diese Versionen sind aufeinander abgestimmt und verhindern den Application.hx Fehler
haxelib install lime 8.1.2 --quiet
haxelib install openfl 9.3.3 --quiet
haxelib install flixel 5.5.0 --quiet

# 3. P-Slice spezifische Bibliotheken
haxelib git flixel https://github.com/Psych-Slice/p-slice-1.0-flixel.git 9b1192a23fcfb456123efa14c63c8506ded20e5e --quiet --skip-dependencies
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666 
haxelib git flxanimate https://github.com/Psych-Slice/FlxAnimate.git 82a720663f9ed6328d91a727c2b17501d91e3b11 --skip-dependencies
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90 --skip-dependencies
haxelib git hxcpp https://github.com/Psych-Slice/hxcpp.git 65b851f749a10c1df34f2ef55836bdec67ee81c2 --quiet --skip-dependencies

# 4. Der Rest (Addons & Tools)
haxelib install hxvlc 1.9.2 --quiet --skip-dependencies
haxelib install flixel-addons 3.3.2 --quiet --skip-dependencies
haxelib install flixel-tools 1.5.1 --quiet --skip-dependencies
haxelib install hscript-iris 1.1.3 --quiet --skip-dependencies
haxelib install tjson 1.4.0 --quiet --skip-dependencies
haxelib install hxdiscord_rpc 1.2.4 --quiet --skip-dependencies
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec.git 0a51aed0d9523d22a83e453ce7b593ec7fed4742 --skip-dependencies
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit 1906c4a96f6bb6df66562b3f24c62f4c5bba14a7 --skip-dependencies

echo "### SETUP FINISHED SUCCESSFULLY ###"
