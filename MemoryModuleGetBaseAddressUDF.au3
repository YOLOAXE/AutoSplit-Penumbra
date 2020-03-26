Func _MemoryModuleGetBaseAddress($iPID, $sModule)
    If Not ProcessExists($iPID) Then Return SetError(1, 0, 0)

    If Not IsString($sModule) Then Return SetError(2, 0, 0)

    Local   $PSAPI = DllOpen("psapi.dll")

    ;Get Process Handle
    Local   $hProcess
    Local   $PERMISSION = BitOR(0x0002, 0x0400, 0x0008, 0x0010, 0x0020) ; CREATE_THREAD, QUERY_INFORMATION, VM_OPERATION, VM_READ, VM_WRITE

    If $iPID > 0 Then
        Local $hProcess = DllCall("kernel32.dll", "ptr", "OpenProcess", "dword", $PERMISSION, "int", 0, "dword", $iPID)
        If $hProcess[0] Then
            $hProcess = $hProcess[0]
        EndIf
    EndIf

    ;EnumProcessModules
    Local   $Modules = DllStructCreate("ptr[1024]")
    Local   $aCall = DllCall($PSAPI, "int", "EnumProcessModules", "ptr", $hProcess, "ptr", DllStructGetPtr($Modules), "dword", DllStructGetSize($Modules), "dword*", 0)
    If $aCall[4] > 0 Then
        Local   $iModnum = $aCall[4] / 4
        Local   $aTemp
        For $i = 1 To $iModnum
            $aTemp =  DllCall($PSAPI, "dword", "GetModuleBaseNameW", "ptr", $hProcess, "ptr", Ptr(DllStructGetData($Modules, 1, $i)), "wstr", "", "dword", 260)
            If $aTemp[3] = $sModule Then
                DllClose($PSAPI)
                Return Ptr(DllStructGetData($Modules, 1, $i))
            EndIf
        Next
    EndIf

    DllClose($PSAPI)
    Return SetError(-1, 0, 0)

EndFunc