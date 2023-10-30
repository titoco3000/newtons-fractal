//
// Got initial code from:
//https://github.com/not-fl3/macroquad/blob/master/examples/post_processing.rs

// Disable terminal
#![windows_subsystem = "windows"]

use macroquad::prelude::*;


#[macroquad::main("Newton's fractal")]
async fn main() {
    let mut zoom:f32 = 1.0;
    let render_target = render_target(1, 1);
    //render_target.texture.set_filter(FilterMode::Nearest);

    let material = load_material(
        ShaderSource::Glsl {
            vertex: CRT_VERTEX_SHADER,
            fragment: include_str!("fragment.glsl"),
        },
        MaterialParams {
            uniforms: vec![
                ("WindowSize".to_owned(), UniformType::Float2),
                ("offset".to_owned(), UniformType::Float2),
                ("zoom".to_owned(), UniformType::Float1)
            ],
            ..Default::default()
        },
    )
    .unwrap();
    
    let window_size:(f32,f32) = (screen_width(), screen_height());
    let mut offset:(f32,f32) = (0.0 , 0.0);
    let movement_speed:f32 = 0.01;
    loop {
        // drawing to the texture
        
        // 0..100, 0..100 camera
        set_camera(&Camera2D {
            zoom: vec2(0.01, 0.01),
            target: vec2(0.0, 0.0),
            render_target: Some(render_target.clone()),
            ..Default::default()
        });
        
        clear_background(WHITE);
        
        // drawing to the screen
        
        
        let (_, mouse_wheel_y) = mouse_wheel();
        if mouse_wheel_y < 0.0{
            zoom *= 1.1;
        }
        else if mouse_wheel_y > 0.0{
            zoom /= 1.1;
        }

        if is_key_down(KeyCode::Right) {
            offset.0 += movement_speed;
        }
        if is_key_down(KeyCode::Left) {
            offset.0 -= movement_speed;
        }
        if is_key_down(KeyCode::Up) {
            offset.1 += movement_speed;
        }
        if is_key_down(KeyCode::Down) {
            offset.1 -= movement_speed;
        }

        material.set_uniform("WindowSize", window_size);
        material.set_uniform("offset", offset);
        material.set_uniform("zoom", zoom);

        set_default_camera();

        clear_background(WHITE);
        gl_use_material(&material);
        draw_texture_ex(
            &render_target.texture,
            0.,
            0.,
            WHITE,
            DrawTextureParams {
                dest_size: Some(vec2(screen_width(), screen_height())),
                ..Default::default()
            },
        );
        gl_use_default_material();

        next_frame().await;
    }
}


const CRT_VERTEX_SHADER: &'static str = "#version 100
attribute vec3 position;
attribute vec2 texcoord;

uniform mat4 Model;
uniform mat4 Projection;

void main() {
    gl_Position = Projection * Model * vec4(position, 1);
}
";