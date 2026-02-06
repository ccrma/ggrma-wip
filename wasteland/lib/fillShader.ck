@import "spring.ck"

public class QuestionMark extends GGen {
    "
    #include FRAME_UNIFORMS
    #include DRAW_UNIFORMS
    #include STANDARD_VERTEX_INPUT
    #include STANDARD_VERTEX_OUTPUT
    #include STANDARD_VERTEX_SHADER

    @group(1) @binding(0) var<uniform> u_color : vec3f;
    @group(1) @binding(1) var u_sampler : sampler;
    @group(1) @binding(2) var u_color_map : texture_2d<f32>;
    @group(1) @binding(3) var<uniform> u_fill_y : f32;

    fn srgbToLinear(c : vec4f) -> vec4f {
        return vec4f(
            pow(c.r, 2.2),
            pow(c.g, 2.2),
            pow(c.b, 2.2),
            c.a
        );
    }

    @fragment 
    fn fs_main(in : VertexOutput) -> @location(0) vec4f
    {   
        let uv = in.v_uv;
        var col = srgbToLinear(textureSample(u_color_map, u_sampler, uv));

        let fill_y = uv.y + .02*sin(10*uv.x + 3*u_frame.time);

        if (fill_y < u_fill_y) { col *= vec4f(u_color, 1); }

        // alpha test
        if (col.a < .01) { discard; }

        return col;
    }
    " => static string shader_code;

    static Shader@ fill_shader;
    static Texture@ tex;

    Spring spring(0, 4200, 20);

    if (fill_shader == null) {
        ShaderDesc shader_desc;
        shader_code => shader_desc.vertexCode;
        shader_code => shader_desc.fragmentCode;

        // create shader from shader_desc
        new Shader(shader_desc) @=> fill_shader; 

        // load tex
        TextureLoadDesc load_desc;
        true => load_desc.flip_y;  // flip the texture vertically
        true => load_desc.gen_mips; // generate mip maps automatically
        Texture.load(me.dir() + "../assets/question_mark.png", load_desc) @=> tex;
    }

    Material material;
    fill_shader => material.shader; // connect shader to material

    material.uniformFloat3(0, Color.hex(0x901212));
    material.sampler(1, TextureSampler.linear());
    material.texture(2, tex);
    material.uniformFloat(3, 0);

    PlaneGeometry geo;
    GMesh mesh(geo, material) --> this;

    fun void fill(float percentage) { material.uniformFloat(3, percentage); }
    fun void color(vec3 color) { material.uniformFloat3(0, color); }
    fun void alert() { spring.pull(.5); }

    fun void update(float dt) {
        spring.update(dt);

        1 + spring.x => mesh.sca;
    }
}

// unit test
if (0) {
    QuestionMark mark --> GG.scene();

    UI_Float3 color(Color.hex(0x901212));
    UI_Float y;
    UI_Float force(.1);

    // render loop
    while (1)
    {
        GG.nextFrame() => now;

        // Math.sin(now/second) => mark.fill;
        // .5 => mark.fill;

        UI.slider("fill", y, 0, 1);
        UI.colorEdit("color", color);
        UI.slider("force", force, 0, 1);

        // if (UI.button("bounce")) mark.spring.pull(force.val());
        if (UI.button("bounce")) mark.alert();


        y.val() => mark.fill;
        // mark.color(color.val());


    }
}