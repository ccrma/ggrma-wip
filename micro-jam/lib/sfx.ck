public class SFX
{
    static SFX @ _instance;

    fun static void init() {
        if (_instance == null) new SFX @=> _instance;
    }

    // Round-robin buffer pool for overlapping SFX playback
    8 => static int voices;
    SndBuf buf[voices];
    Gain bus => dac;
    bus.gain(1.5);

    for (int i; i < buf.size(); i++) {
        buf[i] => bus;
    }

    0 => int poolIndex;

    [
        "chew0.wav",
        "chew1.wav",
        "chew2.wav",
        "chew3.wav",
        "chew4.wav",
        "chew5.wav",
        "choice_cheer.wav",
        "choice_select.wav",
        "face_done.wav",
        "face_hit.wav",
        "pop1.wav",
        "pop2.wav",
        "pop3.wav",
        "pop4.wav",
        "pop5.wav",
        "reaction_click.wav",
        "reaction_complete.wav",
        "stab.wav",
        "toss.wav",
        "train.wav",
        "yummy.wav"
    ] @=> static string filePaths[];

    // Enum constants
    -1 => static int NONE;
    0 => static int CHEW0;
    1 => static int CHEW1;
    2 => static int CHEW2;
    3 => static int CHEW3;
    4 => static int CHEW4;
    5 => static int CHEW5;
    6 => static int BALANCE_CHEER;
    7 => static int BALANCE_SELECT;
    8 => static int FACE_DONE;
    9 => static int FACE_HIT;
    10 => static int POP1;
    11 => static int POP2;
    12 => static int POP3;
    13 => static int POP4;
    14 => static int POP5;
    15 => static int REACTION_CLICK;
    16 => static int REACTION_COMPLETE;
    17 => static int STAB;
    18 => static int TOSS;
    19 => static int TRAIN;
    20 => static int YUMMY;

    // Round-robin: load into next buffer, trigger playback, advance index
    fun void playInstance(int index) {
        playInstance(index, 1.0);
    }

    fun void playInstance(int index, float rate) {
        if (index == NONE || index < 0 || index >= filePaths.size()) return;

        buf[poolIndex].read(me.dir() + "../assets/audio/sfx/" + filePaths[index]);
        buf[poolIndex].pos(0);
        buf[poolIndex].loop(false);
        buf[poolIndex].rate(rate);

        (poolIndex + 1) % buf.size() => poolIndex;
    }

    fun void playInstance(string name) {
        for (int i; i < filePaths.size(); i++) {
            if (filePaths[i] == name + ".wav" || filePaths[i] == name) {
                playInstance(i);
                return;
            }
        }
    }

    fun static void play(int index) {
        if (_instance == null) init();
        _instance.playInstance(index);
    }

    fun static void play(int index, float rate) {
        if (_instance == null) init();
        _instance.playInstance(index, rate);
    }

    fun static void play(string name) {
        if (_instance == null) init();
        _instance.playInstance(name);
    }
}
