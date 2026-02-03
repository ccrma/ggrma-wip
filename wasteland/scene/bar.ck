@import "../../ChuGUI/src/ChuGUI.ck"
@import "scene.ck"
@import "../lib/player.ck"
@import "../lib/npc.ck"

public class BarScene extends Scene {

    NPC @ stranger;

    int dialogIndex;
    [
        "PLAYER:Where am I?",
        "NPC:You're in the wasteland, stranger.",
        "PLAYER:The wasteland? How did I get here?",
        "NPC:That's what everyone asks at first.",
        "NPC:You'll remember eventually. Or you won't.",
        "PLAYER:That's... not very reassuring.",
        "NPC:Welcome to the wasteland."
    ] @=> string dialogue[];

    fun BarScene() {
        me.dir() + "../assets/background.jpg" => assetPath;
    }

    fun void init(Player @ player) {
        dm.dialog().leftMargin(3.0);
        dm.setPlayer(player);

        // Create scene NPC
        new NPC("Stranger", me.dir() + "../assets/npc1.png") @=> stranger;
        dm.setNpc(stranger);
        dm.showNpc();

        // Start with first dialogue
        0 => dialogIndex;
        showDialogue(dialogIndex);
    }

    fun void showDialogue(int index) {
        if (index >= dialogue.size()) {
            dm.clearSpeaker();
            dm.setDialog("", "Press SPACE to restart...");
            return;
        }

        dialogue[index] => string line;

        // Parse speaker and text
        if (line.find("PLAYER:") == 0) {
            line.substring(7) => string text;
            dm.playerSays(text);
        } else if (line.find("NPC:") == 0) {
            line.substring(4) => string text;
            dm.npcSays(text);
        }
    }

    fun void advanceDialogue() {
        dialogIndex++;
        if (dialogIndex > dialogue.size()) {
            0 => dialogIndex;
        }
        showDialogue(dialogIndex);
    }

    fun void update(ChuGUI gui) {
        super.render(gui);
        dm.update(gui);
    }
}
