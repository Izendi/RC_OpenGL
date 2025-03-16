#version 430 core

// This is the maximum number of local invations you are allowed (1024), so you can't go above cascade level 4 with your current implementation unless you reduce the branching factor.
layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;

layout(rgba32f, binding = 6) uniform image2D imgOutput;

uniform float mouseX[100];
uniform float mouseY[100];

uniform int mouseIndex;

//Interval may as well be MAX LENGTH

//### Need to set these or nothing will work ###
uniform float lvl_4_interval;
uniform float lvl_3_interval;
uniform float lvl_2_interval;
uniform float lvl_1_interval;
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

    float angle = radians((0.17578125 + (0.3515625 * iterationID)));
    vec2 dirVec = vec2(cos(angle), sin(angle)); //This vector is already normalized by default.

    ivec2 texelCoord = ivec2(gl_GlobalInvocationID.xy);

    float rayStartDistanceFromNode = lvl_0_interval + lvl_1_interval + lvl_2_interval + lvl_3_interval;
    float xyIntervalsPerWorkgroup = 32;
    float xyOffsetPerWorkgroup = 16;

    vec2 rayOrigin = vec2((gl_WorkGroupID.x * xyIntervalsPerWorkgroup) + xyOffsetPerWorkgroup, (gl_WorkGroupID.y * xyIntervalsPerWorkgroup) + xyOffsetPerWorkgroup) + (dirVec * rayStartDistanceFromNode);

    vec2 ray = rayOrigin;// +dirVec;

    // ------

    vec4 value = vec4(0.1, 0.1, 0.1, 1.0); //Default value if ray does not hit a sphere.

    float distanceFromNearestSDF = lvl_4_interval - 0.1;

    //Remember, canvas will be 512 by 512 in this test

    //ray equation = O + Pt

    float radius = 20.0;

    for (int i = 0; i < 10; i++)
    {
        
        if (distanceFromNearestSDF > lvl_0_interval)
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


