class Ini {
    __New(inifile) {
        this.inifile :=inifile
    }

    Char[] {
        get {
            char := this.getIniVal("lastsettings","lastChar")
            return (cfg="N/A" ? "gideon" : char)
        }

        set {
            this.setIniVal("lastsettings","lastChar",value)
        }
    }

    Config[] {
        get {
            cfg := this.getIniVal("lastsettings","lastCfg")
            return (cfg="N/A" ? "HomeNox" : cfg)
        }

        set {
            this.setIniVal("lastsettings","lastCfg",value)
        }
    }

    AllConfigs[] {
        get {
            if (_cfgs
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
    }

    saveVars(section,vars) {
        For key,val in vars {
            setIniVal(section,key,value)
        }
    }

    loadVars(section,ByRef vars,default:="") {
        if(strlen(default)>0) {
        For key,val in vars {
            val := getIniVal(default,key)
            if (val != "N/A") {
                vars[key]:=val
            }
        }
        }
        For key,val in vars {
            val := getIniVal(section,key)
            if (val != "N/A") {
                vars[key]:=val
            }
        }
        return vars
    }

    getIniVal(section,var) {
        IniRead, val, %this.inifile%, %section%, %var%, N/A
        return val
    }
        
    setIniVal(section,var,value) {
        IniWrite, %value%, %this.inifile%, %section%, %var%
    }

}


class Config {
    static vars := ["WINDOW_NAME","ORIGIN_X","ORIGIN_Y","SIZE_X","SIZE_Y","OFFSET_X","OFFSET_Y","PADDING"]
    
    __New(ini,name) {
        this.name:=name
        this.ini :=ini
    }

    save(){

    }

    load(){

    }
}