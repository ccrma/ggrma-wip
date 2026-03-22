@import "../lib/util.ck"

public class Overlay extends GGen {
    @(GG.camera().viewSize() * 9 / 16, GG.camera().viewSize(), 1) => vec3 aspect;
    this.scaWorld(aspect);

    GLines border;

    GMesh @ heart;
    Texture @ heartTex;
    Texture @ heartRedTex;
    int liked;

    100 => int batteryPercentage;

    fun Overlay() {
        // border
        border.positions([
            @(0.5, 0.5),
            @(0.5, -0.5),
            @(-0.5, -0.5),
            @(-0.5, 0.5),
            @(0.5, 0.5)
        ]);
        border.color(Color.BLACK);
        border.width(0.015);
        border.posZ(2.0);
        border --> this;

        TextureLoadDesc load_desc;
        true => load_desc.flip_y;  // flip the texture vertically
        true => load_desc.gen_mips; // generate mip maps automatically

        TextureSampler sampler;
        TextureSampler.WRAP_CLAMP => sampler.wrapU;
        TextureSampler.WRAP_CLAMP => sampler.wrapV;
        TextureSampler.WRAP_CLAMP => sampler.wrapW;
        TextureSampler.FILTER_NEAREST => sampler.filterMag;
        TextureSampler.FILTER_NEAREST => sampler.filterMin;
        TextureSampler.FILTER_NEAREST => sampler.filterMip;

        // heart
        Texture.load(me.dir() + "../assets/ui/heart.png", load_desc) @=> heartTex;
        Texture.load(me.dir() + "../assets/ui/heart_red.png", load_desc) @=> heartRedTex;
        FlatMaterial heartMat;
        heartMat.sampler(sampler);
        heartMat.transparent(true);
        heartMat.colorMap(heartTex);
        new GMesh(new PlaneGeometry, heartMat) @=> heart;
        heart.sca(heart.sca() * 0.025 * this.aspect);
        heart.pos(@(0.4, -0.2, 2.0));
        heart --> this;

        // comment
        Texture.load(me.dir() + "../assets/ui/comment.png", load_desc) @=> Texture @ commentTex;
        FlatMaterial commentMat;
        commentMat.sampler(sampler);
        commentMat.transparent(true);
        commentMat.colorMap(commentTex);
        GMesh comment(new PlaneGeometry, commentMat);
        comment.sca(comment.sca() * 0.025 * this.aspect);
        comment.pos(@(0.4, -0.275, 2.0));
        comment --> this;

        // share
        Texture.load(me.dir() + "../assets/ui/share.png", load_desc) @=> Texture @ shareTex;
        FlatMaterial shareMat;
        shareMat.sampler(sampler);
        shareMat.transparent(true);
        shareMat.colorMap(shareTex);
        GMesh share(new PlaneGeometry, shareMat);
        share.sca(share.sca() * 0.025 * this.aspect);
        share.pos(@(0.4, -0.35, 2.0));
        share --> this;

        // toolbar
        FlatMaterial toolbarMat;
        toolbarMat.color(Color.BLACK);
        GMesh toolbar(new PlaneGeometry, toolbarMat) --> this;
        toolbar.pos(@(0, 0.48, 2.0));
        toolbar.sca(@(1.0, 0.04));

        // battery
        Texture.load(me.dir() + "../assets/ui/battery.png", load_desc) @=> Texture @ batteryTex;
        FlatMaterial batteryMat;
        batteryMat.colorMap(batteryTex);
        batteryMat.color(Color.WHITE);
        GMesh battery(new PlaneGeometry, batteryMat);
        battery.sca(battery.sca() * 0.015 * this.aspect);
        battery.scaX(-battery.scaX());
        battery.pos(@(0.425, 0.48, 2.0));
        battery --> this;

        // battery percentage
        GText batteryText --> this;
        batteryText.text(batteryPercentage + "%");
        batteryText.sca(battery.sca() / 2);
        batteryText.controlPoints(@(1.0, 0.5));
        batteryText.pos(@(0.365, 0.48, 2.0));
        batteryText.color(Color.WHITE);
    }

    fun void update(float dt) {
        // todo: interaction stuff - like, comment, share, whatever

        if (Util.mouseHovered(heart) && GWindow.mouseLeftDown()) {
            if (liked) (heart.mat() $ FlatMaterial).colorMap(heartTex);
            else (heart.mat() $ FlatMaterial).colorMap(heartRedTex);
            !liked => liked;
        }
    }
}