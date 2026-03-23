public class Hand extends GGen {
    FlatMaterial handMat;
    Texture swipeTextures[];
    Texture twitchTextures[];

    fun Hand() {
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

        Texture.load(me.dir() + "../assets/ui/hand/hand1.png", load_desc) @=> Texture @ hand1Tex;
        Texture.load(me.dir() + "../assets/ui/hand/hand2.png", load_desc) @=> Texture @ hand2Tex;
        Texture.load(me.dir() + "../assets/ui/hand/hand3.png", load_desc) @=> Texture @ hand3Tex;

        [
            hand1Tex,
            hand2Tex,
            hand3Tex,
            hand2Tex,
            hand1Tex
        ] @=> swipeTextures;

        [
            hand1Tex,
            hand2Tex,
        ] @=> twitchTextures;

        handMat.transparent(true);
        handMat.colorMap(hand1Tex);
        handMat.sampler(sampler);
        PlaneGeometry plane_geo;
        GMesh hand(plane_geo, handMat);
        hand.scaX(0.985);
        hand.scaY(0.985);
        hand.posY(-0.0075);
        hand.posZ(3.0);
        hand --> this;
    }

    fun void swipe() {
        for (Texture texture : swipeTextures) {
            handMat.colorMap(texture);
            75::ms => now;
        }
    }

    fun void twitch() {
        while (true) {
            handMat.colorMap(twitchTextures[0]);
            200::ms => now;
            handMat.colorMap(twitchTextures[1]);
            200::ms => now;
        }
    }
}
    