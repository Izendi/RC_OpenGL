#version 430 core

// This is the maximum number of local invations you are allowed (1024), so you can't go above cascade level 4 with your current implementation unless you reduce the branching factor.
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba32f, binding = 4) uniform image2D imgOutput;

uniform float mouseX[95];
uniform float mouseY[95];

uniform int mouseIndex;

//### Need to set these or nothing will work ###
//uniform float lvl_4_interval;
uniform float lvl_2_interval;
uniform float lvl_1_interval;
uniform float lvl_0_interval;

uniform sampler2D u_tex_rc3;

float sdfCircle(vec2 p, vec2 circelPos, float radius)
{
    return length(p - circelPos) - radius;
}

//fx is x direction weight fy is y direction weight
// if fx == 0, the point is all the way to the left
// if fy == 0, the point is all the way at the top
//
// so, if both are 0 we are at the top left, if both are 1 we are at the bottom rigt.
//
vec3 bilinearInterpolation(vec3 tl, vec3 tr, vec3 bl, vec3 br, float fx, float fy) 
{
    // Interpolate top row (left to right)
    vec3 top = mix(tl, tr, fx);
    // Interpolate bottom row (left to right)
    vec3 bottom = mix(bl, br, fx);
    // Interpolate between the two rows (top to bottom)
    return mix(top, bottom, fy);
}


void main()
{
    //We start at the top left and go row by row
    uint iterationID = (gl_LocalInvocationID.x) + gl_LocalInvocationID.y * gl_WorkGroupSize.x;


    //We have 64 rays per probe. 360/64 = 5.625 degrees per ray.
    //5.625 / 2 = 2.8125

    float angle = radians((2.8125 + (5.625 * iterationID)));
    vec2 dirVec = vec2(cos(angle), sin(angle)); //This vector is already normalized by default.

    ivec2 texelCoord = ivec2(gl_GlobalInvocationID.xy);

    float rayStartDistanceFromNode = lvl_0_interval + lvl_1_interval;
    float xyIntervalsPerWorkgroup = 8.0;
    float xyOffsetPerWorkgroup = 4.0;

    vec2 rayOrigin = vec2((gl_WorkGroupID.x * xyIntervalsPerWorkgroup) + xyOffsetPerWorkgroup, (gl_WorkGroupID.y * xyIntervalsPerWorkgroup) + xyOffsetPerWorkgroup) + (dirVec * rayStartDistanceFromNode);

    vec2 ray = rayOrigin;// +dirVec;

    // ------

    vec4 value = vec4(0.1, 0.1, 0.1, 1.0); //Default value if ray does not hit a sphere.

    float distanceFromNearestSDF = lvl_2_interval - 0.1;

    //Remember, canvas will be 512 by 512 in this test

    //ray equation = O + Pt

    float radius = 20.0;
    float totalRayTravelDistance = 0.0;

    for (int i = 0; i < 10; i++)
    {

        if (distanceFromNearestSDF < 0.1)
        {
            value = vec4(0.0, 1.0, 0.0, 1.0); //Make fragment blue if ray intersects with a sphere.

            break;
        }

        if (distance(ray, rayOrigin) > lvl_2_interval)
        {
            break;
        }

        for (int ii = 0; ii < mouseIndex; ii++)
        {
            vec2 circlePosition = vec2(mouseX[ii] * 512.0, mouseY[ii] * 512.0);
            float newDistance = sdfCircle(ray, circlePosition, radius);

            distanceFromNearestSDF = min(distanceFromNearestSDF, newDistance);
        }

        ray = ray + dirVec * distanceFromNearestSDF;

    }

    //### We need to marge the color here with the relvant color from the higher cascasde level

    //Find the 4 nearest probes in level N+1 to this position

    //find the 4 colors from each of 4 relative rays to the current ray angle then merge then average the 4 colors for each  

    vec4 TL_color_0;
    vec4 TL_color_1;
    vec4 TL_color_2;
    vec4 TL_color_3;

    vec4 avg_TL;

    vec4 TR_color_0;
    vec4 TR_color_1;
    vec4 TR_color_2;
    vec4 TR_color_3;

    vec4 avg_TR;

    vec4 BL_color_0;
    vec4 BL_color_1;
    vec4 BL_color_2;
    vec4 BL_color_3;

    vec4 avg_BL;

    vec4 BR_color_0;
    vec4 BR_color_1;
    vec4 BR_color_2;
    vec4 BR_color_3;

    vec4 avg_BR;


    // Perform bilinear interpolation on the 4 colors

    // Average their color values into a single vec4 value and combine it with the color value on this level.


    // Store final combines value in the rc_level 2 texture file:

    //value = vec4(0.5, 0.0, 1.0, 1.0);
    imageStore(imgOutput, texelCoord, value);
}


