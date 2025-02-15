#version 430 core

in vec2 texCoord;

out vec4 FragColor;

uniform vec4 ourColor;
uniform sampler2D u_tex_0;

uniform float mouseX[500];
uniform float mouseY[500];

uniform int mouseIndex;

vec3 BLACK = vec3(0.0, 0.0, 0.0);
vec3 WHITE = vec3(1.0, 1.0, 1.0);
vec3 GREY = vec3(0.6, 0.6, 0.6);

vec3 RED = vec3(0.9, 0.21, 0.21);

float inverseLerp(float v, float minValue, float maxValue) 
{
    return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) 
{
    float t = inverseLerp(v, inMin, inMax);
    return mix(outMin, outMax, t);
}

vec3 BackgroundColor()
{
    float distFromCenter = length(abs(texCoord - 0.5));

    float vignette = 1.0 - distFromCenter;

    vignette = smoothstep(0.0, 0.7, vignette);
    vignette = remap(vignette, 0.0, 1.0, 0.3, 1.0);

    return vec3(vignette);
}

vec3 drawGrid(vec3 color, vec3 lineColor, float cellSpacing, float lineWidth)
{
    vec2 resolution = vec2(800, 600);
    vec2 center = texCoord - 0.5;
    vec2 cells = abs(fract(center * resolution / cellSpacing) - 0.5);
    float distToEdge = (0.5 - max(cells.x, cells.y)) * cellSpacing;
    float lines = smoothstep(0.0, lineWidth, distToEdge);

    color = mix(lineColor, color, lines);

    return color;
}

float sdfCircle(vec2 fragPos, float r, float offset_y, float offset_x)
{
    fragPos.x = fragPos.x + offset_x;
    fragPos.y = fragPos.y + offset_y;
    return length(fragPos) - r;
}

void main()
{

    vec2 pixelCoords = (texCoord) * vec2(800, 600);

    //vec4 texColor = texture(u_tex_0, texCoord);
    //FragColor = vec4(0.7, 0.2, 0.5, 1.0);

    float x = step((abs(mod(texCoord.x, 0.025))), 0.004); // if value is less than 0.004 return 1
    float y = step((abs(mod(texCoord.y, 0.025))), 0.004);

    float isBlack = max(x, y);

    vec4 black = vec4(BLACK, 1.0);
    vec4 white = vec4(WHITE, 1.0);

    vec3 finalColor = BackgroundColor();
    finalColor = drawGrid(finalColor, GREY, 10.0, 1.0);
    finalColor = drawGrid(finalColor, BLACK, 100.0, 1.5);

    //float d = sdfCircle(pixelCoords, 200.0, -20.0, -300.0);
    //finalColor = mix(RED, finalColor, step(0.0, d));

    float d;

    for (int i = 0; i < mouseIndex; i++)
    {
        d = sdfCircle(pixelCoords, 20.0, -mouseY[i] * 600.0, -mouseX[i] * 800.0);
        finalColor = mix(RED, finalColor, step(0.0, d));
    }

    //finalColor = mix(RED, finalColor, step(0.0, d));

    FragColor = vec4(finalColor, 1.0);
}