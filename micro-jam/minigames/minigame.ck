@import "../lib/g2d/g2d.ck"
@import "../lib/music.ck"
@import "../lib/sfx.ck"

public class Minigame extends GGen {
    // gruck all your game ggens to `this`
    @(GG.camera().viewSize() * 9 / 16, GG.camera().viewSize(), 1) * 0.8 => vec3 aspect;
    1 => aspect.z;

    // shared static assets
    // static TextureLoadDesc@ load_desc;
    static PlaneGeometry@ plane_geo;
    static TextureSampler@ linear_sampler;
    static TextureSampler@ nearest_sampler;

    static GMesh@ mouse_click;
    static GMesh@ mouse_scroll;

    // init static 
    if (plane_geo == null) {
        new PlaneGeometry @=> plane_geo;

        TextureSampler.linear() @=> linear_sampler;
        TextureSampler.Wrap_Clamp => linear_sampler.wrapU;
        TextureSampler.Wrap_Clamp => linear_sampler.wrapV;
        TextureSampler.Wrap_Clamp => linear_sampler.wrapW;

        TextureSampler.nearest() @=> nearest_sampler;
        TextureSampler.Wrap_Clamp => nearest_sampler.wrapU;
        TextureSampler.Wrap_Clamp => nearest_sampler.wrapV;
        TextureSampler.Wrap_Clamp => nearest_sampler.wrapW;

        sprite(me.dir() + "../assets/ui/mouseLeft.png") @=> mouse_click;
        sprite(me.dir() + "../assets/ui/mouseScroll.png") @=> mouse_scroll;
    }


// == mvars ==============================
    int _finished;
    int _win;
    int stopped; // set to true when disconnected from scene (replaced with next_mini_game)

// == helper fns ==============================
    // fun GMesh sprite(Texture@ tex) {
    //     n => go_name;

    //     Texture.load(me.dir() + assetPath, desc) @=> tex;
    //     mat.colorMap(tex);
    //     mesh.mesh(geo, mat);
    //     mesh --> this;
    //     mesh.posZ(layer * 0.01);
    //     mesh.sca(@(width / 180.0, height / 180.0, 1.0));

    // }

    fun GMesh sprite(string path) {
        TextureLoadDesc desc;
        true => desc.flip_y;
        false => desc.gen_mips;

        Texture.load(path, desc) @=> Texture tex;

        tex.width() $ float / tex.height() => float aspect;

        FlatMaterial mat;
        mat.sampler(linear_sampler);
        mat.colorMap(tex);
        mat.transparent(true);

        GMesh mesh(plane_geo, mat);
        mesh.sca(@(aspect, 1));

        return mesh;
    }


// == external api ==============================
    fun int finished() { // returns true when player can swipe to next screen
        return _finished;
    }

    fun int music() {
        return Music.NONE; // return the music enum
    }

    fun int win() { // returns true if the minigame is finished and won
        return _finished && _win;
    }

    fun void update(float dt) { // called once per frame. put all your game logic here
    }

    // called when the minigame is ungrucked.
    // hook into this for cleanup.
    fun void ungruck() {}
}