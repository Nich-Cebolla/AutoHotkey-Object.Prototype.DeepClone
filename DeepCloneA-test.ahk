
#Include Object.Prototype.DeepCloneA.ahk
#Include GetObjectFromString.ahk
/*
    I just load this in a debugger and put a breakpoint on "sleep 1" to inspect it.
*/
class TestObject {
    __New(Param1, Param2, Param3?, ParamWithDefault := 4) {
        this.Param1 := Param1
        this.Param2 := Param2
        if IsSet(Param3) {
            this.Param3 := Param3
            this.DefineProp('Method3', { Call: (*) => 3 })
        } else {
            this.DefineProp('Method3_b', { Call: (*) => '3-b' })
        }
        this.ParamWithDefault := ParamWithDefault
    }

    Get(TestID) {
        switch TestID {
            case 1: return TestObject.A_Object
        }
    }
    
    A_Object := {
        B1_Obj: {C1_Obj: {D1_Prop: 'Val'}, C1_Map: Map('D1_Item', 'Val'), C1_Array: ['Val']}
      , B2_Map: Map('C2_Obj', {D2_Prop: 'Val'}, 'C2_Map', Map('D2_Item', 'Val'), 'C2_Array', ['Val'])
      , B3_Array: [{D3_Prop: 'Val'}, Map('D3_Item', 'Val'), ['Val']]
    }
    A_Map := Map(
        'B1_Obj', {C1_Obj: {D1_Prop: 'Val'}, C1_Map: Map('D1_Item', 'Val'), C1_Array: ['Val']}
      , 'B2_Map', Map('C2_Obj', {D2_Prop: 'Val'}, 'C2_Map', Map('D2_Item', 'Val'), 'C2_Array', ['Val'])
      , 'B3_Array', [{D3_Prop: 'Val'}, Map('D3_Item', 'Val'), ['Val']]
    )
    A_Array := [
        {C1_Obj: {D1_Prop: 'Val'}, C1_Map: Map('D1_Item', 'Val'), C1_Array: ['Val']}
      , Map('C2_Obj', {D2_Prop: 'Val'}, 'C2_Map', Map('D2_Item', 'Val'), 'C2_Array', ['Val'])
      , [{D3_Prop: 'Val'}, Map('D3_Item', 'Val'), ['Val']]
    ]
    ErrorProp {
        Get {
            return this.__ErrorProp
        }
    }
}

instance := TestObject(1, 2, 3, 4)

; To demonstrate it successfully handles circular references.
instance.A_Object.B1_Obj.C1_Obj.Example := instance.A_Object

ConstructorParams := Map(Type(instance), [5, 6, , 8])

new := instance.DeepCloneA(ConstructorParams)

; To demonstrate that the new object is, indeed, new.
_RecurseDelete(instance)
_RecurseDelete(Obj) {
    list := []
    for Prop in Obj.OwnProps() {
        list.Push(Prop)
    }
    for Prop in list {
        if Prop == 'Example'
            continue
        Desc := Obj.GetOwnPropDesc(Prop)
        if Desc.HasOwnProp('Value') && IsObject(Desc.Value) {
            _RecurseDelete(Desc.Value)
        }
        Obj.DeleteProp(Prop)
    }
}

sleep 1