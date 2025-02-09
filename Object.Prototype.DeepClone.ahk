
Object.Prototype.DefineProp('DeepClone', { Call: OBJECT_DEEPCLONE })
/**
 * @description - Performs a deep clone, with an optional maximum depth.
 * @param {Object} Self - The object to be deep cloned. If calling this method from an instance,
 * exclude this parameter.
 * @param {Integer} [Depth=-1] - The maximum depth to clone. A value of -1 indicates no limit.
 * @returns {Object} - The deep cloned object.
 */
OBJECT_DEEPCLONE(Self, Depth := -1) {
    PtrList := Map(ObjPtr(Self), Result := _GetTarget(Self))
    CurrentDepth := 1
    return _Recurse(Result, Self, PtrList, &CurrentDepth)

    _Recurse(Target, Subject, PtrList, &CurrentDepth) {
        CurrentDepth++
        for Prop in Subject.OwnProps() {
            if Prop  == 'Base'
                continue
            Desc := Subject.GetOwnPropDesc(Prop)
            if Desc.HasOwnProp('Value') {
                if Type(Desc.Value) == 'ComValue' || Type(Desc.Value) == 'ComObject' {
                    Target.DefineProp(Prop, { Value: Desc.Value })
                    continue
                }
                if IsObject(Desc.Value) {
                    if PtrList.Has(ObjPtr(Desc.Value)) {
                        Target.DefineProp(Prop, { Value: PtrList[ObjPtr(Desc.Value)] })
                        continue
                    }
                    if Depth == -1 || CurrentDepth < Depth {
                        PtrList.Set(ObjPtr(Desc.Value), _Target := _GetTarget(Desc.Value))
                        Target.DefineProp(Prop, { Value: _Recurse(_Target, Desc.Value, PtrList, &CurrentDepth) })
                    } else {
                        Target.DefineProp(Prop, { Value: Desc.Value })
                    }
                } else {
                    Target.DefineProp(Prop, { Value: Desc.Value })
                }
            } else {
                Target.DefineProp(Prop, Desc)
            }
        }
        ; If Subject is a custom class that has implemented an __Enum method, then the items are
        ; stored somewhere on a property anyway, and so repeating __Enum is likely not necessary.
        ; If the items are produced as a result of a calculation, then we do not need to capture
        ; those; __Enum can be called on the resulting cloned object to get them. Classes based on
        ; Array and Map are the exception, as they themselves are the containers of the items, and
        ; so there is no property from which to retrieve the items; we have to all __Enum to get them.
        if Target is Array {
            n := Flag := 0
            loop {
                Target.Length += 1000
                loop 1000 {
                    if !Subject.Has(++n) {
                        Flag := 1
                        break
                    }
                    Val := Subject[n]
                    if Type(Val) == 'ComValue' || Type(Val) == 'ComObject' {
                        Target[n] := Val
                        continue
                    }
                    if IsObject(Val) {
                        if PtrList.Has(ObjPtr(Val)) {
                            Target[n] := PtrList[ObjPtr(Val)]
                            continue
                        }
                        if Depth == -1 || CurrentDepth < Depth {
                            PtrList.Set(ObjPtr(Val), _Target := _GetTarget(Val))
                            Target[n] :=  _Recurse(_Target, Val, PtrList, &CurrentDepth)
                        } else {
                            Target[n] := Val
                        }
                    } else {
                        Target[n] := Val
                    }
                }
                if Flag
                    break
            }
            Target.Length := n
        } else if Target is Map {
            for Key, Val in Subject {
                if Type(Val) == 'ComValue' || Type(Val) == 'ComObject' {
                    Target[Key] := Val
                    continue
                }
                if IsObject(Val) {
                    if PtrList.Has(ObjPtr(Val)) {
                        Target[Key] := PtrList[ObjPtr(Val)]
                        continue
                    }
                    if Depth == -1 || CurrentDepth < Depth {
                        PtrList.Set(ObjPtr(Val), _Target := _GetTarget(Val))
                        Target[Key] :=  _Recurse(_Target, Val, PtrList, &CurrentDepth)
                    } else {
                        Target[Key] := Val
                    }
                } else {
                    Target[Key] := Val
                }
            }
        }
        CurrentDepth--
        return Target
    }

    _GetTarget(Subject) {
        if Type(Subject) == 'Prototype' {
            Target := _GetTargetHelper(Subject.__Class)
        } else {
            obj := Subject.Base
            while !obj.HasOwnProp('__Class') {
                obj := obj.Base
                if A_Index >= 15 ; Arbitrary limit to prevent infininite loop.
                    throw Error('Failed to identify subject base type.', -1)
            }
            Target := _GetTargetHelper(obj.__Class)
        }
        try
            ObjSetBase(Target, Subject.Base)
        return Target

        _GetTargetHelper(ClassString) {
            try
                return GetObjectFromString(ClassString)()
            catch {
                if Subject Is Map {
                    return Map()
                } else if Subject is Array {
                    return Array()
                } else {
                    return Object()
                }
            }
        }
    }
}

/**
 * @description -
 * Use this function when you need to convert a string to an object reference, and the object
 * is nested within an object path. For example, we cannot get a reference to the class `Gui.Control`
 * by setting the string in double derefs like this: `obj := %'Gui.Control'%. Instead, we have to
 * traverse the path to get each object along the way, which is what this function does.
 * @param {String} Path - The object path.
 * @returns {*} - The object if it exists in the scope. Else, returns an empty string.
 * @example
    class MyClass {
        class MyNestedClass {
            static MyStaticProp := {prop1_1: 1, prop1_2: {prop2_1: {prop3_1: 'Hello, World!'}}}
        }
    }
    obj := GetObjectFromString('MyClass.MyNestedClass.MyStaticProp.prop1_2.prop2_1')
    OutputDebug(obj.prop3_1) ; Hello, World!
 * @
 */
GetObjectFromString(Path) {
    Split := StrSplit(Path, '.')
    if !IsSet(%Split[1]%)
        return
    OutObj := %Split[1]%
    i := 1
    while ++i <= Split.Length {
        if !OutObj.HasOwnProp(Split[i])
            return
        OutObj := OutObj.%Split[i]%
    }
    return OutObj
}
