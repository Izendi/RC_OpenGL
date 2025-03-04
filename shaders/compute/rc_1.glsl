#version 430 core

layout(local_size_x = 4, local_size_y = 4, local_size_z = 1) in;

layout(rgba32f, binding = 3) uniform image2D imgOutput;

uniform float mouseX[100];
uniform float mouseY[100];

uniform int mouseIndex;

uniform float lvl_0_interval;

/*
vec2 rotateVecAntiClockwise(vec2 v, float radians)
{
    float c = cos(radians);
    float s = sin(radians);

    return vec2
    (
        c * v.x - s * v.y,
        s * v.x + c * v.y
    );
}
*/

float sdfCircle(vec2 p, vec2 circelPos, float radius)
{
    return length(p - circelPos) - radius;
}


void main()
{

    uint iterationID = (gl_LocalInvocationID.x) + gl_LocalInvocationID.y * gl_WorkGroupSize.x; //This means we start at the top left and go row by row

    float angle = radians((12.5 + (22.5 * iterationID)));
    vec2 dirVec = vec2(cos(angle), sin(angle)); //This vector is already normalized by default.

    ivec2 texelCoord = ivec2(gl_GlobalInvocationID.xy);

    vec2 rayOrigin = vec2((gl_WorkGroupID.x * 4) + 2, (gl_WorkGroupID.y * 4) + 2) + (dirVec * lvl_0_interval); //We need to use "+ (dirVec * lvl_0_interval)" because the next cascade level up starts where the previous ray ends (its max length)


    vec2 ray = rayOrigin; 

    // ------

    vec4 value = vec4(0.1, 0.1, 0.1, 1.0); //Default value if ray does not hit a sphere.

    float distanceFromNearestSDF = (lvl_0_interval * 4.0) - 0.1;

    //Remember, canvas will be 512 by 512 in this test

    //ray equation = O + Pt

    float radius = 20.0;

    for (int i = 0; i < 10; i++)
    {
        
        if (distanceFromNearestSDF > (lvl_0_interval * 4.0))
        {
            break;
        }
        

        if (distanceFromNearestSDF < 0.1)
        {
            value = vec4(0.0, 0.0, 1.0, 1.0); //Make fragment red if ray intersects with a sphere.
            break;
        }

        for (int ii = 0; ii < mouseIndex; ii++)
        {
            vec2 circlePosition = vec2(mouseX[ii]*512.0, mouseY[ii]*512.0);
            float newDistance = sdfCircle(ray, circlePosition, radius);
            
            distanceFromNearestSDF = min(distanceFromNearestSDF, newDistance);
        }

        ray = ray + dirVec * distanceFromNearestSDF;
    }


    imageStore(imgOutput, texelCoord, value);
}


