import ./module
import ../globals
import ../utils/utils
import math

type
    WaveFoldModule* = ref object of SynthModule

proc constructWaveFoldModule*(): WaveFoldModule =
    var module = new WaveFoldModule
    module.outputs = @[Link(moduleIndex: -1, pinIndex: -1)]
    module.inputs = @[Link(moduleIndex: -1, pinIndex: -1)]
    return module


method synthesize*(module: WaveFoldModule, x: float64, pin: int): float64 =
    if(module.inputs[0].moduleIndex < 0): return 0
    let moduleA = synthContext.moduleList[module.inputs[0].moduleIndex]
    if(moduleA == nil): 
        return 0.0
    else:
        let output = moduleA.synthesize(moduloFix(x * 2, 2 * PI), module.inputs[0].pinIndex)
        if(x < PI): return output else: return -output

import ../serializationObject
import flatty

method serialize*(module: WaveFoldModule): ModuleSerializationObject =
    return ModuleSerializationObject(mType: ModuleType.WAVE_FOLD, data: toFlatty(module))
