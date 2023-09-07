package;

#if windows
// Most of these are unused so clean this up later, but im on mac, so i cant test
@:buildXml('
<target id="haxe">
	<lib name="dwmapi.lib" if="windows" />
	<lib name="shell32.lib" if="windows" />
	<lib name="gdi32.lib" if="windows" />
	<lib name="ole32.lib" if="windows" />
	<lib name="uxtheme.lib" if="windows" />
</target>
')
@:cppFileCode('
#include <Windows.h>
#include <cstdio>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
#include <Shlobj.h>
#include <wingdi.h>
#include <shellapi.h>
#include <uxtheme.h>
')
#end
class Window {
    #if windows
    @:functionCode('
		int darkMode = enable ? 1 : 0;
		HWND window = GetActiveWindow();
		if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
			DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
		}
	')
    #end
	public static function setDarkMode(enable:Bool) {}

    #if windows
    @:functionCode('
		SetProcessDPIAware();
	')
    #end
	public static function registerAsDPICompatible() {}
}