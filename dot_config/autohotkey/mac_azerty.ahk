#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"

; macOS-like keyboard layer for a Mac AZERTY keyboard on Windows.
; Left Command (LWin) is used as Command.
; Left Option (LAlt) provides macOS-like symbol bindings.
; Right Alt (AltGr) stays untouched for native Windows FR symbols.

; Command shortcuts.
<#a::Send "^a"
<#c::Send "^c"
<#f::Send "^f"
<#l::Send "^l"
<#n::Send "^n"
<#o::Send "^o"
<#p::Send "^p"
<#r::Send "^r"
<#s::Send "^s"
<#t::Send "^t"
<#v::Send "^v"
<#w::Send "^w"
<#x::Send "^x"
<#y::Send "^y"
<#z::Send "^z"
<#+z::Send "^+z"
<#q::
{
    Send "!{F4}"
}
<#1::Send "^1"
<#2::Send "^2"
<#3::Send "^3"
<#4::Send "^4"
<#5::Send "^5"
<#6::Send "^6"
<#7::Send "^7"
<#8::Send "^8"
<#9::Send "^9"
<#0::Send "^0"
<#Space::
{
    Send "#{s}"
}

; macOS-like app switching with Command+Tab.
<#Tab::
{
    Send "{Alt down}{Tab}"
}

<#Tab up::
{
    Send "{Alt up}"
}

<#+Tab::
{
    Send "{Alt down}+{Tab}"
}

<#+Tab up::
{
    Send "{Alt up}"
}

; Command navigation.
<#Left::Send "{Home}"
<#Right::Send "{End}"
<#+Left::Send "+{Home}"
<#+Right::Send "+{End}"
<#Up::Send "^{Home}"
<#Down::Send "^{End}"
<#+Up::Send "^+{Home}"
<#+Down::Send "^+{End}"

; Option navigation/editing.
<!Left::Send "^{Left}"
<!Right::Send "^{Right}"
<+!Left::Send "^+{Left}"
<+!Right::Send "^+{Right}"
<!Backspace::Send "^{Backspace}"

; ISO/dev symbols (macOS-like, left Option only).
; The key under Esc on many FR ISO layouts (SC029) should feel like Mac @/#.
SC029::SendText "@"
+SC029::SendText "#"

; Option/Option+Shift symbol layer based on Apple French keylayout.
<!SC002::SendText ""
<+!SC002::SendText "´"
<!SC003::SendText "ë"
<+!SC003::SendText "„"
<!SC004::SendText "“"
<+!SC004::SendText "”"
<!SC005::SendText "‘"
<+!SC005::SendText "’"
<!SC006::SendText "{"
<+!SC006::SendText "["
<!SC007::SendText "—"
<+!SC007::SendText "–"
<!SC008::SendText "«"
<+!SC008::SendText "»"
<!SC009::SendText "¡"
<+!SC009::SendText "Û"
<!SC00A::SendText "Ç"
<+!SC00A::SendText "Á"
<!SC00B::SendText "ø"
<+!SC00B::SendText "Ø"
<!SC00C::SendText "}"
<+!SC00C::SendText "]"
<!SC01B::SendText "€"
<+!SC01B::SendText "¥"

<!SC028::SendText "Ù"
<+!SC028::SendText "‰"
<!SC02B::SendText "@"
<+!SC02B::SendText "#"
<!SC035::SendText "÷"
<+!SC035::SendText "\"
<!SC056::SendText "≤"
<+!SC056::SendText "≥"

<!SC012::SendText "ê"
<!SC026::SendText "¬"
<+!SC026::SendText "|"
<!SC031::SendText "~"

; Terminal-specific override: Command+C/V should copy/paste, not SIGINT.
#HotIf WinActive("ahk_exe WindowsTerminal.exe") || WinActive("ahk_exe wezterm-gui.exe")
<#c::Send "^+c"
<#v::Send "^+v"
#HotIf

; Right Command behaves like left Command.
RWin::LWin
