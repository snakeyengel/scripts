; Example #4: Parse a comma separated value (CSV) file:
SetWorkingDir %A_ScriptDir%
Loop, read, test_walmart.txt
{
    MsgBox, 4, , Line %A_Index%`n%A_LoopReadLine%`n`nContinue?
    IfMsgBox, No
        return
    LineNumber = %A_Index%
    Loop, parse, A_LoopReadLine, CSV
    {
        MsgBox, 4, , Field %LineNumber%-%A_Index% is:`n%A_LoopField%`n`nContinue?
        IfMsgBox, No
            return
    }
}