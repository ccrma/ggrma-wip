/*

Lvls
1: cartoon face
2: 
3: art from other game?
4: ???
5: scary face / crazy features

*/

class Face {

    Texture@ features[0];
    Texture@ face;

    static TextureLoadDesc load_desc;
    true => load_desc.flip_y;

    fun Face(string path) {
        FileIO dir;
        dir.open(path);
        dir.dirList() @=> string images[];

        for (auto s : images) {
            if (s.charAt(0) == '.') continue; // ignore .DS_Store

            Texture.load(path + "/" + s, load_desc) @=> Texture tex;

            if (s.find("face") == 0) tex @=> this.face;
            else features << tex;
        }

        features.shuffle();
    }
}

public class FaceGame extends Minigame
{
    G2D g --> this;

    static Face faces[];

    fun static void loadAssets() {
        if (faces == null) {
            [
                new Face(me.dir() + "../assets/face/face1"),
                new Face(me.dir() + "../assets/face/face2"),
                new Face(me.dir() + "../assets/face/face3"),
                new Face(me.dir() + "../assets/face/face4"),
                new Face(me.dir() + "../assets/face/face5"),
            ] @=> faces;
        }
    }

    true => _win; // not loseable

    // vec2 positions[0];
    vec2 _pos;
    -1 => int face_feature_idx;
    @(0, -1) => vec2 dir;
    faces[0] @=> Face@ face;

    1.0 => float sca_mod;

    GGen@ go_face;
    GGen@ go_face_features[0];
    GGen@ go_feature;

    int level;

    // render sprite with correct aspect ratio
    // fun GGen sprite(Texture tex, vec2 pos, float sca) {
    fun GGen sprite(Texture tex, int is_feature) {
        tex.width() $ float / tex.height() => float aspect;

        FlatMaterial mat;
        mat.sampler(linear_sampler);
        mat.colorMap(tex);
        if (is_feature) Color.WHITE * 2 => mat.color;

        GMesh mesh(plane_geo, mat);
        mesh.sca(10 * sca_mod * @(aspect, 1));

        // g.sprite(tex, pos, sca_mod * sca * @(aspect, 1), 0);

        return mesh;
    }

    fun FaceGame(int level) {
        false => _finished;
        level => this.level;

        // reset game
        faces[(level - 1) % faces.size()] @=> face;
        -1 => face_feature_idx;

        // adjust scale based on image sizes 
        if (level == 2)      .6 => sca_mod;
        else if (level == 4) .72 => sca_mod;
        else if (level == 5) .77 => sca_mod;

        // init face sprites
        sprite(faces[level-1].face, false) @=> go_face;
        go_face --> this;

        for (auto tex : face.features) go_face_features << sprite(tex, true);
    } 

    fun void update(float dt) { // called once per frame. put all your game logic here
        g.mousePos() => vec2 mouse_pos;

        // only allow placing feature if beyond threshold
        (dir.y < 0) => int falling;

        (falling && _pos.y < 4)
        ||
        (!falling && _pos.y > -4) => int legal_drop;

        if (legal_drop && GWindow.mouseLeftDown() && face_feature_idx < face.features.size()) {
            face_feature_idx++;

            if (face_feature_idx >= face.features.size()) {
                true => _finished;
                null @=> go_feature;
            }
            else {
                go_face_features[face_feature_idx] @=> go_feature;
                go_feature --> this;

                // randomize direction
                if (maybe && maybe) {
                    @(0,1) => dir;
                    -1.5 * @(0, 5) => _pos;
                } else {
                    @(0,-1) => dir;
                    1.5 * @(0, 5) => _pos;
                }
            }


        }

        if (go_feature != null) {
            5 * dt * dir +=> _pos;
            Math.clampf(mouse_pos.x, -.5 * aspect.x, .5 * aspect.x) => _pos.x;
            // wrap around
            if (dir.y < 0 && _pos.y < -7.5) {
                7.5 => _pos.y;
            }
            if (dir.y > 0 && _pos.y > 7.5) {
                -7.5 => _pos.y;
            }

            go_feature.pos(_pos.x, _pos.y, 1.0);
        }

        // black background
        // if (level >= 4) {
        //     g.boxFilled(@(0, 0), (9/16.0) * g.screen_h, g.screen_h, Color.BLACK);
        // }

        // sprite(face.face, @(0, 0), 10);
        // draw features

        // g.pushLayer(1);
        // g.pushColor(2*Color.WHITE);
        // for (int i; i < positions.size(); ++i) 
        //     sprite(face.features[i], positions[i], 10);
        // g.popColor();
        // g.popLayer();
    }
}

if (0)
{

while (1) {
    GG.nextFrame() => now;
    GG.dt() => float dt;

}
}