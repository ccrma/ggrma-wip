@import "phone/start.ck"
@import "phone/phone.ck"

GG.camera().orthographic();
GG.camera().viewSize(10);

// GWindow.sizeLimits(1920, 1080, 0, 0, @(16, 9));
GWindow.center();

GG.scene().backgroundColor(Color.WHITE);
// disable skybox
null => GG.scene().skybox;
// disable tonemapping / HDR
// GG.outputPass().tonemap(OutputPass.ToneMap_None);
// disable gamma
// GG.outputPass().gamma(false);

Phone phone;
Start start;
Event fadeInEvent;

fun void startListener() {
    while(true) {
        start.startEvent => now;
        spork ~ fadeIn();
    }
}

fun void fadeInListener() {
    while(true) {
        fadeInEvent => now;
        phone --> GG.scene();
        spork ~ phone.slideUp();
    }
}

fun void fadeIn() {
    3 => float duration;
    float t;

    while (t < duration) {
        GG.nextFrame() => now;
        GG.dt() +=> t;
        if (t > duration) duration => t;
        
        t / duration => float p;

        0.75 => float c1;
        c1 * 1.25 => float c2;

        Math.sin((p * Math.PI) / 2) => float ease;

        GG.outputPass().exposure(ease);
    }

    fadeInEvent.broadcast();
}

fun void playTrain() {
    SndBuf buf(me.dir() + "assets/audio/sfx/train.wav") => dac;
    buf.loop(true);
    buf.gain(0.5);
    while (true) {
        100::ms => now;
    }
}

if (1) {
    start --> GG.scene();
    spork ~ startListener();
    spork ~ fadeInListener();
    spork ~ playTrain();
} else {
    phone --> GG.scene();
    spork ~ phone.slideUp();
}

while(true) {
    GG.nextFrame() => now;
}