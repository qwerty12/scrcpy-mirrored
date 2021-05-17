;@Ahk2Exe-ConsoleApp
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#NoTrayIcon
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines -1
ListLines Off
AutoTrim Off

dllPath := A_ScriptDir . "\scrcpy-mirrored.dll"
exePath := A_ScriptDir . "\scrcpy.exe"
cmdLine := """" . exePath . """"

if (A_Args.Length() > 0) {
	thisCmdLine := DllCall("GetCommandLine", "Str")
	FoundPos := InStr(thisCmdLine, A_Args[1], True) - 1
	cmdLine .= A_Space . SubStr(thisCmdLine, FoundPos)
}

_PROCESS_INFORMATION(pi)
VarSetCapacity(si, (siCb := A_PtrSize == 8 ? 104 : 68), 0), NumPut(siCb, si,, "UInt")

if (DllCall("CreateProcess", "Str", exePath
			,"Str", cmdLine
			,"Ptr", 0
			,"Ptr", 0
			,"Int", False
			,"UInt", CREATE_SUSPENDED := 0x00000004
			,"Ptr", 0
			,"Ptr", 0
			,"Ptr", &si
			,"Ptr", &pi))
{
	hProcess := NumGet(pi,, "Ptr")
	hThread := NumGet(pi, A_PtrSize, "Ptr")

	if (FileExist(dllPath)) {
		 GetBinaryType := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "kernel32.dll", "Ptr"), "AStr", A_IsUnicode ? "GetBinaryTypeW" : "GetBinaryTypeA", "Ptr")
		,LoadLibrary := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "kernel32.dll", "Ptr"), "AStr", A_IsUnicode ? "LoadLibraryW" : "LoadLibraryA", "Ptr")
		cbDllPath := VarSetCapacity(dllPath)

		if ((DllCall(GetBinaryType, "Str", exePath, "UInt*", BinaryType))) {
			if ((BinaryType == 6 && A_PtrSize == 8) || (BinaryType == 0 && A_PtrSize == 4)) {
				if ((pRemoteDllPath := DllCall("VirtualAllocEx", "Ptr", hProcess, "Ptr", 0, "Ptr", cbDllPath, "UInt", MEM_COMMIT := 0x00001000, "UInt", PAGE_READWRITE := 0x04, "Ptr"))) {
					if (DllCall("WriteProcessMemory", "Ptr", hProcess, "Ptr", pRemoteDllPath, "Ptr", &dllPath, "Ptr", cbDllPath, "Ptr", 0)) {
						if (hRemoteThread := DllCall("CreateRemoteThread", "Ptr", hProcess, "Ptr", 0, "Ptr", 0, "Ptr", LoadLibrary, "Ptr", pRemoteDllPath, "UInt", 0, "Ptr", 0, "Ptr")) {
							DllCall("WaitForSingleObject", "Ptr", hRemoteThread, "UInt", 0xFFFFFFFF)
							DllCall("CloseHandle", "Ptr", hRemoteThread)
						}
					}
					DllCall("VirtualFreeEx", "Ptr", hProcess, "Ptr", pRemoteDllPath, "Ptr", 0, "UInt", MEM_RELEASE := 0x8000)
				}
			}
		}
	}


	DllCall("ResumeThread", "Ptr", hThread)
	DllCall("CloseHandle", "Ptr", hThread)
	DllCall("CloseHandle", "Ptr", hProcess)
}

_PROCESS_INFORMATION(ByRef pi) {
	static piCb := A_PtrSize == 8 ? 24 : 16
	if (IsByRef(pi))
		VarSetCapacity(pi, piCb, 0)
}
