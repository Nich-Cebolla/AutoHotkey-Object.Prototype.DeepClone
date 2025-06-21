## Description

Recursively copies an object's properties onto a new object. For all new objects, `ObjDeepClone` attempts to set the new object's base to the same base as the subject. See "Limitations" for situations when this may not be possible. For objects that inherit from `Map` or `Array`, clones the items in addition to the properties.

When `ObjDeepClone` encounters an object that has been processed already, `ObjDeepClone` assigns a reference to the copy of said object, instead of processing the object again.

## AHK forum post

[https://www.autohotkey.com/boards/viewtopic.php?f=83&t=135780](https://www.autohotkey.com/boards/viewtopic.php?f=83&t=135780)

## Parameters

- {*} Self - The object to be deep cloned. If calling this method from an instance, exclude this parameter.
- {Map} [ConstructorParams] - A map of constructor parameters, where the key is the class name (use `ObjToBeCloned.__Class` as the key), and the value is an array of values that will be passed to the constructor. Using `ConstructorParams` can allow `ObjDeepClone` to create correctly-typed objects in cases where normally AHK will not allow setting the type using `ObjSetBase()`.
- {Integer} [Depth = 0] - The maximum depth to clone. A value equal to or less than 0 will result in no limit.

## Limitations

- `ObjDeepClone` may fail to set the correct type in some situations. This limitation can sometimes be avoided by using the parameter `ConstructorParams`. `ObjDeepClone` sets the object type by following this sequence of actions:
  - `ObjDeepClone` attempts to create an instance of the object's class.
  - If this fails (for example, if the constructor requires input parameters), `ObjDeepClone` checks if the object inherits from `Map` or `Array`, and creates a new object from the respective class. If the object does not inherit from `Map` or `Array`, then an instance of `Object` is created.
  - The new object's base is re-assigned to be the same as the original's base. This is where failure will occur for some types, because AutoHotkey prevents assigning a base type in situations where the object and the target base object are fundamentally different. If this occurs, `ObjDeepClone` continues to deep clone the object, but the new object remains an instance of `Object`.
- For each of `Menu`, `MenuBar`, `Gui`, `Gui.Control` and its derivatives, `Func` and its derivatives, `ComValue` and its derivatives, `Primitive` and its derivatives - These cannot be effectively cloned using `ObjDeepClone`.
- `RegExMatchInfo` objects will not have their subcapture groups copied to the new object.
- Attempting to clone a `File` object may produce unexpected results.
- `ComValue` objects are ignored by `ObjDeepClone`. References to the original object
are set on the new object instead of attempting to clone them.
- `ObjDeepClone` has not been tested using an instance of `InputHook`.

## Changelog

2025-06-21
- Fixed the initial depth.

2025-06-09
**Breaking**
- Renamed "Object.Prototype.DeepClone.ahk" to "ObjDeepClone.ahk".
- Renamed `OBJECT_DEEPCLONE` to `ObjDeepClone`.
- Removed `DeepCloneA`. Its functionality is consolidated in `ObjDeepClone`.
- Changed the default value of `Depth` to 0.
- Removed dependency `GetObjectFromString` and placed the function as a nested function in `ObjDeepClone`.
- Cleaned up code.
- Adjusted wording in function description.
- Expanded the "Limitations" section of the documentation.
- Cleaned up documentation.

2025-02-13
- Added `if Subject.Has(n)` conditional to Array block.

2025-02-13
- Refactored the function loop.
- Removed long comment about `__Enum`.
- Clarified `DeepCloneA` description.
- Removed unnecessary parameters within `_Recurse` function statement.
- Added `Target.Capacity := Subject.Capacity` for both `Array` and `Map` blocks.

2025-02-11
- Fixed a logical error that would cause cloning an array to terminate early when encountering an unset index.

2025-02-08
- Uploaded library
- A bit later, wrote DeepCloneEx and added it. Also separated GetObjectFromString into its own file.
