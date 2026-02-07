@import "../../ChuGUI/src/ChuGUI.ck"
@import "../lib/camera.ck"

public class DialogBox {
    string _speakerName;
    string _text;
    float _scale;

    0.25 => float dialogHeightRatio;

    1.5 => float _leftMargin;
    1.5 => float _rightMargin;

    float _charCount;
    int _targetCharCount;
    0.5 => float _charsPerFrame;

    fun void update(ChuGUI gui) {
        if (_charCount < _targetCharCount) {
            _charCount + _charsPerFrame => _charCount;
            if (_charCount > _targetCharCount) _targetCharCount => _charCount;
        }
        render(gui);
    }

    fun void render(ChuGUI gui) {
        if (_scale <= 0) return;

        gui.units(ChuGUI.WORLD);

        Math.max(0.0, Math.min(1.0, _scale)) => float s;

        Camera.worldWidth() => float width;
        Camera.worldHeight() * dialogHeightRatio => float height;

        (width * s) => float scaledWidth;
        (height * s) => float scaledHeight;

        Camera.worldHeight() / -2 + scaledHeight / 2 => float yPos;

        // UIStyle.pushColor(UIStyle.COL_RECT, @(0.05, 0.05, 0.08));
        // UIStyle.pushColor(UIStyle.COL_RECT_BORDER, @(0.3, 0.3, 0.35));
        // UIStyle.pushVar(UIStyle.VAR_RECT_SIZE, @(scaledWidth - 0.1, scaledHeight - 0.05));
        // UIStyle.pushVar(UIStyle.VAR_RECT_CONTROL_POINTS, @(0.5, 0.5));
        // UIStyle.pushVar(UIStyle.VAR_RECT_BORDER_WIDTH, 0.03 * s);
        // UIStyle.pushVar(UIStyle.VAR_RECT_BORDER_RADIUS, 0.1);
        // UIStyle.pushVar(UIStyle.VAR_RECT_Z_INDEX, 0.9);
        // gui.rect(@(0, yPos));
        // UIStyle.popVar(5);
        // UIStyle.popColor(2);

        gui.posUnits(ChuGUI.NDC);
        
        UIStyle.pushVar(UIStyle.VAR_ICON_CONTROL_POINTS, @(0.5, 0));
        UIStyle.pushVar(UIStyle.VAR_ICON_SIZE, @(1730./1730 * 12, 490./1730 * 8));
        gui.icon(me.dir() + "../assets/dialogue_box.png", @(0.15, -1));
        UIStyle.popVar(2);

        gui.posUnits(ChuGUI.WORLD);

        scaledWidth / -2 + _leftMargin + 1.375 => float textLeftX;
        scaledWidth - _leftMargin - _rightMargin - 0.4 => float textMaxWidth;

        if (_speakerName != "") {
            yPos + scaledHeight / 2 + 0.165 => float nameY;

            UIStyle.pushColor(UIStyle.COL_LABEL, @(0.9, 0.8, 0.5));
            UIStyle.pushVar(UIStyle.VAR_LABEL_CONTROL_POINTS, @(0.5, 0.5));
            UIStyle.pushVar(UIStyle.VAR_LABEL_Z_INDEX, 3.75);
            UIStyle.pushVar(UIStyle.VAR_LABEL_SIZE, 0.24 * s);
            gui.label(_speakerName, @(textLeftX, nameY));
            UIStyle.popVar(3);
            UIStyle.popColor();
        }

        yPos + scaledHeight / 2 - 0.18 => float textY;

        UIStyle.pushColor(UIStyle.COL_LABEL, Color.WHITE);
        UIStyle.pushVar(UIStyle.VAR_LABEL_CONTROL_POINTS, @(0, 1));
        UIStyle.pushVar(UIStyle.VAR_LABEL_Z_INDEX, 3.75);
        UIStyle.pushVar(UIStyle.VAR_LABEL_SIZE, 0.19 * s);
        UIStyle.pushVar(UIStyle.VAR_LABEL_MAX_WIDTH, textMaxWidth);
        UIStyle.pushVar(UIStyle.VAR_LABEL_CHARACTERS, _charCount $ int);
        gui.label(_text.trim(), @(textLeftX - 0.9, textY));
        UIStyle.popVar(5);
        UIStyle.popColor();

        gui.units(ChuGUI.NDC);
    }

    fun void text(string text) {
        text => _text;
        0 => _charCount;
        _text.length() => _targetCharCount;
    }

    // Set text but start typewriter from a specific character position
    fun void text(string text, int startFrom) {
        text => _text;
        startFrom => _charCount;
        _text.length() => _targetCharCount;
    }

    fun string text() {
        return _text;
    }

    fun void skipTypewriter() {
        _targetCharCount => _charCount;
    }

    fun int isTyping() {
        return _charCount < _targetCharCount;
    }

    fun void speakerName(string name) {
        name => _speakerName;
    }

    fun string speakerName() {
        return _speakerName;
    }

    fun void show() {
        30 => int frames;
        for (int i; i <= frames; i++) {
            Math.sqrt((i * 1.0) / frames) => float t;
            t => _scale;
            GG.nextFrame() => now;
        }
        1.0 => _scale;
    }

    fun void hide() {
        30 => int frames;
        for (int i; i <= frames; i++) {
            (1.0 - Math.sqrt((i * 1.0) / frames)) => float t;
            t => _scale;
            GG.nextFrame() => now;
        }
        0.0 => _scale;
    }

    fun float scale() {
        return _scale;
    }

    fun void scale(float s) {
        s => _scale;
    }

    fun void leftMargin(float margin) {
        margin => _leftMargin;
    }

    fun float leftMargin() {
        return _leftMargin;
    }

    fun void rightMargin(float margin) {
        margin => _rightMargin;
    }

    fun float rightMargin() {
        return _rightMargin;
    }
}
