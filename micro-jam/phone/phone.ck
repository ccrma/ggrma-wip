@import "../minigames/throw.ck"
@import "../minigames/face.ck"
@import "../minigames/pimple.ck"
@import "../minigames/rxn.ck"
@import "../minigames/balance.ck"
@import "overlay.ck"
@import "../lib/music.ck"
@import "../minigames/mukbang.ck"

public class Phone extends GGen {
    Music music;

    Minigame @ minigame;
    Minigame @ nextMinigame;
    int minigame_type;
    int next_minigame_type;

    0 => static int Game_Throw;
    1 => static int Game_Face;
    2 => static int Game_Pimples;
    3 => static int Game_Rxn;
    4 => static int Game_Mukbang;
    5 => static int Game_Balance;
    6 => static int Game_Count;

    int game_levels[Game_Count];
    // start all games at level 1
    for (int i; i < Game_Count; ++i) 1 => game_levels[i];
    // 5 => game_levels[Game_Face];
    // 5 => game_levels[Game_Mukbang];

    // FaceGame face_game;

    // preload assets
    Rxn.init();
    Mukbang.loadAssets();
    Balance.init();

    Overlay overlay --> this;
    int scrolling;

    int batteryDrain4Count;
    16 => int batteryDrain4Max;
    int batteryDrain3Count;
    12 => int batteryDrain3Max;

    fun Minigame@ nextGame() { 
        <<< "calling nextgame" >>>; 
        int valid_games[0];
        for (int i; i < Game_Count; ++i) {
            if (game_levels[i] <= 5) valid_games << i;
        }

        // only allow games that are not level 5
        if (valid_games.size() == 0) return null;
        valid_games[Math.random2(0, valid_games.size() - 1)] 
            => next_minigame_type;

        // NOCHECKIN
        // Game_Mukbang => next_minigame_type;

        game_levels[next_minigame_type] => int level;

        Minigame@ game;
        <<< "initialized game", next_minigame_type, "level", level >>>;
        if (next_minigame_type == Game_Throw) {
            return new Throw(level);
        }
        else if (next_minigame_type == Game_Face) {
            return new FaceGame(level);
        }
        else if (next_minigame_type == Game_Pimples) {
            return new Pimples(level);
        }
        else if (next_minigame_type == Game_Rxn) {
            // RXN game levels go from 0-4
            return new Rxn(level - 1);
        }
        else if (next_minigame_type == Game_Mukbang) {
            // 0 index
            return new Mukbang(level-1);
        }
        else if (next_minigame_type == Game_Balance) {
            return new Balance(level);
        }

        <<< "ERROR Phone.nextGame() returning null" >>>;
        return null;
    }

    fun Phone() {
        // TODO impl random game selection
        nextGame() @=> minigame;
        next_minigame_type => minigame_type;
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

        music.switchTo(minigame.music());
    }

    fun void scroll() {
        true => scrolling;

        GG.camera().viewSize() => float screenHeight;
        0.5 => float duration;
        float t;

        overlay.swipe();

        while (t < duration) {
            GG.nextFrame() => now;
            GG.dt() +=> t;
            if (t > duration) duration => t;

            t / duration => float p;
            p * (2 - p) => float ease;

            ease * screenHeight * 0.8 => float offset;
            minigame.posY(offset);
            nextMinigame.posY(-screenHeight + screenHeight * 0.2 + offset);
        }

        minigame.ungruck();
        minigame --< this;
        nextMinigame.posY(0);

        nextMinigame @=> minigame;
        next_minigame_type => minigame_type;
        false => scrolling;
    }

    fun void update(float dt) {
        if (scrolling) return;

        if (minigame.finished()) {
            overlay.twitch();
        }

        if (GWindow.scrollY() > 1 && minigame.finished()) {
            if (minigame.win()) { // increment minigame level if won
                ++game_levels[minigame_type];
                
                true => int drain4;
                if (maybe) {
                    if (batteryDrain4Count >= batteryDrain4Max)
                        false => drain4;
                } else {
                    if (batteryDrain3Count < batteryDrain3Max)
                        false => drain4;
                }
                if (drain4) {
                    overlay.batteryDrain(4);
                    1 +=> batteryDrain4Count;
                } else {
                    overlay.batteryDrain(3);
                    1 +=> batteryDrain3Count;
                }

                if (overlay.batteryPercentage <= 0) { // game over
                    overlay --< this;
                    minigame --< this;
                    if (nextMinigame.parent() != null) nextMinigame --< this;
                }
            }

            true => minigame.stopped;

            nextGame() @=> nextMinigame; // select random minigame for next one
            nextMinigame --> this; // render the next minigame
            nextMinigame.posY(-GG.camera().viewSize()); // position next minigame at bottom

            music.switchTo(nextMinigame.music());

            spork ~ scroll();
        }
    }
}