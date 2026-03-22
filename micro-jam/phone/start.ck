@import "../lib/util.ck"

public class Start extends GGen {
    Event startEvent;

    true => int active;

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

    PlaneGeometry plane_geo;

    // frame
    Texture.load(me.dir() + "../assets/ui/start/phone.png", load_desc) @=> Texture @ phoneTex;
    FlatMaterial phoneMat;
    phoneMat.transparent(true);
    phoneMat.colorMap(phoneTex);
    GMesh phone(plane_geo, phoneMat);
    phone.posZ(2.0);
    phone.sca(1);
    phone --> this;

    GText text --> this;
    text.text("DOOMSCROLLING");
    text.color(Color.BLACK);
    text.posY(2);
    text.sca(2);
    text.font(me.dir() + "../assets/ui/rvn.ttf");

    GText start --> this;
    start.text("START");
    start.color(Color.BLACK);
    start.posY(-2);
    text.sca(1.5);
    start.font(me.dir() + "../assets/ui/rvn.ttf");

    fun void hide() {
        false => active;

        GG.camera().viewSize() => float screenHeight;
        1.5 => float duration;
        float t;

        while (t < duration) {
            GG.nextFrame() => now;
            GG.dt() +=> t;
            if (t > duration) duration => t;
            
            t / duration => float p;

            0.75 => float c1;
            c1 * 1.25 => float c2;

            p < 0.5
            ? (Math.pow(2 * p, 2) * ((c2 + 1) * 2 * p - c2)) / 2
            : (Math.pow(2 * p - 2, 2) * ((c2 + 1) * (p * 2 - 2) + c2) + 2) / 2 => float ease;

            ease * screenHeight => float offset;

            text.posY(offset + 2);
            start.posY(offset - 2);
        }

        text --< this;
        start --< this;

        startEvent.broadcast();
    }

    fun void update(float dt) {
        if (!active) return;
        
        if (Util.mouseHovered(start) && GWindow.mouseLeftDown()) {
            spork ~ hide();
        }
    }
}