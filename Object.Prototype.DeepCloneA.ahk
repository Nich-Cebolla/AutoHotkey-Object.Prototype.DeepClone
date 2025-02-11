
/*
    Dependency
        GetObjectFromString.ahk
*/

Object.Prototype.DefineProp('DeepCloneA', { Call: OBJECT_DEEPCLONEA })
/**
 * @description - Performs a deep clone, with an optional maximum depth. This version was created
 * to broaden the range of types that DeepClone can handle. Since ObjSetBase cannot set an object's
 * base to a type that is fundamentally different from itself or its own base, the original DeepClone
 * can sometimes fail to set the correct type. This version allows the user to provide a set of
 * default parameters to pass the constructor, potentially allowing DeepCloneA to produce a copy
 * of any type. This will not work with objects that are prototypes, because `Type(obj)` returns
 * "Prototype", instead of the class name.
 * @param {Object} Self - The object to be deep cloned. If calling this method from an instance,
 * exclude this parameter.
 * @param {Map} ConstructorParams - A map of constructor parameters, where the key is the class
 * name (use `Type(ObjToBeCloned)` as the key), and the value is an array of values that will be
 * passed to the constructor.
 * @param {Integer} [Depth=-1] - The maximum depth to clone. A value of -1 indicates no limit.
 * @returns {Object} - The deep cloned object.
 */
OBJECT_DEEPCLONEA(Self, ConstructorParams, Depth := -1) {
    PtrList := Map(ObjPtr(Self), Result := _GetTarget(Self))
    CurrentDepth := 1
    return _Recurse(Result, Self, PtrList, &CurrentDepth)

    _Recurse(Target, Subject, PtrList, &CurrentDepth) {
        CurrentDepth++
        for Prop in Subject.OwnProps() {
            if Prop == 'Example'
                sleep 1
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
                    if ++n > Subject.Length {
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
            Target.Length := n - 1
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
        List := []
        for Prop in Target.OwnProps() {
            if Prop == 'Base'
                continue
            if !Subject.HasOwnProp(Prop)
                List.Push(Prop)
        }
        for Prop in List
            Target.DeleteProp(Prop)
        CurrentDepth--
        return Target
    }

    _GetTarget(Subject) {
        if ConstructorParams.Has(Type(Subject)) {
            Target := GetObjectFromString(Type(Subject))(ConstructorParams.Get(Type(Subject))*)
        } else {
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
