@import "../lib/g2d/g2d.ck"
@import "../lib/music.ck"

public class Minigame extends GGen {
    // gruck all your game ggens to `this`
    @(GG.camera().viewSize() * 9 / 16, GG.camera().viewSize(), 1) * 0.8 => vec3 aspect;
    // this.scaWorld(aspect);

    // static G2D@ g; // used by face.ck, pimples.ck
    // if (g == null) {
    //     new G2D @=> g;
    //     g --> this;
    // }

    int _finished;
    int _win;

    static PlaneGeometry@ plane_geo;
    if (plane_geo == null) new PlaneGeometry @=> plane_geo;

    fun void init(int level) {} // called to start minigame at level

    fun int finished() { // returns true when player can swipe to next screen
        return _finished;
    }

    fun int music() {
        return Music.NONE; // return the music enum
    }

    fun int win() { // returns true if the minigame is finished and won
        return _finished && _win;
    }

    fun void update(float dt) { // called once per frame. put all your game logic here
    }
}