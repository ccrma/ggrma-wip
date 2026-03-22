@import "minigame.ck"

public class Rxn extends Minigame 
{
    // The current level (0-4)
    int active_level;
    // Whether the player has completed the level
    false => int completed;

    // Which video is currently being played
    int active_video_index;
    // Timestamp of current video start
    time trial_start;

    // Current progress through the level
    float current_progress;
    // Decay rate of the progress bar
    0.0001 => float progress_decay;

    // The type of reaction the player is currently making (neutral, good, bad)
    "bad" => string reaction_type;

    // Number of clicks it takes to complete the level
    50 => float max_clicks;

    aspect.y / aspect.x => float aspect_ratio;
    aspect.x => float frame_width;

    // Instruction text
    // ------------------------------------------------------------
    // Consists of the instruction text "REACT HARDER" which appears at the top of the screen
    // TODO: animate the text to pulse in size and color 

    GText instruction_text --> this;
    instruction_text.text("REACT HARDER");
    instruction_text.color(@(1, 0, 0));
    instruction_text.size(.4);
    instruction_text.posX(0);
    instruction_text.posY(frame_width * aspect_ratio / 2 - 1);
    instruction_text.posZ(2);

    // Progress bar
    // ------------------------------------------------------------
    // Colored bar at top of screen to indicate player progress through the level.
    // Decays over time based on level difficulty, decays faster for higher levels
    // TODO: potentially animate the bar to pulse grow on click

    FlatMaterial progress_mat;
    progress_mat.color(@(1, 0, 0));
    GMesh progress(plane_geo, progress_mat) --> this;
    progress.scaY(.1);
    progress.posY(instruction_text.posY() - .3);
    progress.posZ(1);


    // File management for video texture preloading
    static string filenames[5][0];
    static Video@ videos[5][0];
    static Texture@ video_textures[5][0];

    // Active video
    FlatMaterial video_mat;
    video_mat.scale(@(1, -1));
    GMesh video_mesh(plane_geo, video_mat) --> this;
    video_mesh.posZ(.5);
    video_mesh.sca(@(aspect.x, aspect.y));
    TextureSampler.nearest() => video_mat.sampler;

    // Reaction face
    // ------------------------------------------------------------
    // Consists of blank face texture and three sets of facial features (neutral, good, bad)

    // Texture loading
    static TextureLoadDesc load_desc;

    // Arrays to hold the preloaded facial feature textures
    static Texture@ neutral_textures[0];
    static Texture@ good_textures[0];
    static Texture@ bad_textures[0];

    // Parent mesh for the reaction face
    GGen reaction_parent --> this;
    reaction_parent.sca(2.5);
    reaction_parent.posX(-1.2);
    reaction_parent.posY(-2.5);
    reaction_parent.posZ(1);

    // Blank face texture
    static Texture@ reaction_base_tex;
    FlatMaterial reaction_base_mat;
    TextureSampler reaction_base_sampler;
    TextureSampler.Wrap_Clamp => reaction_base_sampler.wrapU;
    TextureSampler.Wrap_Clamp => reaction_base_sampler.wrapV;
    TextureSampler.Wrap_Clamp => reaction_base_sampler.wrapW;
    reaction_base_mat.colorMap(reaction_base_tex);
    reaction_base_mat.sampler(reaction_base_sampler);
    GMesh reaction_base_mesh(plane_geo, reaction_base_mat) --> reaction_parent;

    // Reaction facial features
    FlatMaterial reaction_mat;
    GMesh reaction_mesh(plane_geo, reaction_mat) --> reaction_parent;

    // Viewcount at bottom of screen
    // ------------------------------------------------------------
    // Consists of eye texture and viewcount text which goes up and down based on player activity

    GGen viewcount_parent --> this;
    static Texture@ eye_tex;
    FlatMaterial eye_mat;
    eye_mat.colorMap(eye_tex);
    GMesh eye_mesh(plane_geo, eye_mat) --> viewcount_parent;
    eye_mesh.sca(.25);
    eye_mesh.posZ(1);
    viewcount_parent.posX(1.5);
    viewcount_parent.posY(-3.5);
    viewcount_parent.posZ(1);

    Math.random2(8000, 100000) $ int => int viewcount;
    active_level * Math.random2(1000, 10000) $ int +=> viewcount;

    GText viewcount_text --> viewcount_parent;
    viewcount_text.text(Std.itoa(viewcount));
    viewcount_text.color(@(0, 0, 0));
    viewcount_text.size(.1);
    viewcount_text.posX(0.4);
    viewcount_text.posY(0);
    viewcount_text.posZ(1);

    FlatMaterial view_bg_mat;
    view_bg_mat.color(@(1, 1, 1));
    GMesh view_bg(plane_geo, view_bg_mat) --> viewcount_parent;
    view_bg.posX(.225);
    view_bg.posZ(0);
    view_bg.sca(@(.8, .15));

    static int _init;
    fun static void init() {
        if (_init) return;
        true => _init;

        true => load_desc.flip_y;
        true => load_desc.gen_mips;

        FileIO fio;
        me.dir() + "../assets/rxn" => string assets_dir;

        Texture.load(assets_dir + "/reactions/base.png", load_desc) @=> reaction_base_tex;
        Texture.load(assets_dir + "/eye.png", load_desc) @=> eye_tex;

        loadVideoTextures(fio, assets_dir);
        loadReactionTextures(fio, assets_dir);
    }


    // Video texture preloading
    // ------------------------------------------------------------
    // Loads all video textures for all levels and stores them in the filenames, videos, and video_textures arrays
    fun static void loadVideoTextures(FileIO fio, string assets_dir)
    {
        <<<"Loading video textures...">>>;
        
        for(int i; i < 5; i++)
        {
            assets_dir + "/level" + Std.itoa(i) => string level_dir;
            if(fio.open(level_dir, FileIO.READ))
            {
                fio.dirList() @=> string level_filenames[];
                fio.close();

                string mpg_filenames[0];
                Video@ level_videos[0];
                Texture@ level_textures[0];
                for(int j; j < level_filenames.size(); j++)
                {
                    if(level_filenames[j].find(".mpg") != -1) {
                        level_filenames[j] => string filename;
                        <<<"Read file: ", filename>>>;
                        Video video(level_dir + "/" + filename);
                        video.loop(true);
                        video.rate(0);
                        mpg_filenames << filename;
                        level_videos << video;
                        level_textures << video.texture();
                    }
                }
                <<<"Loaded ", mpg_filenames.size(), " videos for level ", i>>>;
                mpg_filenames @=> filenames[i];
                level_videos @=> videos[i];
                level_textures @=> video_textures[i];
            }
        }
    }

    // Reaction texture preloading
    // ------------------------------------------------------------
    // Loads all reaction textures for all levels and stores them in the neutral_textures, good_textures, and bad_textures arrays
    fun static void loadReactionTextures(FileIO fio, string assets_dir)
    {
        assets_dir + "/reactions/neutral/" => string neutral_dir;
        for (int i; i < 5; i++) neutral_textures << Texture.load(neutral_dir + i + ".png", load_desc);

        assets_dir + "/reactions/good/" => string good_dir;
        for (int i; i < 5; i++) good_textures << Texture.load(good_dir + i + ".png", load_desc);

        assets_dir + "/reactions/bad/" => string bad_dir;
        for (int i; i < 6; i++) bad_textures << Texture.load(bad_dir + i + ".png", load_desc);

        <<<"Loaded ", neutral_textures.size(), " neutral textures, ", good_textures.size(), " good textures, ", bad_textures.size(), " bad textures">>>;
    }

    // Reaction selection
    // ------------------------------------------------------------
    // Selects the reaction texture for the given type and index

    fun void selectReaction(string type, int index)
    {
        if(type == "neutral")
        {
            if(index < 0 || index >= neutral_textures.size())
            {
                <<<"Invalid index: ", index>>>;
                return;
            }
            reaction_mat.colorMap(neutral_textures[index]);
        }
        else if(type == "good")
        {
            if(index < 0 || index >= good_textures.size())
            {
                <<<"Invalid index: ", index>>>;
                return;
            }
            reaction_mat.colorMap(good_textures[index]);
        }
        else if(type == "bad")
        {
            if(index < 0 || index >= bad_textures.size())
            {
                <<<"Invalid index: ", index>>>;
                return;
            }
            reaction_mat.colorMap(bad_textures[index]);
        }
        else
        {
            <<<"Invalid type: ", type>>>;
            return;
        }
        <<<"Selected reaction: ", type, " ", index>>>;
    }

    // Progress bar update
    // ------------------------------------------------------------

    fun void updateProgressBar(float percent)
    {
        Math.clampf(percent, 0, 1) => percent;
        progress.scaX(percent * frame_width);
        progress.posX((-frame_width / 2) + (percent * frame_width / 2));
        progress_mat.color(Color.hsv2rgb(@(percent * 120, 1, 1)));
    }

    // Constructor
    fun Rxn(int lvl)
    {
        lvl => active_level;
        lvl * .00025 + .0001 => progress_decay;
        selectVideo();
        selectReaction("neutral", 0);
        updateProgressBar(0);
        true => _win; // unloseable
    }

    fun void ungruck() { 
        // pause current video
        videos[active_level][active_video_index].rate(0.0);
    }

    [
        60, 40, 40, 50, 60
    ] @=> int level_max_clicks[];
    fun void selectVideo()
    {   
        // NOCHECKIN
        5 => max_clicks;
        // level_max_clicks[level] => max_clicks;

        // pause current video
        videos[active_level][active_video_index].rate(0.0);

        // choose unchosen video
        Math.random2(0, video_textures[active_level].size() - 1) => int index;
        if (index == active_video_index) (index + 1) % video_textures[active_level].size() => index;
        index => active_video_index;

        now => trial_start;
        videos[active_level][active_video_index].rate(2.0);
        video_mat.colorMap(video_textures[active_level][active_video_index]);
    }

    // Update the reaction face based on current progress
    fun void reactionMeter()
    {
        if(current_progress <= 0.4)
        {
            Math.round(current_progress * neutral_textures.size()) $ int => int index;
            // jitter and clamp
            index + Math.random2(-1, 1) => index;
            Math.clampi(index, 0, neutral_textures.size() - 1) => index;
            selectReaction("neutral", index);
        }
        else
        {
            if(reaction_type == "bad")
            {
                Math.round(current_progress * bad_textures.size()) $ int => int index;
                // jitter
                index + Math.random2(-1, 1) => index;
                Math.clampi(index, 0, bad_textures.size() - 1) => index;
                selectReaction("bad", index);
            }
            else if(reaction_type == "good")
            {
                Math.round(current_progress * good_textures.size()) $ int => int index;
                // jitter
                index + Math.random2(-1, 1) => index;
                Math.clampi(index, 0, good_textures.size() - 1) => index;
                selectReaction("good", index);
            }
        }
    }

    fun void update(float dt) // called once per frame. put all your game logic here
    {
        if (stopped) return; 

        Math.random2(-5, 10) +=> viewcount;
        Std.itoa(viewcount) => viewcount_text.text;

        if(now - trial_start >= 2::second) selectVideo();

        if(GWindow.mouseLeftDown()) { 
            1 / max_clicks +=> current_progress;
            Math.clampf(current_progress, 0, 1) => current_progress;
            reactionMeter();
            // win condition
            if (current_progress >= 1) true => _finished;
        }

        // decay
        if(current_progress < 1) Math.clampf(current_progress - progress_decay, 0, 1) => current_progress;
        updateProgressBar(current_progress);
    }
}

// Testing
if (0) {
    GG.camera().orthographic();
    GG.bloom( true ); 
    GG.bloomPass().intensity(0.075);

    Rxn rxn --> GG.scene();

    while(true)
    {
        GG.nextFrame() => now;
    }
}