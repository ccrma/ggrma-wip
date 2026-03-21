@import "phone/phone.ck"

GG.camera().orthographic();

GWindow.sizeLimits(1920, 1080, 0, 0, @(16, 9));
GWindow.center();

GG.scene().backgroundColor(Color.WHITE);

Phone phone --> GG.scene();

while(true) {
    GG.nextFrame() => now;
}