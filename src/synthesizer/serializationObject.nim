type
    ModuleType* = enum
        NULL,
        ABSOLUTER,
        AMPLIFIER,
        AVERAGE,
        BQ_FILTER
        CHORD,
        CLIPPER,
        DC_OFFSET,
        DOWNSAMPLER,
        DUAL_WAVE,
        EXPONENT,
        FEEDBACK,
        FM,
        FM_PRO,
        INVERTER,
        LFO,
        MIXER,
        MORPHER,
        MULT,
        NOISE,
        NORMALIZER,
        SINE_OSC,
        TRI_OSC,
        SAW_OSC,
        PULSE_OSC,
        WAVE_OSC,
        OUTPUT,
        PHASE_DIST,
        PHASE,
        QUANTIZER,
        RECTIFIER,
        SOFT_CLIP,
        SPLITTER,
        SYNC,
        UNISON,
        WAVE_FOLDER,
        WAVE_FOLD,
        MIRROR,
        CH_FILTER,
        QUAD_WAVE_ASM,
        CALCULATOR,
        FAST_FEEDBACK,
        FAST_BQ_FILTER,
        FAST_CH_FILTER,
        BOX

    ModuleSerializationObject* = object
        mType*: ModuleType
        data*: string