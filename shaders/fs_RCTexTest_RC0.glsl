#version 430 core

in vec2 texCoord;

out vec4 FragColor;

uniform vec4 ourColor;
//uniform sampler2D u_tex_2;
uniform sampler2D u_tex_rc0;

//The below is a method of getting the texture from textue unit 0 without manually having to send it in yourself.
//layout(binding = 0) uniform sampler2D colortexture;

void main()
{
    vec4 texColor = texture(u_tex_rc0, texCoord);
    //FragColor = vec4(0.7, 0.2, 0.5, 1.0);
    FragColor = vec4(texColor.x, texColor.y, texColor.z, 1.0);

    //FragColor = vec4(0.0, 0.0, 0.8, 1.0);
}