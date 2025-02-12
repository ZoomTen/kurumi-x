import ../utils/utils
import ../serializationObject

type
    SynthModule* = ref object of RootObj
        inputs*  : seq[Link]
        outputs* : seq[Link]
        update*: bool = true

method synthesize*(module: SynthModule, x: float64, pin: int): float64 {.base.} =
    return x

method serialize*(module: SynthModule): ModuleSerializationObject {.base.} =
    return ModuleSerializationObject(mType: ModuleType.NULL, data: "")