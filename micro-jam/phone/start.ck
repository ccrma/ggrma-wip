@import "../lib/util.ck"

public class Start extends GGen {
    Event startEvent;

    true => int active;
    false => int creditsActive;

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

    // phone
    Texture.load(me.dir() + "../assets/ui/start/phone.png", load_desc) @=> Texture @ phoneTex;
    FlatMaterial phoneMat;
    phoneMat.transparent(true);
    phoneMat.colorMap(phoneTex);
    GMesh phone(plane_geo, phoneMat);
    phone.pos(@(0.0, 0, 2.0));
    phone.sca(@(GG.camera().viewSize() * 16 / 9., GG.camera().viewSize()));
    phone --> this;

    // start icon
    Texture.load(me.dir() + "../assets/ui/start/start.png", load_desc) @=> Texture @ startTex;
    FlatMaterial startMat;
    startMat.transparent(true);
    startMat.colorMap(startTex);
    GMesh start(plane_geo, startMat);
    start.pos(@(-3.1, -1.4, 2.0));
    start.sca(@(160./210, 210./210) * 2);
    start --> this;

    // credits icon
    Texture.load(me.dir() + "../assets/ui/start/credits.png", load_desc) @=> Texture @ creditsTex;
    FlatMaterial creditsMat;
    creditsMat.transparent(true);
    creditsMat.colorMap(creditsTex);
    GMesh credits(plane_geo, creditsMat);
    credits.pos(@(-1.05, -1.4, 2.0));
    credits.sca(@(160./210, 210./210) * 2);
    credits --> this;

    // credits pane
    Texture.load(me.dir() + "../assets/ui/start/creditsPopup.png", load_desc) @=> Texture @ creditsPaneTex;
    FlatMaterial creditsPaneMat;
    creditsPaneMat.transparent(true);
    creditsPaneMat.colorMap(creditsPaneTex);
    GMesh creditsPane(plane_geo, creditsPaneMat);
    creditsPane.pos(@(0, -1, 2.5));
    creditsPane.sca(0);
    creditsPane --> this;

    // quit icon
    Texture.load(me.dir() + "../assets/ui/start/quit.png", load_desc) @=> Texture @ quitTex;
    FlatMaterial quitMat;
    quitMat.transparent(true);
    quitMat.colorMap(quitTex);
    GMesh quit(plane_geo, quitMat);
    quit.pos(@(-3.1, -3.65, 2.0));
    quit.sca(@(160./210, 210./210) * 2);
    quit --> this;

    // subway bg
    Texture.load(me.dir() + "../assets/ui/background.png", load_desc) @=> Texture @ bg_tex;
    FlatMaterial bgMat;
    bgMat.colorMap(bg_tex);
    GMesh bg(plane_geo, bgMat);
    bg.sca(10 * @( 16 / 9.0, 1.0 ));

    fun void hide() {
        false => active;

        2 => float duration;
        float t;

        while (t < duration) {
            GG.nextFrame() => now;
            GG.dt() +=> t;
            if (t > duration) duration => t;
            
            t / duration => float p;

            0.75 => float c1;
            c1 * 1.25 => float c2;

            Math.sin((p * Math.PI) / 2) => float ease;

            Math.map(ease, 0, 1, 1, 0) => float opacity;

            GG.outputPass().exposure(opacity);
        }

        start --< this;
        credits --< this;
        creditsPane --< this;
        quit --< this;
        phone --< this;

        bg --> this;
        bg.posZ(-1);
        startEvent.broadcast();
    }

    fun void showCredits() {
        0.25 => float duration;
        float t;

        while (t < duration) {
            GG.nextFrame() => now;
            GG.dt() +=> t;
            if (t > duration) duration => t;
            
            t / duration => float p;

            0.75 => float c1;
            c1 * 1.25 => float c2;

            Math.sin((p * Math.PI) / 2) => float ease;

            creditsPane.sca(ease * 7);
        }
    }

    fun void hideCredits() {
        0.25 => float duration;
        float t;

        while (t < duration) {
            GG.nextFrame() => now;
            GG.dt() +=> t;
            if (t > duration) duration => t;
            
            t / duration => float p;

            0.75 => float c1;
            c1 * 1.25 => float c2;

            Math.sin((p * Math.PI) / 2) => float ease;

            Math.map(ease, 0, 1, 1, 0) => ease;

            creditsPane.sca(ease * 7);
        }

        false => creditsActive;
    }

    fun void update(float dt) {
        if (!active) return;

        Util.mouseHovered(start) ? startMat.alpha(0.8) : startMat.alpha(1.0);
        Util.mouseHovered(credits) ? creditsMat.alpha(0.8) : creditsMat.alpha(1.0);
        Util.mouseHovered(quit) ? quitMat.alpha(0.8) : quitMat.alpha(1.0);
        
        if (Util.mouseHovered(start) && GWindow.mouseLeftDown()) {
            spork ~ hide();
        }
        if (!creditsActive && Util.mouseHovered(credits) && GWindow.mouseLeftDown()) {
            true => creditsActive;
            spork ~ showCredits();
        }
        if (creditsActive && Util.mouseHovered(creditsPane) && GWindow.mouseLeftDown()) {
            spork ~ hideCredits();
        }
        if (Util.mouseHovered(quit) && GWindow.mouseLeftDown()) {
            GWindow.close();
        }
    }
}