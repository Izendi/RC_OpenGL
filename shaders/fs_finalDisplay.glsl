#version 430 core

in vec2 texCoord;

out vec4 FragColor;

//uniform vec4 ourColor;
uniform sampler2D u_tex_rc0;

uniform float u_resolution_x;
uniform float u_resolution_y;

uniform vec3 u_circleColor[50];
uniform int mouseIndex;

uniform float mouseX[500];
uniform float mouseY[500];

/*
uniform vec4 u_circleColor[20];

uniform int mouseIndex;
*/

//The below is a method of getting the texture from textue unit 0 without manually having to send it in yourself.
//layout(binding = 0) uniform sampler2D colortexture;

float sdfCircle(vec2 fragPos, float r, float offset_y, float offset_x)
{
    fragPos.x = fragPos.x + offset_x;
    fragPos.y = fragPos.y + offset_y;
    return length(fragPos) - r;
}


vec4 bilinearInterpolation(vec4 tl, vec4 tr, vec4 bl, vec4 br, float fx, float fy)
{
    // Interpolate top row (left to right)
    vec4 top = mix(tl, tr, fx);
    // Interpolate bottom row (left to right)
    vec4 bottom = mix(bl, br, fx);
    // Interpolate between the two rows (top to bottom)
    return mix(top, bottom, fy);
}

vec4 getCombinedProbeColor(vec2 probeCoord)
{
    vec4 colorValue_0 = texelFetch(u_tex_rc0, ivec2(int(probeCoord.x * 2), int(probeCoord.y * 2)), 0);
    vec4 colorValue_1 = texelFetch(u_tex_rc0, ivec2(int(probeCoord.x * 2 + 1), int(probeCoord.y * 2)), 0);
    vec4 colorValue_2 = texelFetch(u_tex_rc0, ivec2(int(probeCoord.x * 2), int(probeCoord.y * 2 + 1)), 0);
    vec4 colorValue_3 = texelFetch(u_tex_rc0, ivec2(int(probeCoord.x * 2 + 1), int(probeCoord.y * 2 + 1)), 0);

    colorValue_0 = colorValue_0 / 4.0;
    colorValue_1 = colorValue_1 / 4.0;
    colorValue_2 = colorValue_2 / 4.0;
    colorValue_3 = colorValue_3 / 4.0;

    vec4 combinedColor = colorValue_0 + colorValue_1 + colorValue_2 + colorValue_3;

    combinedColor.a = 1.0;

    return combinedColor;
}

void main()
{

    float x_probe_L = floor(texCoord.x * 256);
    float y_probe_B = floor(texCoord.y * 256);
    float x_probe_R = x_probe_L + 1;
    float y_probe_T = y_probe_B + 1;
    
    vec2 TL_probe_coord = vec2(x_probe_L, y_probe_T);
    vec2 TR_probe_coord = vec2(x_probe_R, y_probe_T);
    vec2 BL_probe_coord = vec2(x_probe_L, y_probe_B);
    vec2 BR_probe_coord = vec2(x_probe_R, y_probe_B);
    
    // Get colors and sum them up for each probe
    //Fetch Color Values from rc_0 texture:
    vec4 TL_color = getCombinedProbeColor(TL_probe_coord);
    vec4 TR_color = getCombinedProbeColor(TR_probe_coord);
    vec4 BL_color = getCombinedProbeColor(BL_probe_coord);
    vec4 BR_color = getCombinedProbeColor(BR_probe_coord);

    // Find the probes position in fragment space (0 to 1 same range as texture coords), by multiplying the probe ID with the resolution/No probes in x and y respectivly
    vec2 TL_fragPos = vec2(floor((u_resolution_x / 256) * TL_probe_coord.x + ((u_resolution_x / 256) / 2.0)), floor((u_resolution_y / 256) * TL_probe_coord.y + ((u_resolution_y / 256) / 2.0)));
    vec2 TR_fragPos = vec2(floor((u_resolution_x / 256) * TR_probe_coord.x + ((u_resolution_x / 256) / 2.0)), floor((u_resolution_y / 256) * TR_probe_coord.y + ((u_resolution_y / 256) / 2.0)));
    vec2 BL_fragPos = vec2(floor((u_resolution_x / 256) * BL_probe_coord.x + ((u_resolution_x / 256) / 2.0)), floor((u_resolution_y / 256) * BL_probe_coord.y + ((u_resolution_y / 256) / 2.0)));
    vec2 BR_fragPos = vec2(floor((u_resolution_x / 256) * BR_probe_coord.x + ((u_resolution_x / 256) / 2.0)), floor((u_resolution_y / 256) * BR_probe_coord.y + ((u_resolution_y / 256) / 2.0)));

    // Find the weight value for bilinear interpolation using the same rearanged bilinear equation from rc_2_v2
    float fx = (float(float(gl_FragCoord.x) - TL_fragPos.x)) / (float(float(TR_fragPos.x) - TL_fragPos.x));
    float fy = (float(float(gl_FragCoord.y) - BL_fragPos.y)) / (float(float(TL_fragPos.y) - BL_fragPos.y));
    
    // Send the weights for x and y (they are not the same and could be different) to the bilinear interpolation function
    vec4 finalColor = bilinearInterpolation(TL_color, TR_color, BL_color, BR_color, fx, fy);

    finalColor.a = 1.0;

    //That result is the final color value you need to return
    // 
    // Then you just need to adjsut the colors of the SDFs and the ray distance in each interval and we are done!


    //vec4 texColor = texture(u_tex_0, texCoord);
    //FragColor = vec4(0.7, 0.2, 0.5, 1.0);
    //FragColor = vec4(texColor.x, texColor.y, texColor.z, 1.0);

    //vec4 testFinalColor = vec4(1.0, 0.0, 1.0, 1.0);

    /*
    vec4 testColor = vec4(u_circleColor[mouseIndex].x, u_circleColor[mouseIndex].y, u_circleColor[mouseIndex].z, 1.0);
    */

    vec2 pixelCoords = (texCoord)*vec2(512, 512);
    float d;



    for (int i = 0; i < mouseIndex; i++)
    {
        vec4 circColor = vec4(u_circleColor[i].x, u_circleColor[i].y, u_circleColor[i].z, 1.0);

        d = sdfCircle(pixelCoords, 10.0, -mouseY[i] * 512.0, -mouseX[i] * 512.0);
        finalColor = mix(circColor, finalColor, step(0.0, d));
    }

    FragColor = finalColor;
    //FragColor = testFinalColor;
}