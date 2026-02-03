/* ==================================================
// how to use:

// parse a dialog string 
Prompt.parse(demo_prompt2, false) @=> Prompt prompts[];

// the first prompt will be what you should display first
prompts[0] @=> Prompt@ curr_prompt;

// if there are no response options, this is how you get the next line of text
curr_prompt.next @=> Prompt@ next_prompt;

// else if the prompt has user response options, they will be stored here:
curr_prompt.responses.size() > 0 => int has_responses;

// if the user selects a response, follow it to the next response via:
curr_prompt.responses[response_idx].next @=> next_prompt;
================================================== */

// *, _, {}, |, ==, [], //
// use string ids and chuck assoc array

public class Prompt {
    // prompt type enum
    0 => static int Type_Prose;
    1 => static int Type_Response;

    // style enum
    0 => static int Style_None;
    1 => static int Style_Italic;

    0 => static int Speaker_Player;
    1 => static int Speaker_NPC;

    int type;
    int style;
    int speaker;

    string tag;      // user-set tag of this prompt
    string next_tag; // set if this prompt redirects to another prompt
    string text;

    Prompt@ parent;       // for response prompts, the prose they are tied to
    Prompt@ next;         // a prompt either goes directly into another prompt
    Prompt@ responses[0];  // OR ends the NPC's line and requires user input to proceed

    fun string toString() {
        string s;
        if (type == Type_Response) "- " +=> s;
        if (tag.length()) "{" + tag + "} " +=> s;
        if (style == Style_Italic) "*" +=> s;
        text +=> s;
        if (style == Style_Italic) "*" +=> s;
        if (next_tag.length()) "[" + next_tag + "]" +=> s;
        return s;
    }

    fun static Prompt[] parse(string s, int log) {
        Prompt prompts[0];
        int idx;
        int style;
        Prompt.Type_Prose => int type;
        Prompt.Speaker_Player => int speaker;
        string tag;
        Prompt@ last_prompt;

        while (idx < s.length()) {
            s.charAt(idx) => int char;
            // consume leading whitespace
            if (char == ' ' || char == '\t' || char == '\n') {
                ++idx;
                continue;
            }
            // check if this is tag
            else if (char == '{') {
                ++idx;
                // make sure there's a closing tag
                s.find('}', idx) => int close_tag_idx;
                if (close_tag_idx == -1) {
                    <<< "missing closing tag } to match with tag at index ", idx >>>; 
                    return null;
                }
                // else consume tag
                s.substring(idx, close_tag_idx - idx) => tag; 
                if (log) <<< "parsed tag", tag >>>;
                close_tag_idx + 1 => idx;

                // warn for duplicate tags
                if (prompts.isInMap(tag)) <<< "warning, duplicate tag: ", tag >>>;
                continue;
            }
            // check for speaker designation
            else if (char == '(') {
                 ++idx;
                // make sure there's a closing paranthesis
                s.find(')', idx) => int close_spk_idx;
                if (close_spk_idx == -1) {
                    <<< "missing closing tag ) to match with tag at index ", idx >>>; 
                    return null;
                }
                s.substring(idx, close_spk_idx - idx) => string spk;
                spk == "Player" ? Prompt.Speaker_Player => speaker : Prompt.Speaker_NPC => speaker;
                if (log) <<< "parsed speaker", spk >>>;
                close_spk_idx + 1 => idx;
            }
            // ignore comments
            else if (char == '#' || (char == '/' && s.charAt(idx + 1) == '/')) {
                s.find('\n', idx+1) => int end_comment_idx;
                if (end_comment_idx == -1) s.length() => idx;
                end_comment_idx + 1 => idx;
                continue;
            }
            // push style stack
            else if (char == '*') {
                Prompt.Style_Italic => style;
                ++idx;
                continue;
            }
            // push prompt stack 
            else if (char == '-') {
                Prompt.Type_Response => type;
                ++idx;
                continue;
            }
            // consume prompt
            else {
                Prompt p;
                type => p.type; Prompt.Type_Prose => type;
                style => p.style; Prompt.Style_None => style;
                speaker => p.speaker; Prompt.Speaker_Player => speaker;
                tag => p.tag; "" => tag;

                // prompt is text up to newline or [] redirect
                idx => int start_text_idx;
                int end_text_idx;
                int prompt_redirect_idx;
                while (s.charAt(idx) != '\n' && idx != s.length()) {
                    if (s.charAt(idx) == '#') {
                        break;
                    }
                    if (s.charAt(idx) == '[') {
                        s.find(']', idx) => int close_redirect_idx;
                        if (close_redirect_idx == -1)
                            <<< "missing closing ] to match with [ at index ", idx >>>; 
                        else {
                            s.substring(idx+1, close_redirect_idx - idx - 1) => string redirect_tag;
                            redirect_tag => p.next_tag;
                            if (log) <<< "parsed redirect tag", p.next_tag, redirect_tag >>>;
                        }
                        break;
                    }
                    ++idx;
                }
                idx => end_text_idx;

                // set text
                s.substring(start_text_idx, end_text_idx - start_text_idx) => p.text;

                // go to end of line
                if (idx < s.length() - 1) {
                    s.find('\n', idx) => idx;
                    if (idx == -1) s.length() => idx;
                }

                // reset prompt / tag state consuming a prompt
                if (p.type == Prompt.Type_Prose) {
                    p @=> prompts[p.tag];

                    // update the `next` of prev prompt if it didn't have explicit tag A
                    if (last_prompt != null && (last_prompt.next_tag == "" || last_prompt.next_tag == null)) {
                        p @=> last_prompt.next;
                    }
                    p @=> last_prompt;
                } 
                else if (p.type == Prompt.Type_Response) {
                    if (p.tag.length()) <<< "cannot have tag ", tag, " with response ", p.toString() >>>;
                    if (last_prompt != null) {
                        last_prompt.responses << p;
                        last_prompt @=> p.parent;
                    }
                }

                // cleanup
                prompts << p;

                if (log) <<< "parsed prompt:\n\t", p.toString() >>>;
            }
        }

        // second pass: map tags to [] redirection
        for (auto p : prompts) {
            if (p.next_tag.length()) {
                if (!prompts.isInMap(p.next_tag)) {
                    <<< "error: redirect tag [", p.next_tag, "] does not exist for prompt", p.toString() >>>;
                    continue;
                }
                prompts[p.next_tag] @=> p.next;
            } else {
                // for responses with no redirect, just follow parent\
                if (p.type == Prompt.Type_Response && p.parent != null) p.parent.next @=> p.next;
            }
        }

        return prompts;
    }
}

"
{begin} this is the start of dialog

then we go here

what is your name?
- Audrey [Audrey]
- Ben [Ben]
- Andrew [Andrew]

{Audrey} Hi Audrey! [resume]

{Ben} Hi Ben! [resume]

{Andrew} Hi Andrew! [resume]


{resume} reconnect dialog here [begin]
" => string demo_prompt2;


// e.g.
/*
G2D g;
Prompt.parse(demo_prompt2, false) @=> Prompt prompts[];
prompts[0] @=> Prompt@ curr_prompt;
int response_idx;
while (1) {
    GG.nextFrame() => now;

    { // input
        if (g.mouseLeftDown()) {
            // no responses, move on
            if (!curr_prompt.responses.size()) curr_prompt.next @=> curr_prompt;
            else {
                curr_prompt.responses[response_idx].next @=> curr_prompt;
            }
            0 => response_idx;
        }

        if (GWindow.keyDown(GWindow.KEY_DOWN)) 1 +=> response_idx;
        if (GWindow.keyDown(GWindow.KEY_RIGHT)) 1 +=> response_idx;
        if (GWindow.keyDown(GWindow.KEY_UP)) 1 -=> response_idx;
        if (GWindow.keyDown(GWindow.KEY_LEFT)) 1 -=> response_idx;
        Math.clampi(response_idx, 0, curr_prompt.responses.size()-1) => response_idx;

    }

    if (curr_prompt != null) {
        g.CENTER => vec2 pos;
        g.text(curr_prompt.text, pos, .2);

        @(0, -4) => pos;
        for (int i; i < curr_prompt.responses.size(); i++) {
            .2 -=> pos.y;

            Color.WHITE => vec3 color;
            if (i == response_idx) Color.RED => color;

            g.pushColor(color);
            g.text(curr_prompt.responses[i].text, pos, .2);
            g.popColor();
        }
    }

}
*/