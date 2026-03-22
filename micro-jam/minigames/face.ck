/*

Lvls
1: cartoon face
2: 
3: art from other game?
4: ???
5: scary face / crazy features

*/

@import "../lib/g2d/g2d.ck"

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
    [
        new Face(me.dir() + "./assets/face1"),
        new Face(me.dir() + "./assets/face2"),
        new Face(me.dir() + "./assets/face3"),
        new Face(me.dir() + "./assets/face4"),
        new Face(me.dir() + "./assets/face5"),
    ] @=> Face faces[];

    true => _win; // not loseable

    vec2 positions[0];
    vec2 _pos;
    -1 => int face_feature_idx;
    g.DOWN => vec2 dir;
    0 => int face_idx;
    faces[0] @=> Face@ face;


    // render sprite with correct aspect ratio
    fun void sprite(Texture tex, vec2 pos, float sca) {
        tex.width() $ float / tex.height() => float aspect;
        g.sprite(tex, pos, sca * @(aspect, 1), 0);
    }

    fun void init(int level) {
        false => _finished;

        // reset game
        (level - 1) % faces.size() => face_idx;
        faces[face_idx] @=> face;

        -1 => face_feature_idx;
        positions.clear();

    } 

    fun void update(float dt) { // called once per frame. put all your game logic here
        g.mousePos() => vec2 mouse_pos;

        if (GWindow.mouseLeftDown()) {
            if (face_feature_idx < 0) {
                0 => face_feature_idx;
            }
            else {
                positions << _pos;
                face_feature_idx++;
            }

            // randomize direction
            if (maybe && maybe) {
                g.UP => dir;
                1.5 * @(0, g.screen_min.y) => _pos;
            } else {
                g.DOWN => dir;
                1.5 * @(0, g.screen_max.y) => _pos;
            }
        }

        if (face_feature_idx >= 0 && face_feature_idx < face.features.size()) {
            5 * dt * dir +=> _pos;
            mouse_pos.x => _pos.x;

            g.pushLayer(1);
            g.pushColor(2*Color.WHITE);
            sprite(face.features[face_feature_idx], _pos, 10);
            g.popColor();
            g.popLayer();
        }

        sprite(face.face, @(0, 0), 10);
        // draw features
        g.pushLayer(1);
        g.pushColor(2*Color.WHITE);
        for (int i; i < positions.size(); ++i) 
            sprite(face.features[i], positions[i], 10);
        g.popColor();
        g.popLayer();
    }
}

if (1)
{

while (1) {
    GG.nextFrame() => now;
    GG.dt() => float dt;

}
}