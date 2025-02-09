## Description
Deep clones an object, with an option to specify a maximum depth.
This function works by first identifying the base type. For most types, including custom types, DeepClone will produce an object that is the same type as the original, and will have the same methods and properties available as the original. See "Limitations" for situations when this may not be possible.
After identifying the base type and constructing the new object, the original object's properties are iterated, recursively deep cloning any nested objects. For dynamic properties, the `GetOwnPropDesc` function is called, and the result is assigned directly to the new object's property. See https://www.autohotkey.com/docs/v2/lib/Object.htm#GetOwnPropDesc for more information.
If the original object is (or inherits from) Array or Map, any contained items are copied as well, recursively deep cloning any values which are objects.
`DeepClone` gracefully handles duplicate objects by keeping track of the Ptr addresses of each cloned object. When `DeepClone` encounters an object that has been deep cloned already, `DeepClone` correctly assigns a reference to the copy of said object, instead of deep cloning the object again.

## Additional Features
`DeepClone` has one (included) dependency, function `GetObjectFromString`. `GetObjectFromString` takes a string input and returns a reference to the object. This is necessary to handle classes that have "." in the name, as `%'ParentClass.ChildClass'%` does not work.

## AHK forum post
[https://github.com/Nich-Cebolla/AutoHotkey-Object.Prototype.DeepClone](https://www.autohotkey.com/boards/viewtopic.php?f=83&t=135780)

## Parameters
- @param {Object} Self - The object to be deep cloned. If calling this from an instance, exclude this parameter.
- @param {Integer} [Depth=-1]  - The maximum depth to clone. A value of -1 indicates no limit.

## Limitations
**Note** - This limitation is addressed by `DeepCloneA`. If you need to deep clone an object that fails to have its type set correctly by `DeepClone`, you can overcome this limitation by using `DeepCloneA` and providing a set of default parameters to pass to the object's constructor.

Though any object may be deep cloned, the function may fail to set the correct type in some situations. `DeepClone` sets the object type by following this sequence of actions:
- `DeepClone` attempts to create an instance of the object's class. For objects which are class objects, `DeepClone` creates an instance of `Class`.
- If this fails (for example, if the constructor requires input parameters), `DeepClone` checks if the object inherits from `Map` or `Array`, and creates a new object from the respective class. If the object does not inherit from `Map` or `Array`, then an instance of `Object` is created.
- The new object's base is re-assigned to be the same as the original's base. This is where failure will occur for some types, because AutoHotkey prevents assigning a base type in situations where the object and the target base object are fundamentally different. If this occurs, `DeepClone` continues to deep clone the object, but the new object remains an instance of `Object`. The primary consequence of this is that some methods which get added to the new object would be invalid, and any properties that refer to something inherent to the original base type would be meaningless in relation to the new object.

## Contents

### Object.Prototype.DeepClone.ahk
Contains the code for the DeepClone method.

### Object.Prototype.DeepCloneA.ahk
Performs the same function as `DeepClone`, but addresses the problem described in "Limitations". Also requires an additional parameter.
- @param {Map} ConstructorParams - A map of constructor parameters, where the key is the class name (use `Type(ObjToBeCloned)` as the key), and the value is an array of values that will be passed to the constructor.

### GetObjectFromString.ahk

### DeepClone-test.ahk
A test case that demonstrates the functionality of `DeepClone`.

### DeepCloneA-test.ahk
A test case that demonstrates the functionality of `DeepCloneA`.

## Changelog
<span style="font-size:18;">2025-02-08
- Uploaded library
- A bit later, wrote DeepCloneA and added it. Also separated GetObjectFromString into its own file.
