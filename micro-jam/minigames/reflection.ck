
public class Reflection extends Minigame
{
    // fun GGen sprite(Texture tex, float width, float height, float layer)
    // {
    //     FlatMaterial mat; 
    //     true => mat.transparent;
    //     mat.sampler(linear_sampler);

    //     mat.colorMap(tex);

    //     GMesh mesh(plane_geo, mat);
    //     mesh.posZ(layer * 0.01);
    //     // mesh.sca(@(width / 180.0, height / 180.0, 1.0));
    //     mesh.sca(@(.75 * width / 180.0, .75 * height / 180.0, 1.0));

    //     mesh --> GGen ggen;

    //     return ggen;
    // }

    static Texture@ tex[5];

    fun static void loadAssets() {
        TextureLoadDesc load_desc;
        true => load_desc.flip_y;
        false => load_desc.gen_mips;

        for (int i; i < 5; i++)
            Texture.load(me.dir() +  "../assets/reflection/" + i + ".png", load_desc) @=> tex[i];
    }

    // black plane
    // FlatMaterial bg_mat;
    // Color.BLACK => bg_mat.color;
    // GMesh bg(plane_geo, bg_mat) --> this;
    // bg.sca(@(aspect.x, aspect.y));

    FlatMaterial reflect_mat;
    linear_sampler => reflect_mat.sampler;
    true => reflect_mat.transparent;
    GMesh reflect_mesh(plane_geo, reflect_mat) --> this;
    reflect_mesh.sca(@(aspect.x, aspect.y));
    reflect_mesh.posZ(0);

    int level;
    fun Reflection(int level) {
        level => this.level;
        reflect_mat.colorMap(tex[level-1]);

        false => _win;
    }

    float t;
    fun void update(float dt) {
        dt +=> t;

        if (stopped) {
            reflect_mesh.pos(@(0, 0));
            reflect_mesh.posZ(1);
        }
        else 
            reflect_mesh.posWorld(@(0, 0));

        if (t > 5) {
            true => _finished;

            if (level == 5 && t > 7) {
                Math.randomf() * Color.WHITE => reflect_mat.color;
            }
        }
    }
}