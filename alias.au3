#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Rsolde

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------



#include <MsgBoxConstants.au3>
#include <Constants.au3>
#include <File.au3>
#include <Array.au3>
#include <Process.au3>
#include <FTPEx.au3>

#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#include <ButtonConstants.au3>
#include <StaticConstants.au3>

#include <GuiEdit.au3>
#include <GuiStatusBar.au3>
#include <ScrollBarsConstants.au3>
local $argc = UBound($CmdLine)
local $pwd="rsolde"
local $help = @CRLF &@TAB& "Usage :" & @CRLF & @CRLF & @TAB & @TAB
	  $help &= "alias <alias_name>  <command>" &@CRLF &@CRLF & @TAB
	  $help &= 'OPTIONS: ' &@CRLF &@CRLF & @TAB & @TAB
	  $help &= '-rm <alias_name>   : delete an alias' &@CRLF &@CRLF & @TAB & @TAB
	  $help &= '-l                 : list existing aliases' &@CRLF &@CRLF & @TAB & @TAB
	  $help &= '-imp               : import aliases from aliasrc configuration' &@CRLF &@CRLF & @TAB & @TAB
	  $help &= '-src <password>    : extract the source code of the program' &@CRLF &@CRLF & @TAB & @TAB


checkOption()
func checkOption()
   if $argc=1 or $CmdLine[1] = "-h" or $CmdLine[1] = "-help" or $CmdLine[1] = "--h" or $CmdLine[1] = "--help" then
	  help()
   ElseIf $CmdLine[1]="-imp" or $CmdLine[1]="-import" Then
	  RunWait("aliasrc.cmd", @ScriptDir)
   ElseIf $CmdLine[1]="-l" or $CmdLine[1]="-list" Then
	  aliasList()
   ElseIf $argc >= 3 and $CmdLine[1] = "-rm"  Then
	  deleteAlias()
   ElseIf $argc >= 3 and $CmdLine[1] = "-src" Then
	  getSources()
   ElseIf $argc>=3 and StringLeft( $CmdLine[1], 1) <> "-" then
	  addAlias()
   Else
	  help()
   EndIf
EndFunc





Func addAlias()
   if $CmdLine[1]="aliasrc" Then
	  ConsoleWrite(@CRLF&"Error:"&@CRLF&"  Can't create alias 'aliasrc', aliasrc is already used by this program"&@CRLF)
	  exit
   EndIf
   local $outfile = $CmdLine[1] & ".cmd"
   local $cmd = $CmdLine[2]

   if $argc -1 >= 3 then
	  for $i = 3 to $argc -1
		 $cmd &= " " & $CmdLine[$i]
	  Next
   EndIf

   $cmd = StringReplace( $cmd,'"','')



   EcrireFic(@ScriptDir & "\" &  $outfile , $cmd & " %1 %2 %3 %4 %5 %6 %7 %8 %9", $FO_OVERWRITE)
   local $connectionData = FileRead(@ScriptDir & "\aliasrc.cmd")
   $connectionData = StringSplit($connectionData, @CRLF)

   local $size = UBound($connectionData)
   local $ret = 0
   for $i = 1 to $size - 1
	  if $connectionData[$i]="alias " & $CmdLine[1] & " " & $cmd Then
		 $ret = 1
	  EndIf
   Next
   if $ret =0 then
   EcrireFic(@ScriptDir & "\aliasrc.cmd" , "alias " & $CmdLine[1] & " " & $cmd & @CRLF, $FO_APPEND)
   EndIf
   aliasList()

EndFunc



Func getSources()
   if $CmdLine[2] <> $pwd Then
	  ConsoleWrite("Wrong password" & @CRLF)
	  exit
   EndIf
   $SrcDir = @ScriptDir & "\Sources"
   DirCreate($SrcDir)
   ConsoleWrite("script : " & @ScriptName & @crlf)
   ; Extraction du/des fichier(s) source.
   FileInstall(".\alias.au3", $SrcDir & "\")

   ConsoleWrite(@CRLF&@CRLF&"Sources extracted to "  & $SrcDir)
   exit
EndFunc

func deleteAlias()
   FileDelete(@ScriptDir & "\" &  $CmdLine[2] & ".cmd")
   local $connectionData = FileRead(@ScriptDir & "\aliasrc.cmd")
   $connectionData = StringSplit($connectionData, @CRLF)

   local $size = UBound($connectionData)
   for $i = 1 to $size - 1
	  if StringInStr($connectionData[$i], ' ' & $CmdLine[2] & ' ') > 0 Then
		 $connectionData[$i] = ""
	  EndIf
   Next
   local $res = ""
   for $i = 1 to $size - 1
	  if Stringlen($connectionData[$i]) > 0 Then
		$res &= $connectionData[$i] & @CRLF
	  EndIf
   Next
   EcrireFic(@ScriptDir & "\aliasrc.cmd", $res, $FO_OVERWRITE)
   aliasList()
   exit
EndFunc
func aliasList()
   ConsoleWrite(@CRLF & @TAB & "Liste des alias disponibles" & @CRLF & @CRLF)
   ConsoleWrite(FileRead(@ScriptDir & "\aliasrc.cmd"))
   exit
EndFunc
Func EcrireFic($RepFic, $txt, $mod)

   Local $fic
   $fic = FileOpen($RepFic,$mod)
   FileWrite($fic,$txt)
   FileClose($fic)
EndFunc
Func help()
   ConsoleWrite($help)
   exit
EndFunc