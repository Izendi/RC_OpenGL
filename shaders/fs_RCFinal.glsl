#version 430 core

in vec2 texCoord;

out vec4 FragColor;

uniform vec4 ourColor;
uniform sampler2D u_tex_3;

uniform ivec2 screenRes; // This is probably not needed! Since we can use gl_FragCoord variable to get screen coords in this case. But if gl_fragCoord gives problems, it may still be needed.

//The below is a method of getting the texture from textue unit 0 without manually having to send it in yourself.
//layout(binding = 0) uniform sampler2D colortexture;

void main()
{
    vec2 screenCoord = gl_FragCoord.xy;
    //#HERE You need to sample the corresponding RC data depending on the fragments position and average it with all 4 directions, 
    // each of the 4 directions should be merged and average with the above levels, just like was specified in the paper, you should be able to do
    // All of that here in this shader, assuming you have passed in the corresponding RC texture data and know the rules for where sampling should occur.

    //first retrive the texture dimesions and store them in a vec 2
    ivec2 texSize = textureSize(u_tex_3, 0);

    int num_x_lvl_0_probes = texSize.x / 2; //# maybe Subtract by 1 so that the last probe has something to ref against when it offsets down and to the right. and we don't get an array out of bounds error.
    int num_y_lvl_0_probes = texSize.y / 2;

    ivec2 BotLeft_currentProbeID = ivec2(screenCoord.x / num_x_lvl_0_probes, screenCoord.y / num_y_lvl_0_probes);

    ivec2 NW_R0_0 = ivec2(BotLeft_currentProbeID.x * 2, BotLeft_currentProbeID.y * 2);
    ivec2 NW_R1_0 = ivec2(BotLeft_currentProbeID.x * 2 + 2, BotLeft_currentProbeID.y * 2);
    ivec2 NW_R2_0 = ivec2(BotLeft_currentProbeID.x * 2, BotLeft_currentProbeID.y * 2 + 2);
    ivec2 NW_R3_0 = ivec2(BotLeft_currentProbeID.x * 2 + 2, BotLeft_currentProbeID.y * 2 + 2);

    ivec2 NE_R0_1 = ivec2(BotLeft_currentProbeID.x * 2 + 1, BotLeft_currentProbeID.y * 2);
    ivec2 NE_R1_1 = ivec2(BotLeft_currentProbeID.x * 2 + 3, BotLeft_currentProbeID.y * 2);
    ivec2 NE_R2_1 = ivec2(BotLeft_currentProbeID.x * 2 + 1, BotLeft_currentProbeID.y * 2 + 2);
    ivec2 NE_R3_1 = ivec2(BotLeft_currentProbeID.x * 2 + 3, BotLeft_currentProbeID.y * 2 + 2);

    ivec2 SE_R0_2 = ivec2(BotLeft_currentProbeID.x * 2 + 1, BotLeft_currentProbeID.y * 2 + 1);
    ivec2 SE_R1_2 = ivec2(BotLeft_currentProbeID.x * 2 + 3, BotLeft_currentProbeID.y * 2 + 1);
    ivec2 SE_R2_2 = ivec2(BotLeft_currentProbeID.x * 2 + 1, BotLeft_currentProbeID.y * 2 + 3);
    ivec2 SE_R3_2 = ivec2(BotLeft_currentProbeID.x * 2 + 3, BotLeft_currentProbeID.y * 2 + 3);

    ivec2 SW_R0_3 = ivec2(BotLeft_currentProbeID.x * 2, BotLeft_currentProbeID.y * 2 + 1);
    ivec2 SW_R1_3 = ivec2(BotLeft_currentProbeID.x * 2 + 2, BotLeft_currentProbeID.y * 2 + 1);
    ivec2 SW_R2_3 = ivec2(BotLeft_currentProbeID.x * 2, BotLeft_currentProbeID.y * 2 + 3);
    ivec2 SW_R3_3 = ivec2(BotLeft_currentProbeID.x * 2 + 2, BotLeft_currentProbeID.y * 2 + 3);

    vec4 NW_0_color = texelFetch(u_tex_3, NW_R0_0, 0);
    vec4 NW_1_color = texelFetch(u_tex_3, NW_R1_0, 0);
    vec4 NW_2_color = texelFetch(u_tex_3, NW_R2_0, 0);
    vec4 NW_3_color = texelFetch(u_tex_3, NW_R3_0, 0);

    vec4 NE_0_color = texelFetch(u_tex_3, NE_R0_1, 0);
    vec4 NE_1_color = texelFetch(u_tex_3, NE_R1_1, 0);
    vec4 NE_2_color = texelFetch(u_tex_3, NE_R2_1, 0);
    vec4 NE_3_color = texelFetch(u_tex_3, NE_R3_1, 0);

    vec4 SE_0_color = texelFetch(u_tex_3, SE_R0_2, 0);
    vec4 SE_1_color = texelFetch(u_tex_3, SE_R1_2, 0);
    vec4 SE_2_color = texelFetch(u_tex_3, SE_R2_2, 0);
    vec4 SE_3_color = texelFetch(u_tex_3, SE_R3_2, 0);

    vec4 SW_0_color = texelFetch(u_tex_3, SW_R0_3, 0);
    vec4 SW_1_color = texelFetch(u_tex_3, SW_R1_3, 0);
    vec4 SW_2_color = texelFetch(u_tex_3, SW_R2_3, 0);
    vec4 SW_3_color = texelFetch(u_tex_3, SW_R3_3, 0);

    vec4 probe_0_color = (NW_0_color + NE_0_color + SE_0_color + SW_0_color) * 0.25;
    vec4 probe_1_color = (NW_1_color + NE_1_color + SE_1_color + SW_1_color) * 0.25;
    vec4 probe_2_color = (NW_2_color + NE_2_color + SE_2_color + SW_2_color) * 0.25;
    vec4 probe_3_color = (NW_3_color + NE_3_color + SE_3_color + SW_3_color) * 0.25;

    //Find the biliear interpolation weights for x and y dimensions;

    int no_fragments_per_probe_x = screenRes.x / num_x_lvl_0_probes;
    int no_fragments_per_probe_y = screenRes.y / num_y_lvl_0_probes;

    float x_weight = gl_FragCoord.x - (BotLeft_currentProbeID.x * no_fragments_per_probe_x);
    float y_weight = gl_FragCoord.y - (BotLeft_currentProbeID.y * no_fragments_per_probe_y);

    vec4 bot_x_lerp_color = mix(probe_0_color, probe_1_color, x_weight);
    vec4 top_x_lerp_color = mix(probe_2_color, probe_3_color, x_weight);

    vec4 final_lerp_color = mix(bot_x_lerp_color, top_x_lerp_color, y_weight);

    //final_lerp_color.a = 1.0;

    // -------
    //vec4 texColor = texture(u_tex_3, texCoord);
    //FragColor = vec4(0.7, 0.2, 0.5, 1.0);
    FragColor = vec4(final_lerp_color.x, final_lerp_color.y, final_lerp_color.z, 1.0);


    //FragColor = vec4(1.0, 1.0, 0.0, 1.0);

}