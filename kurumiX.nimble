# Package

version       = "0.1.0"
author        = "System64MC"
description   = "Kurumi-X wavetable workstation"
license       = "MIT"
srcDir        = "src"
bin           = @["kurumiX"]


# Dependencies

requires "nim >= 1.9.3"
requires "nimgl == 1.3.2"
requires "https://github.com/nimgl/imgui.git == 1.84.2"
requires "flatty == 0.3.4"
requires "supersnappy == 2.1.3"
requires "tinydialogs == 1.0.0"
requires "kissfft == 0.0.1"
requires "mathexpr == 1.3.2"
