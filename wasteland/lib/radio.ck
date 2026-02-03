@import "../../ChuGUI/src/ChuGUI.ck"

public class RadioMechanic {
    float val;

    1.0 => float _scale;
    vec2 sliderSize;

    int numOptions;

    ["4", "6", "7", "8", "10", "12", "14", "16"] @=> string radioNumbers[];

    float dotX[0];

    // audio

    SndBuf fear(me.dir() + "../assets/audio/fear.wav") => dac;
    SndBuf hate(me.dir() + "../assets/audio/hate.wav") => dac;
    SndBuf love(me.dir() + "../assets/audio/love.wav") => dac;
    fear.loop(1);
    hate.loop(1);
    love.loop(1);

    // CNoise noise => dac;

    fun RadioMechanic(int numOptions) {
        numOptions => this.numOptions;
    }
    fun RadioMechanic(int numOptions, int scale) {
        numOptions => this.numOptions;
        scale => _scale;
        @(0.5, 0.01) * _scale => sliderSize;
    }

    fun void init() {
        spork ~ keyboardHandler();

        // randomize dot positions based on number of options, where each dot is in a different segment
        for (int i; i < numOptions; i++) {
            dotX << Math.random2f(-sliderSize.x / 2 + (i * 1.0) / numOptions * sliderSize.x,
                          -sliderSize.x / 2 + ((i + 1) * 1.0) / numOptions * sliderSize.x);
        }
    }

    fun void update(ChuGUI gui) {
        audio();
        render(gui);
    }

    fun float trunc_fallof( float x, float m )
    {
        if( x>m ) return 0.0;
        m /=> x;
        return (x-2.0)*x+1.0;
    }

    fun void audio() {
        val => float pos;
        
        Math.remap(dotX[0], -sliderSize.x / 2, sliderSize.x / 2, 0, 1) => float fearPos;
        Math.remap(dotX[1], -sliderSize.x / 2, sliderSize.x / 2, 0, 1) => float hatePos;
        Math.remap(dotX[2], -sliderSize.x / 2, sliderSize.x / 2, 0, 1) => float lovePos;

        trunc_fallof(Math.fabs(pos - fearPos), 0.2) => fear.gain;
        trunc_fallof(Math.fabs(pos - hatePos), 0.2) => hate.gain;
        trunc_fallof(Math.fabs(pos - lovePos), 0.2) => love.gain;
    }

    fun void render(ChuGUI gui) {
        // dots
        UIStyle.pushColor(UIStyle.COL_RECT, Color.PURPLE);
        UIStyle.pushVar(UIStyle.VAR_RECT_SIZE, @(0.01, 0.01) * _scale);
        for (int i; i < dotX.size(); i++) {
            gui.rect(@(dotX[i], -0.01));
        }
        UIStyle.popVar();
        UIStyle.popColor();

        // numbers
        UIStyle.pushColor(UIStyle.COL_LABEL, Color.WHITE);
        UIStyle.pushVar(UIStyle.VAR_LABEL_SIZE, 0.02 * _scale);

        for (int i; i < radioNumbers.size(); i++) {
            -sliderSize.x / 2. + (i * 1.0) / (radioNumbers.size() - 1) * sliderSize.x => float xPos;
            gui.label(radioNumbers[i], @(xPos, 0.035 * _scale));
        }

        UIStyle.popVar();
        UIStyle.popColor();

        // slider
        UIStyle.pushColor(UIStyle.COL_SLIDER_HANDLE, Color.RED);
        UIStyle.pushVar(UIStyle.VAR_SLIDER_TRACK_SIZE, @(0.5, 0.01) * _scale);
        UIStyle.pushVar(UIStyle.VAR_SLIDER_HANDLE_SIZE, @(0.005, 0.15) * _scale);
        gui.slider("radio", @(0, 0), 0, 1, val) => val;
        UIStyle.popVar(2);
        UIStyle.popColor();

        gui.debugAdd();
    }

    fun void keyboardHandler() {
        while(true) {
            GG.nextFrame() => now;

            if (GWindow.key(GWindow.KEY_LEFT)) {
                0.0025 -=> val;
            }
            if (GWindow.key(GWindow.KEY_RIGHT)) {
                0.0025 +=> val;
            }
        }
    }

    fun void scale(float s) {
        s => _scale;
    }
}

// graphics

ChuGUI gui --> GG.scene();
gui.debugEnabled(true);

RadioMechanic r(3, 2);
r.init();

GG.camera().orthographic();

// main loop
while(true) {
    GG.nextFrame() => now;
    r.update(gui);

    gui.debug();
}