@import "minigame.ck"
@import "../lib/util.ck"

public class Throw extends Minigame {
    this.scaWorld(aspect);

    int throwActive;
    int throwing;

    vec2 startPos;
    time startTime;
    0.5 => float threshold;

    GMesh @ obj;
    vec3 baseObjSca;

    GMesh @ trash;
    float trashLeft;
    float trashRight;
    float trashY;

    static Texture@ bgTex;

    fun Throw(int level) {
        // TODO have all textures be loaded on start
        me.dir() + "../assets/throw/bg.png" => string bgPath;
        me.dir() + "../assets/throw/object" + level + ".png" => string objectPath;
        me.dir() + "../assets/throw/bucket" + level + ".png" => string trashPath;

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

        if (bgTex == null) Texture.load(bgPath, load_desc) @=> bgTex;
        FlatMaterial bgMat;
        bgMat.sampler(sampler);
        bgMat.colorMap(bgTex);
        GMesh bg(new PlaneGeometry, bgMat) --> this;
        bg.sca(1);

        Texture.load(objectPath, load_desc) @=> Texture objTex;
        FlatMaterial objMat;
        objMat.sampler(sampler);
        objMat.transparent(true);
        objMat.colorMap(objTex);
        new GMesh(new PlaneGeometry, objMat) @=> obj;
        obj --> this;
        obj.pos(@(0, -0.5, 1.1));
        @(0.25 * 16. / 9, 0.25 * 514/436.) => baseObjSca;
        obj.sca(baseObjSca);

        Texture.load(trashPath, load_desc) @=> Texture trashTex;
        FlatMaterial trashMat;
        trashMat.sampler(sampler);
        trashMat.transparent(true);
        trashMat.colorMap(trashTex);
        new GMesh(new PlaneGeometry, trashMat) @=> trash;
        trash --> this;
        trash.pos(@(0, 0.35 - 0.175 * (level - 1)));
        0.15 + 0.1 * (level - 1) => float trashSca;
        trash.sca(@(trashSca * 16. / 9, trashSca * 534/403.));
        trash.posWorld().x - Math.fabs(trash.scaWorld().x / 2) => trashLeft;
        trash.posWorld().x + Math.fabs(trash.scaWorld().x / 2) => trashRight;
        trash.posWorld().y + Math.fabs(trash.scaWorld().y / 4) => trashY;
    }

    // todo: account for if the player holds then swipes. in this case, the velocity will be lower than expected since timeElapsed will be greater
    fun void startThrow(float distance, float angle) {
        false => throwActive;
        now - startTime => dur timeElapsed;
        distance / (timeElapsed / ms) => float velocity; // ranges from 0 to approx. 0.05
        Math.map2(velocity, 0, 0.05, 0, 1) => float normalizedVelocity;

        obj.pos(@(0, -0.5));
        obj.sca(baseObjSca);

        true => throwing;
        spork ~ throw(normalizedVelocity, angle);
    }

    fun void throw(float velocity, float angle) {
        float t;
        while (true) {
            GG.nextFrame() => now;
            GG.dt() +=> t;

            0 + (velocity * Math.cos(angle)) * t => float posX;
            -0.5 + (velocity * Math.sin(angle)) * t => float posY; // no gravity
            Math.map2(posY, -0.5, 0.5, 1, 0.25) => float scale;

            obj.sca(baseObjSca * scale);
            obj.pos(@(posX, posY));

            obj.posWorld() => vec3 posWorld;
            if (posWorld.x >= trashLeft && posWorld.x <= trashRight && Math.fabs(posWorld.y - trashY) < 0.2) {
                true => _win;
                true => _finished;
                false => throwing;
                break;
            }

            if (obj.pos().x > 0.5 || obj.pos().x < -0.5 || obj.pos().y > 0.5 || obj.pos().y < -0.5) {
                true => _finished;
                false => throwing;
                break;
            }
        }
    }

    fun void update(float dt) { // called once per frame. put all your game logic here
        if (_finished) return;

        // mouse left down for the first time -- activates the throw
        if (!throwActive && !throwing && GWindow.mouseLeftDown()) {
            // convert from mouse position to world space
            Util.mousePos() => startPos;
            now => startTime;
            true => throwActive;
        }

        // the actual work, this is when the throw is active
        if (throwActive) {
            Util.mousePos() => vec2 mousePos;

            // if active, compute distance and angle
            Util.distance(startPos, mousePos) => float distance;
            Util.angle(startPos, mousePos) => float angle;
            
            // mouse is released
            if (!GWindow.mouseLeft()) {
                // if distance is greater than the threshold, hit the cue ball!
                if (distance > threshold) {
                    startThrow(distance, angle);
                } else {
                    false => throwActive;
                }
            }
        }
    }
}
