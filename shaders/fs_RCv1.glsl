#version 330 core

in vec2 texCoord;

out vec4 FragColor;

uniform vec4 ourColor;

uniform vec2 uMousePos;
uniform vec2 uResolution;
uniform float uMousePressed;
uniform float uTime;

//The below is a method of getting the texture from textue unit 0 without manually having to send it in yourself.
//layout(binding = 0) uniform sampler2D colortexture;

void main()
{
    //Convert fragments to NDC [-1.0, 1.0]:
    vec2 NDC_2d = (texCoord - 0.5) * 2.0;

    float dist = distance(texCoord, uMousePos);

    vec3 color = vec3(1.0 - dist) * uMousePressed;

    
    FragColor = vec4(color, 1.0);
}