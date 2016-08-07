;region ;INI functions; ################################################################
lastChar(){
    char := getIniVal("lastsettings","lastChar")
    if (char="N/A")
        char="gideon"
    return char
}

lastCfg(){
    cfg := getIniVal("lastsettings","lastCfg")
    if (cfg="N/A")
        cfg="HomeNox"
    return cfg
}

setLastCfg(){
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

SaveConfig(name,config) {
    For var,val in config {
        setIniVal(config,var,val)
    }
}

getIniVal(section,var) {
    val := "N/A"
    IniRead, val, config.ini, %section%, %var%, N/A
    return val    
}
     
setIniVal(section,var,value) {
    IniWrite, %value%, config.ini, %section%, %var%
}

;end_region