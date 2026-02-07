/*
Mediabot: blit with fixed pitch, random harmonics
vaccuumbot: noise + bandpass filter
tsunderebot: sawtooth, sparse
sommellier bot: most musical, quantize to scale?

Improvement (if time)
- add panning / spatialization
- fix vaccuum bot he sounds like ass
*/

class TextSonifier extends Chugraph {
    ADSR adsr(5::ms, 45::ms, 0, 0::ms) => outlet;
    UGen@ curr;

    SinOsc sin;
    SinOsc sin2; .5 => sin2.gain;

    PulseOsc pulse;
    SawOsc saw;
    Blit blit;
    CNoise noise => BPF bpf(440, 8);
    noise.mode("pink");

    [sin, pulse, saw, blit] @=> UGen oscillators[];

    blit.freq() => float default_freq;

    0 => static int Mode_MediaBot;
    1 => static int Mode_VaccuumBot;
    2 => static int Mode_TsundereBot;
    3 => static int Mode_SommelierBot;
    4 => static int Mode_Count;

    [
      "MediaBot",
      "VaccuumBot",
      "TsundereBot",
      "SommelierBot",
    ] @=> static string mode_names[];

    int _mode;

    // for tsundere bot
    int count;
    int every;

    fun TextSonifier(int mode) { this.mode(mode); }

    fun void mode(int mode) {
        // disconnect curr
        if (curr != null) curr =< adsr;
        sin2 =< adsr;
        mode => this._mode;

        // default adsr settings
        5::ms => adsr.attackTime;
        45::ms => adsr.decayTime;

        if (mode == Mode_MediaBot) {
            blit => adsr;
            45::ms => adsr.decayTime;
            blit @=> curr;
        }
        if (mode == Mode_TsundereBot) {
            saw => adsr;
            150::ms => adsr.decayTime;
            saw @=> curr;
        }
        if (mode == Mode_VaccuumBot) {
            bpf => adsr;
            100::ms => adsr.decayTime;
            150::ms => adsr.attackTime;
            bpf @=> curr;
        }
        if (mode == Mode_SommelierBot) {
            sin => adsr;
            sin2 => adsr;
            sin @=> curr;
            150::ms => adsr.decayTime;
        }
        else <<< "unsupported mode", mode >>>;

        <<< "mode", mode_names[mode] >>>;
    }

    [
        -5, -3, 0, 2, 4, 7, 9,
    ] @=> int scale[];

    fun void speak() {
        // tsundere bot speaks every N chars
        if (_mode == Mode_TsundereBot) {
            if (every == 0) Math.random2(2,5) => every;
            <<< "here", count, every >>>;
            if ((count++ % every) != 0) return;
            Math.random2(2,5) => every;

            // randomize pitch
            Std.mtof(Math.random2(63,64)) => saw.freq;
        }

        if (_mode == Mode_VaccuumBot) {
            if (every == 0) Math.random2(3,5) => every;
            <<< "here", count, every >>>;
            if ((count++ % every) != 0) return;
            Math.random2(3,5) => every;

            Math.random2f(4000,7000) => bpf.freq;
        }

        if (_mode == Mode_SommelierBot) {
            if (every == 0) 2 => every;
            if ((count++ % every) != 0) return;

            Std.mtof(
                72 + scale[Math.random2(0, scale.size()-1)]
            ) => sin.freq;
            sin.freq() * 3 * 1.33 => sin2.freq;
        }

        // Std.mtof(text.text().charAt(char_count) - 32) => osc.freq;
        if (_mode == Mode_MediaBot) Math.random2(1,12) => blit.harmonics;
        // if (_mode == Mode_TsundereBot) Math.random2f(.1,.9) => pulse.width;
        adsr.keyOn();
        <<< "speak" >>>;
    }

    // call after each sentence
    fun void reset() {
        0 => count;
        default_freq => saw.freq;
    }

}

GText text --> GG.scene();
text.text("hello this is an example dialog string");
// text.text("123 456 789");
.1 => text.size;
text.characters(0);
int char_count;

TextSonifier son(TextSonifier.Mode_SommelierBot) => dac;

fun int numSpaces(string s) {
    int count;
    for (int i; i < s.length(); ++i) {
        if (s.charAt(i) == ' ') ++count;
    }
    return count;
}

// returns length of string minus spaces
// because GTExt.characters() ignores spaces
fun int charLength(string s) {
    return s.length() - numSpaces(s);
}

UI_Int mode(son._mode);
UI_Float attack_ms(son.adsr.attackTime()/ms);
UI_Float decay_ms(son.adsr.decayTime()/ms);

fun void g() {
    while (1) {
        GG.nextFrame() => now;
        if (UI.slider("attack (ms)", attack_ms, 0, 100)) son.adsr.attackTime(attack_ms.val()::ms);
        if (UI.slider("decay (ms)", decay_ms, 0, 100)) son.adsr.decayTime(decay_ms.val()::ms);

        if (UI.listBox("mode", mode, TextSonifier.mode_names)) son.mode(mode.val());

        if (UI.button("reset")) {
            son.reset();
            0 => char_count;
        }
    }
} spork ~ g();


charLength(text.text()) => int len;


while (1) {
    text.characters(char_count + 1);
    if (char_count < len) { 
        son.speak();
    }
    ++char_count;
    // <<< char_count >>>;
    60::ms => now;
}