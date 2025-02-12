import ./module
import ../globals
import ../utils/utils

type
    InverterModule* = ref object of SynthModule

proc constructInverterModule*(): InverterModule =
    var module = new InverterModule
    module.outputs = @[Link(moduleIndex: -1, pinIndex: -1)]
    module.inputs = @[Link(moduleIndex: -1, pinIndex: -1)]
    return module

method synthesize*(module: InverterModule, x: float64, pin: int): float64 =
    if(module.inputs[0].moduleIndex < 0): return 0
    let moduleA = synthContext.moduleList[module.inputs[0].moduleIndex]
    if(moduleA == nil): return 0.0 else: return -moduleA.synthesize(x, module.inputs[0].pinIndex)

import ../serializationObject
import flatty

method serialize*(module: InverterModule): ModuleSerializationObject =
    return ModuleSerializationObject(mType: ModuleType.INVERTER, data: toFlatty(module))
