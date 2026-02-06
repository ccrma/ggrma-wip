@import "scene.ck"

public class BarScene extends Scene {

    NPC @ stranger;

    fun BarScene() {
        me.dir() + "../assets/background.jpg" => assetPath;
    }

    fun void init(Player @ player, Prompt prompts[]) {
        dm.dialog().leftMargin(3.5);
        dm.setPlayer(player);

        // Create scene NPC
        new NPC("Stranger", me.dir() + "../assets/sommelier-bot.png") @=> stranger;
        dm.setNpc(stranger);
        dm.showNpc();

        // Start dialogue
        dm.startDialogue(prompts);
    }

    fun void update(ChuGUI gui) {
        super.render(gui);
        stranger.update(gui);
        dm.update(gui);
    }
}
