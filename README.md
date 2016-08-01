# ahk

##About
Autohotkey Script for offering optimal swap choices Magic The Gathering Puzzle Quest

mtgpq.ahk is the main Script
Lib is containing some Libraries, not all of them are still used.
Some of them are from the web.
Notably:

- Gdip.ahk, Gdip_All.ahk
```
; Gdip standard library v1.45 by tic (Tariq Porter) 07/09/11
; Modifed by Rseding91 using fincs 64 bit compatible Gdip library 5/1/2013
; Supports: Basic, _L ANSi, _L Unicode x86 and _L Unicode x64
```

- GDIpHelper.ahk

only found this. not sure if it is inedeed the source

[brigand/GDIpHelper.ahk](https://gist.github.com/brigand)

- regionGetColor.ahk

generates median Color of a screen region

[Author: infogulch](https://github.com/infogulch)

##State

After some back and forth I implemented median color to compare against fix color with distance

Distance to median seems to be the most robust and fast choice for the job



##ToDo
