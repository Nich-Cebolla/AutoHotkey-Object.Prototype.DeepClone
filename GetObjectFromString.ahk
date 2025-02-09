
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
