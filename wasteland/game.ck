@import "../ChuGUI/src/ChuGUI.ck"
@import "lib/player.ck"
@import "lib/radio.ck"
@import "lib/data.ck"
@import "lib/deathMusic.ck"
@import "lib/dialogEngine.ck"
@import "scene/bar.ck"

public class Game {
    ChuGUI gui --> GG.scene();

    Prompt.parse(Data.script, false) @=> Prompt prompts[];

    // Player persists across all scenes
    Player player("You", me.dir() + "assets/human.png");

    BarScene scene;

    // Radio mechanic for dialogue choices
    RadioMechanic radio(gui);

    // death state stuff
    int dead;
    time dead_time;
    3 => float FADE_TIME_SECS;
    DeathMusic death_music;

    fun void init() {
        // Initialize radio
        radio.scale(@(0.525, 1.5));
        radio.setPosition(@(-0.575, 0.4));
        radio.setAudioBasePath(me.dir() + "assets/audio/");
        radio.init();

        // Pass radio to scene/dialog manager
        scene.init(player, prompts);
        scene.dialogManager().setRadio(radio);
    }

    fun void run() {
        init();

        // Main game loop
        while (true) {
            GG.nextFrame() => now;

            UIStyle.pushVar(UIStyle.VAR_LABEL_FONT, me.dir() + "assets/fonts/GiantRobotArmy.ttf");

            player.update(gui);
            scene.update(gui);
            radio.update();

            // Disable all input during NPC transitions and death
            if (!scene.dialogManager().inTransition() && !dead) {
                // ENTER advances dialogue and confirms radio selections
                if (GWindow.keyDown(GWindow.KEY_ENTER)) {
                    if (scene.dialogManager().isTyping()) {
                        scene.dialogManager().skipTypewriter();
                    } else if (scene.dialogManager().canAdvance()) {
                        scene.dialogManager().advanceDialogue();
                    }
                }

                // SPACE skips typewriter or advances non-choice dialogue
                if (GWindow.keyDown(GWindow.KEY_SPACE)) {
                    if (scene.dialogManager().isTyping()) {
                        scene.dialogManager().skipTypewriter();
                    } else if (scene.dialogManager().canAdvanceNonChoice()) {
                        scene.dialogManager().advanceDialogue();
                    }
                }
            }

            UIStyle.popVar();

            // death
            {
                if (radio.outOfTime() && !dead) {
                    true => dead;
                    now => dead_time;
                    radio.mark.alert();
                    spork ~ deathScreenShred();
                }
                
                if (dead) {
                    (now - dead_time) / second => float secs_since_death;

                    Math.clampf(secs_since_death / FADE_TIME_SECS, 0, 1) => float alpha;
                    UIStyle.pushColor(UIStyle.COL_RECT, @(0, 0, 0, alpha));
                    UIStyle.pushVar(UIStyle.VAR_RECT_SIZE, @(2, 2));
                    UIStyle.pushVar(UIStyle.VAR_RECT_TRANSPARENT, true);
                    UIStyle.pushVar(UIStyle.VAR_RECT_Z_INDEX, 4.5);
                    gui.rect(@(0, 0));
                    UIStyle.popVar(3);
                    UIStyle.popColor();


                    Math.clampf((secs_since_death - FADE_TIME_SECS) / FADE_TIME_SECS, 0, 1) => float t;
                    UIStyle.pushColor(UIStyle.COL_LABEL, t * @(1.0, 0.0, 0.0));
                    UIStyle.pushVar(UIStyle.VAR_LABEL_CONTROL_POINTS, @(0.5, 0.5));
                    UIStyle.pushVar(UIStyle.VAR_LABEL_Z_INDEX, 4.51);
                    UIStyle.pushVar(UIStyle.VAR_LABEL_SIZE, t*0.24);
                    gui.label("YOU DIED BRO", @(0, 0));
                    UIStyle.popVar(3);
                    UIStyle.popColor();
                }
            }
        }
    }

    fun void deathScreenShred() {
        FADE_TIME_SECS::second => now;
        radio.deactivate();

        FADE_TIME_SECS::second => now;
        death_music.play(65);
        1::second => now;
    }
}
