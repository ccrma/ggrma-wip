@import "../minigames/throw.ck"
@import "../minigames/face.ck"
@import "overlay.ck"

public class Phone extends GGen {
    Minigame @ minigame;
    Minigame @ nextMinigame;

    Overlay overlay --> this;

    1 => int throwLevel;
    int scrolling;

    fun Phone() {
        // TODO impl random game selection
        new Throw(throwLevel) @=> minigame;
        minigame --> this;
        this.posY(-GG.camera().viewSize());
    }

    fun void slideUp() {
        GG.camera().viewSize() => float screenHeight;
        1.5 => float duration;
        float t;

        while (t < duration) {
            GG.nextFrame() => now;
            GG.dt() +=> t;
            if (t > duration) duration => t;
            
            t / duration => float p;

            0.375 => float c1;
            c1 + 1 => float c3;

            1 + c3 * Math.pow(p - 1, 3) + c1 * Math.pow(p - 1, 2) => float ease;
            
            ease * screenHeight => float offset;
            this.posY(-screenHeight * 2 + offset * 2);
        }
    }

    fun void scroll() {
        true => scrolling;

        GG.camera().viewSize() => float screenHeight;
        0.5 => float duration;
        float t;

        while (t < duration) {
            GG.nextFrame() => now;
            GG.dt() +=> t;
            if (t > duration) duration => t;

            t / duration => float p;
            p * (2 - p) => float ease;

            ease * screenHeight * 0.85 => float offset;
            minigame.posY(offset);
            nextMinigame.posY(-screenHeight + screenHeight * 0.15 + offset);
        }

        minigame --< this;
        nextMinigame.posY(0);

        nextMinigame @=> minigame;
        false => scrolling;
    }

    fun void update(float dt) {
        if (scrolling) return;

        if (GWindow.scrollY() > 1 && minigame.finished()) {
            if (minigame.win()) { // increment minigame level if won
                if (minigame.typeOfInstance() == Throw) {
                    1 +=> throwLevel;
                }
            }

            new Throw(throwLevel) @=> nextMinigame; // select random minigame for next one -- for now it's just the throw game lol
            nextMinigame --> this; // render the next minigame
            nextMinigame.posY(-GG.camera().viewSize()); // position next minigame at bottom

            spork ~ scroll();
        }
    }
}