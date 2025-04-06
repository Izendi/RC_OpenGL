#version 430 core

// This is the maximum number of local invations you are allowed (1024), so you can't go above cascade level 4 with your current implementation unless you reduce the branching factor.
layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;

layout(rgba32f, binding = 7) uniform image2D imgOutput;

uniform float mouseX[50];
uniform float mouseY[50];
uniform vec3 u_circleColor[50];

uniform int mouseIndex;

//### Need to set these or nothing will work ###
uniform float lvl_4_interval;
uniform float lvl_3_interval;
uniform float lvl_2_interval;
uniform float lvl_1_interval;
uniform float lvl_0_interval;

float sdfCircle(vec2 p, vec2 circelPos, float radius)
{
    return length(p - circelPos) - radius;
}

void main()
{
    //We start at the top left and go row by row
    uint iterationID = (gl_LocalInvocationID.x) + gl_LocalInvocationID.y * gl_WorkGroupSize.x;


    //We have 1024 rays per probe. 360/1024 = 0.3515625 degrees per ray.
    //0.3515625 / 2 = 0.17578125

    float angle = radians((0.17578125 + (0.3515625 * iterationID)));
    vec2 dirVec = vec2(cos(angle), sin(angle)); //This vector is already normalized by default.

    ivec2 texelCoord = ivec2(gl_GlobalInvocationID.xy);

    float rayStartDistanceFromNode = lvl_0_interval + lvl_1_interval + lvl_2_interval + lvl_3_interval;
    float xyIntervalsPerWorkgroup = 32.0;
    float xyOffsetPerWorkgroup = 16.0;

    vec2 rayOrigin = vec2((gl_WorkGroupID.x * xyIntervalsPerWorkgroup) + xyOffsetPerWorkgroup, (gl_WorkGroupID.y * xyIntervalsPerWorkgroup) + xyOffsetPerWorkgroup) + (dirVec * rayStartDistanceFromNode);

    vec2 ray = rayOrigin;// +dirVec;

    // ------

    vec4 value = vec4(0.02, 0.02, 0.02, 1.0); //Default value if ray does not hit a sphere.

    float distanceFromNearestSDF = lvl_4_interval - 0.1;
    float oldDistanceFromNearestSDF = distanceFromNearestSDF;
    int nearestIndex = 0;

    //Remember, canvas will be 512 by 512 in this test

    //ray equation = O + Pt

    float radius = 10.0;
    float totalRayTravelDistance = 0.0;

    //bool rayHitCircle = false;

    for (int i = 0; i < 10; i++)
    {

        if (distanceFromNearestSDF < 0.1)
        {
            //nearestIndex = nearestIndex - 1;
            //value = vec4(0.0, 1.0, 0.0, 1.0); //Make fragment blue if ray intersects with a sphere.
            value = vec4(u_circleColor[nearestIndex].x, u_circleColor[nearestIndex].y, u_circleColor[nearestIndex].z, 1.0);
            //value.a = 1.0;
            //rayHitCircle = true;
            break;
        }

        if (distance(ray, rayOrigin) > lvl_4_interval)
        {
            break;
        }

        for (int ii = 0; ii < mouseIndex; ii++)
        {
            vec2 circlePosition = vec2(mouseX[ii] * 512.0, mouseY[ii] * 512.0);
            float newDistance = sdfCircle(ray, circlePosition, radius);

            distanceFromNearestSDF = min(distanceFromNearestSDF, newDistance);

            if (distanceFromNearestSDF != oldDistanceFromNearestSDF)
            {
                nearestIndex = ii;
            }

            oldDistanceFromNearestSDF = distanceFromNearestSDF;

        }

        ray = ray + dirVec * distanceFromNearestSDF;

    }

    /*
    bool isEvenWrkspce = ((gl_WorkGroupID.x + gl_WorkGroupID.y) % 2 == 0);
    bool isOddWrkspce = ((gl_WorkGroupID.x + gl_WorkGroupID.y) % 2 != 0);

    if (!rayHitCircle)
    {
        if (isEvenWrkspce)
        {
            value = vec4(0.0, 0.0, 0.0, 1.0);
        }
        else
        {
            value = vec4(0.0, 0.0, 0.4, 1.0);
        }
    }
    */


    //value = vec4(0.5, 0.0, 1.0, 1.0);
    imageStore(imgOutput, texelCoord, value);
}


