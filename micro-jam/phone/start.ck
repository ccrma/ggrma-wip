@import "../lib/util.ck"

public class Start extends GGen {
    Event startEvent;

    true => int active;

    GText text --> this;
    text.text("DOOMSCROLLING");
    text.color(Color.BLACK);
    text.posY(2);
    text.sca(2);
    text.font(me.dir() + "../assets/ui/rvn.ttf");

    GText start --> this;
    start.text("START");
    start.color(Color.BLACK);
    start.posY(-2);
    text.sca(1.5);
    start.font(me.dir() + "../assets/ui/rvn.ttf");

    fun void hide() {
        false => active;

        1.5 => float duration;
        float t;

        while (t < duration) {
            GG.nextFrame() => now;
            GG.dt() +=> t;
            if (t > duration) duration => t;
            
            t / duration => float p;

            Math.sin((p * Math.PI) / 2) => float ease;

            Math.map(ease, 0, 1, 1, 0) => float opacity;

            text.alpha(opacity);
            start.alpha(opacity);            
        }

        text --< this;
        start --< this;

        startEvent.broadcast();
    }

    fun void update(float dt) {
        if (!active) return;
        
        if (Util.mouseHovered(start) && GWindow.mouseLeftDown()) {
            spork ~ hide();
        }
    }
}