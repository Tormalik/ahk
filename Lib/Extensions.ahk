
; https://autohotkey.com/boards/viewtopic.php?t=7124
;String Join
; array := ["a", "e", "fish"]
; ", ".join("a", "c", "fish")
; ", ".join(array)
; ", ".join(array*)
Join(s,p*){
  static _:="".base.Join:=Func("Join")
  for k,v in p
  {
    if isobject(v)
      for k2, v2 in v
        o.=s v2
    else
      o.=s v
  }
  return SubStr(o,StrLen(s)+1)
}


Array_DeepClone(Array, Objs:=0) {
    if !Objs
        Objs := {}
    Obj := Array.Clone()
    Objs[&Array] := Obj ; Save this new array
    For Key, Val in Obj
        if (IsObject(Val)) ; If it is a subarray
            Obj[Key] := Objs[&Val] ; If we already know of a refrence to this array
            ? Objs[&Val] ; Then point it to the new array
            : Array_DeepClone(Val,Objs) ; Otherwise, clone this sub-array

    return Obj
}


timediff(st) {
   transform,S,MOD,st,60
   stringlen,L1,S
   if L1 =1
   S=0%S%
   if S=0
   S=00

   M1 :=(st/60)
   transform,M2,MOD,M1,60
   transform,M3,Floor,M2
   stringlen,L2,M3
   if L2 =1
   M3=0%M3%
   if M3=0
   M3=00

   H1 :=(M1/60)
   transform,H2,Floor,H1
   stringlen,L2,H2
   if L2=1
   H2=0%H2%
   if H2=0
   H2=00
   result= %H2%:%M3%:%S%

   return result
}

Null(){
    return
}

