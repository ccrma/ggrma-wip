public class Util {
    // Any utility functions can go here

    // returns the distance between two points
    fun static float distance(vec2 a, vec2 b) {
        return Math.sqrt(Math.pow((a.x - b.x), 2) + Math.pow((a.y - b.y), 2));
    }

    // returns the angle between two points in radians
    fun static float angle(vec2 a, vec2 b) {
        return Math.atan2(b.y - a.y, b.x - a.x);
    }

    fun static vec2 mousePos() {
        return GG.camera().screenCoordToWorldPos(GWindow.mousePos(), 1.0) $ vec2;
    }
    fun static vec2 mousePos(float distanceFromCamera) {
        return GG.camera().screenCoordToWorldPos(GWindow.mousePos(), distanceFromCamera) $ vec2;
    }
}