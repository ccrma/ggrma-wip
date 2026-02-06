@import "../../ChuGUI/src/ChuGUI.ck"
@import "radioFilter.ck"

public class RadioMechanic {
    float val;

    @(1., 1.) => vec2 _scale;
    vec2 sliderSize;

    int numOptions;
    string optionLabels[0];

    ["4", "8", "12", "16"] @=> string radioNumbers[];

    float dotX[0];

    // Selection threshold - how close slider needs to be to a dot to "select" it
    0.05 => float selectThreshold;

    // Currently selected option index (-1 if none)
    -1 => int _selectedIndex;

    // Whether the radio is active (for dialogue choices)
    0 => int _active;
    time _activate_time;

    // Position offset for rendering
    vec2 _position;    // target pos

    // audio
    SndBuf audio[0];
    Pan2   pan[0];
    RadioFilter radio_left => dac.left;
    RadioFilter radio_right => dac.right;
    CNoise n => LPF noise(600, 1); noise => radio_left; noise => radio_right; 0 => noise.gain;
    string audioFiles[0];
    string _audioBasePath;
    time loop_time[0];
    1::second => dur LOOP_DUR;

    256 => int WINDOW_SIZE;
    3 => float WAVEFORM_Y;
    2.2 => float DISPLAY_WIDTH;
    GLines waveform; waveform.width(.025);
    waveform.posY( WAVEFORM_Y );
    waveform.posX(-3.6);
    waveform.color(Color.GREEN);

    dac => Gain input;
    input => Flip accum => blackhole;
    input => PoleZero dcbloke => FFT fft => blackhole;
    .95 => dcbloke.blockZero;
    WINDOW_SIZE => accum.size;
    Windowing.hann(WINDOW_SIZE) => fft.window;
    WINDOW_SIZE*2 => fft.size;
    Windowing.hann(WINDOW_SIZE) @=> float window[];

    float samples[0];
    complex response[0];
    vec2 positions[WINDOW_SIZE];

    // map audio buffer to 3D positions
    fun void map2waveform( float in[], vec2 out[] )
    {
        if( in.size() != out.size() )
        {
            <<< "size mismatch in map2waveform()", "" >>>;
            return;
        }
        
        // mapping to xyz coordinate
        int i;
        DISPLAY_WIDTH => float width;
        for( auto s : in )
        {
            // space evenly in X
            -width/2 + width/WINDOW_SIZE*i => out[i].x;
            // map y, using window function to taper the ends
            s*8 * window[i] => out[i].y;
            // increment
            i++;
        }
    }

    // sfx
    SndBuf radio_on(me.dir() + "../assets/audio/radio-on.wav") => dac; 
    0 => radio_on.rate;
    SndBuf radio_static(me.dir() + "../assets/audio/radio-static.wav") => dac;
    0 => radio_static.rate; 1 => radio_static.loop;
    SndBuf radio_hum(me.dir() + "../assets/audio/radio-hum.wav") => dac;
    0 => radio_hum.rate; 1 => radio_hum.loop;

    fun RadioMechanic() {
        0 => numOptions;
        @(0.5, 0.01) => sliderSize;
    }

    fun RadioMechanic(int numOptions) {
        numOptions => this.numOptions;
        @(0.5, 0.01) => sliderSize;
    }

    fun RadioMechanic(int numOptions, vec2 scale) {
        numOptions => this.numOptions;
        scale => _scale;
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

        while (pan.size() < labels.size()) {
            audio << new SndBuf;
            pan << new Pan2;
            loop_time << now;
        }

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

            now + audio[i].length() + LOOP_DUR => loop_time[i];
        }
    }

    fun void setOptions(string labels[]) {
        optionLabels.clear();
        dotX.clear();

        labels.size() => numOptions;
        @(0.5 * _scale.x, 0.01 * _scale.y) => sliderSize;

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

    fun float easeOutElastic(float x) {
        (2 * Math.PI) / 3 => float c4;

        if (x < 0) return 0;
        if (x >= 1) return 1;
        return Math.pow(2, -10 * x) * Math.sin((x * 10 - 0.75) * c4) + 1;
    }

    fun float easeOutBounce(float x) {
        7.5625 => float n1;
        2.75 => float d1;
        if (x > 1) return 1;
        if (x < 1 / d1) {
            return n1 * x * x;
        } else if (x < 2 / d1) {
            return n1 * (1.5 / d1 -=> x) * x + 0.75;
        } else if (x < 2.5 / d1) {
            return n1 * (2.25 / d1 -=> x) * x + 0.9375;
        } else {
            return n1 * (2.625 / d1 -=> x) * x + 0.984375;
        }
    }

    fun void activate() {
        spork ~ activateShred();
    }

    fun void activateShred() {
        1 => _active;
        now => _activate_time;
        waveform --> GG.scene();

        // Unmute all audio when activated
        for (int i; i < audio.size(); i++) {
            0.5 => audio[i].gain;
        }
        0.2 => radio_left.gain;
        0.2 => radio_right.gain;

        1 => radio_static.gain;
        1 => radio_hum.gain;

        { // sfx
            1::second => now;
            0 => radio_on.pos;
            1 => radio_on.rate;
            1 => radio_on.gain;
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
        0 => radio_on.gain;
        0 => radio_static.gain;
        0 => radio_hum.gain;

        if (waveform.parent() != null) {
            waveform --< GG.scene();
        }
    }

    fun int isActive() {
        return _active;
    }

    fun void update(ChuGUI gui) {
        if (!_active || numOptions == 0) return;
        updateSelection();
        updateAudio();
        render(gui);
        map2waveform( samples, positions );
        // set the mesh position
        waveform.positions( positions );
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
    }

    // do audio stuff
    fun void doAudio()
    {
        while( true )
        {
            // upchuck to process accum
            accum.upchuck();
            // get the last window size samples (waveform)
            accum.output( samples );
            // upchuck to take FFT, get magnitude reposne
            fft.upchuck();
            // get spectrum (as complex values)
            fft.spectrum( response );
            // jump by samples
            WINDOW_SIZE::samp/2 => now;
        }
    } spork ~ doAudio();

    fun int getSelectedIndex() {
        return _selectedIndex;
    }

    fun int hasSelection() {
        return _selectedIndex >= 0;
    }

    fun void slider(ChuGUI gui, string id, vec2 scale, vec2 pos, float z_index) {
        @(0.5 * scale.x, 0.01 * scale.y) => vec2 localSliderSize;

        // Scale factor from base sliderSize to this slider's size
        scale.x / _scale.x => float scaleRatio;

        // dots with option labels
        for (int i; i < dotX.size(); i++) {
            // Highlight selected dot
            if (i == _selectedIndex) {
                UIStyle.pushColor(UIStyle.COL_RECT, Color.GREEN);
            } else {
                UIStyle.pushColor(UIStyle.COL_RECT, Color.RED);
            }
            UIStyle.pushVar(UIStyle.VAR_RECT_SIZE, @(0.01 * scale.x, 0.01 * scale.y));
            UIStyle.pushVar(UIStyle.VAR_RECT_Z_INDEX, z_index - 0.05);
            gui.rect(@(dotX[i] * scaleRatio + pos.x, -0.01 + pos.y));
            UIStyle.popVar(2);
            UIStyle.popColor();
        }

        // numbers (radio dial markings)
        UIStyle.pushColor(UIStyle.COL_LABEL, @(0.5, 0.5, 0.5));
        UIStyle.pushVar(UIStyle.VAR_LABEL_SIZE, 0.04 * scale.x);
        UIStyle.pushVar(UIStyle.VAR_LABEL_Z_INDEX, z_index);

        for (int i; i < radioNumbers.size(); i++) {
            -localSliderSize.x / 2. + (i * 1.0) / (radioNumbers.size() - 1) * localSliderSize.x => float xPos;
            gui.label(radioNumbers[i], @(xPos + pos.x, 0.03 * scale.y + pos.y));
        }

        UIStyle.popVar(2);
        UIStyle.popColor();

        // slider
        if (_selectedIndex >= 0) {
            UIStyle.pushColor(UIStyle.COL_SLIDER_HANDLE, Color.GREEN);
        } else {
            UIStyle.pushColor(UIStyle.COL_SLIDER_HANDLE, Color.RED);
        }
        UIStyle.pushVar(UIStyle.VAR_SLIDER_TRACK_SIZE, @(0.5 * scale.x , 0.01 * scale.y));
        UIStyle.pushVar(UIStyle.VAR_SLIDER_HANDLE_SIZE, @(0.005 * scale.x, 0.08 * scale.y));
        UIStyle.pushVar(UIStyle.VAR_SLIDER_Z_INDEX, z_index);
        gui.slider(id, @(pos.x, pos.y), 0, 1, val) => val;
        UIStyle.popVar(3);
        UIStyle.popColor();
    }


    fun void render(ChuGUI gui) {
        // tween between actual and target pos
        // 2::second => dur ANIM_TIME;
        // easeOutElastic((now - _activate_time) / ANIM_TIME) => float t;
        1.2::second => dur ANIM_TIME;
        easeOutBounce((now - _activate_time) / ANIM_TIME) => float t;
        // set pos to above screen so we can animate the fall downwards
        @(  
            0,
            .25 * GG.camera().viewSize()
        ) => vec2 start_pos;

        @(0, 0) => vec2 target_pos;
        start_pos + t * (target_pos - start_pos) => vec2 pos;

        slider(gui, "radio", _scale, _position, 3.0);
        slider(gui, "zoomed_radio", @(_scale.x * 3, _scale.y * 1.5), pos, 4.1);

        UIStyle.pushVar(UIStyle.VAR_ICON_Z_INDEX, 4.0);
        UIStyle.pushVar(UIStyle.VAR_ICON_SIZE, @(1314./1314, 553./1314));
        gui.icon(me.dir() + "../assets/radio_box.png", pos); 
        UIStyle.popVar(2);
    }

    fun void keyboardHandler() {
        // 1 => int dir;
        float curr_vel;
        UI_Float a(.015);

        while (true) {
            GG.nextFrame() => now;
            GG.dt() => float dt;

            UI.slider("acceleration", a, 0, .1);

            if (_active) {
                float dir;
                if (GWindow.key(GWindow.KEY_LEFT)) -1 => dir;
                if (GWindow.key(GWindow.KEY_RIGHT)) 1 => dir;

                Math.random2f(0, 1) * dir * dt * a.val() => float dv;
                dv +=> curr_vel;
                curr_vel +=> val;

                // hit edge
                if (val < 0 || val > 1) 0 => curr_vel;
            }
        }
    }

    fun void scale(vec2 s) {
        s => _scale;
    }
}