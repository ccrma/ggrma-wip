@import "C:/Users/banhq/Documents/Projects/ChuGUI/src/ChuGUI.ck"
@import "lib/player.ck"
@import "scene/bar.ck"

public class Game {
    ChuGUI gui --> GG.scene();

    // Player persists across all scenes
    Player player("You", me.dir() + "assets/robot.png");

    BarScene scene;

    fun void init() {
        scene.init(player);
    }

    fun void run() {
        init();

        // Main game loop
        while (true) {
            GG.nextFrame() => now;

            // Update scene
            scene.update(gui);

            // Handle input (advance dialog with SPACE or ENTER)
            if (GWindow.keyDown(GWindow.KEY_SPACE) || GWindow.keyDown(GWindow.KEY_ENTER)) {
                scene.advanceDialogue();
            }
        }
    }
}
