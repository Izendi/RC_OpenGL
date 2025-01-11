#version 330 core

in vec2 texCoord;

out vec4 FragColor;

uniform vec4 ourColor;

//The below is a method of getting the texture from textue unit 0 without manually having to send it in yourself.
//layout(binding = 0) uniform sampler2D colortexture;

void main()
{
    FragColor = vec4(0.7, 0.2, 0.5, 1.0);
}