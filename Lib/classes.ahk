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

    Cfg[] {
        get {
            cfg := this.getIniVal("lastsettings","lastCfg")
            return (cfg="N/A" ? "HomeNox" : cfg)
        }

        set {
            this.setIniVal("lastsettings","lastCfg",value)
        }
    }


    getIniVal(section,var) {
        IniRead, val, %this.inifile%, %section%, %var%, N/A
        return val
    }
        
    setIniVal(section,var,value) {
        IniWrite, %value%, %this.inifile%, %section%, %var%
    }

}


class Config extends Property{
    static vars := ["WINDOW_NAME","ORIGIN_X","ORIGIN_Y","SIZE_X","SIZE_Y","OFFSET_X","OFFSET_Y","PADDING"]
    
    __New(){
        this._cfgs:=this.Configs 
    }

    getConfigs(){
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