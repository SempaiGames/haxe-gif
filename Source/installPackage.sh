#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
haxelib remove haxe-gif
haxelib local haxe-gif.zip
