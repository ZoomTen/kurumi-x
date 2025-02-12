import ./globals
import flatty
import ./synth
import ./utils/utils
import supersnappy
# import modules/[
#     oscillatorModule, 
#     fmModule, 
#     mixerModule, 
#     amplifierModule, 
#     absoluterModule, 
#     rectifierModule, 
#     clipperModule, 
#     inverterModule, 
#     pdModule, 
#     syncModule,
#     morphModule,
#     expModule,
#     module,
#     multModule,
#     dualWaveModule,
#     averageModule,
#     fmProModule,
#     phaseModule,
#     waveFoldModule,
#     waveMirrorModule,
#     dcOffsetModule,
#     chordModule,
#     feedbackModule,
#     downsamplerModule,
#     quantizerModule,
#     outputModule,
#     lfoModule,
#     softClipModule,
#     waveFolderModule,
#     splitterModule,
#     normalizerModule,
#     bqFilterModule,
#     unisonModule,
#     noiseModule
# ]
import modules
import serializationObject
import synthesizeWave
import chronicles

const defaultSavestateName = "backup.bak"

type
    SynthSerializeObject = object
        moduleList*: array[GRID_SIZE_X * GRID_SIZE_Y, ModuleSerializationObject]
        waveDims*: VecI32 = VecI32(x: 32, y: 15)
        oversample*: int32
        outputIndex*: uint16
        macroLen*: int32
        macroFrame*: int32

proc saveState*() =
    var obj: SynthSerializeObject
    obj.waveDims = synthContext.waveDims
    obj.oversample = synthContext.oversample
    obj.outputIndex = synthContext.outputIndex
    obj.macroLen = synthContext.macroLen
    obj.macroFrame = synthContext.macroFrame

    for n in 0..<synthContext.moduleList.len:
        let m = synthContext.moduleList[n]
        if(m == nil):
            obj.moduleList[n] = ModuleSerializationObject(mType: NULL, data: "")
            continue
        obj.moduleList[n] = m.serialize()

    let str = "VAMPIRE " & compress(toFlatty(obj))
    info "Saving Kurumi-X state", fileName=defaultSavestateName
    writeFile(defaultSavestateName, str)

proc unserializeModule(mData: ModuleSerializationObject): SynthModule =
    var module: SynthModule
    case mData.mType:
        of ABSOLUTER:
            module = mData.data.fromFlatty(AbsoluterModule)
        of AMPLIFIER:
            module = mData.data.fromFlatty(AmplifierModule)
        of AVERAGE:
            module = mData.data.fromFlatty(AverageModule)
        of BQ_FILTER:
            module = mData.data.fromFlatty(BqFilterModule)
        of CH_FILTER:
            module = mData.data.fromFlatty(ChebyshevFilterModule)
        of CHORD:
            module = mData.data.fromFlatty(ChordModule)
        of CLIPPER:
            module = mData.data.fromFlatty(ClipperModule)
        of DC_OFFSET:
            module = mData.data.fromFlatty(DcOffsetModule)
        of DOWNSAMPLER:
            module = mData.data.fromFlatty(DownsamplerModule)
        of DUAL_WAVE:
            module = mData.data.fromFlatty(DualWaveModule)
        of EXPONENT:
            module = mData.data.fromFlatty(ExpModule)
        of FEEDBACK:
            module = mData.data.fromFlatty(FeedbackModule)
        of FM:
            module = mData.data.fromFlatty(FmodModule)
        of FM_PRO:
            module = mData.data.fromFlatty(FmProModule)
        of INVERTER:
            module = mData.data.fromFlatty(InverterModule)
        of LFO:
            module = mData.data.fromFlatty(LfoModule)
        of MIXER:
            module = mData.data.fromFlatty(MixerModule)
        of MORPHER:
            module = mData.data.fromFlatty(MorphModule)
        of MULT:
            module = mData.data.fromFlatty(MultModule)
        of NOISE:
            module = mData.data.fromFlatty(NoiseOscillatorModule)
        of NORMALIZER:
            module = mData.data.fromFlatty(NormalizerModule)
        of SINE_OSC:
            module = mData.data.fromFlatty(SineOscillatorModule)
        of TRI_OSC:
            module = mData.data.fromFlatty(TriangleOscillatorModule)
        of SAW_OSC:
            module = mData.data.fromFlatty(SawOscillatorModule)
        of PULSE_OSC:
            module = mData.data.fromFlatty(SquareOscillatorModule)
        of WAVE_OSC:
            module = mData.data.fromFlatty(WavetableOscillatorModule)
        of OUTPUT:
            module = mData.data.fromFlatty(OutputModule)
        of PHASE_DIST:
            module = mData.data.fromFlatty(PdModule)
        of PHASE:
            module = mData.data.fromFlatty(PhaseModule)
        of QUANTIZER:
            module = mData.data.fromFlatty(QuantizerModule)
        of RECTIFIER:
            module = mData.data.fromFlatty(RectifierModule)
        of SOFT_CLIP:
            module = mData.data.fromFlatty(SoftClipModule)
        of SPLITTER:
            module = mData.data.fromFlatty(SplitterModule)
        of SYNC:
            module = mData.data.fromFlatty(SyncModule)
        of UNISON:
            module = mData.data.fromFlatty(UnisonModule)
        of WAVE_FOLDER:
            module = mData.data.fromFlatty(WaveFolderModule)
        of WAVE_FOLD:
            module = mData.data.fromFlatty(WaveFoldModule)
        of MIRROR:
            module = mData.data.fromFlatty(WaveMirrorModule)
        of QUAD_WAVE_ASM:
            module = mData.data.fromFlatty(QuadWaveAssemblerModule)
        of CALCULATOR:
            module = mData.data.fromFlatty(CalculatorModule)
        of FAST_FEEDBACK:
            module = mData.data.fromFlatty(FastFeedbackModule)
        of FAST_BQ_FILTER:
            module = mData.data.fromFlatty(FastBqFilterModule)
        of BOX:
            let sData = mData.data.fromFlatty(BoxModuleSerialize)
            var moduleBox = BoxModule()
            var modList: array[16 * 16, SynthModule]
            for i in 0..<sData.data.len():
                modList[i] = sData.data[i].unserializeModule()
            moduleBox.inputIndex = sData.inputIndex
            moduleBox.outputIndex = sData.outputIndex
            moduleBox.inputs = sData.inputs
            moduleBox.outputs = sData.outputs
            moduleBox.moduleList = modList
            moduleBox.name = sData.name
            return moduleBox
        else:
            module = nil
    return module       

var moduleClipboard*: ModuleSerializationObject

proc unserializeModules(data: SynthSerializeObject) =
    for i in 0..<data.moduleList.len:
        let mData = data.moduleList[i]
        synthContext.moduleList[i] = mData.unserializeModule()

proc unserializeFromClipboard*(): SynthModule =
    return moduleClipboard.unserializeModule()

proc loadState*() =
    try:
        info "Opening existing Kurumi-X state", fileName=defaultSavestateName
        let str = readFile(defaultSavestateName)
        if(str.substr(0, "VAMPIRE ".len - 1) != "VAMPIRE "):
            error "Invalid state file!"
            return
        let data = str.substr("VAMPIRE ".len).uncompress().fromFlatty(SynthSerializeObject)
        # let data = str.fromFlatty(SynthSerializeObject)
        synthContext.waveDims = data.waveDims
        synthContext.oversample = data.oversample
        synthContext.outputIndex = data.outputIndex
        synthContext.macroLen = data.macroLen
        synthContext.macroFrame = data.macroFrame
        data.unserializeModules()
        synthesize()

    except IOError:
        error "IOError, couldn't load from state"
        return
