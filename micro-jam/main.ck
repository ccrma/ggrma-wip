@import "phone/start.ck"
@import "phone/phone.ck"

GG.camera().orthographic();
GG.camera().viewSize(10);

GWindow.sizeLimits(1920, 1080, 0, 0, @(16, 9));
GWindow.center();

GG.scene().backgroundColor(Color.WHITE);
// disable skybox
null => GG.scene().skybox;
// disable tonemapping / HDR
GG.outputPass().tonemap(OutputPass.ToneMap_None);
// disable gamma
// GG.outputPass().gamma(false);

Phone phone;
Start start;

fun void startListener() {
    while(true) {
        start.startEvent => now;
        phone --> GG.scene();
        spork ~ phone.slideUp();
    }
}

if (0) {
    start --> GG.scene();
    spork ~ startListener();
} else {
    phone --> GG.scene();
    spork ~ phone.slideUp();
}

while(true) {
    GG.nextFrame() => now;
}