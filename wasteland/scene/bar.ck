@import "scene.ck"

public class BarScene extends Scene {
    NPC @ stranger;

    GMesh @ light_mesh;
    SndBuf light_buzz(me.dir() + "../assets/audio/light_buzz.wav") => dac;
    1 => light_buzz.loop;
    0.8 => float buzzBaseGain;

    SndBuf robot_steps(me.dir() + "../assets/audio/robot-steps.wav") => dac;
    1 => robot_steps.loop;
    0.05 => robot_steps.gain;

    SndBuf robot_noises(me.dir() + "../assets/audio/robot-noises.wav") => dac;
    1 => robot_noises.loop;
    0.1 => robot_noises.gain;


    fun BarScene() {
        me.dir() + "../assets/background.png" => assetPath;
        TextureLoadDesc desc;
        true => desc.flip_y;
        Texture.load( me.dir() + "../assets/bar_light.png", desc ) @=> Texture light_tex;
        PlaneGeometry geo;
        FlatMaterial mat;
        mat.colorMap(light_tex);
        mat.transparent(true);
        new GMesh( geo, mat ) @=> light_mesh;
        light_mesh.sca(ChuGUI.NDCToWorldSize(@(2, 2)));
        light_mesh --> GG.scene();
    }

    fun void init(Player @ player, Prompt prompts[]) {
        dm.dialog().leftMargin(3.5);
        dm.dialog().rightMargin(3.8);
        dm.setPlayer(player);

        new NPC("", "") @=> stranger;
        dm.setNpc(stranger);

        dm.registerNpc("Cleaner", me.dir() + "../assets/cleaning-bot.png");
        dm.registerNpc("Media", me.dir() + "../assets/media-bot.png");
        dm.registerNpc("Sommelier", me.dir() + "../assets/sommelier-bot.png");
        dm.registerNpc("Tsundere", me.dir() + "../assets/tsundere-bot.png");

        dm.startDialogue(prompts);

        spork ~ lightFlicker();
    }

    fun void update(ChuGUI gui) {
        super.render(gui);
        stranger.update(gui);
        dm.update(gui);
    }

    fun void setLight(float alpha) {
        (light_mesh.mat() $ FlatMaterial).alpha(alpha);
        alpha / 0.8 * buzzBaseGain => light_buzz.gain;
    }

    fun void lightFlicker() {
        0.8 => float baseAlpha;
        0.1 => float flickerIntensity;

        while (true) {
            // shutoff (~2% chance)
            if (Math.random2f(0, 1) < 0.02) {
                setLight(Math.random2f(0, 0.15));
                Math.random2f(0.05, 0.2)::second => now;
                if (maybe) {
                    setLight(baseAlpha);
                    0.05::second => now;
                    setLight(Math.random2f(0, 0.1));
                    Math.random2f(0.03, 0.08)::second => now;
                }
            }

            Math.random2f(-flickerIntensity, flickerIntensity) + baseAlpha => float flicker;
            setLight(flicker);
            Math.random2f(0.06, 0.15)::second => now;
        }
    }
}
