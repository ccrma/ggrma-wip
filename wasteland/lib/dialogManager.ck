@import "C:/Users/banhq/Documents/Projects/ChuGUI/src/ChuGUI.ck"
@import "camera.ck"
@import "player.ck"
@import "npc.ck"
@import "../ui/dialogBox.ck"

public class DialogManager {
    -1 => static int SPEAKER_NONE;
    0 => static int SPEAKER_PLAYER;
    1 => static int SPEAKER_NPC;

    int _currentSpeaker;

    Player @ _player;
    NPC @ _npc;

    DialogBox dialogBox;

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
        if (_player != null) {
            _player.update(gui);
        }

        if (_npc != null) {
            _npc.update(gui);
        }

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

    fun void setSpeaker(int speaker) {
        speaker => _currentSpeaker;
        updateHighlights();
    }

    fun void playerSays(string text) {
        setSpeaker(SPEAKER_PLAYER);
        if (_player != null) {
            dialogBox.speakerName(_player.name());
        }
        dialogBox.text(text);
    }

    fun void npcSays(string text) {
        setSpeaker(SPEAKER_NPC);
        if (_npc != null) {
            dialogBox.speakerName(_npc.name());
        }
        dialogBox.text(text);
    }

    fun void updateHighlights() {
        if (_player != null) {
            if (_currentSpeaker == SPEAKER_PLAYER) {
                _player.highlight();
            } else if (_currentSpeaker != SPEAKER_NONE) {
                _player.dim();
            }
        }

        if (_npc != null) {
            if (_currentSpeaker == SPEAKER_NPC) {
                _npc.highlight();
            } else if (_currentSpeaker != SPEAKER_NONE) {
                _npc.dim();
            }
        }
    }

    fun void clearSpeaker() {
        SPEAKER_NONE => _currentSpeaker;
        if (_player != null) _player.highlight();
        if (_npc != null) _npc.highlight();
    }

    fun int currentSpeaker() {
        return _currentSpeaker;
    }
}
