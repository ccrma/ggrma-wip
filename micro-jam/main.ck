@import "phone/start.ck"
@import "phone/phone.ck"

GG.camera().orthographic();
GG.camera().viewSize(10);

GWindow.sizeLimits(0, 0, 0, 0, @(16, 9));
GWindow.center();

GG.scene().backgroundColor(Color.BLACK);
// disable skybox
null => GG.scene().skybox;

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

int train_playing;
fun void playTrain() {
    if (train_playing) return;
    true => train_playing;
    SndBuf buf(me.dir() + "assets/audio/sfx/train.wav") => dac;
    buf.loop(true);
    buf.gain(0.8);
    while (true) {
        100::ms => now;
    }
}

fun void resizeListener() {
    while (true) {
        GWindow.resizeEvent() => now;
        GWindow.sizeLimits(0, 0, 0, 0, @(16, 9));
    }
} spork ~ resizeListener();

start --> GG.scene();
spork ~ startListener();
spork ~ fadeInListener();
spork ~ playTrain();
while(true) {
    GG.nextFrame() => now;
}