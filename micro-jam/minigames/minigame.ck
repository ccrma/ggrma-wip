public class Minigame extends GGen {
    // gruck all your game ggens to `this`
    @(GG.camera().viewSize() * 9 / 16, GG.camera().viewSize(), 1) => vec3 aspect;
    // this.scaWorld(aspect);

    int _finished;
    int _win;

    fun int finished() { // returns true when player can swipe to next screen
        return _finished;
    }

    fun int win() { // returns true if the minigame is finished and won
        return _finished && _win;
    }

    fun void update(float dt) { // called once per frame. put all your game logic here
    }
}