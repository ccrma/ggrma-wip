@import "minigame.ck"
@import "../lib/util.ck"

public class Throw extends Minigame {
    int throwActive;
    int throwing;

    vec2 startPos;
    time startTime;
    0.5 => float threshold;

    GMesh @ obj;
    vec3 baseObjSca;

    GMesh @ trash;

    fun Throw(int level) {
        me.dir() + "../assets/throw/object_level" + level + ".png" => string objectPath;
        me.dir() + "../assets/throw/trash_level" + level + ".png" => string trashPath;

        TextureLoadDesc load_desc;
        true => load_desc.flip_y;  // flip the texture vertically
        true => load_desc.gen_mips; // generate mip maps automatically

        Texture.load(objectPath, load_desc) @=> Texture objTex;
        Texture.load(trashPath, load_desc) @=> Texture trashTex;

        FlatMaterial objMat;
        objMat.colorMap(objTex);
        GMesh objMesh(new PlaneGeometry, objMat) @=> obj;

        FlatMaterial trashMat;
        trashMat.colorMap(trashTex);
        GMesh trashMesh(new PlaneGeometry, trashMat) @=> trash;

        obj.pos(@(0, -0.5, 1.1));

        obj.sca() * 0.1 * this.aspect => baseObjSca;
        obj.sca(baseObjSca);

        trash.sca(trash.sca() * 0.1 * this.aspect);

        obj --> this;
        trash --> this;
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
