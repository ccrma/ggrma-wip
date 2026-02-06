public class Waveform extends Chugraph {
    512 => int WINDOW_SIZE; // TODO experiment with different sizes
    Flip waveform_accum;
    Windowing.hann(WINDOW_SIZE) @=> float hann_window[];
    float samples[WINDOW_SIZE];

    // UAna graph
    inlet => waveform_accum => blackhole;

    int _last_update_fc;
    fun void update() {
        // only need to update once per frame
        if (GG.fc() == _last_update_fc) return;

        GG.fc() => _last_update_fc;
        waveform_accum.upchuck();
        waveform_accum.output( samples );

        // taper and map to 
        for (int s; s < samples.size(); s++) {
            hann_window[s] *=> samples[s];
        }
    }

}