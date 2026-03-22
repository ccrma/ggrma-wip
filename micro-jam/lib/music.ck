public class Music {
    SndBuf buf => Gain gain => dac;
    gain.gain(0.5);

    Shred @ playShred;

    [
        "breakcore1.wav",
        "bubble1.wav",
        "bubble2.wav",
        "evil1.wav",
        "evil2.wav",
        "evil3.wav",
        "pop1.wav",
        "pop2.wav",
    ] @=> static string filePaths[];

    fun void switchTo(int index) {
        if (index == NONE) return;
        buf.read(me.dir() + "../assets/audio/" + filePaths[index]);
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
    0 => static int BREAKCORE1;
    1 => static int BUBBLE1;
    2 => static int BUBBLE2;
    3 => static int EVIL1;
    4 => static int EVIL2;
    5 => static int EVIL3;
    6 => static int POP1;
    7 => static int POP2;
}