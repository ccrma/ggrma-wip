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

Phone phone --> GG.scene();

while(true) {
    GG.nextFrame() => now;
}