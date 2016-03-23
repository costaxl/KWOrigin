//
//  PMVideoFrameShaderFragmentYUV420p.fsh
//

precision mediump float;

varying vec2      v_texCoord;

uniform sampler2D s_texture0;
uniform sampler2D s_texture1;
uniform sampler2D s_texture2;

void main()
{
    float r, g, b, y, u, v;
    
    y = texture2D(s_texture0, v_texCoord).r;
    u = texture2D(s_texture1, v_texCoord).r;
    v = texture2D(s_texture2, v_texCoord).r;
    
    if ((y == 0.0) && (u == 0.0) && (v == 0.0)) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        r = (1.164 * (y - 0.0625)) + (2.018 * (v - 0.5));
        g = (1.164 * (y - 0.0625)) - (0.813 * (u - 0.5)) - (0.391 * (v - 0.5));
        b = (1.164 * (y - 0.0625)) + (1.596 * (u - 0.5));
        
        gl_FragColor = vec4(r, g, b, 1.0);
    }
}
	