import ./module
import ../globals
import ../utils/utils

type
    MultModule* = ref object of SynthModule

proc constructMultModule*(): MultModule =
    var module = new MultModule
    module.outputs = @[
        Link(moduleIndex: -1, pinIndex: -1)]
    module.inputs = @[
        Link(moduleIndex: -1, pinIndex: -1),
        Link(moduleIndex: -1, pinIndex: -1)]
    return module

method synthesize*(module: MultModule, x: float64, pin: int): float64 =
    var moduleA: SynthModule = nil
    var moduleB: SynthModule = nil

    if(module.inputs[0].moduleIndex > -1):
        moduleA = synthContext.moduleList[module.inputs[0].moduleIndex]
    if(module.inputs[1].moduleIndex > -1):
        moduleB = synthContext.moduleList[module.inputs[1].moduleIndex]
    
    if(moduleA == nil and moduleB == nil): return 0

    let a = if(moduleA != nil): moduleA.synthesize(x, module.inputs[0].pinIndex) else: 1.0
    let b = if(moduleB != nil): moduleB.synthesize(x, module.inputs[1].pinIndex) else: 1.0

    return a * b

import ../serializationObject
import flatty

method serialize*(module: MultModule): ModuleSerializationObject =
    return ModuleSerializationObject(mType: ModuleType.MULT, data: toFlatty(module))
