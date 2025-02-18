#version 430 core

in vec2 texCoord;

out vec4 FragColor;

uniform vec4 ourColor;
uniform sampler2D u_tex_3;

//The below is a method of getting the texture from textue unit 0 without manually having to send it in yourself.
//layout(binding = 0) uniform sampler2D colortexture;

void main()
{

    //#HERE You need to sample the corresponding RC data depending on the fragments position and average it with all 4 directions, 
    // each of the 4 directions should be merged and average with the above levels, just like was specified in the paper, you should be able to do
    // All of that here in this shader, assuming you have passed in the corresponding RC texture data and know the rules for where sampling should occur.


    vec4 texColor = texture(u_tex_3, texCoord);
    //FragColor = vec4(0.7, 0.2, 0.5, 1.0);
    FragColor = vec4(texColor.x, texColor.y, texColor.z, 1.0);

}