public class Music {
    SndBuf buf => Gain gain => dac;
    gain.gain(0.5);

    Shred @ playShred;

    [
        "toss1.wav",
        "toss2.wav",
        "toss3.wav",
        "toss4.wav",
        "toss5.wav",
        "face1.wav",
        "face2.wav",
        "face3.wav",
        "face4.wav",
        "face5.wav",
        "popping1.wav",
        "popping2.wav",
        "popping3.wav",
        "popping4.wav",
        "popping5.wav",
        "reaction1.wav",
        "reaction2.wav",
        "reaction3.wav",
        "reaction4.wav",
        "reaction5.wav",
        "mukbang1.wav",
        "mukbang2.wav",
        "mukbang3.wav",
        "mukbang4.wav",
        "mukbang5.wav",
        "choice1.wav",
        "choice2.wav",
        "choice3.wav",
    ] @=> static string filePaths[];

    fun void switchTo(int index) {
        if (index == NONE) return;
        buf.read(me.dir() + "../assets/audio/music/" + filePaths[index]);
        if (playShred != null) {
            playShred.exit();
            null => playShred;
        }
        spork ~ play() @=> playShred;
    }

    fun void play() {
        buf.pos(0);
        buf.rate(1);
        buf.loop(true);
        while (true) {
            100::ms => now;
        }
    }

    -1 => static int NONE;
    0 => static int TOSS1;
    1 => static int TOSS2;
    2 => static int TOSS3;
    3 => static int TOSS4;
    4 => static int TOSS5;
    5 => static int FACE1;
    6 => static int FACE2;
    7 => static int FACE3;
    8 => static int FACE4;
    9 => static int FACE5;
    10 => static int POPPING1;
    11 => static int POPPING2;
    12 => static int POPPING3;
    13 => static int POPPING4;
    14 => static int POPPING5;
    15 => static int REACTION1;
    16 => static int REACTION2;
    17 => static int REACTION3;
    18 => static int REACTION4;
    19 => static int REACTION5;
    20 => static int MUKBANG1;
    21 => static int MUKBANG2;
    22 => static int MUKBANG3;
    23 => static int MUKBANG4;
    24 => static int MUKBANG5;
    25 => static int CHOICE1;
    26 => static int CHOICE2;
    27 => static int CHOICE3;
}