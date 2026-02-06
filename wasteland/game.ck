@import "../ChuGUI/src/ChuGUI.ck"
@import "lib/player.ck"
@import "lib/radio.ck"
@import "lib/data.ck"
@import "lib/dialogEngine.ck"
@import "scene/bar.ck"

public class Game {
    ChuGUI gui --> GG.scene();

    Prompt.parse(Data.script, false) @=> Prompt prompts[];

    // Player persists across all scenes
    Player player("You", me.dir() + "assets/human.png");

    BarScene scene;

    // Radio mechanic for dialogue choices
    RadioMechanic radio;

    fun void init() {
        // Initialize radio
        radio.scale(1.5);
        radio.setPosition(@(0, -0.3));
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

            player.update(gui);
            scene.update(gui);
            radio.update(gui);

            // ENTER advances dialogue (for both choices and regular dialogue)
            // For choices, only advances if slider is on a dot (has selection)
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
                } else if (scene.dialogManager().responseCount() == 0 || scene.dialogManager().selectionShown) {
                    scene.dialogManager().advanceDialogue();
                }
            }
        }
    }
}
