# scrcpy-mirrored

A quick hack to have [scrcpy's](https://github.com/Genymobile/scrcpy) output flipped for when you're using it with a buggy device. 
This is [rom1v's fix](https://github.com/Genymobile/scrcpy/issues/1380#issuecomment-626612709) implemented in a Detours DLL to avoid compiling scrcpy myself with every new release.

To run, place [x64/Release/scrcpy-mirrored.dll](https://raw.githubusercontent.com/qwerty12/scrcpy-mirrored/master/x64/Release/scrcpy-mirrored.dll) and [scrcpy-mirrored.exe](https://raw.githubusercontent.com/qwerty12/scrcpy-mirrored/master/scrcpy-mirrored.exe) into the same folder as scrcpy.exe.
Use scrcpy-mirrored.exe to launch scrcpy.

To build, `git clone https://github.com/microsoft/Detours.git scrcpy-mirrored\Detours` and place [msvcrt.lib](https://github.com/neosmart/msvcrt.lib/releases) into the scrcpy-mirrored folder.