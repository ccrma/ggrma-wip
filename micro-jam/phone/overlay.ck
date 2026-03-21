public class Overlay extends GGen {
    @(GG.camera().viewSize() * 9 / 16, GG.camera().viewSize(), 1) => vec3 aspect;
    this.scaWorld(aspect);

    // border wireframe
    GPlane border --> this;
    border.mat().wireframe(true);
    border.sca(1);
    border.color(Color.BLACK);

    

    fun void update(float dt) {
        // todo: interaction stuff - like, comment, share, whatever
    }
}