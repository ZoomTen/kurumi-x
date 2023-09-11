import imgui, imgui/[impl_opengl, impl_glfw]#, nimgl/imnodes
import nimgl/[opengl, glfw]
import ../synthesizer/synth
import ../synthesizer/linkManagement
import ../synthesizer/synthesizeWave
# import ../synthesizer/modules/[
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
#     noiseModule,
#     module
# ]
import ../synthesizer/modules
import ../synthesizer/globals
import ../synthesizer/serialization
import chronicles

const modEntries = [
    "Output".cstring,
    "Oscillator",
    "Phase Modulation",
]

type
    ActionType = enum
        OUTPUT,
        OSCILLATOR,
        PHASE_MODULATION

proc executeContextClick(index: int, actionId: int): void =
    logScope:
        topics = "executeContextClick"
    case actionId.ActionType
    of OUTPUT:
        info "Output", index=index
    of OSCILLATOR:
        info "Oscillator", index=index
    of PHASE_MODULATION:
        info "FM", index=index
        
    
    return

proc drawContextMenu(cellIndex: int): void {.inline.} =
    var oldModule = synthContext.moduleList[cellIndex]


    if(igMenuItem("Set output here")):
        oldModule.breakAllLinks()
        synthContext.moduleList[synthContext.outputIndex].breakAllLinks()
        synthContext.moduleList[synthContext.outputIndex] = nil
        synthContext.moduleList[cellIndex] = constructOutputModule()
        synthContext.outputIndex = cellIndex.uint16
        info "Moved output box", cellIndex=cellIndex
        synthesize()

    if (synthContext.moduleList[cellIndex] of OutputModule): return

    igSeparator()

    if(igMenuItem("Copy")):
        if(oldModule != nil): moduleClipboard = oldModule.serialize()

    if(igMenuItem("Cut")):
        if(oldModule != nil):
            oldModule.breakAllLinks()
            moduleClipboard = oldModule.serialize()
            deleteModule(cellIndex) 
            synthesize()
    
    if(igMenuItem("Paste")):
        if(oldModule != nil):
            oldModule.breakAllLinks()
            deleteModule(cellIndex)
        synthContext.moduleList[cellIndex] = unserializeFromClipboard()
        synthContext.moduleList[cellIndex].breakAllLinks()
        synthesize()

    igSeparator()

    if(igBeginMenu("Oscillators")):
        if(igMenuItem("Sine Oscillator")):
            synthContext.moduleList[cellIndex] = constructSineOscillatorModule()
            info "Instantiated a sine oscillator"
            synthesize()

        if(igMenuItem("Triangle Oscillator")):
            synthContext.moduleList[cellIndex] = constructTriangleOscillatorModule()
            info "Instantiated a triangle oscillator"
            synthesize()

        if(igMenuItem("Saw Oscillator")):
            synthContext.moduleList[cellIndex] = constructSawOscillatorModule()
            info "Instantiated a saw oscillator"
            synthesize()

        if(igMenuItem("Pulse Oscillator")):
            synthContext.moduleList[cellIndex] = constructSquareOscillatorModule()
            info "Instantiated a pulse oscillator"
            synthesize()

        if(igMenuItem("Wavetable Oscillator")):
            synthContext.moduleList[cellIndex] = constructWavetableOscillatorModule()
            info "Instantiated a wavetable oscillator"
            synthesize()

        if(igMenuItem("Noise Oscillator")):
            synthContext.moduleList[cellIndex] = constructNoiseOscillatorModule()
            info "Instantiated a noise oscillator"
            synthesize()
        igEndMenu()

    if(igMenuItem("FM")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructFmodModule()
        info "Instantiated FM"
        synthesize()

    if(igMenuItem("FM Pro")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructFmProModule()
        info "Instantiated FM Pro"
        synthesize()

    if(igMenuItem("Mixer")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructMixerModule()
        info "Instantiated mixer"
        synthesize()

    if(igMenuItem("Average")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructAverageModule()
        info "Instantiated averages"
        synthesize()

    if(igMenuItem("Amplifier")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructAmplifierModule()
        info "Instantiated amp"
        synthesize()

    if(igMenuItem("Rectifier")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructRectifierModule()
        info "Instantiated rectifier"
        synthesize()

    if(igMenuItem("Absoluter")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructAbsoluterModule()
        info "Instantiated absoluter"
        synthesize()

    if(igMenuItem("Clipper")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructClipperModule()
        info "Instantiated clipper"
        synthesize()
    
    if(igMenuItem("Inverter")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructInverterModule()
        info "Instantiated inverter"
        synthesize()

    if(igMenuItem("Phase dist.")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructPdModule()
        info "Instantiated phase distorter"
        synthesize()
    
    if(igMenuItem("Sync")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructSyncModule()
        info "Instantiated sync module"
        synthesize()

    if(igMenuItem("Morpher")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructMorphModule()
        info "Instantiated morpher"
        synthesize()

    if(igMenuItem("Exponenter")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructExpModule()
        info "Instantiated exponenter"
        synthesize()

    # if(igMenuItem("Overflower")):
    #     oldModule.breakAllLinks()
    #     synthContext.moduleList[cellIndex] = constructOverflowModule()
    #     synthesize()

    if(igMenuItem("Multiplier")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructMultModule()
        info "Instantiated multiplier"
        synthesize()

    if(igMenuItem("DualWave")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructDualWaveModule()
        info "Instantiated dual wave module"
        synthesize()

    if(igMenuItem("Phase")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructPhaseModule()
        info "Instantiated phase module"
        synthesize()

    if(igMenuItem("Wave Folding")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructWaveFoldModule()
        info "Instantiated wave folding"
        synthesize()
    
    if(igMenuItem("Wave Mirroring")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructWaveMirrorModule()
        info "Instantiated wave mirrorer"
        synthesize()

    if(igMenuItem("DC Offset")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructDcOffsetModule()
        info "Instantiated DC offset module"
        synthesize()

    if(igMenuItem("Chord")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructChordModule()
        info "Instantiated chord module"
        synthesize()

    if(igMenuItem("FM Feedback")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructFeedbackModule()
        info "Instantiated FM feedback module"
        synthesize()

    if(igMenuItem("Fast FM Feedback")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructFastFeedbackModule()
        info "Instantiated fast FM feedback module"
        synthesize()

    if(igMenuItem("Downsampler")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructDownsamplerModule()
        info "Instantiated downsampler"
        synthesize()

    if(igMenuItem("Quantizer")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructQuantizerModule()
        info "Instantiated quantizer"
        synthesize()

    if(igMenuItem("LFO")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructLfoModule()
        info "Instantiated LFO"
        synthesize()

    if(igMenuItem("Soft Clip")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructSoftClipModule()
        info "Instantiated soft clip module"
        synthesize()

    if(igMenuItem("Wave Folder")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructWaveFolderModule()
        info "Instantiated wave folder module"
        synthesize()

    if(igMenuItem("Splitter")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructSplitterModule()
        info "Instantiated splitter"
        synthesize()

    if(igMenuItem("Normalizer")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructNormalizerModule()
        info "Instantiated normalizer"
        synthesize()

    if(igMenuItem("Biquad Filter")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructBqFilterModule()
        info "Instantiated biquad filter"
        synthesize()

    if(igMenuItem("Fast Biquad Filter")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructFastBqFilterModule()
        info "Instantiated fast biquad filter"
        synthesize()

    if(igMenuItem("Chebyshev Filter")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructChebyshevFilterModule()
        info "Instantiated Chebyshev filter"
        synthesize()

    if(igMenuItem("Fast Chebyshev Filter")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructFastChebyshevFilterModule()
        info "Instantiated fast Chebyshev filter"
        synthesize()
    
    if(igMenuItem("Unison")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructUnisonModule()
        info "Instantiated unison"
        synthesize()

    if(igMenuItem("Quad Wave Assembler")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructQuadWaveAssemblerModule()
        info "Instantiated quad wave assemblerr"
        synthesize()

    if(igMenuItem("Calculator")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructCalculatorModule()
        info "Instantiated calculator"
        synthesize()

    if(igMenuItem("Box")):
        oldModule.breakAllLinks()
        synthContext.moduleList[cellIndex] = constructBoxModule()
        info "Instantiated box"
        synthesize()

proc drawModuleCreationContextMenu*(cellIndex: int): void {.inline.} =
    if(igBeginPopupContextItem(("moduleContext" & $cellIndex).cstring)):
        drawContextMenu(cellIndex)
        igEndPopup()
    
        
    
