#version 330 core
layout(location = 0) in vec3 aPos;
layout(location = 1) in vec2 aTexCoord;

out vec2 texCoord;

void main()
{
    gl_Position = vec4(aPos, 1.0);

    texCoord = aTexCoord;
    //ourColor = vec3(0.5, 0.0, 0.0);
}