@import "scene.ck"

public class BarScene extends Scene {
    NPC @ stranger;

    GMesh @ light_mesh;
    SndBuf light_buzz(me.dir() + "../assets/audio/light_buzz.wav") => dac;
    1 => light_buzz.loop;
    0 => light_buzz.rate;
    0.4 => float buzzBaseGain;

    SndBuf robot_steps(me.dir() + "../assets/audio/robot-steps.wav") => dac;
    1 => robot_steps.loop;
    0 => robot_steps.rate;

    SndBuf robot_noises(me.dir() + "../assets/audio/robot-noises.wav") => dac;
    1 => robot_noises.loop;
    0 => robot_noises.rate;

    false => int _stopAudio;

    fun BarScene() {
        me.dir() + "../assets/background.png" => assetPath;
    }

    fun void init(Player @ player, Prompt prompts[]) {
        dm.dialog().leftMargin(3.5);
        dm.dialog().rightMargin(3.8);
        dm.setPlayer(player);

        new NPC("", "") @=> stranger;
        dm.setNpc(stranger);

        dm.registerNpc("Daisun", me.dir() + "../assets/cleaning-bot.png");
        dm.registerNpc("Dolbi", me.dir() + "../assets/media-bot.png");
        dm.registerNpc("Doju", me.dir() + "../assets/sommelier-bot.png");
        dm.registerNpc("Doshiba", me.dir() + "../assets/tsundere-bot.png");

        dm.startDialogue(prompts);

        // Start ambient audio (gains fade in)
        1 => light_buzz.rate;
        0.5 => robot_steps.rate;
        0.5 => robot_noises.rate;
        spork ~ fadeInAudio();

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

    fun void stopAudio() {
        true => _stopAudio;
        spork ~ fadeOutAudio();
    }

    fun void startAudio() {
        false => _stopAudio;
        spork ~ fadeInAudio();
        spork ~ lightFlicker();
    }

    fun void fadeOutAudio() {
        2.0 => float fadeDur;
        1 => float t;
        while (t > 0) {
            GG.nextFrame() => now;
            GG.dt() / fadeDur -=> t;
            if (t < 0) 0 => t;
            t * 0.4 => light_buzz.gain;
            t * 0.025 => robot_steps.gain;
            t * 0.03 => robot_noises.gain;
        }
    }

    fun void fadeInAudio() {
        2.0 => float fadeDur;
        0 => float t;
        while (t < 1) {
            GG.nextFrame() => now;
            GG.dt() / fadeDur +=> t;
            if (t > 1) 1 => t;
            t * 0.4 => light_buzz.gain;
            t * 0.025 => robot_steps.gain;
            t * 0.03 => robot_noises.gain;
        }
    }

    fun void lightFlicker() {
        0.8 => float baseAlpha;
        0.1 => float flickerIntensity;

        while (true) {
            if (_stopAudio) return;
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
