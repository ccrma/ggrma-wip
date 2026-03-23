public class Music {
    SndBuf buf => Gain gain => dac;
    gain.gain(0.5);

    Shred @ playShred;

    [
        "toss1.wav",
        "toss2.wav",
        "toss3.wav",
        "face1.wav",
        "face2.wav",
        "face3.wav",
        "popping1.wav",
        "popping2.wav",
        "popping3.wav",
        "reaction1.wav",
        "reaction2.wav",
        "reaction3.wav",
        "mukbang1.wav",
        "mukbang2.wav",
        "mukbang3.wav",
        "choice1.wav",
        "choice2.wav",
        "choice3.wav",
    ] @=> static string filePaths[];

    fun void switchTo(int index) {
        if (index == NONE) {
            buf.rate(0); // pause
            return;
        }
        buf.read(me.dir() + "../assets/audio/" + filePaths[index]);
        buf.pos(0);
        buf.rate(1);
        buf.loop(true);
    }

    -1 => static int NONE;
    0 => static int TOSS1;
    1 => static int TOSS2;
    2 => static int TOSS3;
    3 => static int FACE1;
    4 => static int FACE2;
    5 => static int FACE3;
    6 => static int POPPING1;
    7 => static int POPPING2;
    8 => static int POPPING3;
    9 => static int REACTION1;
    10 => static int REACTION2;
    11 => static int REACTION3;
    12 => static int MUKBANG1;
    13 => static int MUKBANG2;
    14 => static int MUKBANG3;
    15 => static int CHOICE1;
    16 => static int CHOICE2;
    17 => static int CHOICE3;
}