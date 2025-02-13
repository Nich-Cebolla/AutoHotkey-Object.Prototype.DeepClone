
/*
    Dependency
        GetObjectFromString.ahk
*/

Object.Prototype.DefineProp('DeepCloneA', { Call: OBJECT_DEEPCLONEA })
/**
 * @description - Performs a deep clone, with an optional maximum depth. This version was created
 * to broaden the range of types that DeepClone can handle. Since ObjSetBase cannot set an object's
 * base to a type that is fundamentally different from the object's own base, the original DeepClone
 * can sometimes fail to set the correct type. This version allows you to define one or more sets
 * of parameters that will be passed to the associated class constructor any time an object of that
 * type is processed.
 * @param {Object} Self - The object to be deep cloned. If calling this method from an instance,
 * exclude this parameter.
 * @param {Map} ConstructorParams - A map of constructor parameters, where the key is the class
 * name (use `Type(ObjToBeCloned)` as the key), and the value is an array of values that will be
 * passed to the constructor. Any number of key-value pairs can be present in the object.
 * @param {Integer} [Depth=-1] - The maximum depth to clone. A value of -1 indicates no limit.
 * @returns {Object} - The deep cloned object.
 */
OBJECT_DEEPCLONEA(Self, ConstructorParams, Depth := -1) {
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
