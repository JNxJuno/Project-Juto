#!/bin/sh
echo "Installing dependencies..."

# 1. Alte/Kaputte Versionen restlos entfernen
haxelib remove lime --quiet
haxelib remove openfl --quiet

# 2. Das "Dream-Team" installieren (Versionen, die zusammenpassen)
haxelib install lime 8.1.2 --quiet
haxelib install openfl 9.3.3 --quiet
haxelib install flixel 5.5.0 --quiet

# 3. Den Rest der P-Slice Gits laden
haxelib git flixel https://github.com/Psych-Slice/p-slice-1.0-flixel.git 9b1192a23fcfb456123efa14c63c8506ded20e5e --quiet --skip-dependencies
haxelib git grig.audio https://gitlab.com/haxe-grig/grig.audio.git cbf91e2180fd2e374924fe74844086aab7891666 
haxelib git flxanimate https://github.com/Psych-Slice/FlxAnimate.git 82a720663f9ed6328d91a727c2b17501d91e3b11 --skip-dependencies
haxelib git funkin.vis https://github.com/FunkinCrew/funkVis 22b1ce089dd924f15cdc4632397ef3504d464e90 --skip-dependencies
haxelib git hxcpp https://github.com/Psych-Slice/hxcpp.git 65b851f749a10c1df34f2ef55836bdec67ee81c2 --quiet --skip-dependencies

# 4. Addons und Tools (feste Versionen)
haxelib install flixel-addons 3.2.2 --quiet --skip-dependencies
haxelib install flixel-tools 1.5.1 --quiet --skip-dependencies
haxelib install hscript-iris 1.1.3 --quiet --skip-dependencies
haxelib install tjson 1.4.0 --quiet --skip-dependencies
haxelib install hxdiscord_rpc 1.2.4 --quiet --skip-dependencies
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec.git 0a51aed0d9523d22a83e453ce7b593ec7fed4742 --skip-dependencies
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit 1906c4a96f6bb6df66562b3f24c62f4c5bba14a7 --skip-dependencies

echo "Finished!"