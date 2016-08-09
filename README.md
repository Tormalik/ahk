# ahk

##About
Autohotkey Script for offering optimal swap choices Magic The Gathering Puzzle Quest

mtgpq.ahk is the main Script
Lib is containing some Libraries, not all of them are still used.
Some of them are from the web.
Notably:

* Gdip.ahk, Gdip_All.ahk
```
; Gdip standard library v1.45 by tic (Tariq Porter) 07/09/11
; Modifed by Rseding91 using fincs 64 bit compatible Gdip library 5/1/2013
; Supports: Basic, _L ANSi, _L Unicode x86 and _L Unicode x64
```

* GDIpHelper.ahk

only found this. not sure if it is inedeed the source

[brigand/GDIpHelper.ahk](https://gist.github.com/brigand)

* regionGetColor.ahk

generates median Color of a screen region

[Author: infogulch](https://github.com/infogulch)

##State

After some back and forth I implemented median color to compare against fix color with distance

Distance to median seems to be the most robust and fast choice for the job

getMoves gives now color valued options

Now simulate drops correctly and recursive

One Gui to rule them all

##ToDo

* Bug: Last Char not remembered correctly 
* include estimate value of unknown dropped gems
* include possible remaining moves for opponent
* Planeswalker recognition
* selecting move
* move
* refactor: create mtgpqGrid Class which wraps all the mechanics
* highlight & tooltip per move
* add 1p per match
* value moves
* show window on update
* screen calibrator

##Done

* simulate drop (recursive)
* include values from simdrop
* Landfall Mechanic
* void, support, support count
* fixed: red support shows as p or w. Solution: multiple reference colors
* create more elaborate move return data (mana, planeswalker, Landfall (color), extra move)
* create gui for color values
    * later: planeswalker and lvl select
* show moves overlay