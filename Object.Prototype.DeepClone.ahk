
/*
    Dependency
        GetObjectFromString.ahk
*/

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
    return _Recurse(Result, Self)

    _Recurse(Target, Subject) {
        CurrentDepth++
        for Prop in Subject.OwnProps() {
            if Prop  == 'Base'
                continue
            Desc := Subject.GetOwnPropDesc(Prop)
            if Desc.HasOwnProp('Value')
                Target.DefineProp(Prop, { Value: _ProcessValue(Desc.Value) })
            else
                Target.DefineProp(Prop, Desc)
        }
        if Target is Array {
            n := 0
            loop {
                Target.Length += 1000
                loop 1000 {
                    if ++n > Subject.Length
                        break 2
                    Target[n] := _ProcessValue(Subject[n])
                }
            }
            Target.Length := n - 1
            Target.Capacity := Subject.Capacity
        } else if Target is Map {
            for Key, Val in Subject
                    Target[Key] := _ProcessValue(Val)
            Target.Capacity := Subject.Capacity
        }
        CurrentDepth--
        return Target
    }

    _GetTarget(Subject) {
        if Type(Subject) == 'Prototype'
            Target := _GetTargetHelper(Subject.__Class)
        else {
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
                if Subject Is Map
                    return Map()
                else if Subject is Array
                    return Array()
                else
                    return Object()
            }
        }
    }
    _ProcessValue(Val) {
        if Type(Val) == 'ComValue' || Type(Val) == 'ComObject'
            return Val
        if IsObject(Val) {
            if PtrList.Has(ObjPtr(Val))
                return PtrList[ObjPtr(Val)]
            if Depth == -1 || CurrentDepth < Depth {
                PtrList.Set(ObjPtr(Val), _Target := _GetTarget(Val))
                return _Recurse(_Target, Val)
            } else
                return Val
        } else
            return Val
    }
}
