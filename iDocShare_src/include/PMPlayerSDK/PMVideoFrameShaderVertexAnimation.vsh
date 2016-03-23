//
//  PMVideoFrameShaderVertexAnimation.vsh
//

attribute vec2 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_transform;
attribute vec4 a_reference;
attribute vec3 a_parameter;
attribute vec2 a_backingSize;

varying   vec2 v_texCoord;

void main()
{
    vec3  position;
    vec4  transform;
    float step;
    mat3 scale;
    // Animation
    if (a_parameter.x != 0.0) {
        step = a_parameter.x / a_parameter.y;
        transform = a_transform - a_reference;
        transform = transform * step;
        transform = transform + a_reference;
    } else {
        transform = a_transform;
    }
    
    // Screen scale factor
    transform = transform * a_parameter[2];
    
    // Transform
    //position = a_position * transform.z;
    scale = mat3(
                 vec3(transform[2], 0.0, 0.0),
                 vec3(    0.0, transform[3], 0.0),
                 vec3(    0.0, 0.0, 1.0)
                 );
    position = vec3(a_position, 1.0);

    position = position * scale;
    //position = position.xy + transform.xy;
    
    // Orthogonal
    gl_Position = vec4( position.x * (2.0 / a_backingSize.x) - 1.0,
                       -position.y * (2.0 / a_backingSize.y) + 1.0,
                       0.0,
                       1.0);
    
    v_texCoord = a_texCoord;
}
