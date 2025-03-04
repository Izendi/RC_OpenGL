#version 430 core

in vec2 texCoord;

out vec4 FragColor;

uniform vec4 ourColor;
uniform sampler2D u_tex_3;
uniform sampler2D u_tex_4;

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

    ivec2 lvl1_texSize = textureSize(u_tex_4, 0);
    int num_x_lvl_1_probes = lvl1_texSize.x / 4;
    int num_y_lvl_1_probes = lvl1_texSize.y / 4;

    ivec2 BotLeft_currentProbeID = ivec2(screenCoord.x / (texSize.x / num_x_lvl_0_probes), screenCoord.y / (texSize.y / num_y_lvl_0_probes));
    ivec2 lvl1_BotLeft_currentProbeID = ivec2(screenCoord.x / (lvl1_texSize.x / num_x_lvl_1_probes), screenCoord.y / (lvl1_texSize.y / num_y_lvl_1_probes));

    //Get the texture coordinates to sample
    ivec2 NW_R0_lvl0 = ivec2(BotLeft_currentProbeID.x * 2, BotLeft_currentProbeID.y * 2);
    ivec2 NW_R1_lvl0 = ivec2(BotLeft_currentProbeID.x * 2 + 2, BotLeft_currentProbeID.y * 2);
    ivec2 NW_R2_lvl0 = ivec2(BotLeft_currentProbeID.x * 2, BotLeft_currentProbeID.y * 2 + 2);
    ivec2 NW_R3_lvl0 = ivec2(BotLeft_currentProbeID.x * 2 + 2, BotLeft_currentProbeID.y * 2 + 2);
               
    ivec2 NE_R0_lvl0 = ivec2(BotLeft_currentProbeID.x * 2 + 1, BotLeft_currentProbeID.y * 2);
    ivec2 NE_R1_lvl0 = ivec2(BotLeft_currentProbeID.x * 2 + 3, BotLeft_currentProbeID.y * 2);
    ivec2 NE_R2_lvl0 = ivec2(BotLeft_currentProbeID.x * 2 + 1, BotLeft_currentProbeID.y * 2 + 2);
    ivec2 NE_R3_lvl0 = ivec2(BotLeft_currentProbeID.x * 2 + 3, BotLeft_currentProbeID.y * 2 + 2);
               
    ivec2 SE_R0_lvl0 = ivec2(BotLeft_currentProbeID.x * 2 + 1, BotLeft_currentProbeID.y * 2 + 1);
    ivec2 SE_R1_lvl0 = ivec2(BotLeft_currentProbeID.x * 2 + 3, BotLeft_currentProbeID.y * 2 + 1);
    ivec2 SE_R2_lvl0 = ivec2(BotLeft_currentProbeID.x * 2 + 1, BotLeft_currentProbeID.y * 2 + 3);
    ivec2 SE_R3_lvl0 = ivec2(BotLeft_currentProbeID.x * 2 + 3, BotLeft_currentProbeID.y * 2 + 3);
               
    ivec2 SW_R0_lvl0 = ivec2(BotLeft_currentProbeID.x * 2, BotLeft_currentProbeID.y * 2 + 1);
    ivec2 SW_R1_lvl0 = ivec2(BotLeft_currentProbeID.x * 2 + 2, BotLeft_currentProbeID.y * 2 + 1);
    ivec2 SW_R2_lvl0 = ivec2(BotLeft_currentProbeID.x * 2, BotLeft_currentProbeID.y * 2 + 3);
    ivec2 SW_R3_lvl0 = ivec2(BotLeft_currentProbeID.x * 2 + 2, BotLeft_currentProbeID.y * 2 + 3);

    //Use the gathered tex coordinates to get a color value
    vec4 NW_0_color = texelFetch(u_tex_3, NW_R0_lvl0, 0);
    vec4 NW_1_color = texelFetch(u_tex_3, NW_R1_lvl0, 0);
    vec4 NW_2_color = texelFetch(u_tex_3, NW_R2_lvl0, 0);
    vec4 NW_3_color = texelFetch(u_tex_3, NW_R3_lvl0, 0);
                                       
    vec4 NE_0_color = texelFetch(u_tex_3, NE_R0_lvl0, 0);
    vec4 NE_1_color = texelFetch(u_tex_3, NE_R1_lvl0, 0);
    vec4 NE_2_color = texelFetch(u_tex_3, NE_R2_lvl0, 0);
    vec4 NE_3_color = texelFetch(u_tex_3, NE_R3_lvl0, 0);
                                       
    vec4 SE_0_color = texelFetch(u_tex_3, SE_R0_lvl0, 0);
    vec4 SE_1_color = texelFetch(u_tex_3, SE_R1_lvl0, 0);
    vec4 SE_2_color = texelFetch(u_tex_3, SE_R2_lvl0, 0);
    vec4 SE_3_color = texelFetch(u_tex_3, SE_R3_lvl0, 0);
                                       
    vec4 SW_0_color = texelFetch(u_tex_3, SW_R0_lvl0, 0);
    vec4 SW_1_color = texelFetch(u_tex_3, SW_R1_lvl0, 0);
    vec4 SW_2_color = texelFetch(u_tex_3, SW_R2_lvl0, 0);
    vec4 SW_3_color = texelFetch(u_tex_3, SW_R3_lvl0, 0);

    //Combine the color values for the 4 probes (Ideally, this should be combined with the upper layers first)
    vec4 probe_0_color = (NW_0_color + NE_0_color + SE_0_color + SW_0_color) * 0.25;
    vec4 probe_1_color = (NW_1_color + NE_1_color + SE_1_color + SW_1_color) * 0.25;
    vec4 probe_2_color = (NW_2_color + NE_2_color + SE_2_color + SW_2_color) * 0.25;
    vec4 probe_3_color = (NW_3_color + NE_3_color + SE_3_color + SW_3_color) * 0.25;

    //Find the biliear interpolation weights for x and y dimensions;

    int no_fragments_per_probe_x = screenRes.x / num_x_lvl_0_probes;
    int no_fragments_per_probe_y = screenRes.y / num_y_lvl_0_probes;

    float x_weight = float(gl_FragCoord.x) - float(BotLeft_currentProbeID.x * no_fragments_per_probe_x);
    float y_weight = float(gl_FragCoord.y) - float(BotLeft_currentProbeID.y * no_fragments_per_probe_y);

    vec4 bot_x_lerp_color = mix(probe_0_color, probe_1_color, x_weight);
    vec4 top_x_lerp_color = mix(probe_2_color, probe_3_color, x_weight);

    vec4 final_lerp_color = mix(bot_x_lerp_color, top_x_lerp_color, y_weight);


    // ### CASCADE LEVEL 1 - START -------------------------------------

    //Get the texture coordinates to sample the color from:


    // If we are outside the bilinear interpolation range for these probes (near the edges), then we will only sample the nearest probe for simplicity
    //          [### Look at fixing this later ###]
    if (lvl1_BotLeft_currentProbeID.x == 0 || lvl1_BotLeft_currentProbeID.y == 0)
    {
        //### Need to write the edge case here ###
    }
    else
    {
        vec4 lv1_p0_colors[16];
        vec4 lv1_p1_colors[16];
        vec4 lv1_p2_colors[16];
        vec4 lv1_p3_colors[16];

        //Get the texture coordinates to sample
        ivec2 currentProbe_botLeft = ivec2(lvl1_BotLeft_currentProbeID.x * 4, lvl1_BotLeft_currentProbeID.y * 4);

        vec4 colors[4];
        int index = 0;

        // Bottom Left
        for (int i = 0; i < 4; i++)
        {
            for (int ii = 0; ii < 4; ii++)
            {
                //Coordinates to fetch data:
                ivec2 texelCoord_lvl1 = ivec2(currentProbe_botLeft.x * 4 + ii, currentProbe_botLeft.y * 4 + i);

                //Retrive data from texture and store in color array:
                lv1_p0_colors[index] = texelFetch(u_tex_4, texelCoord_lvl1, 0);

                index = index + 1;
            }
        }

        index = 0;

        // Bottom Right
        for (int i = 0; i < 4; i++)
        {
            for (int ii = 0; ii < 4; ii++)
            {
                //Coordinates to fetch data:
                ivec2 texelCoord_lvl1 = ivec2((currentProbe_botLeft.x + 1) * 4 + ii, currentProbe_botLeft.y * 4 + i);

                //Retrive data from texture and store in color array:
                lv1_p1_colors[index] = texelFetch(u_tex_4, texelCoord_lvl1, 0);

                index = index + 1;
            }
        }

        index = 0;

        // Top Left
        for (int i = 0; i < 4; i++)
        {
            for (int ii = 0; ii < 4; ii++)
            {
                //Coordinates to fetch data:
                ivec2 texelCoord_lvl1 = ivec2(currentProbe_botLeft.x * 5 + ii, (currentProbe_botLeft.y+1) * 4 + i);

                //Retrive data from texture and store in color array:
                lv1_p2_colors[index] = texelFetch(u_tex_4, texelCoord_lvl1, 0);

                index = index + 1;
            }
        }

        index = 0;

        // Top Right
        for (int i = 0; i < 4; i++)
        {
            for (int ii = 0; ii < 4; ii++)
            {
                //Coordinates to fetch data:
                ivec2 texelCoord_lvl1 = ivec2((currentProbe_botLeft.x + 1) * 5 + ii, (currentProbe_botLeft.y + 1) * 4 + i);

                //Retrive data from texture and store in color array:
                lv1_p3_colors[index] = texelFetch(u_tex_4, texelCoord_lvl1, 0);

                index = index + 1;
            }
        }

    }

    // Now we need to average the colors from each quadrant and store the averaged result:

    vec4 lv1_p0_avg_colors[4];
    vec4 lv1_p1_avg_colors[4];
    vec4 lv1_p2_avg_colors[4];
    vec4 lv1_p3_avg_colors[4];

    //# Technically this should be done by every 

    for (int i = 0; i < 4; i++)
    {
        lv1_p0_avg_colors[i] = (lv1_p0_colors[i * 4] + lv1_p0_colors[i * 4 + 1] + lv1_p0_colors[i * 4 + 2] + lv1_p0_colors[i * 4 + 3]) / 4.0;
        lv1_p1_avg_colors[i] = (lv1_p1_colors[i * 4] + lv1_p1_colors[i * 4 + 1] + lv1_p1_colors[i * 4 + 2] + lv1_p1_colors[i * 4 + 3]) / 4.0;
        lv1_p2_avg_colors[i] = (lv1_p2_colors[i * 4] + lv1_p2_colors[i * 4 + 1] + lv1_p2_colors[i * 4 + 2] + lv1_p2_colors[i * 4 + 3]) / 4.0;
        lv1_p3_avg_colors[i] = (lv1_p3_colors[i * 4] + lv1_p3_colors[i * 4 + 1] + lv1_p3_colors[i * 4 + 2] + lv1_p3_colors[i * 4 + 3]) / 4.0;
    }
    
    //#HERE: Now we need t


    // ### CASCADE LEVEL 1 - END   -------------------------------------

    //# Testing_texel_fetch to see if it is working (it is) #
    //vec4 testColor = texelFetch(u_tex_3, currentTexelCoord, 0);
    //FragColor = vec4(testColor.x, testColor.y, testColor.z, 1.0);

    //final_lerp_color.a = 1.0;

    // -------
    
    FragColor = vec4(final_lerp_color.x, final_lerp_color.y, final_lerp_color.z, 1.0);
    
    //# Test Outputs # 
    //ivec2 currentTexelCoord = ivec2(texCoord * texSize);
    //FragColor = vec4(float(screenCoord.x / (texSize.x / num_x_lvl_0_probes)) / 100.0, 0.0, 0.0, 1.0);

    
    //vec4 texColor = texture(u_tex_3, texCoord);
    //FragColor = vec4(texColor.x, texColor.y, texColor.z, 1.0);

}