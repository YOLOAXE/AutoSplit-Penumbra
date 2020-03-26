#cs ----------------------------------------------------------------------------

	Author:         YOLOAXE
	Description:    AutoSpliteur

	Script Function: AutoSpliteur pour live slipt
	GameContext
	TP
#ce ----------------------------------------------------------------------------
#RequireAdmin
#include <NomadMemory.au3>
#include <MemoryModuleGetBaseAddressUDF.au3>
#include <Misc.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <FileConstants.au3>
SetPrivilege("SeDebugPrivilege", 1)

Local $hDLL = DllOpen("user32.dll")

local $PosXR[21] = [-7.50,-12,-2.51,-5,21,-8,-32,9,15,-16.5,-7,1,5.8,-0.36,32.5,0,7.6,-6.63]
local $PosYR[21] = [0.53,1.99,0.88,-5,4,0.84,-1.5,0.8,-1,0.77,-1.5,0.7,20.3,11,-3,0.8,-3,0.8]
local $PosZR[21] = [-10.65,-2.2,-5.32,-2,14.5,1.1,9,3,24,26.8,-31.6,-3.6,-34.5,-25,5.5,-0.6,-10,1.6]
local $Split = 0
local $State = 0
local $Start = 0
local $conteur = 0
local $conteur2 = 0
local $oldGameTime = 0
local $oldName = ""
local $input[3]

If ProcessExists("Penumbra.exe") == 0 Then
    MsgBox(0, "", "Penumbra n'est pas Execute. Lance le jeux !!! stp.")
    Exit
 EndIf
 If ProcessExists("LiveSplit.exe") == 0 Then
    MsgBox(0, "", "LiveSplit n'est pas Execute.!!!")
    Exit
 EndIf

Dim $LocateLS = StringReplace(_ProcessGetLocation(ProcessExists("LiveSplit.exe")), "LiveSplit.exe", "settings.cfg")
Local $hFileOpen = FileOpen($LocateLS, $FO_READ)
Dim $SplitKey = StringLower(StringReplace(StringReplace(StringReplace(FileReadLine($hFileOpen,3),"<SplitKey>",""),"</SplitKey>","")," ",""))
Dim $ResetKey = StringLower(StringReplace(StringReplace(StringReplace(FileReadLine($hFileOpen,4),"<ResetKey>",""),"</ResetKey>","")," ",""))
Dim $PauseKey = StringLower(StringReplace(StringReplace(StringReplace(FileReadLine($hFileOpen,7),"<PauseKey>",""),"</PauseKey>","")," ",""))
FileClose($hFileOpen)

MsgBox(0, "AutoSplit by YOLOAXE", "Live Split :  Split :" & $SplitKey & "  Reset :" & $ResetKey & "  Pause :" & $PauseKey & "                                                              Info: I'envoie des touches à live split fonctionnent mieux si vous utilisez des lettres du clavier    Bonne run  ;)  !!!")
Dim $iPID = ProcessExists("Penumbra.exe")
Dim $hMem = _MemoryOpen($iPID)
Dim $PenumbraEXE = _MemoryModuleGetBaseAddress($iPID, "penumbra.exe")
Dim $baseAddrPos = $PenumbraEXE + 0x002DCAF0
Dim $baseAddrTimer = $PenumbraEXE + 0x2DCAF0
Dim $baseAddrName = $PenumbraEXE + 0x2DCAF0

Global $OffsetTime[4]
$OffsetTime[1] = Dec("188") ; Static Addr Oset.
$OffsetTime[2] = Dec("4C")
$OffsetTime[3] = Dec("1C")

Global $OffsetName[4]
$OffsetName[1] = Dec("154") ; Static Addr Oset.
$OffsetName[2] = Dec("40")
$OffsetName[3] = Dec("0")

Global $OffsetX[5]
$OffsetX[1] = Dec("158") ; Static Addr Oset.
$OffsetX[2] = Dec("38")
$OffsetX[3] = Dec("274")
$OffsetX[4] = Dec("48")

Global $OffsetY[5]
$OffsetY[1] = Dec("158") ; Static Addr Oset.
$OffsetY[2] = Dec("38")
$OffsetY[3] = Dec("274")
$OffsetY[4] = Dec("50")

Global $OffsetZ[5]
$OffsetZ[1] = Dec("158") ; Static Addr Oset.
$OffsetZ[2] = Dec("38")
$OffsetZ[3] = Dec("274")
$OffsetZ[4] = Dec("4C")

Dim $ReadX = _MemoryPointerRead($baseAddrPos, $hMem, $OffsetX, "float")
Dim $ReadY = _MemoryPointerRead($baseAddrPos, $hMem, $OffsetY, "float")
Dim $ReadZ = _MemoryPointerRead($baseAddrPos, $hMem, $OffsetZ, "float")
Dim $ReadTimer = _MemoryPointerRead($baseAddrTimer, $hMem, $OffsetTime, "float")
Dim $ReadName = _MemoryPointerRead($baseAddrName, $hMem, $OffsetName, 'char[255]')

#Region ### START Koda GUI section ### Form=
$Form1_2 = GUICreate("Auto Slipt Penumbra", 262, 142, 0, 0,BitOR($WS_MAXIMIZEBOX,$WS_POPUP,$WS_POPUPWINDOW,$WS_GROUP,$WS_EX_TOPMOST))
GUISetBkColor(0x000000)
$Label1 = GUICtrlCreateLabel("Null", 64, 2, 182, 20)
GUICtrlSetFont(-1, 15, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFF0000)
$Label2 = GUICtrlCreateLabel("Null", 64, 28, 182, 24)
GUICtrlSetFont(-1, 15, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x00A800)
$Label3 = GUICtrlCreateLabel("Null", 64, 57, 182, 24)
GUICtrlSetFont(-1, 15, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0080FF)
$Label4 = GUICtrlCreateLabel("PosY :", 0, 27, 62, 24)
GUICtrlSetFont(-1, 15, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x00A800)
$Label5 = GUICtrlCreateLabel("PosX :", -1, 0, 62, 24)
GUICtrlSetFont(-1, 15, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFF0000)
$Label6 = GUICtrlCreateLabel("PosZ :", 0, 57, 62, 24)
GUICtrlSetFont(-1, 15, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0080FF)
$Label7 = GUICtrlCreateLabel("Distance next Trigger:", 0, 81, 198, 24)
GUICtrlSetFont(-1, 15, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x800000)
$Dist = GUICtrlCreateLabel("0", 196, 83, 62, 24)
GUICtrlSetFont(-1, 15, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0x800000)
$Label8 = GUICtrlCreateLabel("Step:", 0, 112, 42, 24)
GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFFFFFF)
$Step = GUICtrlCreateLabel("Map", 43, 113, 165, 24)
GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xFFFFFF)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

func _Lecture()
   $ReadX = _MemoryPointerRead($baseAddrPos, $hMem, $OffsetX, "float")
   $ReadY = _MemoryPointerRead($baseAddrPos, $hMem, $OffsetZ, "float")
   $ReadZ = _MemoryPointerRead($baseAddrPos, $hMem, $OffsetY, "float")
   $ReadTimer = _MemoryPointerRead($baseAddrTimer, $hMem, $OffsetTime, "float")
   $ReadName = _MemoryPointerRead($baseAddrName, $hMem, $OffsetName, 'char[255]')
EndFunc

func _Distance($x,$y,$z,$x1,$y1,$z1)
   return Sqrt((($x-$x1)^2)+(($y-$y1)^2)+(($z-$z1)^2))
EndFunc
;_editKey()
While 1
   _Lecture()
   GUICtrlSetData($Label1, Round($ReadX[1],3))
   GUICtrlSetData($Label2, Round($ReadY[1],3))
   GUICtrlSetData($Label3, Round($ReadZ[1],3))
   GUICtrlSetData($Dist, Round(_Distance($ReadX[1],$ReadY[1],$ReadZ[1],$PosXR[$Split],$PosYR[$Split],$PosZR[$Split]),2))
   GUICtrlSetData($Step,$ReadName[1])
   GUICtrlSetData($Label8,$Split)

   if $ReadX[1] <> 0 And $ReadY[1] <> 0 And $ReadZ[1] <> 0 And $Start == 1 Then
	  $Start = 0
	  Send($SplitKey)
   EndIf

   if $conteur >= 20 And $Start == 0 Then
	  Send($ResetKey)
	  $Start = 1
	  $Split = 0
	  $State = 0
	  $conteur = 0

   EndIf


   if $oldGameTime == $ReadTimer[1] And  $ReadTimer[1] >= 1 And  $State == 0 And $conteur2 >= 30 Then
	  Send($PauseKey)
	  $State = 1
   EndIf

   if $oldGameTime < $ReadTimer[1] And  $ReadTimer[1] >= 1 And  $State == 1 Then
	  _Split1()
	  $State = 0
	  $conteur2 = 0
   EndIf

   if $ReadX[1] == 0 And $ReadY[1] == 0 And $ReadZ[1] == 0 And $ReadTimer[1] == 0 then
	  $conteur += 1
   Else
	  $conteur = 0
   EndIf
   Sleep(50)
   $conteur2 += 1
   $oldGameTime = $ReadTimer[1]


   $nMsg = GUIGetMsg()
   Switch $nMsg
	  Case $GUI_EVENT_CLOSE
		 _QUIT ()
   EndSwitch
   If ProcessExists("Penumbra.exe") == 0 Then
	  _QUIT ()
   EndIf
WEnd


func _inttoflo($d)
    return (1 - (2*BitShift($d,31))) * (2^(bitAND(bitshift($d,23),255)-127)) * (1+BitAND($d,8388607)/8388608)
 EndFunc

Func _Split1()
   if $Split == 6 And $ReadName[1] == "level07_residental_corridors.dae" then
	  return
   EndIf
   if $Split == 6 And $ReadName[1] == "level06_dr_swansons_room.dae" then
	  return
   EndIf
   if $ReadName[1] == "level21_tower_1.dae" And $oldName == "level16_infected_corridors.dae" then
	  return
   EndIf
   if $ReadName[1] == "level21_tower_2.dae" And $oldName == "level21_tower_1.dae" then
	  return
   EndIf
   if $ReadName[1] == "level21_tower_3.dae" And $oldName == "level21_tower_1.dae" then
	  return
   EndIf
   if $ReadName[1] == "level21_tower_4.dae" And $oldName == "level21_tower_1.dae" then
	  return
   EndIf
   if $ReadName[1] == "level21_tower_1.dae" And $oldName == "level21_tower_4.dae" then
	  return
   EndIf
   if $ReadName[1] <> "" And $ReadName[1] <> $oldName And Not _IsPressed("1B", $hDLL) Then
	  $Split += 1
	  $oldName = $ReadName[1]
	  Send($PauseKey)
	   Sleep(50)
	  Send($SplitKey)
   Else
	  Send($PauseKey)
   EndIf

EndFunc

Func _QUIT ()
   DllClose($hDLL)
   MsgBox(0,"Close","a+",1)
   Exit
EndFunc

Func _ProcessGetLocation($iPID)
    Local $aProc = DllCall('kernel32.dll', 'hwnd', 'OpenProcess', 'int', BitOR(0x0400, 0x0010), 'int', 0, 'int', $iPID)
    If $aProc[0] = 0 Then Return SetError(1, 0, '')
    Local $vStruct = DllStructCreate('int[1024]')
    DllCall('psapi.dll', 'int', 'EnumProcessModules', 'hwnd', $aProc[0], 'ptr', DllStructGetPtr($vStruct), 'int', DllStructGetSize($vStruct), 'int_ptr', 0)
    Local $aReturn = DllCall('psapi.dll', 'int', 'GetModuleFileNameEx', 'hwnd', $aProc[0], 'int', DllStructGetData($vStruct, 1), 'str', '', 'int', 2048)
    If StringLen($aReturn[3]) = 0 Then Return SetError(2, 0, '')
    Return $aReturn[3]
EndFunc


