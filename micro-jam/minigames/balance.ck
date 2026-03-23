@import "minigame.ck"

public class GameObject extends GGen
{
    // GameObject Name
    string go_name;

    // Scene Material
    Texture tex;
    FlatMaterial mat;

    TextureSampler.nearest() @=> TextureSampler pixel_sampler;
    TextureSampler.Wrap_Clamp => pixel_sampler.wrapU;
    TextureSampler.Wrap_Clamp => pixel_sampler.wrapV;
    TextureSampler.Wrap_Clamp => pixel_sampler.wrapW;
    mat.transparent(true);
    mat.sampler(pixel_sampler);
    
    // Scene Geometry
    PlaneGeometry geo;
    GMesh mesh;

    // assetPath: relative path to the asset
    // e: elevation
    // width: width of the plane
    // height: height of the plane
    // pivot1: upper ground position for line pivot (same as pivot2 if no or point pivot)
    // pivot2: lower ground position for line pivot (same as pivot1 if no or point pivot)
    // whichPivot: 0 means no pivot (ex: background), 1 means point pivot, 2 means line pivot
    // desc: Texture Load Description
    fun void Initialize(string assetPath, string n, float width, float height, float layer, TextureLoadDesc desc)
    {
        n => go_name;

        Texture.load(me.dir() + assetPath, desc) @=> tex;
        mat.colorMap(tex);
        mesh.mesh(geo, mat);
        mesh --> this;
        mesh.posZ(layer * 0.01);
        mesh.sca(@(width / 180.0, height / 180.0, 1.0));
    }

    fun void Initialize(Texture t, string n, float width, float height, float layer)
    {
        n => go_name;

        t @=> tex;
        mat.colorMap(tex);
        mesh.mesh(geo, mat);
        mesh --> this;
        mesh.posZ(layer * 0.01);
        mesh.sca(@(width / 180.0, height / 180.0, 1.0));
    }
}

public class Balance extends Minigame {

    int level;

    // --- State --- //
    int stage;
    int backgroundCounter;
    int backgroundCounter2;
    int blinkCounter;
    int bool_hovered1;
    int bool_hovered2;
    int bool_answer1;
    int bool_answer2;

    0.15 => float backgroundTime;
    0.5 => float blinkTime;

    // --- Texture Loader --- //
    static TextureLoadDesc load_desc;

    // --- Preloaded Textures (indexed by level 0-2) --- //
    static Texture@ bg_tex[3][3];
    static Texture@ bg2_tex[3][3];
    static Texture@ face_tex[3][2];
    static Texture@ head_tex[3];
    static Texture@ live_tag_tex;
    static Texture@ question_tex[3][3];
    static Texture@ response_tex[3][2];
    static Texture@ select_face_tex[2];
    // Level 1: single answer faces
    static Texture@ answer1_face_single_tex[3];
    static Texture@ answer2_face_single_tex[3];
    // Levels 2 & 3: answer face arrays
    static Texture@ answer1_face_arr_tex[3][2];
    static Texture@ answer2_face_arr_tex[3][2];

    static int _init;
    fun static void init() {
        if (_init) return;
        true => _init;

        true => load_desc.flip_y;
        true => load_desc.gen_mips;
        true => load_desc.read;

        me.dir() + "../assets/balance/" => string base;

        for (int lvl; lvl < 3; lvl++)
        {
            base + "level" + Std.itoa(lvl + 1) + "/" => string assets;
            base + "level1/" => string shared;

            // Background
            for (int i; i < 3; i++)
                Texture.load(assets + "Background_" + Std.itoa(i) + ".png", load_desc) @=> bg_tex[lvl][i];

            // Background2 (levels 2 & 3 only)
            if (lvl >= 1)
            {
                for (int i; i < 3; i++)
                    Texture.load(assets + "Background2_" + Std.itoa(i) + ".png", load_desc) @=> bg2_tex[lvl][i];
            }

            // Face
            for (int i; i < 2; i++)
                Texture.load(assets + "Face_" + Std.itoa(i) + ".png", load_desc) @=> face_tex[lvl][i];

            // Head (level 3 uses level1's)
            if (lvl == 2)
                Texture.load(shared + "Head.png", load_desc) @=> head_tex[lvl];
            else
                Texture.load(assets + "Head.png", load_desc) @=> head_tex[lvl];

            // Question, Hover, Response
            Texture.load(assets + "Base_" + Std.itoa(lvl + 1) + "_Question_1.png", load_desc) @=> question_tex[lvl][0];
            Texture.load(assets + "Base_" + Std.itoa(lvl + 1) + "_Hover_1.png", load_desc) @=> question_tex[lvl][1];
            Texture.load(assets + "Base_" + Std.itoa(lvl + 1) + "_Hover_2.png", load_desc) @=> question_tex[lvl][2];

            Texture.load(assets + "Base_" + Std.itoa(lvl + 1) + "_Response_1.png", load_desc) @=> response_tex[lvl][0];
            Texture.load(assets + "Base_" + Std.itoa(lvl + 1) + "_Response_2.png", load_desc) @=> response_tex[lvl][1];

            // Answer faces
            if (lvl == 0)
            {
                Texture.load(assets + "Answer1_Face.png", load_desc) @=> answer1_face_single_tex[lvl];
                Texture.load(assets + "Answer2_Face.png", load_desc) @=> answer2_face_single_tex[lvl];
            }
            else
            {
                Texture.load(assets + "Answer1_Face1.png", load_desc) @=> answer1_face_arr_tex[lvl][0];
                Texture.load(assets + "Answer1_Face2.png", load_desc) @=> answer1_face_arr_tex[lvl][1];
                Texture.load(assets + "Answer2_Face1.png", load_desc) @=> answer2_face_arr_tex[lvl][0];
                Texture.load(assets + "Answer2_Face2.png", load_desc) @=> answer2_face_arr_tex[lvl][1];
            }
        }

        // Shared textures (from level1)
        base + "level1/" => string shared;
        Texture.load(shared + "Live_tag.png", load_desc) @=> live_tag_tex;
        for (int i; i < 2; i++)
            Texture.load(shared + "Select_Face_" + Std.itoa(i) + ".png", load_desc) @=> select_face_tex[i];

        <<< "Balance textures loaded" >>>;
    }

    // --- Scene Objects --- //
    GameObject go_background[3];
    GameObject go_background2[3];
    int has_background2;

    GameObject go_face[2];
    GameObject go_Head;
    GameObject go_Live;

    GameObject question[3];
    GameObject go_answer1;
    GameObject go_answer2;

    GameObject go_answerHead[2];

    // Level 1: single objects. Level 2/3: arrays of 2
    GameObject go_answerFace1_single;
    GameObject go_answerFace2_single;
    GameObject go_answerFace1_arr[2];
    GameObject go_answerFace2_arr[2];
    int has_answer_face_arr; // true for levels 2 & 3

    // Level 3: jitterBackground2 also runs in stage 1
    int bg2_jitter_stage1;

    0.75 => float scale;

    // Hit test planes
    GPlane hitbox1;
    hitbox1.color(@(1.0, 0.0, 0.0));
    hitbox1.sca(@(1500.0 * scale / 360.0, 260.0 * scale / 360.0));
    hitbox1.posY(-2.8125 * scale);
    hitbox1.posZ(1.5);

    GPlane hitbox2;
    hitbox2.color(@(1.0, 0.0, 0.0));
    hitbox2.sca(@(1500.0 * scale / 360.0, 260.0 * scale / 360.0));
    hitbox2.posY(-3.375 * scale);
    hitbox2.posZ(1.5);

    FlatMaterial bgMat;
    bgMat.color(Color.BLACK);
    GMesh bg(new PlaneGeometry, bgMat) --> this;
    bg.sca(@(1080 * scale / 180.0, 1920 * scale / 180.0, 1.0));

    fun int music() {
        return Music.CHOICE1 + (level - 1) % 3; // return the music enum
    }

    fun Balance(int level)
    {
        Math.clampi(level, 1, 3) => this.level;
        true => _win;

        this.level - 1 => int lvl;

        // Background
        for (int i; i < 3; i++)
        {
            go_background[i].Initialize(bg_tex[lvl][i], "background", 1080.0 * scale, 1920.0 * scale, 1);
            go_background[0] --> this;
        }

        // Background2 (levels 2 & 3)
        if (level >= 2)
        {
            true => has_background2;
            for (int i; i < 3; i++)
            {
                go_background2[i].Initialize(bg2_tex[lvl][i], "background", 1080.0 * scale, 1920.0 * scale, 1);
                go_background2[0] --> this;
            }
        }

        // Face
        for (int i; i < 2; i++)
        {
            go_face[i].Initialize(face_tex[lvl][i], "background", 1080.0 * scale, 1920.0 * scale, 1);
            go_face[0] --> this;
        }

        // Head
        go_Head.Initialize(head_tex[lvl], "background", 1080.0 * scale, 1920.0 * scale, 1);
        go_Head --> this;

        // Live Icon
        go_Live.Initialize(live_tag_tex, "background", 1192.0, 376.0, 1);
        go_Live.pos(@(-1.95 * scale, 4.5 * scale, 0.1));
        go_Live.sca(0.25 * 0.75 * scale);
        go_Live --> this;

        // Question
        question[0].Initialize(question_tex[lvl][0], "background", 600.0 * scale, 424.5 * scale, 1.1);
        question[1].Initialize(question_tex[lvl][1], "background", 600.0 * scale, 424.5 * scale, 1.1);
        question[2].Initialize(question_tex[lvl][2], "background", 600.0 * scale, 424.5 * scale, 1.1);

        question[0] --> this;
        question[0].posY(-2.8125 * scale);
        question[1].posY(-2.8125 * scale);
        question[2].posY(-2.8125 * scale);

        // Answer
        go_answer1.Initialize(response_tex[lvl][0], "background", 600.0 * scale, 111.0 * scale, 1.1);
        go_answer1.posY(-3.375 * scale);

        go_answer2.Initialize(response_tex[lvl][1], "background", 600.0 * scale, 111.0 * scale, 1.1);
        go_answer2.posY(-3.375 * scale);

        // Answer Head (shared)
        for (int i; i < 2; i++)
        {
            go_answerHead[i].Initialize(select_face_tex[i], "background", 1080.0 * scale, 1920.0 * scale, 1);
        }

        // Answer Faces
        if (level == 1)
        {
            false => has_answer_face_arr;
            go_answerFace1_single.Initialize(answer1_face_single_tex[lvl], "background", 1080.0 * scale, 1920.0 * scale, 1);
            go_answerFace2_single.Initialize(answer2_face_single_tex[lvl], "background", 1080.0 * scale, 1920.0 * scale, 1);
        }
        else
        {
            true => has_answer_face_arr;
            if (level == 3)
            {
                true => bg2_jitter_stage1;
                go_answerFace1_arr[0].Initialize(answer1_face_arr_tex[lvl][0], "background", 1080.0 * scale, 1920.0 * scale, 1.1);
                go_answerFace1_arr[1].Initialize(answer1_face_arr_tex[lvl][1], "background", 1080.0 * scale, 1920.0 * scale, 1.2);
                go_answerFace2_arr[0].Initialize(answer2_face_arr_tex[lvl][0], "background", 1080.0 * scale, 1920.0 * scale, 1.1);
                go_answerFace2_arr[1].Initialize(answer2_face_arr_tex[lvl][1], "background", 1080.0 * scale, 1920.0 * scale, 1.2);
            }
            else
            {
                go_answerFace1_arr[0].Initialize(answer1_face_arr_tex[lvl][0], "background", 1080.0 * scale, 1920.0 * scale, 1);
                go_answerFace1_arr[1].Initialize(answer1_face_arr_tex[lvl][1], "background", 1080.0 * scale, 1920.0 * scale, 1);
                go_answerFace2_arr[0].Initialize(answer2_face_arr_tex[lvl][0], "background", 1080.0 * scale, 1920.0 * scale, 1);
                go_answerFace2_arr[1].Initialize(answer2_face_arr_tex[lvl][1], "background", 1080.0 * scale, 1920.0 * scale, 1);
            }
        }

        // Start sporked functions
        spork ~ jitterBackground();
        if (has_background2) spork ~ jitterBackground2();
        spork ~ blinkFace();
    }

    fun int isHovered(GGen box, vec3 mouse_pos)
    {
        box.scaWorld() => vec3 worldScale;
        worldScale.x / 2.0 => float halfWidth;
        worldScale.y / 2.0 => float halfHeight;
        box.posWorld() => vec3 worldPos;

        if (
            mouse_pos.x > worldPos.x - halfWidth
            &&
            mouse_pos.x < worldPos.x + halfWidth
            &&
            mouse_pos.y > worldPos.y - halfHeight
            &&
            mouse_pos.y < worldPos.y + halfHeight
        )
        {
            return true;
        }
        return false;
    }

    fun void jitterBackground()
    {
        while (stage == 0 && !stopped)
        {
            backgroundCounter++;
            go_background[backgroundCounter % 3] --> this;
            (Math.random2f(0.5, 1.25) * backgroundTime)::second => now;
            go_background[(backgroundCounter - 1) % 3] --< this;
            if (stage == 0 && !stopped)
                (Math.random2f(0.5, 1.25) * backgroundTime)::second => now;
        }

        while (stage == 1 && !stopped)
        {
            backgroundCounter++;
            go_answerHead[backgroundCounter % 2] --> this;
            (Math.random2f(0.5, 1.25) * backgroundTime)::second => now;
            go_answerHead[(backgroundCounter - 1) % 2] --< this;
            if (stage == 1 && !stopped)
                (Math.random2f(0.5, 1.25) * backgroundTime)::second => now;
        }
    }

    fun void jitterBackground2()
    {
        while (stage == 0 && !stopped)
        {
            backgroundCounter2++;
            go_background2[backgroundCounter2 % 3] --> this;
            (Math.random2f(0.5, 1.25) * backgroundTime)::second => now;
            go_background2[(backgroundCounter2 - 1) % 3] --< this;
            if (stage == 0 && !stopped)
                (Math.random2f(0.5, 1.25) * backgroundTime)::second => now;
        }

        // Level 3: also jitter answerHead in stage 1
        if (bg2_jitter_stage1)
        {
            while (stage == 1 && !stopped)
            {
                backgroundCounter2++;
                go_answerHead[backgroundCounter2 % 2] --> this;
                (Math.random2f(0.5, 1.25) * backgroundTime)::second => now;
                go_answerHead[(backgroundCounter2 - 1) % 2] --< this;
                if (stage == 1 && !stopped)
                    (Math.random2f(0.5, 1.25) * backgroundTime)::second => now;
            }
        }
    }

    fun void blinkFace()
    {
        while (stage == 0 && !stopped)
        {
            // Close Eyes
            go_face[blinkCounter % 2] --< this;
            blinkCounter++;
            go_face[blinkCounter % 2] --> this;
            (blinkTime * Math.random2f(0.35, 0.6))::second => now;

            // Open Eyes
            if (stage == 0 && !stopped)
            {
                go_face[blinkCounter % 2] --< this;
                blinkCounter++;
                go_face[blinkCounter % 2] --> this;
            }

            if (stage == 0 && !stopped)
                Math.random2f(0.5, 1.5)::second => now;
        }

        // Levels 2 & 3: blink the answer faces in stage 1
        if (has_answer_face_arr && stage == 1 && !stopped)
        {
            if (bool_answer1)
                go_answerFace1_arr[0] --> this;

            if (bool_answer2)
                go_answerFace2_arr[0] --> this;

            while (stage == 1 && !stopped)
            {
                if (bool_answer1)
                {
                    go_answerFace1_arr[1] --> this;
                    (blinkTime * Math.random2f(0.7, 1.2))::second => now;
                    go_answerFace1_arr[1] --< this;
                    (blinkTime * Math.random2f(0.7, 1.2))::second => now;
                }

                if (bool_answer2)
                {
                    go_answerFace2_arr[1] --> this;
                    (blinkTime * Math.random2f(0.7, 1.2))::second => now;
                    go_answerFace2_arr[1] --< this;
                    (blinkTime * Math.random2f(0.7, 1.2))::second => now;
                }
            }
        }
    }

    fun void selectAnswer1()
    {
        1 => bool_answer1;
        1 => stage;

        // Disconnect question-stage elements
        for (int i; i < 3; i++)
        {
            if (go_background[i].parent() != null) go_background[i] --< this;
        }
        if (has_background2)
        {
            for (int i; i < 3; i++)
                if (go_background2[i].parent() != null) go_background2[i] --< this;
        }
        for (int i; i < 2; i++)
        {
            if (go_face[i].parent() != null) go_face[i] --< this;
        }
        if (go_Head.parent() != null) go_Head --< this;
        if (question[0].parent() != null) question[0] --< this;
        if (question[1].parent() != null) question[1] --< this;
        if (question[2].parent() != null) question[2] --< this;

        // Display answer
        if (has_answer_face_arr)
        {
            // Levels 2 & 3: blinkFace handles the answer face
            go_answer1 --> this;
        }
        else
        {
            // Level 1: show single answer face
            go_answerFace1_single --> this;
            go_answer1 --> this;
        }

        true => _finished;
        SFX.play(SFX.BALANCE_CHEER, Math.random2f(0.9, 1.1));
    }

    fun void selectAnswer2()
    {
        1 => bool_answer2;
        1 => stage;

        // Disconnect question-stage elements
        for (int i; i < 3; i++)
        {
            if (go_background[i].parent() != null) go_background[i] --< this;
        }
        if (has_background2)
        {
            for (int i; i < 3; i++)
                if (go_background2[i].parent() != null) go_background2[i] --< this;
        }
        for (int i; i < 2; i++)
        {
            if (go_face[i].parent() != null) go_face[i] --< this;
        }
        if (go_Head.parent() != null) go_Head --< this;
        if (question[0].parent() != null) question[0] --< this;
        if (question[1].parent() != null) question[1] --< this;
        if (question[2].parent() != null) question[2] --< this;

        // Display answer
        if (has_answer_face_arr)
        {
            go_answer2 --> this;
        }
        else
        {
            go_answerFace2_single --> this;
            go_answer2 --> this;
        }

        true => _finished;
    }

    fun void update(float dt)
    {
        if (stopped || _finished) return;

        GG.camera().screenCoordToWorldPos(GWindow.mousePos(), 1) => vec3 mouse_world_pos;
        // Scale compensation for parent scale
        mouse_world_pos => vec3 scaled_pos;

        // --- Hitbox 1 (top answer) --- //
        if (isHovered(hitbox1, scaled_pos) && stage == 0)
        {
            if (!bool_hovered1)
            {
                if (question[0].parent() != null) question[0] --< this;
                if (question[1].parent() == null) question[1] --> this;
                1 => bool_hovered1;
            }

            if (GWindow.mouseLeftDown() && !bool_answer1)
            {
                selectAnswer1();
                SFX.play(SFX.BALANCE_SELECT, Math.random2f(0.9, 1.1));
            }
        }
        else
        {
            if (bool_hovered1 && stage == 0)
            {
                if (question[1].parent() != null) question[1] --< this;
                if (question[0].parent() == null) question[0] --> this;
                0 => bool_hovered1;
            }
        }

        // --- Hitbox 2 (bottom answer) --- //
        if (isHovered(hitbox2, scaled_pos) && stage == 0)
        {
            if (!bool_hovered2)
            {
                if (question[0].parent() != null) question[0] --< this;
                if (question[2].parent() == null) question[2] --> this;
                1 => bool_hovered2;
            }

            if (GWindow.mouseLeftDown() && !bool_answer2)
            {
                selectAnswer2();
                SFX.play(SFX.BALANCE_SELECT, Math.random2f(0.9, 1.1));
            }
        }
        else
        {
            if (bool_hovered2 && stage == 0)
            {
                if (question[2].parent() != null) question[2] --< this;
                if (question[0].parent() == null) question[0] --> this;
                0 => bool_hovered2;
            }
        }
    }
}
