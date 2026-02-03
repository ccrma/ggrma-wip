@import "../../ChuGUI/src/ChuGUI.ck"
@import "player.ck"
@import "npc.ck"
@import "dialogEngine.ck"
@import "../ui/dialogBox.ck"

public class DialogManager {
    Player @ _player;
    NPC @ _npc;

    DialogBox dialogBox;

    // Prompt state
    Prompt @ _currentPrompt;
    int _responseIndex;

    fun DialogManager() {
        dialogBox.scale(1.0);
        dialogBox.text("...");
    }

    fun void setPlayer(Player @ p) {
        p @=> _player;
    }

    fun void setNpc(NPC @ n) {
        n @=> _npc;
    }

    fun void update(ChuGUI gui) {
        dialogBox.update(gui);
    }

    fun void showPlayer() {
        if (_player != null) _player.show();
    }

    fun void hidePlayer() {
        if (_player != null) _player.hide();
    }

    fun void showNpc() {
        if (_npc != null) _npc.show();
    }

    fun void hideNpc() {
        if (_npc != null) _npc.hide();
    }

    fun void setDialog(string speaker, string text) {
        dialogBox.speakerName(speaker);
        dialogBox.text(text);
    }

    fun void showDialog() {
        spork ~ dialogBox.show();
    }

    fun void hideDialog() {
        spork ~ dialogBox.hide();
    }

    fun DialogBox dialog() {
        return dialogBox;
    }

    fun Player player() {
        return _player;
    }

    fun NPC npc() {
        return _npc;
    }

    fun void playerSays(string text) {
        if (_player != null) {
            dialogBox.speakerName(_player.name());
            _player.highlight();
        }
        if (_npc != null) _npc.dim();
        dialogBox.text(text);
    }

    fun void npcSays(string text) {
        if (_npc != null) {
            dialogBox.speakerName(_npc.name());
            _npc.highlight();
        }
        if (_player != null) _player.dim();
        dialogBox.text(text);
    }

    fun void clearSpeaker() {
        if (_player != null) _player.highlight();
        if (_npc != null) _npc.highlight();
    }

    // Prompt handling

    fun void startDialogue(Prompt prompts[]) {
        prompts[0] @=> _currentPrompt;
        0 => _responseIndex;
        showCurrentPrompt();
    }

    fun void showCurrentPrompt() {
        if (_currentPrompt == null) {
            clearSpeaker();
            setDialog("", "End of dialogue.");
            return;
        }

        if (_currentPrompt.speaker == Prompt.Speaker_NPC) {
            npcSays(_currentPrompt.text);
        } else {
            playerSays(_currentPrompt.text);
        }

        0 => _responseIndex;
    }

    fun void advanceDialogue() {
        if (_currentPrompt == null) return;

        if (_currentPrompt.responses.size() > 0) {
            _currentPrompt.responses[_responseIndex].next @=> _currentPrompt;
        } else {
            _currentPrompt.next @=> _currentPrompt;
        }

        0 => _responseIndex;
        showCurrentPrompt();
    }

    fun void selectResponse(int delta) {
        if (_currentPrompt == null) return;
        if (_currentPrompt.responses.size() == 0) return;

        _responseIndex + delta => _responseIndex;
        Math.clampi(_responseIndex, 0, _currentPrompt.responses.size() - 1) => _responseIndex;
    }

    fun int responseCount() {
        if (_currentPrompt == null) return 0;
        return _currentPrompt.responses.size();
    }

    fun int selectedResponse() {
        return _responseIndex;
    }

    fun Prompt @ getResponse(int idx) {
        if (_currentPrompt == null) return null;
        if (idx < 0 || idx >= _currentPrompt.responses.size()) return null;
        return _currentPrompt.responses[idx];
    }

    fun void renderResponses(ChuGUI gui) {
        if (_currentPrompt == null || _currentPrompt.responses.size() == 0) return;

        @(0, 0) => vec2 pos;
        for (int i; i < _currentPrompt.responses.size(); i++) {
            -.15 +=> pos.y;

            Color.WHITE => vec3 color;
            if (i == _responseIndex) Color.BLACK => color;

            string prefix;
            if (i == _responseIndex) "> " => prefix;
            UIStyle.pushColor(UIStyle.COL_LABEL, color);
            UIStyle.pushVar(UIStyle.VAR_LABEL_SIZE, 0.05);
            gui.label(prefix + _currentPrompt.responses[i].text, pos);
            UIStyle.popVar();
            UIStyle.popColor();
        }
    }
}
