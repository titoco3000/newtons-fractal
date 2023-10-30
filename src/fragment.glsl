#version 100
uniform vec2 WindowSize;
uniform vec2 offset;
uniform float zoom;

//define complex arithm
//based on https://github.com/julesb/glsl-util/blob/master/complexvisual.glsl

vec2 cx_add(vec2 a, vec2 b){return vec2(a.x + b.x, a.y + b.y);}
vec2 cx_sub(vec2 a, vec2 b){ return vec2(a.x - b.x, a.y - b.y); }
vec2 cx_mul(vec2 a, vec2 b){ return vec2(a.x*b.x-a.y*b.y, a.x*b.y+a.y*b.x); }
vec2 cx_div(vec2 a, vec2 b){ return vec2(((a.x*b.x+a.y*b.y)/(b.x*b.x+b.y*b.y)),((a.y*b.x-a.x*b.y)/(b.x*b.x+b.y*b.y))); }


vec2 cx_pow(vec2 a, int b){
    vec2 result = vec2(1,0);
    for(int i=0; i<b;i++)
        result = cx_mul(result, a);
    return result;
}

// x^4 - x^3 - 1.75x^2 + x
// vec2 f(vec2 x){
//     return cx_add(
//         cx_sub(
//             cx_sub(
//                 cx_pow(x,4),
//                 cx_pow(x,3)
//             ),
//             cx_mul(
//                 vec2(1.75, 0.0),
//                 cx_pow(x, 2)
//             )
//         ),
//         x
//     );
// }

// 4x^3 - 3x^2 - 3.5x + 1
// vec2 f_prime(vec2 x){
//     return cx_add(
//         cx_sub(
//             cx_sub(
//                 cx_mul(
//                     vec2(4.0, 0.0),
//                     cx_pow(x,3)
//                 ),
//                 cx_mul(
//                     vec2(3.0, 0.0),
//                     cx_pow(x,2)
//                 )
//             ),
//             cx_mul(
//                 vec2(3.5, 0.0),
//                 x
//             )
//         ),
//         vec2(1.0, 0.0)
//     );
// }

// x^4 -1
vec2 f(vec2 x){
    return cx_sub(cx_pow(x,4), vec2(-1.0, 0.0));
}

// 4x^3
vec2 f_prime(vec2 x){
    return cx_mul(vec2(3.0,0.0),cx_pow(x,3));
}

vec2 aproximate(vec2 entry){
    for(int i=0; i<1000;i++){
        entry = entry - cx_div(f(entry), f_prime(entry));
    }
    return entry;
}

out vec4 fragColor; // Output color

void main() {
    ivec2 fragCoord = ivec2(gl_FragCoord.xy); // Get the fragment/pixel coordinates
    int x = int(fragCoord.x);

    vec2 relativePosition = vec2((float(fragCoord.x) / WindowSize.x + offset.x) * zoom, (float(fragCoord.y) / WindowSize.y + offset.y) * zoom);

    vec2 guess = aproximate(relativePosition);

    //float d0 = distance(guess, vec2(-0.186,0.0));
    //float d1 = distance(guess, vec2(0.0,0.0));
    //float d2 = distance(guess, vec2(0.5,0.0));
    //float d3 = distance(guess, vec2(1.686,0.0));

    float d0 = distance(guess, vec2(1.0,0.0));
    float d1 = distance(guess, vec2(-1.0,0.0));
    float d2 = distance(guess, vec2(0.0,1.0));
    float d3 = distance(guess, vec2(0.0,-1.0));

    fragColor = vec4(1.0, 0.0, 0.0, 1.0);


    if(d1<d0){
        fragColor = vec4(0.0, 1.0, 0.0, 1.0);
    }
    if(d2<d1){
        fragColor = vec4(0.0, 0.0, 1.0, 1.0);
    }
    if(d3<d2){
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }

    // if (x < 200 ) {
    //     // Even pixel: Blue color
    //     fragColor = vec4(0.0, 0.0, 1.0, 1.0); // Blue color (RGBA)
    // } else {
    //     // Odd pixel: Red color
    //     fragColor = vec4(1.0, 0.0, 0.0, 1.0); // Red color (RGBA)
    // }
}
