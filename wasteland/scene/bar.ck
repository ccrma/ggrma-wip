@import "scene.ck"

public class BarScene extends Scene {

    NPC @ stranger;

    fun BarScene() {
        me.dir() + "../assets/background.jpg" => assetPath;
    }

    fun void init(Player @ player, Prompt prompts[]) {
        dm.dialog().leftMargin(3.0);
        dm.setPlayer(player);

        // Create scene NPC
        new NPC("Stranger", me.dir() + "../assets/npc1.png") @=> stranger;
        dm.setNpc(stranger);
        dm.showNpc();

        // Start dialogue
        dm.startDialogue(prompts);
    }

    fun void update(ChuGUI gui) {
        super.render(gui);
        stranger.update(gui);
        dm.update(gui);
        dm.renderResponses(gui);
    }
}
