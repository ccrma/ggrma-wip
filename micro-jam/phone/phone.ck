@import "../minigames/throw.ck"
@import "../minigames/face.ck"
@import "../minigames/pimple.ck"
@import "../minigames/rxn.ck"
@import "../minigames/balance.ck"
@import "overlay.ck"
@import "../lib/music.ck"
@import "../lib/sfx.ck"
@import "../minigames/mukbang.ck"
@import "../minigames/reflection.ck"

@import "../lib/M.ck"

public class Phone extends GGen {
    Music music;

    SndBuf end_music(me.dir() + "../assets/audio/music/ending.wav") => dac;
    end_music.rate(0);

    PulseOsc pulse => blackhole;
    3 => pulse.freq;

    Minigame @ minigame;
    Minigame @ nextMinigame;
    int minigame_type;
    int next_minigame_type;


    TextureLoadDesc load_desc;
    true => load_desc.flip_y;  // flip the texture vertically
    false => load_desc.gen_mips; 

    Texture.load(me.dir() + "../assets/ui/background-masked.png", load_desc) @=> Texture @ masked_bg_tex;
    FlatMaterial maskedBgMat;
    maskedBgMat.colorMap(masked_bg_tex);
    true => maskedBgMat.transparent;
    GMesh masked_bg(new PlaneGeometry, maskedBgMat);
    masked_bg.sca(10 * @( 16 / 9.0, 1.0 ));

    0 => static int Game_Throw;
    1 => static int Game_Face;
    2 => static int Game_Pimples;
    3 => static int Game_Rxn;
    4 => static int Game_Mukbang;
    5 => static int Game_Balance;
    6 => static int Game_Reflection;
    7 => static int Game_Count;

    int game_levels[Game_Count];
    // start all games at level 1
    for (int i; i < Game_Count; ++i) 1 => game_levels[i];
    // 5 => game_levels[Game_Face];
    // 5 => game_levels[Game_Pimples];
    // 5 => game_levels[Game_Mukbang];

    // preload assets
    FaceGame.loadAssets();
    Pimples.loadAssets();
    Rxn.init();
    Mukbang.loadAssets();
    Balance.init();
    Reflection.loadAssets();

    Overlay overlay --> this;
    int scrolling;

    int batteryDrain4Count;
    16 => int batteryDrain4Max;
    int batteryDrain3Count;
    12 => int batteryDrain3Max;

    int games_played; // counts NON-reflection games played

    Balance balance_games[0];


    // spawn random dudes

    // randomize(new GSphere);
    // randomize(balance.go_answerFace2_arr[1]);

    fun Minigame@ nextGame() { 
        ++games_played;

        if (overlay.batteryPercentage <= 0) {
            overlay.actualOverlay --< overlay;
            if (!end_scene_init) spork ~ endScene();
            return new Reflection(5);
        }
        if (games_played == 6) {
            overlay.actualOverlay --< overlay;
            return new Reflection(1);
        }
        else if (games_played == 12) {
            overlay.actualOverlay --< overlay;
            return new Reflection(2);
        }
        else if (games_played == 18) {
            overlay.actualOverlay --< overlay;
            return new Reflection(3);
        }
        else if (games_played == 23) {
            overlay.actualOverlay --< overlay;
            return new Reflection(4);
        } 

        if (games_played > 2) overlay.actualOverlay --> overlay;

        int valid_games[0];
        for (int i; i < Game_Count; ++i) {
            if (i == Game_Balance && game_levels[i] > 3) continue;
            if (game_levels[i] <= 5 && i != Game_Reflection) valid_games << i;
        }

        // only allow games that are not level 5
        if (valid_games.size() == 0) return null;
        valid_games[Math.random2(0, valid_games.size() - 1)] 
            => next_minigame_type;

        // NOCHECKIN
        // Game_Reflection => next_minigame_type;

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
            balance_games << new Balance(level);
            return balance_games[-1];
        }

        <<< "ERROR Phone.nextGame() returning null" >>>;
        return null;
    }

    fun Phone() {
        SFX.init();
        // TODO impl random game selection
        nextGame() @=> minigame;
        Minigame.mouse_click --> minigame;
        Minigame.mouse_click.posX(4.5);
        Minigame.mouse_click.posZ(4);
        Minigame.mouse_click.sca(
            @(
            Minigame.mouse_click.scaX() * 1.5,
            Minigame.mouse_click.scaY() * 1.5
            )
        );

        next_minigame_type => minigame_type;
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
        
        masked_bg --> this;
        masked_bg.posZ(2.5);
        overlay.actualOverlay --> overlay;
        minigame --> this;
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
            // if first time, attach scroll instructions
            if (Minigame.mouse_scroll.parent() == null) {
                Minigame.mouse_scroll --> minigame;
                Minigame.mouse_scroll.posX(-4.5);
                Minigame.mouse_scroll.posZ(4);
                Minigame.mouse_scroll.sca(
                    @(
                    Minigame.mouse_scroll.scaX() * 1.5,
                    Minigame.mouse_scroll.scaY() * 1.5
                    )
                );
            }
            overlay.twitch();
        }

        // color flicker on mouse_scroll
        (1 + .5 * pulse.last()) * Color.WHITE => (Minigame.mouse_scroll.mat() $ FlatMaterial).color;
        (1 + -.5 * pulse.last()) * Color.WHITE => (Minigame.mouse_click.mat() $ FlatMaterial).color;

        if (Math.fabs(GWindow.scrollY()) > .1 && minigame.finished()) {
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
            }

            true => minigame.stopped;

            nextGame() @=> nextMinigame; // select random minigame for next one
            nextMinigame --> this; // render the next minigame
            nextMinigame.posY(-GG.camera().viewSize()); // position next minigame at bottom

            music.switchTo(nextMinigame.music());

            spork ~ scroll();
        }
    }

    int end_scene_init;
    fun void endScene() {
        true => end_scene_init;

        8::second => now;
        end_music.rate(1);
        true => overlay.hand.game_end;

        1::second => now;
        Balance balance(2);
        randomize(balance.go_answerFace2_arr[0].mesh);
        randomize(balance.go_answerFace2_arr[1].mesh);
        1::second => now;
        Balance balance3(3);
        randomize(balance3.go_answerFace2_arr[0].mesh);
        randomize(balance3.go_answerFace2_arr[1].mesh);
        1::second => now;
        spork ~ cameraShakeEffect(.2, 10::minute, 15);

        2::second => now;

        1::second => dur wait;

        spork ~ fadeOutEffect(7);
        repeat(40) {
            randomize(balance3.go_answerFace2_arr[0].mesh);
            randomize(balance3.go_answerFace2_arr[1].mesh);
            randomize(balance.go_answerFace2_arr[0].mesh);
            randomize(balance.go_answerFace2_arr[1].mesh);
            .9 *=> wait;
            wait => now;
        }

        // Machine.crash();
    }

    fun void randomize(GMesh ggen) {
        GMesh mesh(ggen.geo(), ggen.mat()) --> GG.scene();
        mesh.sca(ggen.scaWorld());
        M.randomPointInArea(@(0, 0), 6, 4) => mesh.pos;
        Math.random2f(0, Math.pi) => mesh.rotZ;
        2.75 => mesh.posZ; 
    }


    static int camera_shake_generation;
    fun static void cameraShakeEffect(float amplitude, dur shake_dur, float hz) {
        ++camera_shake_generation => int gen;
        dur elapsed_time;

        // generate shake params
        shake_dur / 1::second => float shake_dur_secs;
        vec2 camera_deltas[(hz * shake_dur_secs + 1) $ int];
        for (int i; i < camera_deltas.size(); i++) {
            @(Math.random2f(-amplitude, amplitude),
            Math.random2f(-amplitude, amplitude)) => camera_deltas[i];
        }
        @(0,0) => camera_deltas[0]; // start from original pos
        @(0,0) => camera_deltas[-2]; // return to original pos
        @(0,0) => camera_deltas[-1]; // return to original pos (yes need this one too)

        (1.0 / hz)::second => dur camera_delta_period; // time for 1 cycle of shake

        while (true) {
            GG.nextFrame() => now;
            // another shake triggred, stop this one
            if (elapsed_time > shake_dur || gen != camera_shake_generation) break;
            // update elapsed time
            GG.dt()::second +=> elapsed_time;

            // compute fraction shake progress
            elapsed_time / shake_dur => float progress;
            elapsed_time / camera_delta_period => float elapsed_periods;
            elapsed_periods $ int => int floor;
            elapsed_periods - floor => float fract;

            // clamp to end of camera_deltas
            if (floor + 1 >= camera_deltas.size()) {
                camera_deltas.size() - 2 => floor;
                1.0 => fract;
            }

            // interpolate the progress
            camera_deltas[floor] * (1.0 - fract) + camera_deltas[floor + 1] * fract => vec2 delta;
            // update camera pos with linear decay based on progress
            (1.0 - progress) * delta => GG.camera().pos;
        }
    }


    fun void fadeOutEffect(float duration) {
        float t;
        while (t < duration) {
            GG.nextFrame() => now;
            GG.dt() +=> t;
            if (t > duration) duration => t;
            
            t / duration => float p;

            0.75 => float c1;
            c1 * 1.25 => float c2;

            Math.sin((p * Math.PI) / 2) => float ease;

            Math.map(ease, 0, 1, 1, 0) => float opacity;

            GG.outputPass().exposure(opacity);
        }
    }
}