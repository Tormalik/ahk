;region ;INI functions; ################################################################
lastChar() {
    char := getIniVal("lastsettings","lastChar")
    return (char="N/A" ? "gideon" : char)
}

setLastChar() {
global CharChoice
    ret:= setIniVal("lastsettings","lastChar",CharChoice)
}

lastCfg() {
    cfg := getIniVal("lastsettings","lastCfg")
    return (cfg="N/A" ? "HomeNox" : cfg)
}

setLastCfg() {
global LoadedConfig
    setIniVal("lastsettings","lastCfg",LoadedConfig)
}

readChars() {
global chars
    chars:={}
    i:=0
    Loop {
        char := getIniVal("chars",("c" ++i))
        if(char="N/A") {
            break
        }
        chars[char] := LoadChar(char)
    }
    return chars
}

LoadChar(char) {
    ret:= {}
    colors:=["w", "g", "r", "b", "u"]
    For i,col in colors {
        val := getIniVal(char,col)
        if (col != "N/A") {
            ret[col]:=val
        }
    }
    return ret
}

SaveColors() {
global CharChoice
global Col_w
global Col_g
global Col_r
global Col_b
global Col_u
    colors:={"w":Col_w, "g":Col_g, "r":Col_r, "b":Col_b, "u":Col_u}
    SaveChar(CharChoice,colors)
}

SaveChar(char,colors) {
    For col,val in colors {
        setIniVal(char,col,val)
    }
}

AvailableConfigs(){
    cfgs:=[]
    i:=0
    Loop {
        cfg := getIniVal("configs",("c" i++))
        if(cfg="N/A") {
            break
        }
        cfgs.Push(cfg)
    }
    return cfgs
}

LoadConfig(cfg:="default") {
global LoadedConfig
    LoadedConfig := cfg
    vars := ["WINDOW_NAME","ORIGIN_X","ORIGIN_Y","SIZE_X","SIZE_Y","OFFSET_X","OFFSET_Y","PADDING"]
    For i,var in vars {
        val := getIniVal("default",var)
        if (val != "N/A") {
            %var%:=val
        }
        val := getIniVal(cfg,var)
        ;msgbox % var " -> " val
        if (val != "N/A") {
            %var%:=val
        }
    }
}

SaveConfig(cfg:="") {
global WINDOW_NAME
global LoadedConfig
global ORIGIN_X
global ORIGIN_Y
global SIZE_X
global SIZE_Y
global OFFSET_X
global OFFSET_Y
global PADDING
    if (!StrLen(cfg)) {
        cfg:=LoadedConfig
    }
    vars := ["WINDOW_NAME","ORIGIN_X","ORIGIN_Y","SIZE_X","SIZE_Y","OFFSET_X","OFFSET_Y","PADDING"]
    For i,var in vars {
        setIniVal(cfg,var,%var%)
    }
}

getIniVal(section,var) {
    IniRead, val, config.ini, %section%, %var%, N/A
    return val    
}
     
setIniVal(section,var,value) {
    IniWrite, %value%, config.ini, %section%, %var%
}

;end_region
