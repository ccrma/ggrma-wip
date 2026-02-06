@import "../../ChuGUI/src/ChuGUI.ck"
@import "camera.ck"
@import "../ui/portrait.ck"

public class NPC {
    Portrait portrait;
    string _name;

    fun NPC(string name, string assetPath) {
        name => _name;

        Camera.worldWidth() / 2 - 2 => float rightX;
        portrait.assetPath(assetPath);
        portrait.pos(@(rightX, 0));
        portrait.size(@(1640./1640, 2360./1640) * 4.5);
        portrait.zIndex(1.4);
    }

    fun void update(ChuGUI gui) {
        portrait.update(gui);
    }

    fun string name() {
        return _name;
    }

    fun void show() {
        spork ~ portrait.show();
    }

    fun void hide() {
        spork ~ portrait.hide();
    }

    fun void highlight() {
        portrait.highlight();
    }

    fun void dim() {
        portrait.dim();
    }
}
