/*

Lvls
1: bubbles?
2: coins / art from mukbang game
3: eyes / lips body parts from face-making game
4: ?
5: many pimples --> holes --> tripophobia

*/

@import "../lib/g2d/g2d.ck"
@import "../lib/M.ck"

public class Pimples extends Minigame {
    G2D g --> this;

    // static stuff ====================================================
    1 => static int Level_Bubble;
    2 => static int Level_Wrap;
    3 => static int Level_Bug;
    4 => static int Level_Clown;
    5 => static int Level_Monster;


    static Texture@ bubble_tex;
    2 => static float BUBBLE_SPRITE_SCA_MODIFIER;

    static Texture@ bubblewrap_popped;
    static Texture@ bubblewrap_unpopped;
    4 => static int WRAP_N_COLS;
    5 => static int WRAP_N_ROWS;

    static Texture@ pillbug;
    static Texture@ pillbug_smushed;
    // bug
    10 => static int PILLBUG_N_FRAMES;
    .5 => static float PILLBUG_SCA_MOD;

    static Texture@ clown_tex;
    static Texture@ balloon_tex;
    static float BALLOON_ASPECT;
    4.2 => static float BALLOON_VISUAL_SCA;

    static Texture@ monster_tex;
    static Texture@ eyeblink_tex;
    1.2 => static float MONSTER_SPAWN_RADIUS;

    // size
    .5 => static float r;
    r * r => static float r2;

    // load textures
    static int loaded;
    fun static void loadAssets() {
        if (loaded) return;
        true => loaded;

        TextureLoadDesc load_desc;
        false => load_desc.flip_y;
        false => load_desc.gen_mips;

        <<< "loading pop game textures" >>>;
        Texture.load(me.dir() + "../assets/pimple/bubble.png", load_desc) @=> bubble_tex;

        Texture.load(me.dir() + "../assets/pimple/bubblewrap-popped.png", load_desc) @=> bubblewrap_popped;
        Texture.load(me.dir() + "../assets/pimple/bubblewrap-unpopped.png", load_desc) @=> bubblewrap_unpopped;

        Texture.load(me.dir() + "../assets/pimple/pillbug.png", load_desc) @=> pillbug;
        Texture.load(me.dir() + "../assets/pimple/pillbug-smushed.png", load_desc) @=> pillbug_smushed;

        Texture.load(me.dir() + "../assets/pimple/clown.png", load_desc) @=> clown_tex;
        Texture.load(me.dir() + "../assets/pimple/balloon.png", load_desc) @=> balloon_tex;
        balloon_tex.width() / 4.0 / balloon_tex.height() => BALLOON_ASPECT;

        // monster
        Texture.load(me.dir() + "../assets/pimple/monster.png", load_desc) @=> monster_tex;
        Texture.load(me.dir() + "../assets/pimple/eyeblink-no-pupil.png", load_desc) @=> eyeblink_tex;
    }

    // local stuff ====================================================
    vec2 positions[0]; // .z is > 0 if popped
    int active[0];
    vec4 rand[0]; // random val for animations
    int num_pimples;
    int level;

    true => _win; // not loseable

    fun Pimples(int level) {
        false => _finished;
        level => this.level;

        positions.clear();
        active.clear();
        rand.clear();

        if (level == Level_Bubble) {
            Math.random2(8, 12) => int count;
            count => num_pimples;
            positions.size(count);
            active.size(count);
            rand.size(count);

            for (int i; i < count; i++) {
                true => active[i];
                M.randomPointInArea(@(0,0), 1.8, 3.5) => positions[i];
                @(
                    Math.randomf(),
                    Math.randomf(),
                    Math.randomf(),
                    Math.random2f(.5, 1)
                ) => rand[i];
            }
        }
        else if (level == Level_Wrap) {
            // tile to fill the screen, player only needs to pop the unpopped ones
            -r * ((WRAP_N_COLS-1)) => float x;
            for (int i; i < WRAP_N_COLS; i++) {
                -(r * (WRAP_N_ROWS -1)) => float y;
                for (int j; j < WRAP_N_ROWS; ++j) {

                    // add
                    positions << @(x, y);

                    num_pimples++;
                    active << true;
                    2 * r +=> y;
                }
                2*r +=> x;
            }
        }
        else if (level == Level_Bug) {
            true => has_white_background;
            Math.random2(8, 12) => int count;

            // all spawn at center
            positions.size(count);
            active.size(count);
            rand.size(count);
            count => num_pimples;
            for (int i; i < count; ++i) {
                true => active[i];

                // set random bug targets
                M.randomPointInArea(@(0,0), .5 * 5, .3 * g.screen_h) $ vec4 => rand[i];
                // set random frame offset
                Math.random2(0, PILLBUG_N_FRAMES - 1) => rand[i].z;
                Math.random2f(.8, 1.2) => rand[i].w; // speed
            }
        }
        else if (level == Level_Clown) {
            // TODO position hard-code
            Math.random2(12, 16) => int count;

            count => num_pimples;
            positions.size(count);
            active.size(count);
            rand.size(count);

            for (int i; i < count; i++) {
                true => active[i];
                M.randomPointInArea(@(0,0), .4 * aspect.x, .35 * aspect.y) => positions[i];
                @(
                    Math.randomf(),
                    Math.randomf(),
                    Math.randomf(),
                    Math.random2f(.5, 1)
                ) => rand[i];
            }
        }
        else if (level == Level_Monster) {
            Math.random2(8, 20) => int count;
            count => num_pimples;
            positions.size(count);
            active.size(count);
            rand.size(count);

            for (int i; i < count; i++) {
                true => active[i];
                M.randomPointInCircle(@(-.1, .5), .25, MONSTER_SPAWN_RADIUS) => positions[i];
                @(
                    Math.randomf(),
                    Math.randomf(),
                    Math.randomf(),
                    Math.random2f(.5, 1)
                ) => rand[i];
            }
        }
    }

    fun _background(vec3 color) {
        g.pushLayer(0);
        g.boxFilled(@(0, 0), aspect.x, aspect.y, color);
        g.popLayer();
    }

    fun void pop(int idx) {
        SFX.play(SFX.POP1 + (level - 1), Math.random2f(0.85, 1.15));  // level 1→POP1, 2→POP2, ..., 5→POP5
        num_pimples--;
        false => active[idx];
        (num_pimples == 0) => _finished;
    }

    fun int music() {
        return Music.POPPING1 + (level - 1);
    }

    fun void update(float dt) {
        g.mousePos() => vec2 mouse_pos;
        now / second => float t;

        Math.sin(2*t) => float sin_2t;



        int popped; // only pop 1 at a time

        g.pushLayer(1);
        for (int i; i < positions.size(); i++) {
            positions[i] => vec2 p;
            Color.WHITE => vec3 color;
            r => float mod_r;

            // update
            if (level == Level_Bubble) {
                // move in place
                .6 * rand[i].z * Math.sin(t * rand[i].x) +=> p.x;
                .6 * rand[i].z * Math.sin(t * rand[i].y) +=> p.y;
                // vary size
                r * rand[i].w => mod_r;
            }
            else if (level == Level_Wrap) {
                // slide up and down
                (i / WRAP_N_ROWS) % 2 => int col;
                .3 * sin_2t * (col ? 1 : -1) +=> p.y;
            }
            else if (level == Level_Bug) {
                PILLBUG_SCA_MOD * r => mod_r;

                // move bug towards target
                if (active[i]) {
                    rand[i] $ vec2 => vec2 target;

                    // lerp bug towards target
                    if (M.dist2(p, target) < .05) {
                        // stop, pick new target
                        M.randomPointInArea(@(0,0), .5 * 5, .4 * g.screen_h) => vec2 target; 
                        target.x => rand[i].x;
                        target.y => rand[i].y;
                    } else {
                        rand[i].w => float BUG_SPEED;
                        dt * BUG_SPEED * M.dir(p, target) + p => positions[i];
                        positions[i] => p;
                    }
                }
            }
            else if (level == Level_Clown) {
                .6 * (.2 + rand[i].y) * Math.sin(t * (.2 + rand[i].w)) +=> p.y;
                .95 * r => mod_r;
                // g.square(p + .5 * g.UP, 2 * mod_r);
            }
            else if (level == Level_Monster) {
                .9 * r => mod_r;
            }


            if (!popped && active[i]) {
                int collision;

                if (level != Level_Clown) {
                    M.dist(p, mouse_pos) < mod_r => collision;
                } else {
                    M.dist(p + .5 * g.UP, mouse_pos) < mod_r => collision;
                }

                if (collision) {
                    true => popped;
                    Color.RED => color;
                    if (g.mouse_left_down) {
                        pop(i);
                        if (level == Level_Bubble) {
                            g.animate(p, bubble_tex, 7, 1, .05, 2* mod_r * BUBBLE_SPRITE_SCA_MODIFIER);
                        }
                        else if (level == Level_Clown) {
                            AnimationEffect e(
                                balloon_tex,
                                4,
                                0,
                                .05,
                                BALLOON_VISUAL_SCA * r, p, Color.WHITE
                            ); 
                            -1 *=> e._frame_sca.y;
                            g.add(e);
                        }
                        else if (level == Level_Monster) {
                            AnimationEffect e(
                                eyeblink_tex,
                                3,
                                0,
                                .1,
                                r, p, Color.WHITE
                            ); 
                            -1 *=> e._frame_sca.y;
                            g.add(e);
                        }
                    }
                }
            }

            active[i] => int active;



            // draw
            if (level == Level_Bubble) {
                if (active) {
                    g.sprite(bubble_tex, 7, 0, p, 2* mod_r * BUBBLE_SPRITE_SCA_MODIFIER);
                }
            } 
            else if (level == Level_Wrap) {
                g.sprite(active ? bubblewrap_unpopped : bubblewrap_popped, p, 2*r);
            }
            else if (level == Level_Bug) {

                rand[i] $ vec2 => vec2 target;
                M.angle(p, target) + Math.pi/2 => float angle;

                if (active)
                    g.sprite(pillbug, PILLBUG_N_FRAMES, 0, p, r* @(1,1), angle, Color.WHITE);
                else 
                    g.sprite(pillbug_smushed, p, r, angle);
            }
            else if (level == Level_Clown) {

                if (active) 
                    g.sprite(balloon_tex, @(4, 1), @(0, 0), p, BALLOON_VISUAL_SCA * r * @(BALLOON_ASPECT, -1), 0, Color.WHITE);
            }
            else if (level == Level_Monster) {

                // g.circleFilled(@(-.1, .5), 1.2, Color.RED);

                if (active) {
                    g.sprite(eyeblink_tex, 3, 0, p, 2 * r * @(1, -1), 0, Color.WHITE);

                    p + .1 * g.UP => vec2 eye_p;

                    M.dir(eye_p, mouse_pos) => vec2 dir;
                    .05 * dir +=> eye_p;

                    g.pushLayer(2);
                    g.circleFilled(eye_p, .04, Color.YELLOW);
                    g.popLayer();
                } else {
                    g.sprite(eyeblink_tex, 3, 2, p, 2 * r * @(1, -1), 0, Color.WHITE);
                }
                // g.circleFilled(@(0,0), MONSTER_SPAWN_RADIUS);
            }
        }
        g.popLayer();

        // background
        if (level == Level_Bubble || level == Level_Wrap)
            _background(Color.BLACK);
        else if (level == Level_Bug)
            _background(Color.BEIGE);
        else if (level == Level_Clown) {
            g.pushLayer(0);
            g.sprite(clown_tex, @(0,0), @(aspect.x, -aspect.y), 0);
            g.popLayer();
        }
        else if (level == Level_Monster) {
            g.pushLayer(0);
            g.sprite(monster_tex, @(0,0), @(aspect.x, -aspect.y), 0);
            g.popLayer();
        }
    }
}

if (0) {
    Pimples pimples;
    Pimples.Level_Clown => int level;
    Pimples.Level_Monster => level;
    // 1 => level;

    while (1) {
        GG.nextFrame() => now;
        GG.dt() => float dt;

        if (pimples.num_pimples == 0) {
            pimples.init(Math.random2(6,7), level++);
        }

        pimples.update(dt);

    }
}