@import "../lib/util.ck"
@import "hand.ck"

public class Overlay extends GGen {
    @(GG.camera().viewSize() * 9 / 16, GG.camera().viewSize(), 1) * 0.8 => vec3 aspect;
    this.scaWorld(aspect);

    GGen actualOverlay;

    Hand hand;

    GLines border;

    GMesh @ heart;
    Texture @ heartTex;
    Texture @ heartRedTex;
    int liked;

    GText batteryText;
    // NOCHECKIN
    100 => int batteryPercentage;

    PlaneGeometry plane_geo;
    TextureLoadDesc load_desc;
    true => load_desc.flip_y;  // flip the texture vertically
    false => load_desc.gen_mips; // generate mip maps automatically

    TextureSampler sampler;
    TextureSampler.WRAP_CLAMP => sampler.wrapU;
    TextureSampler.WRAP_CLAMP => sampler.wrapV;
    TextureSampler.WRAP_CLAMP => sampler.wrapW;
    TextureSampler.FILTER_NEAREST => sampler.filterMag;
    TextureSampler.FILTER_NEAREST => sampler.filterMin;
    TextureSampler.FILTER_NEAREST => sampler.filterMip;

    FlatMaterial black_mat;
    Color.BLACK => black_mat.color;
    GMesh black_bg(plane_geo, black_mat) --> this;

    <<< "loading Overlay" >>>;
    
    Texture.load(me.dir() + "../assets/ui/share.png", load_desc) @=> Texture @ shareTex;
    FlatMaterial shareMat;
    shareMat.transparent(true);
    shareMat.colorMap(shareTex);

    Texture.load(me.dir() + "../assets/ui/comment.png", load_desc) @=> Texture @ commentTex;
    FlatMaterial commentMat;
    commentMat.transparent(true);
    commentMat.colorMap(commentTex);

    // battery
    Texture.load(me.dir() + "../assets/ui/battery.png", load_desc) @=> Texture @ batteryTex;
    FlatMaterial batteryMat;
    batteryMat.sampler(sampler);
    batteryMat.colorMap(batteryTex);
    batteryMat.color(Color.WHITE);
    GMesh battery(plane_geo, batteryMat);


    .83 => float battery_life_scaX;
    .43 => float battery_life_scaY;
    FlatMaterial batteryLifeMat;
    GMesh batteryLife(plane_geo, batteryLifeMat) --> GGen batteryLifePivot;
    float battery_life_w;
    fun Overlay() {
        // border
        border.positions([
            @(0.5, 0.5),
            @(0.5, -0.5),
            @(-0.5, -0.5),
            @(-0.5, 0.5),
            @(0.5, 0.5),
            @(0.5, -0.5)
        ]);
        border.color(Color.BLACK);
        border.width(0.015);
        border.posZ(2.0);
        // border --> this;

        // hand
        hand --> this;
        hand.posZ(2.1);
        hand.scaWorld(@(GG.camera().viewSize() * 16./9, GG.camera().viewSize(), 1));

        // frame
        Texture.load(me.dir() + "../assets/ui/frame.png", load_desc) @=> Texture @ frameTex;
        FlatMaterial frameMat;
        frameMat.transparent(true);
        frameMat.colorMap(frameTex);
        GMesh frame(plane_geo, frameMat);
        frame.posZ(2.0);
        frame.sca(1.1);
        frame --> this;

        // heart
        Texture.load(me.dir() + "../assets/ui/heart.png", load_desc) @=> heartTex;
        Texture.load(me.dir() + "../assets/ui/heart_red.png", load_desc) @=> heartRedTex;
        FlatMaterial heartMat;
        heartMat.transparent(true);
        heartMat.colorMap(heartTex);
        new GMesh(plane_geo, heartMat) @=> heart;
        heart.sca(heart.sca() * 0.025 * (6.6/10) * this.aspect);
        heart.pos(@(0.375, -0.2, 2.0));
        heart --> actualOverlay;

        // comment
        GMesh comment(plane_geo, commentMat);
        comment.sca(comment.sca() * 0.025 * (6.6/10) * this.aspect);
        comment.pos(@(0.375, -0.275, 2.0));
        comment --> actualOverlay;

        // share
        GMesh share(plane_geo, shareMat);
        share.sca(share.sca() * 0.025 * (6.6/10) * this.aspect);
        share.pos(@(0.375, -0.35, 2.0));
        share --> actualOverlay;

        // battery
        battery.sca(battery.sca() * 0.015 * (6.6/10) * this.aspect);
        battery.scaX(-battery.scaX());
        battery.pos(@(0.4125, 0.445, 2.0));
        battery --> actualOverlay;

        batteryLifePivot --> battery;
        batteryLifeMat.color(Color.RED);
        batteryLife.posZ(.01);
        batteryLife.scaX(battery_life_scaX);
        batteryLife.scaY(battery_life_scaY);
        batteryLife.scaWorld().x => battery_life_w;

        // battery percentage
        batteryText --> actualOverlay;
        batteryText.text("100%");
        batteryText.sca(battery.sca() / 1.5 * (6.6/10));
        batteryText.controlPoints(@(1.0, 0.5));
        batteryText.pos(@(0.3535, 0.445, 2.0));
        batteryText.color(Color.WHITE);
    }

    Shred @ twitchShred;

    0 => static int ICON_LIGHT;
    1 => static int ICON_DARK;
    ICON_LIGHT => int icon_mode;
    fun void iconColor(int icon_mode) { 
        icon_mode => this.icon_mode;
        if (icon_mode == ICON_DARK) {
            Color.BLACK => batteryMat.color;
            Color.BLACK => batteryText.color;
            Color.BLACK => (heart.mat() $ FlatMaterial).color;
            Color.BLACK => shareMat.color;
            Color.BLACK => commentMat.color;
        } else {
            Color.WHITE => batteryMat.color;
            Color.WHITE => batteryText.color;
            Color.WHITE => (heart.mat() $ FlatMaterial).color;
            Color.WHITE => shareMat.color;
            Color.WHITE => commentMat.color;
        }

        // we know this is called every minigame, piggyback to reset heart icon
        false => liked;
        (heart.mat() $ FlatMaterial).colorMap(heartTex);
    }

    fun void swipe() {
        if (twitchShred != null) {
            twitchShred.exit();
            null => twitchShred;
        }
        spork ~ hand.swipe();
    }

    fun void twitch() {
        if (twitchShred != null) return;
        spork ~ hand.twitch() @=> twitchShred;
    }

    fun void batteryDrain(int drain) {
        drain -=> batteryPercentage;
        batteryText.text(batteryPercentage + "%");
    }

    fun void update(float dt) {
        // todo: interaction stuff - like, comment, share, whatever

        if (Util.mouseHovered(heart) && GWindow.mouseLeftDown()) {
            if (liked) (heart.mat() $ FlatMaterial).colorMap(heartTex);
            else {
                (heart.mat() $ FlatMaterial).colorMap(heartRedTex);
                Color.WHITE => (heart.mat() $ FlatMaterial).color;
            }
            !liked => liked;
        }

        // draw a plane over battery for battery life
        batteryPercentage / 100.0 * battery_life_scaX => batteryLife.scaX;
        batteryLife.scaWorld().x => float w;
        .5 * (battery_life_w - w) => float dx;

        battery.posWorld() => vec3 battery_wp;
        batteryLife.posWorld() => vec3 wp;
        batteryLife.posWorld(
            @(battery_wp.x - .135 + .5 * w, wp.y, wp.z)
        );

        if (batteryPercentage <= 20) Color.RED => batteryLifeMat.color;
        else if (batteryPercentage <= 50) Color.YELLOW => batteryLifeMat.color;
        else {
            (icon_mode == ICON_LIGHT) ?  Color.WHITE : Color.BLACK => batteryLifeMat.color;
        }

    }
}