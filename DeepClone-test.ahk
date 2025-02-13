
#Include Object.Prototype.DeepClone.ahk
#Include GetObjectFromString.ahk
/*
    I just load this in a debugger and put a breakpoint on "sleep 1" to inspect it.
*/
class TestObject {
    static Get(TestID) {
        switch TestID {
            case 1: return TestObject.A_Object
        }
    }
    
    static A_Object := {
        B1_Obj: {C1_Obj: {D1_Prop: 'Val'}, C1_Map: Map('D1_Item', 'Val'), C1_Array: ['Val']}
      , B2_Map: Map('C2_Obj', {D2_Prop: 'Val'}, 'C2_Map', Map('D2_Item', 'Val'), 'C2_Array', ['Val'])
      , B3_Array: [{D3_Prop: 'Val'}, Map('D3_Item', 'Val'), ['Val']]
    }
    static A_Map := Map(
        'B1_Obj', {C1_Obj: {D1_Prop: 'Val'}, C1_Map: Map('D1_Item', 'Val'), C1_Array: ['Val']}
      , 'B2_Map', Map('C2_Obj', {D2_Prop: 'Val'}, 'C2_Map', Map('D2_Item', 'Val'), 'C2_Array', ['Val'])
      , 'B3_Array', [{D3_Prop: 'Val'}, Map('D3_Item', 'Val'), ['Val']]
    )
    static A_Array := [
        {C1_Obj: {D1_Prop: 'Val'}, C1_Map: Map('D1_Item', 'Val'), C1_Array: ['Val']}
      , Map('C2_Obj', {D2_Prop: 'Val'}, 'C2_Map', Map('D2_Item', 'Val'), 'C2_Array', ['Val'])
      , [{D3_Prop: 'Val'}, Map('D3_Item', 'Val'), ['Val']]
    ]
    static ErrorProp {
        Get {
            return this.__ErrorProp
        }
    }
}

; To demonstrate it successfully handles circular references.
TestObject.A_Object.B1_Obj.C1_Obj.Example := TestObject.A_Object

new := TestObject.DeepClone()

; To demonstrate that the new object is, indeed, new.
_RecurseDelete(TestObject)
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
