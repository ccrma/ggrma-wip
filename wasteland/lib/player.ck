@import "../../ChuGUI/src/ChuGUI.ck"
@import "camera.ck"
@import "../ui/portrait.ck"

public class Player {
    Portrait portrait;
    string _name;

    fun Player(string name, string assetPath) {
        name => _name;

        // Set up portrait on left side
        Camera.worldWidth() / -2 + 2.5 => float leftX;
        portrait.assetPath(assetPath);
        portrait.size(@(1640./1640, 2360./1640) * 5);
        portrait.pos(@(leftX, -0.6));
        portrait.zIndex(1.5);
        portrait.visible(true);
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
