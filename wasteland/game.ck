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
    Prompt.parse(Data.credits, false) @=> Prompt credit_prompts[];

    // Player persists across all scenes
    Player player("You", me.dir() + "assets/human/human.png");

    true => int titleScreen;

    new BarScene @=> Scene @ scene;

    // Radio mechanic for dialogue choices
    RadioMechanic radio(gui);
    TitleRadioMechanic titleRadio(gui);
    DeathRadioMechanic deathRadio(gui);

    // fade-in state
    float _fadeAlpha;
    2.0 => float FADE_IN_SECS;

    // death state stuff
    int dead;
    int deathMenuActive;
    time dead_time;
    3 => float FADE_TIME_SECS;
    DeathMusic death_music;

    // title screen stuff
    SndBuf title_music(me.dir() + "./assets/audio/wasteland.wav") => ADSR title_music_adsr => dac;
    1 => title_music.loop;
    title_music_adsr.attackTime(10::second);
    PoleZero pole; .99 => pole.blockZero;
    (34 * (second/samp))$int => title_music.pos;

    Spring enter_rot_spring(0, 100, 8);
    Spring enter_sca_spring(0, 420, 8);
    Spring arrow_rot_spring(0, 100, 8);
    Spring arrow_sca_spring(0, 420, 8);


    fun void init() {
        // Initialize game radio
        radio.scale(@(0.525, 1.5));
        radio.setPosition(@(-0.575, 0.4));
        radio.setAudioBasePath(me.dir() + "assets/audio/");
        radio.init();

        // Initialize title radio
        // titleRadio.scale(@(0.525, 1.5));
        titleRadio.scale(@(0.45, 1.5));
        // titleRadio.setPosition(@(0, 0.4));
        1.5 => titleRadio._textScale;
        titleRadio.setAudioBasePath(me.dir() + "assets/audio/");
        titleRadio.init();
        titleRadio.setOptions(["Start", "Credits"]);
        titleRadio.activate();
        .25 => titleRadio.dotX[0];
        .75 => titleRadio.dotX[1];

        dac =< titleRadio.accum;
        title_music_adsr => pole => titleRadio.accum;
        titleRadio.waveform.pos(@(.05, -.315));
        titleRadio.waveform.width(.01);
        1.1 => titleRadio.DISPLAY_WIDTH;
        1 => titleRadio.waveform_sca;

        // Initialize death radio
        deathRadio.scale(@(0.525, 1.5));
        deathRadio.setAudioBasePath(me.dir() + "assets/audio/");
        deathRadio.init();

        // Init music and audio
        titleRadio.sfx_gain =< dac;
        titleRadio.sfx_gain => title_music_adsr;
        spork ~ startMusic();
    }

    fun void startMusic() {
        second => now;
        title_music_adsr.keyOn();
    }

    fun void startGame(Prompt prompt[]) {
        false => titleScreen;
        titleRadio.deactivate();
        1.0 => _fadeAlpha;
        scene.init(player, prompt);
        scene.dialogManager().setRadio(radio);
    }

    fun void run() {
        init();

        // Main game loop
        while (true) {
            GG.nextFrame() => now;
            GG.dt() => float dt;

            UIStyle.pushVar(UIStyle.VAR_LABEL_FONT, me.dir() + "assets/fonts/GiantRobotArmy.ttf");

            if (titleScreen) {

                if (GWindow.keyDown(GWindow.KEY_RIGHT) || GWindow.keyDown(GWindow.KEY_LEFT)) {
                    arrow_rot_spring.pull(.1);
                    arrow_sca_spring.pull(.1);
                }

                if (GWindow.keyDown(GWindow.KEY_ENTER)) {
                    enter_rot_spring.pull(.1);
                    enter_sca_spring.pull(.1);
                }

                arrow_rot_spring.update(dt);
                arrow_sca_spring.update(dt);
                enter_rot_spring.update(dt);
                enter_sca_spring.update(dt);

                UIStyle.pushVar(UIStyle.VAR_ICON_SIZE, @(2, 2));
                UIStyle.pushVar(UIStyle.VAR_ICON_Z_INDEX, -1);
                gui.icon(me.dir() + "assets/title/title_screen.png", @(0, 0));
                UIStyle.popVar(2);

                UIStyle.pushVar(UIStyle.VAR_ICON_SIZE, @(2, 2));
                UIStyle.pushVar(UIStyle.VAR_ICON_Z_INDEX, 0);
                gui.icon(me.dir() + "assets/title/title_silhouettes.png", @(0, 0));
                UIStyle.popVar(2);

                UIStyle.pushVar(UIStyle.VAR_ICON_Z_INDEX, 0);
                UIStyle.pushVar(UIStyle.VAR_ICON_SIZE, (2 + .5 * arrow_sca_spring.x) * @(1, 1));
                gui.icon(me.dir() + "assets/title/title_arrows.png", @(0, 0));
                UIStyle.popVar(2);

                UIStyle.pushVar(UIStyle.VAR_ICON_Z_INDEX, 0);
                UIStyle.pushVar(UIStyle.VAR_ICON_SIZE, (2 + .5 * enter_sca_spring.x) * @(1, 1));
                gui.icon(me.dir() + "assets/title/title_enter.png", @(0, 0));
                UIStyle.popVar(2);

                titleRadio.update();

                if (GWindow.keyDown(GWindow.KEY_ENTER) && titleRadio.hasSelection()) {
                    titleRadio.getSelectedIndex() => int sel;

                    if (sel == 0) {
                        // "Start" selected
                        title_music_adsr.keyOff();
                        startGame(prompts);
                    } else {
                        startGame(credit_prompts);
                    }
                    // sel == 1 is "Credits" — handle later
                }
            } else {
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

                    // Check if dialogue triggered death via [die] tag
                    if (scene.dialogManager().deathTriggered()) {
                        true => dead;
                        now => dead_time;
                        radio.mark.alert();
                        spork ~ deathScreenShred();
                    }
                }
            }

            UIStyle.popVar();

            // fade-in overlay
            if (_fadeAlpha > 0) {
                GG.dt() / FADE_IN_SECS -=> _fadeAlpha;
                if (_fadeAlpha < 0) 0 => _fadeAlpha;
                UIStyle.pushColor(UIStyle.COL_RECT, @(0, 0, 0, _fadeAlpha));
                UIStyle.pushVar(UIStyle.VAR_RECT_SIZE, @(2, 2));
                UIStyle.pushVar(UIStyle.VAR_RECT_TRANSPARENT, true);
                UIStyle.pushVar(UIStyle.VAR_RECT_Z_INDEX, 4.5);
                gui.rect(@(0, 0));
                UIStyle.popVar(3);
                UIStyle.popColor();
            }

            // death
            {
                if (radio.outOfTime() && !dead || GWindow.keyDown(GWindow.KEY_D)) {
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

                    // Death menu radio
                    if (deathMenuActive) {
                        deathRadio.update();

                        if (GWindow.keyDown(GWindow.KEY_ENTER) && deathRadio.hasSelection()) {
                            deathRadio.getSelectedIndex() => int sel;
                            if (sel == 0) {
                                // Restart from beginning
                                radio.deactivate();
                                titleRadio.deactivate();
                                deathRadio.deactivate();
                                death_music.stop();
                                false => dead;
                                false => deathMenuActive;
                                1.0 => _fadeAlpha;
                                (scene $ BarScene).startAudio();
                                scene.dialogManager().restartDialogue();
                            } else if (sel == 1) {
                                // Continue from last choice
                                deathRadio.deactivate();
                                death_music.stop();
                                false => dead;
                                false => deathMenuActive;
                                1.0 => _fadeAlpha;
                                (scene $ BarScene).startAudio();
                                scene.dialogManager().continueFromLastChoice();
                            } else if (sel == 2) {
                                // Credits
                            } else if (sel == 3) {
                                // Exit
                                me.exit();
                            }
                        }
                    }
                }
            }
        }
    }

    fun void deathScreenShred() {
        FADE_TIME_SECS::second => now;
        radio.deactivate();
        titleRadio.deactivate();
        (scene $ BarScene).stopAudio();

        FADE_TIME_SECS::second => now;
        spork ~ death_music.play(65);
        1::second => now;

        // Show death menu radio
        deathRadio.setOptions(["Restart", "Continue", "Credits", "Exit"]);
        deathRadio.activate();
        true => deathMenuActive;
    }
}
