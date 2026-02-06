@import "../../ChuGUI/src/ChuGUI.ck"
@import "player.ck"
@import "npc.ck"
@import "dialogEngine.ck"
@import "radio.ck"
@import "../ui/dialogBox.ck"

public class DialogManager {
    Player @ _player;
    NPC @ _npc;

    DialogBox dialogBox;

    // Radio mechanic for dialogue choices
    RadioMechanic @ _radio;

    // Prompt state
    Prompt @ _currentPrompt;
    int _responseIndex;

    int selectionShown;

    fun DialogManager() {
        dialogBox.scale(1.0);
        dialogBox.text("...");
    }

    fun void setRadio(RadioMechanic @ radio) {
        radio @=> _radio;
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
        if (_radio != null) spork ~ _radio.highlight();
        dialogBox.text(text);
    }

    fun void npcSays(string text) {
        if (_npc != null) {
            dialogBox.speakerName(_npc.name());
            _npc.highlight();
        }
        if (_player != null) _player.dim();
        if (_radio != null) spork ~ _radio.dim();
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
            if (_radio != null) _radio.deactivate();
            return;
        }

        if (_currentPrompt.responses.size() <= 0) {
            if (_currentPrompt.speaker == Prompt.Speaker_NPC) {
                npcSays(_currentPrompt.text);
            } else if (_currentPrompt.speaker == Prompt.Speaker_Player) {
                playerSays(_currentPrompt.text);
            }
        }

        0 => _responseIndex;

        // Configure radio if there are responses
        if (_radio != null) {
            if (_currentPrompt.responses.size() > 0) {
                // Extract response labels
                string labels[0];
                for (int i; i < _currentPrompt.responses.size(); i++) {
                    labels << _currentPrompt.responses[i].text;
                }
                _radio.setOptions(labels);
                _radio.activate();

                // Show response template in dialogue box (player speaking)
                if (_currentPrompt.responseTemplate.length() > 0) {
                    _currentPrompt.responseTemplate.rfind("...") => int ellipsisIdx;
                    playerSays(_currentPrompt.responseTemplate.substring(0, ellipsisIdx) + "...");
                }
            } else {
                _radio.deactivate();
            }
        }
    }

    fun void revealSelected() {
        if (_currentPrompt == null) return;
        if (_currentPrompt.responses.size() == 0) return;
        true => selectionShown;

        _radio.getSelectedIndex() => int selectedIdx;
        _currentPrompt.responses[selectedIdx].text => string responseText;

        // Insert selection after "..."
        _currentPrompt.responseTemplate.find("...") => int ellipsisIdx;
        _currentPrompt.responseTemplate.substring(0, ellipsisIdx + 3) + " " +
            responseText.rtrim() +
            _currentPrompt.responseTemplate.substring(ellipsisIdx + 3) => string fullText;

        dialogBox.text(fullText, ellipsisIdx + 3);
    }

    fun void advanceDialogue() {
        if (_currentPrompt == null) return;

        if (_currentPrompt.responses.size() > 0) {
            // Use radio selection if available, otherwise fall back to _responseIndex
            if (_radio != null && _radio.hasSelection()) {
                _radio.getSelectedIndex() => int selectedIdx;

                if (!selectionShown) {
                    // show selection in dialog box
                    _radio.playSelectionSfx();
                    _radio.deactivate();
                    spork ~ revealSelected();
                    return;
                } else {
                    _currentPrompt.responses[selectedIdx].next @=> _currentPrompt;
                    false => selectionShown;
                }
            } else if (_radio == null) {
                // Fallback for when radio is not set
                _currentPrompt.responses[_responseIndex].next @=> _currentPrompt;
            } else {
                // Radio is active but no selection - don't advance
                return;
            }
        } else {
            _currentPrompt.next @=> _currentPrompt;
        }

        0 => _responseIndex;
        showCurrentPrompt();
    }

    fun int canAdvance() {
        if (_currentPrompt == null) return 0;
        // If there are responses, need a radio selection
        if (_currentPrompt.responses.size() > 0) {
            if (_radio != null) {
                return _radio.hasSelection();
            }
            return 1; // Fallback
        }
        return 1; // No responses, can always advance
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

    fun void skipTypewriter() {
        dialogBox.skipTypewriter();
    }

    fun int isTyping() {
        return dialogBox.isTyping();
    }
}
