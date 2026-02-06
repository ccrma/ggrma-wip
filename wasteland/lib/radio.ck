@import "../../ChuGUI/src/ChuGUI.ck"
@import "radioFilter.ck"
@import "waveform.ck"

public class RadioMechanic {
    float val;

    1.0 => float _scale;
    vec2 sliderSize;

    int numOptions;
    string optionLabels[0];

    ["4", "6", "7", "8", "10", "12", "14", "16"] @=> string radioNumbers[];

    float dotX[0];

    // Selection threshold - how close slider needs to be to a dot to "select" it
    0.05 => float selectThreshold;

    // Currently selected option index (-1 if none)
    -1 => int _selectedIndex;

    // Whether the radio is active (for dialogue choices)
    0 => int _active;

    // Position offset for rendering
    vec2 _position;

    // audio
    SndBuf audio[0];
    Pan2   pan[0];
    RadioFilter radio_left => dac.left;
    RadioFilter radio_right => dac.right;
    CNoise n => LPF noise(600, 1); noise => radio_left; noise => radio_right; 0 => noise.gain;
    // CNoise noise; noise => radio_left; noise => radio_right; 0 => noise.gain;
    // noise.mode("pink");
    string audioFiles[0];
    string _audioBasePath;
    time loop_time[0];
    1::second => dur LOOP_DUR;  // how many seconds before looping each sample

    // sfx
    SndBuf radio_on(me.dir() + "../assets/audio/radio-on.wav") => dac; 
    0 => radio_on.rate;
    SndBuf radio_static(me.dir() + "../assets/audio/radio-static.wav") => dac;
    0 => radio_static.rate; 1 => radio_static.loop;
    SndBuf radio_hum(me.dir() + "../assets/audio/radio-hum.wav") => dac;
    0 => radio_hum.rate; 1 => radio_hum.loop;

    // audio visualizers
    Waveform waveform_ana;
    GLines waveform; waveform.width(.01);
    waveform.color(Color.WHITE);
    vec2 waveform_positions[waveform_ana.WINDOW_SIZE];
    2.0 => float WAVEFORM_WIDTH;





    fun RadioMechanic() {
        0 => numOptions;
        @(0.5, 0.01) => sliderSize;
    }

    fun RadioMechanic(int numOptions) {
        numOptions => this.numOptions;
        @(0.5, 0.01) => sliderSize;
    }

    fun RadioMechanic(int numOptions, int scale) {
        numOptions => this.numOptions;
        scale => _scale;
        @(0.5, 0.01) * _scale => sliderSize;
    }

    fun void init() {
        spork ~ keyboardHandler();
    }

    fun void setAudioBasePath(string path) {
        path => _audioBasePath;
    }

    fun void loadAudioForLabels(string labels[]) {
        // Clear existing audio
        for (int i; i < pan.size(); i++) {
            pan[i].left =< radio_left;
            pan[i].right =< radio_right;
        }
        audioFiles.clear();

        // add more sndbufs and pans as needed
        while (pan.size() < labels.size()) {
            audio << new SndBuf;
            pan << new Pan2;
            loop_time << now;
        }

        // Load audio files based on labels (trimmed, lowercase label + .wav)
        for (int i; i < labels.size(); i++) {
            labels[i].trim().lower() + ".wav" => string filename;
            _audioBasePath + filename => string filepath;
            audioFiles << filepath;
            audio[i] => pan[i];
            pan[i].left => radio_left;
            pan[i].right => radio_right;

            audio[i].read(filepath);
            audio[i].loop(0);
            0 => audio[i].gain;

            // set loop point
            now + audio[i].length() + LOOP_DUR => loop_time[i];
        }
    }

    fun void setOptions(string labels[]) {
        optionLabels.clear();
        dotX.clear();

        labels.size() => numOptions;
        @(0.5, 0.01) * _scale => sliderSize;

        for (int i; i < numOptions; i++) {
            optionLabels << labels[i];
        }

        // Randomize dot positions - each dot in its own segment
        for (int i; i < numOptions; i++) {
            dotX << Math.random2f(-sliderSize.x / 2 + (i * 1.0) / numOptions * sliderSize.x,
                          -sliderSize.x / 2 + ((i + 1) * 1.0) / numOptions * sliderSize.x);
        }

        // Load audio files based on the labels
        loadAudioForLabels(labels);

        // Reset slider to middle
        0.5 => val;
        -1 => _selectedIndex;
    }

    fun void setPosition(vec2 pos) {
        pos => _position;
    }

    fun void activate() {
        spork ~ activateShred();
    }

    fun void activateShred() {
        1 => _active;
        waveform --> GG.scene();
        // Unmute all audio when activated
        for (int i; i < audio.size(); i++) {
            0.5 => audio[i].gain;
        }
        0.2 => radio_left.gain;
        0.2 => radio_right.gain;

        { // sfx
            0 => radio_on.pos;
            1 => radio_on.rate;
            .12::second => now;
            1 => radio_static.rate;
            1 => radio_hum.rate;
        }
    }

    fun void deactivate() {
        0 => _active;
        // Mute all audio when deactivated
        for (int i; i < audio.size(); i++) {
            0 => audio[i].gain;
        }
        0 => radio_left.gain;
        0 => radio_right.gain;

        waveform --< GG.scene();
    }

    fun int isActive() {
        return _active;
    }

    fun void update(ChuGUI gui) {
        if (!_active || numOptions == 0) return;
        updateSelection();
        updateAudio();
        render(gui);
    }

    fun float trunc_fallof(float x, float m) {
        if (x > m) return 0.0;
        m /=> x;
        return (x - 2.0) * x + 1.0;
    }

    fun void updateSelection() {
        -1 => _selectedIndex;

        for (int i; i < numOptions; i++) {
            Math.remap(dotX[i], -sliderSize.x / 2, sliderSize.x / 2, 0, 1) => float dotPos;
            Math.fabs(val - dotPos) => float dist;

            if (dist < selectThreshold) {
                i => _selectedIndex;
                break;
            }
        }
    }

    0.2 => float SAMPLE_RADIUS; // max dist threshold (on a normalized scale 0-1) for hearing a sample
    fun void updateAudio() {
        float total_sample_gain;
        for (int i; i < audio.size() && i < numOptions; i++) {
            Math.remap(dotX[i], -sliderSize.x / 2, sliderSize.x / 2, 0, 1) => float dotPos;
            (val - dotPos) => float sample_dist;

            // gain falloff
            trunc_fallof(Math.fabs(sample_dist), SAMPLE_RADIUS) => audio[i].gain;
            audio[i].gain() +=> total_sample_gain;

            // panning
            Math.remap(sample_dist, -SAMPLE_RADIUS, SAMPLE_RADIUS, 1, -1) => pan[i].pan;

            // loop audio if needed
            if (now > loop_time[i]) {
                0 => audio[i].pos;
                now + LOOP_DUR + audio[i].length() => loop_time[i];
            }
        }

        // radio static
        // .25 * Math.pow(Math.max(0.5, 1 - total_sample_gain), 2) => noise.gain;
        1.0 * Math.pow(Math.max(0.2, 1 - total_sample_gain), 1) => radio_static.gain => radio_hum.gain;

        { // waveform viz
            waveform_ana.update();
            // mapping to xyz coordinate
            for (int i; i < waveform_ana.samples.size(); i++)
            {
                // space evenly in X
                @(
                    -WAVEFORM_WIDTH/2 + WAVEFORM_WIDTH/waveform_ana.WINDOW_SIZE *i, // x
                    waveform_ana.samples[i]                          // y
                ) => waveform_positions[i];
            }
        }
    }

    fun int getSelectedIndex() {
        return _selectedIndex;
    }

    fun int hasSelection() {
        return _selectedIndex >= 0;
    }

    fun void render(ChuGUI gui) {
        // black background rectangle
        UIStyle.pushColor(UIStyle.COL_RECT, Color.BLACK);
        UIStyle.pushVar(UIStyle.VAR_RECT_SIZE, @(0.6, 0.15) * _scale);
        gui.rect(@(_position.x, _position.y + 0.0175));
        UIStyle.popVar();
        UIStyle.popColor();

        // dots with option labels
        for (int i; i < dotX.size(); i++) {
            // Highlight selected dot
            if (i == _selectedIndex) {
                UIStyle.pushColor(UIStyle.COL_RECT, Color.GREEN);
            } else {
                UIStyle.pushColor(UIStyle.COL_RECT, Color.RED);
            }
            UIStyle.pushVar(UIStyle.VAR_RECT_SIZE, @(0.01, 0.01) * _scale);
            gui.rect(@(dotX[i] + _position.x, -0.01 + _position.y));
            UIStyle.popVar();
            UIStyle.popColor();
        }

        // numbers (radio dial markings)
        UIStyle.pushColor(UIStyle.COL_LABEL, @(0.5, 0.5, 0.5));
        UIStyle.pushVar(UIStyle.VAR_LABEL_SIZE, 0.015 * _scale);

        for (int i; i < radioNumbers.size(); i++) {
            -sliderSize.x / 2. + (i * 1.0) / (radioNumbers.size() - 1) * sliderSize.x => float xPos;
            gui.label(radioNumbers[i], @(xPos + _position.x, 0.035 * _scale + _position.y));
        }

        UIStyle.popVar();
        UIStyle.popColor();

        // slider
        if (_selectedIndex >= 0) {
            UIStyle.pushColor(UIStyle.COL_SLIDER_HANDLE, Color.GREEN);
        } else {
            UIStyle.pushColor(UIStyle.COL_SLIDER_HANDLE, Color.RED);
        }
        UIStyle.pushVar(UIStyle.VAR_SLIDER_TRACK_SIZE, @(0.5, 0.01) * _scale);
        UIStyle.pushVar(UIStyle.VAR_SLIDER_HANDLE_SIZE, @(0.005, 0.08) * _scale);
        gui.slider("radio", @(_position.x, _position.y), 0, 1, val) => val;
        UIStyle.popVar(2);
        UIStyle.popColor();
    }

    fun void keyboardHandler() {
        while (true) {
            GG.nextFrame() => now;

            if (_active) {
                if (GWindow.key(GWindow.KEY_LEFT)) {
                    0.0025 -=> val;
                }
                if (GWindow.key(GWindow.KEY_RIGHT)) {
                    0.0025 +=> val;
                }
            }
        }
    }

    fun void scale(float s) {
        s => _scale;
        @(0.5, 0.01) * _scale => sliderSize;
    }
}