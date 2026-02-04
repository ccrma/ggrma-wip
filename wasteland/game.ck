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
    Player player("You", me.dir() + "assets/robot.png");

    BarScene scene;

    RadioMechanic radio;

    fun void init() {
        scene.init(player, prompts);
    }

    fun void run() {
        init();

        // Main game loop
        while (true) {
            GG.nextFrame() => now;

            player.update(gui);
            scene.update(gui);
            radio.update(gui);

            if (GWindow.keyDown(GWindow.KEY_UP)) {
                scene.dialogManager().selectResponse(-1);
            }
            if (GWindow.keyDown(GWindow.KEY_DOWN)) {
                scene.dialogManager().selectResponse(1);
            }

            if (GWindow.keyDown(GWindow.KEY_SPACE) || GWindow.keyDown(GWindow.KEY_ENTER)) {
                scene.dialogManager().advanceDialogue();
            }
        }
    }
}
