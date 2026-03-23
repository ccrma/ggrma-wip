@import "minigame.ck"

public class Mukbang extends Minigame 
{
    0 => static int Human_Idle;
    1 => static int Human_Eating0;
    2 => static int Human_Eating1;
    3 => static int Human_Done;
    4 => static int Human_Fail;

    7 => static int Text_Full;
    8 => static int Text_Yum;
    9 => static int Text_Count;

    // static assets
    static Texture@ bg_tex;
    static Texture@ table_tex;
    static Texture@ human_tex[5][5];
    6 => static int numFood;
    5 => static int numFoodAnim;
    static Texture@ food_tex[4][numFood][numFoodAnim];

    static Texture@ food_tex_level5[32]; // NOTE level5 has different number

    16 => static int numScraps;
    static Texture@ scrap_tex[5][numScraps];
    static Texture@ text_tex[5][Text_Count];
    static float text_aspects[5][Text_Count];
    static Texture@ bar_tex;
    static Texture@ bar_container;
    static Texture@ bar_text;
    static Texture@ reaction_tex[4];

    fun static void loadAssets() {
        TextureLoadDesc load_desc;
        true => load_desc.flip_y;
        false => load_desc.gen_mips;

        Texture.load(me.dir() + "../assets/mukbang/Level1/Background.png", load_desc) @=> bg_tex;
        Texture.load(me.dir() + "../assets/mukbang/Level1/Table.png", load_desc) @=> table_tex;

        // load human assets
        for (1 => int i; i <= 5; i++) {
            Texture.load(me.dir() + "../assets/mukbang/Level" + i + "/Human.png", load_desc) @=> human_tex[i-1][Human_Idle];
            Texture.load(me.dir() + "../assets/mukbang/Level" + i + "/Human_Eating_0.png", load_desc) @=> human_tex[i-1][Human_Eating0];
            Texture.load(me.dir() + "../assets/mukbang/Level" + i + "/Human_Eating_1.png", load_desc) @=> human_tex[i-1][Human_Eating1];
            Texture.load(me.dir() + "../assets/mukbang/Level" + i + "/Human_Eating_Done.png", load_desc) @=> human_tex[i-1][Human_Done];
            Texture.load(me.dir() + "../assets/mukbang/Level" + i + "/Human_Eating_Fail.png", load_desc) @=> human_tex[i-1][Human_Fail];
        }

        // load food
        for (int lvl; lvl < 4; lvl++)
            for (int i; i < numFood; i++)
                for (int j; j < numFoodAnim; j++)
                    Texture.load(me.dir() + "../assets/mukbang/Level" + (lvl+1) + "/Foods/foods" + (i+1) + "-" + j + ".png", load_desc) @=> food_tex[lvl][i][j];

        // load food level 5
        for (1 => int i; i <= 32; ++i) 
            Texture.load(me.dir() + "../assets/mukbang/Level5/Foods/foods" + (i) + ".png", load_desc) @=> food_tex_level5[i-1];
        
        // load scraps
        for (int lvl; lvl < 5; lvl++) {
            for (int i; i < numScraps; i++) {
                Texture.load(me.dir() + "../assets/mukbang/Level" + (lvl+1) + "/Scraps/scraps_" + i + ".png", load_desc) @=> scrap_tex[lvl][i];
            }
        }

        // load text
        for (int lvl; lvl < 5; lvl++) {
            Texture.load(me.dir() + "../assets/mukbang/Level" + (lvl+1) + "/Texts/Text1.png", load_desc) @=> text_tex[lvl][0];
            Texture.load(me.dir() + "../assets/mukbang/Level" + (lvl+1) + "/Texts/Text2.png", load_desc) @=> text_tex[lvl][1];
            Texture.load(me.dir() + "../assets/mukbang/Level" + (lvl+1) + "/Texts/Text3.png", load_desc) @=> text_tex[lvl][2];
            Texture.load(me.dir() + "../assets/mukbang/Level" + (lvl+1) + "/Texts/Text4.png", load_desc) @=> text_tex[lvl][3];
            Texture.load(me.dir() + "../assets/mukbang/Level" + (lvl+1) + "/Texts/Text5.png", load_desc) @=> text_tex[lvl][4];
            Texture.load(me.dir() + "../assets/mukbang/Level" + (lvl+1) + "/Texts/Text6.png", load_desc) @=> text_tex[lvl][5];
            Texture.load(me.dir() + "../assets/mukbang/Level" + (lvl+1) + "/Texts/Text7.png", load_desc) @=> text_tex[lvl][6];
            Texture.load(me.dir() + "../assets/mukbang/Level" + (lvl+1) + "/Texts/full.png", load_desc) @=> text_tex[lvl][Text_Full];
            Texture.load(me.dir() + "../assets/mukbang/Level" + (lvl+1) + "/Texts/yum.png", load_desc) @=> text_tex[lvl][Text_Yum];

            // compute aspects
            for (int i; i < text_tex[lvl].size(); i++) {
                text_tex[lvl][i].height() $ float / text_tex[lvl][i].width() => text_aspects[lvl][i];
            }
        }

        // UI
        Texture.load(me.dir() + "../assets/mukbang/UI/bar.png", load_desc) @=> bar_tex;
        Texture.load(me.dir() + "../assets/mukbang/UI/bar_container.png", load_desc) @=> bar_container;
        Texture.load(me.dir() + "../assets/mukbang/UI/barText.png", load_desc) @=> bar_text;

        // reactions
        Texture.load(me.dir() + "../assets/mukbang/Reactions/Heart.png", load_desc) @=> reaction_tex[0];
        Texture.load(me.dir() + "../assets/mukbang/Reactions/ThumbsUp.png", load_desc) @=> reaction_tex[1];
        Texture.load(me.dir() + "../assets/mukbang/Reactions/BrokenHeart.png", load_desc) @=> reaction_tex[2];
        Texture.load(me.dir() + "../assets/mukbang/Reactions/ThumbsDown.png", load_desc) @=> reaction_tex[3];
    }

// === local stuff ======================================

    sprite(bg_tex, 1080.0, 1920.0, 1) --> this;
    sprite(table_tex, 1080.0, 1920.0, 1) --> this;

    GGen@ go_human_idle;
    GGen@ go_human_eating[2];
    GGen@ go_human_done;
    GGen@ go_human_fail;
    GGen@ go_carrots[numFood][numFoodAnim];
    GGen@ go_carrots_level5[32];
    GGen@ go_scraps[numScraps];

    7 => int numTextIntro;
    GGen@ go_text_intros[numTextIntro];
    GGen@ go_text_yum;
    GGen@ go_text_full;

    GGen go_bar_pivot;
    go_bar_pivot.posY(.75 * 3.49);
    go_bar_pivot.posX(.75 * -1.5);
    GGen@ go_bar;
    GGen@ go_bar_case;
    GGen@ go_bar_text;

    vec2 v_reactions[4];
    @(146.0, 175.0) => v_reactions[0];
    @(155.0, 166.0) => v_reactions[1];
    @(154.0, 174.0) => v_reactions[2];
    @(154.0, 174.0) => v_reactions[3];

    // SYSTEM VARIABLES
    int bool_mukbang_start;
    int bool_mukbang_end;
    int bool_mukbang_fail;
    int bool_reactions;
    30 => int numEat;
    0 => int currentFood;
    0 => int currentAnim;
    0 => int currentScrap;
    0 => int currentHumanAnim;
    20 => int numReactions;
    6.0 => float initialGameTime;
    int level; 

    fun Mukbang(int lvl) {
        lvl => level;
        sprite(human_tex[lvl][Human_Idle], 1080.0, 1920.0, 2) @=> go_human_idle; go_human_idle --> this;
        sprite(human_tex[lvl][Human_Eating0], 1080.0, 1920.0, 2) @=> go_human_eating[0];
        sprite(human_tex[lvl][Human_Eating1], 1080.0, 1920.0, 2) @=> go_human_eating[1];
        sprite(human_tex[lvl][Human_Done], 1080.0, 1920.0, 2) @=> go_human_done;
        sprite(human_tex[lvl][Human_Fail], 1080.0, 1920.0, 2) @=> go_human_fail;

        if (level < 4) {
            for (int i; i < numFood; i++)
                for (int j; j < numFoodAnim; j++)
                        sprite(food_tex[lvl][i][j], 1080.0, 1920.0, 3 + (1.0 - i * 0.1)) @=> go_carrots[i][j];
        }
        // change for level5
        else {
            for (int i; i < 32; i++) {
                sprite(food_tex_level5[i], 1080.0, 1920.0, 3 + (1.0 - i * 0.1)) @=> go_carrots_level5[i];
            }
        }

        for (int i; i < numScraps; i++)
            sprite(scrap_tex[lvl][i], 1080.0, 1920.0, 2) @=> go_scraps[i];

        // text intros
        // TODO if time, change numbers to match mukbang1-5 (store values in array)
        sprite(text_tex[lvl][0], 450.0, 450.0 * text_aspects[lvl][0], 1) @=> go_text_intros[0];
        go_text_intros[0].posY(.75 * 4.5);
        sprite(text_tex[lvl][1], 894.0, 894.0 * text_aspects[lvl][1], 1) @=> go_text_intros[1];
        go_text_intros[1].posY(.75 * 3.75);
        sprite(text_tex[lvl][2], 645.0, 645.0 * text_aspects[lvl][2], 1) @=> go_text_intros[2];
        go_text_intros[2].posY(.75 * 2.8);
        sprite(text_tex[lvl][3], 154.0, 154.0 * text_aspects[lvl][3], 1) @=> go_text_intros[3];
        go_text_intros[3].posY(.75 * 3.5);
        sprite(text_tex[lvl][4], 179.0, 179.0 * text_aspects[lvl][4], 1) @=> go_text_intros[4];
        go_text_intros[4].posY(.75 * 3.5);
        sprite(text_tex[lvl][5], 206.0, 206.0 * text_aspects[lvl][5], 1) @=> go_text_intros[5];
        go_text_intros[5].posY(.75 * 3.5);
        sprite(text_tex[lvl][6], 854.0, 854.0 * text_aspects[lvl][6], 1) @=> go_text_intros[6];
        go_text_intros[6].posY(.75 * 3.5);

        sprite(text_tex[lvl][Text_Yum], 609.0, 609.0 * text_aspects[lvl][Text_Yum], 1) @=> go_text_yum;
        go_text_yum.posY(.75 * 3.5);
        sprite(text_tex[lvl][Text_Full], 882.0, 882.0 * text_aspects[lvl][Text_Full], 1) @=> go_text_full;
        go_text_full.posY(.75 * 3.5);

        // UI
        sprite(bar_tex, 540.0, 38.0, 1) @=> go_bar;
        go_bar.posY(0);
        go_bar.posX(.75 * 1.5);
        go_bar.scaY(1.1);
        go_bar --> go_bar_pivot;

        sprite(bar_container, 547.0, 63.0, 1.1) @=> go_bar_case;
        go_bar_case.posY(.75 * 3.5);

        sprite(bar_text, 306.0, 77.0, 1.1) @=> go_bar_text;
        go_bar_text.posY(.75 * 4.0);

        // this.sca(.5);

        spork ~ introSequence();
    }


    fun void introSequence() {
        1::second => now;
        // Spawn intro things

        // "TODAY"
        go_text_intros[0] --> this;
        spork ~ lerpSca(go_text_intros[0], 0.0, 0.0, 1.0, 1.0, 0.3);
        0.6::second => now;
        // "WE ARE EATING"
        go_text_intros[1] --> this;
        spork ~ lerpSca(go_text_intros[1], 0.0, 0.0, 1.0, 1.0, 0.5);
        0.6::second => now;
        // "CARROTS"
        go_text_intros[2] --> this;
        spork ~ lerpSca(go_text_intros[2], 0.0, 0.0, 1.0, 1.0, 0.5);
        0.2::second => now;

        go_human_idle --< this;
        go_human_done --> this;

        // CARROTS FLYING OUT
        if (level < 4) {
            for (int i; i < numFood; i++) {
                go_carrots[i][0] --> this;
                lerpSca(go_carrots[i][0], 0.0, 0.0, 1.0, 1.0, 0.2);
                0.1::second => now;
            }
        } else {
            for (auto carrot : go_carrots_level5) {
                carrot --> this;
                0.1::second => now;
            }
        }

        // TEXT CLOSE
        for (int i; i < 3; i++)
        {
            spork ~ lerpSca(go_text_intros[i], 1.0, 1.0, 0.0, 0.0, 0.1);
        }

        0.1::second => now;

        for (int i; i < 3; i++)
            go_text_intros[i] --< this;

        0.5::second => now;

        // "3"
        go_text_intros[3] --> this;
        spork ~ lerpSca(go_text_intros[3], 0.0, 0.0, 1.0, 1.0, 0.4);
        0.8::second => now;
        spork ~ lerpSca(go_text_intros[3], 1.0, 1.0, 0.0, 0.0, 0.2);
        0.2::second => now;
        go_text_intros[3] --< this;

        // "2"
        go_text_intros[4] --> this;
        spork ~ lerpSca(go_text_intros[4], 0.0, 0.0, 1.0, 1.0, 0.4);
        0.8::second => now;
        spork ~ lerpSca(go_text_intros[4], 1.0, 1.0, 0.0, 0.0, 0.2);
        0.2::second => now;
        go_text_intros[4] --< this;

        // "1"
        go_text_intros[5] --> this;
        spork ~ lerpSca(go_text_intros[5], 0.0, 0.0, 1.0, 1.0, 0.4);
        0.8::second => now;
        spork ~ lerpSca(go_text_intros[5], 1.0, 1.0, 0.0, 0.0, 0.2);
        0.2::second => now;
        go_text_intros[5] --< this;

        // "LET'S EAT!"
        go_text_intros[6] --> this;
        spork ~ lerpSca(go_text_intros[6], 0.0, 0.0, 1.0, 1.0, 0.8);
        1.2::second => now;
        spork ~ lerpSca(go_text_intros[6], 1.0, 1.0, 0.0, 0.0, 0.2);
        0.2::second => now;
        go_text_intros[6] --< this;

        // start mukbang
        1 => bool_mukbang_start;
        0 => currentFood;
        0 => currentAnim;

        mukbangGame();
    }

    fun int music() {
        return Music.MUKBANG1 + (level - 1) % 3; // return the music enum
    }

    fun void mukbangGame() {
        // Start the UI
        go_bar_pivot --> this;
        go_bar_case --> this;
        go_bar_text --> this;

        initialGameTime => float gameTime;

        while (bool_mukbang_start)
        {
            GG.nextFrame() => now;
            GG.dt() -=> gameTime;

            if (gameTime < 0)
            {
                0.0 => gameTime;
                0 => bool_mukbang_start;
                1 => bool_mukbang_fail;
            }
            go_bar_pivot.scaX(gameTime / initialGameTime);

            if (GWindow.mouseLeftDown() && bool_mukbang_start && !bool_mukbang_fail)
            {
                SFX.play(SFX.CHEW0 + Math.random2(0, 5));
                if (level == 4) {
                    go_human_done --< this;
                    go_carrots_level5[currentFood] --< this;
                    currentFood++;

                    if (currentFood == go_carrots_level5.size())
                    {
                        0 => bool_mukbang_start;
                        1 => bool_mukbang_end;
                        SFX.play(SFX.YUMMY);
                    }

                    // Have Scraps appear on the hankerchief
                    if (maybe)
                    {
                        if (currentScrap < numScraps - 1)
                        {
                            go_scraps[currentScrap] --< this;
                            currentScrap++;
                            go_scraps[currentScrap] --> this;
                        }
                    }

                    // Animate Human

                    go_human_eating[currentHumanAnim % 2] --< this;
                    currentHumanAnim++;
                    go_human_eating[currentHumanAnim % 2] --> this;
                } else {

                    // If the current anim is scraps, then leave them on screen
                    if (currentAnim != 4)
                    {
                        go_carrots[currentFood][currentAnim] --< this;
                    }

                    // Proceed to the next Animation.
                    currentAnim++;
                    // If current Animation is greater than # frames, reset to 0
                    if (currentAnim >= numFoodAnim)
                    {
                        0 => currentAnim;
                        currentFood++;
                    }

                    // If current set of Animations has reached the end
                    if (currentFood == numFood - 1 && currentAnim == numFoodAnim - 1)
                    {
                        go_carrots[currentFood][currentAnim] --> this;
                        0 => bool_mukbang_start;
                        1 => bool_mukbang_end;
                        SFX.play(SFX.YUMMY);
                    }
                    // If not, make the next frame appear.
                    else
                    {
                        if (currentAnim == 0)
                        {
                            go_carrots[currentFood][0] --< this;
                            currentAnim++;  
                        }
                        go_carrots[currentFood][currentAnim] --> this;

                        // Have Scraps appear on the hankerchief
                        if (maybe)
                        {
                            if (currentScrap < numScraps - 1)
                            {
                                go_scraps[currentScrap] --< this;
                                currentScrap++;
                                go_scraps[currentScrap] --> this;
                            }
                        }

                        // Animate Human
                        if (currentFood == 0 && currentAnim == 1)
                        {
                            go_human_done --< this;
                        }

                        go_human_eating[currentHumanAnim % 2] --< this;
                        currentHumanAnim++;
                        go_human_eating[currentHumanAnim % 2] --> this;
                    }
                }
            }
        }

        go_bar_pivot --< this;
        go_bar_case --< this;
        go_bar_text --< this;

        if (bool_mukbang_fail)
        {
            go_text_full --> this;
            go_human_eating[currentHumanAnim % 2] --< this;
            go_human_fail --> this;
        }
        else
        {
            go_text_yum --> this;
            go_human_eating[currentHumanAnim % 2] --< this;
            go_human_done --> this;
        }

        1 => bool_reactions;

        // mark finished and win 
        !bool_mukbang_fail => _win;
        true => _finished;

        // TODO impl reactions
    }

    fun void shootReactions(int num)
    {
        GGen reactions[num];

        int start;
        int end;

        0.1 => float standardSpeed;
        float speed[num];

        for (int i; i < num; i++)
        {
            standardSpeed * Math.random2f(0.75, 1.5) => speed[i];
        }

        if (bool_mukbang_fail)
        {
            2 => start;
            3 => end;
        }
        else
        {
            0 => start;
            1 => end;
        }

        // Initialize reactions
        for (int i; i < num; i++)
        {
            Math.random2(start, end) => int index;
            sprite(reaction_tex[index], v_reactions[index].x, v_reactions[index].y, 5) @=> reactions[i];
            reactions[i].posX(.75 * Math.random2f(-3.5, 3.5));
            reactions[i].posY(.75 * Math.random2f(-7.0, -8.0));
            reactions[i] --> this;
        }

        float s;
        SinOsc foo => blackhole;

        while ((1.0 - s) > 0)
        {
            0.25 / 1.0 => foo.freq;

            for (int i; i < num; i++)
            {
                reactions[i].translateY(speed[i]);
            }
            10::ms => now;
        }
    }

    fun void listenReactions()
    {
        while (true)
        {
            GG.nextFrame() => now;
            if (bool_reactions)
            {
                // optimize; shred should exit while loop
                spork ~ shootReactions(numReactions);
                0 => bool_reactions;
            }
        }
    }
    spork ~ listenReactions();

    fun GGen sprite(Texture tex, float width, float height, float layer)
    {
        FlatMaterial mat; 
        true => mat.transparent;
        mat.sampler(linear_sampler);

        mat.colorMap(tex);

        GMesh mesh(plane_geo, mat);
        mesh.posZ(layer * 0.01);
        // mesh.sca(@(width / 180.0, height / 180.0, 1.0));
        mesh.sca(@(.75 * width / 180.0, .75 * height / 180.0, 1.0));

        mesh --> GGen ggen;

        return ggen;
    }

    // Ease-in-out-Sine Lerp Function
    fun void lerpSca(GGen@ go, float xI, float yI, float xT, float yT, float speed)
    {
        float s;
        // optimize
        SinOsc foo => blackhole;

        while (s < 1)
        {
            0.25 / speed => foo.freq;
            foo.last() => s;

            // move gameObject's position
            go.sca(@(xI + (xT - xI) * s, yI + (yT - yI) * s));
            1::ms => now;
        }
    }

}