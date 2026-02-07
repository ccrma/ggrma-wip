@import "scene.ck"

public class BarScene extends Scene {

    NPC @ stranger;

    fun BarScene() {
        me.dir() + "../assets/background.png" => assetPath;
    }

    fun void init(Player @ player, Prompt prompts[]) {
        dm.dialog().leftMargin(3.5);
        dm.dialog().rightMargin(3.8);
        dm.setPlayer(player);

        // Create scene NPC (identity set by dialogue script)
        new NPC("", "") @=> stranger;
        dm.setNpc(stranger);

        // Register NPC identities
        dm.registerNpc("Cleaner", me.dir() + "../assets/cleaning-bot.png");
        dm.registerNpc("Media", me.dir() + "../assets/media-bot.png");
        dm.registerNpc("Sommelier", me.dir() + "../assets/sommelier-bot.png");
        dm.registerNpc("Tsundere", me.dir() + "../assets/tsundere-bot.png");

        // Start dialogue
        dm.startDialogue(prompts);
    }

    fun void update(ChuGUI gui) {
        super.render(gui);
        stranger.update(gui);
        dm.update(gui);
    }
}
