#version 430 core

layout(local_size_x = 4, local_size_y = 4, local_size_z = 1) in;

layout(rgba32f, binding = 3) uniform image2D imgOutput;

uniform float mouseX[20];
uniform float mouseY[20];
uniform vec3 u_circleColor[20];

uniform int mouseIndex;

uniform float lvl_0_interval;
uniform float lvl_1_interval;

uniform sampler2D u_tex_rc2_v2;

//uniform vec4 u_circleColor;

// There are 32 by 32 probes each taking up 16 by 16 texel slots, therefore, start offset is 16/2 = 8
const float N_plus_1_ProbeStartOffset = 4.0;

const float N_plus_1_ProbeSpacing = 8.0;

const float N_plus_1_MaxNumberOfProbes = 64; //In one dimension

const float N_Offset = 2.0;

const float N_ProbeSpacing = 4.0;

float sdfCircle(vec2 p, vec2 circelPos, float radius)
{
    return length(p - circelPos) - radius;
}

float get_x_N_plus_1_ClosestLeftProbe()
{
    float localInvocation_x = float(gl_WorkGroupID.x);

    float value = ((localInvocation_x * N_ProbeSpacing + N_Offset)) / N_plus_1_ProbeSpacing;

    return floor(value);
}

float get_y_N_plus_1_ClosestLeftProbe()
{
    float localInvocation_y = float(gl_WorkGroupID.y);

    float value = ((localInvocation_y * N_ProbeSpacing + N_Offset)) / N_plus_1_ProbeSpacing;

    return floor(value);
}

ivec2 get_TL_NearestProbe()
{
    float TL_X = get_x_N_plus_1_ClosestLeftProbe();
    float TL_Y = get_y_N_plus_1_ClosestLeftProbe();

    if (TL_X < 0.0)
    {
        // TL probe is outside the screen to the left and has not been calculated.
        //      As such, it will return -1 to indicate this (already done thanks to floor in called functions)

        //For now just uses the top left probe as if it is closest
        TL_X = 0.0;

    }

    if (TL_X > (N_plus_1_MaxNumberOfProbes - 1.0))
    {
        // TL probe is outside the screen to the right and has not been calculated
        TL_X = N_plus_1_MaxNumberOfProbes - 1.0;

    }

    if (TL_Y < 0.0)
    {
        // TL probe is outside the screen (above the screen if 0,0 is the top left or below if it is bottom left).
        //      As such, it will return -1 to indicate this (already done thanks to floor in called functions)
        TL_Y = 0.0;

    }

    if (TL_Y > (N_plus_1_MaxNumberOfProbes - 1.0))
    {
        // TL probe is outside the screen to the right and has not been calculated
        TL_Y = N_plus_1_MaxNumberOfProbes - 1.0;
    }

    return ivec2(TL_X, TL_Y);

}

vec4 averageColorValuesAtNplus1_glInvocation(uvec3 g_TLP, uvec3 g_TRP, uvec3 g_BLP, uvec3 g_BRP)
{
    ivec2 texelCoord_0 = ivec2(g_TLP.xy);
    ivec2 texelCoord_1 = ivec2(g_TRP.xy);
    ivec2 texelCoord_2 = ivec2(g_BLP.xy);
    ivec2 texelCoord_3 = ivec2(g_BRP.xy);

    vec4 color_0 = texelFetch(u_tex_rc2_v2, texelCoord_0, 0);
    vec4 color_1 = texelFetch(u_tex_rc2_v2, texelCoord_1, 0);
    vec4 color_2 = texelFetch(u_tex_rc2_v2, texelCoord_2, 0);
    vec4 color_3 = texelFetch(u_tex_rc2_v2, texelCoord_3, 0);

    vec4 avgColor = ((color_0 + color_1 + color_2 + color_3) / 4.0);// / 16.0;
    avgColor.a = 1.0;

    return avgColor;

}

//fx is x direction weight fy is y direction weight
// if fx == 0, the point is all the way to the left
// if fy == 0, the point is all the way at the top
//
// so, if both are 0 we are at the top left, if both are 1 we are at the bottom rigt.
//
vec4 bilinearInterpolation(vec4 tl, vec4 tr, vec4 bl, vec4 br, float fx, float fy)
{
    // Interpolate top row (left to right)
    vec4 top = mix(tl, tr, fx);
    // Interpolate bottom row (left to right)
    vec4 bottom = mix(bl, br, fx);
    // Interpolate between the two rows (top to bottom)
    return mix(top, bottom, fy);
}

vec4 get_N_plus_1_4RayProbeAveragedColorValue(uint thisIterationID)
{
    //To get the 4 color values we need to find the 4 global invocation IDs that correspond to those colors and sample them from the texture.
    //  Then we need average the 4 colors values.

    // Find the 4 global invocation IDs:
    //      globalInvocationID for N+1 = N+1 WorkGroupID * N+1 WorkGroupSize * localInvocation   (NOTE: all of htese are vec3's)

    //TLP == Top Left Probe
    ivec2 TLP_workGroupID_xy = get_TL_NearestProbe();

    uvec3 TLP_workGroupID_xyz = uvec3(uint(TLP_workGroupID_xy.x), uint(TLP_workGroupID_xy.y), 1);
    uvec3 TRP_workGroupID_xyz = uvec3(uint(TLP_workGroupID_xy.x + 1), uint(TLP_workGroupID_xy.y), 1);
    uvec3 BLP_workGroupID_xyz = uvec3(uint(TLP_workGroupID_xy.x), uint(TLP_workGroupID_xy.y + 1), 1);
    uvec3 BRP_workGroupID_xyz = uvec3(uint(TLP_workGroupID_xy.x + 1), uint(TLP_workGroupID_xy.y + 1), 1);

    // ###

    /*
    ivec2 TL_probeSamplePoint = ivec2((TLP_workGroupID_xyz.x * N_plus_1_ProbeSpacing) + N_plus_1_ProbeStartOffset, (TLP_workGroupID_xyz.y * N_plus_1_ProbeSpacing) + N_plus_1_ProbeStartOffset);
    ivec2 TR_probeSamplePoint = ivec2((TRP_workGroupID_xyz.x * N_plus_1_ProbeSpacing) + N_plus_1_ProbeStartOffset, (TRP_workGroupID_xyz.y * N_plus_1_ProbeSpacing) + N_plus_1_ProbeStartOffset);
    ivec2 BL_probeSamplePoint = ivec2((BLP_workGroupID_xyz.x * N_plus_1_ProbeSpacing) + N_plus_1_ProbeStartOffset, (BLP_workGroupID_xyz.y * N_plus_1_ProbeSpacing) + N_plus_1_ProbeStartOffset);
    ivec2 BR_probeSamplePoint = ivec2((BRP_workGroupID_xyz.x * N_plus_1_ProbeSpacing) + N_plus_1_ProbeStartOffset, (BRP_workGroupID_xyz.y * N_plus_1_ProbeSpacing) + N_plus_1_ProbeStartOffset);

    vec4 color_TL = texelFetch(u_tex_rc2_v2, TL_probeSamplePoint, 0);
    vec4 color_TR = texelFetch(u_tex_rc2_v2, TR_probeSamplePoint, 0);
    vec4 color_BL = texelFetch(u_tex_rc2_v2, BL_probeSamplePoint, 0);
    vec4 color_BR = texelFetch(u_tex_rc2_v2, BR_probeSamplePoint, 0);

    //vec4 tempFinalCol = (color_TL + color_TR + color_BL + color_BR) / 4.0;
    //tempFinalCol.a = 1.0;

    //tempFinalCol.x = 0.0;
    //Something about the bilinear interpolation is wrong...
    float fx_alt = (float((float(gl_WorkGroupID.x) * 8) + 4) - float((TLP_workGroupID_xyz.x * 16 + 8))) / 16;
    float fy_alt = (float((float(gl_WorkGroupID.y) * 8) + 4) - float((TLP_workGroupID_xyz.y * 16 + 8))) / 16; // this depends on wether y goes up or down along the y axis from top to bottom (current assuming UP from top to bottom)

    vec4 biLinInterpolatedFinalColor_alt = bilinearInterpolation(color_TL, color_TR, color_BL, color_BR, fx_alt, fy_alt);

    // @@@ Now that we know this kinda works, we need to see what effect adding in weightin and using bilinear filtering will ve <- HERE

    //return biLinInterpolatedFinalColor_alt;

    //vec4 myVec = vec4(float(TLP_workGroupID_xy.y) / float(N_plus_1_MaxNumberOfProbes), 0.0, 0.0, 1.0);

    //return vec4(fy_alt, 0.0, 0.0, 1.0);
    return biLinInterpolatedFinalColor_alt;
    //return myVec;
    */

    // ###

    uvec3 workGroupSize_xyz = uvec3(8, 8, 1);

    // to find the localInvocation, we first need to find the interation ID and use that to reverse engineer the local invocation:

    // we can find the iteration ID by using the current iteration ID and finding the relvant angles in the above cascade level.


    // the 4 that we need to convert to global interation IDs, one for each of the 4 rays
    float iterID_0 = thisIterationID * 4;
    float iterID_0_y = floor(iterID_0 / float(workGroupSize_xyz.y));
    float iterID_0_x = iterID_0 - (iterID_0_y * 8);

    // N+1 GlobalInvocationID = WorkGroupID * workGroupSize * localInvocationID

    float iterID_1 = iterID_0 + 1;
    float iterID_1_y = floor(iterID_1 / float(workGroupSize_xyz.y));
    float iterID_1_x = iterID_1 - (iterID_1_y * 8);

    float iterID_2 = iterID_0 + 2;
    float iterID_2_y = floor(iterID_2 / float(workGroupSize_xyz.y));
    float iterID_2_x = iterID_2 - (iterID_2_y * 8);

    float iterID_3 = iterID_0 + 3;
    float iterID_3_y = floor(iterID_3 / float(workGroupSize_xyz.y));
    float iterID_3_x = iterID_3 - (iterID_3_y * 8);


    //Must be a problem somewhere here between lines 182 and 237, the rest all seems to work as expected, 
    // but my probes are sampling colors from wrong parts of N+1 texture specifically to the right of them? WHY?  <= HERE
    uvec3 g_TLP_0 = workGroupSize_xyz * TLP_workGroupID_xyz + uvec3(uint(iterID_0_x), uint(iterID_0_y), 1);
    uvec3 g_TLP_1 = workGroupSize_xyz * TLP_workGroupID_xyz + uvec3(uint(iterID_1_x), uint(iterID_1_y), 1);
    uvec3 g_TLP_2 = workGroupSize_xyz * TLP_workGroupID_xyz + uvec3(uint(iterID_2_x), uint(iterID_2_y), 1);
    uvec3 g_TLP_3 = workGroupSize_xyz * TLP_workGroupID_xyz + uvec3(uint(iterID_3_x), uint(iterID_3_y), 1);

    vec4 TLP_color = averageColorValuesAtNplus1_glInvocation(g_TLP_0, g_TLP_1, g_TLP_2, g_TLP_3);

    uvec3 g_TRP_0 = workGroupSize_xyz * TRP_workGroupID_xyz + uvec3(uint(iterID_0_x), uint(iterID_0_y), 1);
    uvec3 g_TRP_1 = workGroupSize_xyz * TRP_workGroupID_xyz + uvec3(uint(iterID_1_x), uint(iterID_1_y), 1);
    uvec3 g_TRP_2 = workGroupSize_xyz * TRP_workGroupID_xyz + uvec3(uint(iterID_2_x), uint(iterID_2_y), 1);
    uvec3 g_TRP_3 = workGroupSize_xyz * TRP_workGroupID_xyz + uvec3(uint(iterID_3_x), uint(iterID_3_y), 1);

    vec4 TRP_color = averageColorValuesAtNplus1_glInvocation(g_TRP_0, g_TRP_1, g_TRP_2, g_TRP_3);

    uvec3 g_BLP_0 = workGroupSize_xyz * BLP_workGroupID_xyz + uvec3(uint(iterID_0_x), uint(iterID_0_y), 1);
    uvec3 g_BLP_1 = workGroupSize_xyz * BLP_workGroupID_xyz + uvec3(uint(iterID_1_x), uint(iterID_1_y), 1);
    uvec3 g_BLP_2 = workGroupSize_xyz * BLP_workGroupID_xyz + uvec3(uint(iterID_2_x), uint(iterID_2_y), 1);
    uvec3 g_BLP_3 = workGroupSize_xyz * BLP_workGroupID_xyz + uvec3(uint(iterID_3_x), uint(iterID_3_y), 1);

    vec4 BLP_color = averageColorValuesAtNplus1_glInvocation(g_BLP_0, g_BLP_1, g_BLP_2, g_BLP_3);

    uvec3 g_BRP_0 = workGroupSize_xyz * BRP_workGroupID_xyz + uvec3(uint(iterID_0_x), uint(iterID_0_y), 1);
    uvec3 g_BRP_1 = workGroupSize_xyz * BRP_workGroupID_xyz + uvec3(uint(iterID_1_x), uint(iterID_1_y), 1);
    uvec3 g_BRP_2 = workGroupSize_xyz * BRP_workGroupID_xyz + uvec3(uint(iterID_2_x), uint(iterID_2_y), 1);
    uvec3 g_BRP_3 = workGroupSize_xyz * BRP_workGroupID_xyz + uvec3(uint(iterID_3_x), uint(iterID_3_y), 1);

    vec4 BRP_color = averageColorValuesAtNplus1_glInvocation(g_BRP_0, g_BRP_1, g_BRP_2, g_BRP_3);


    // Perfrom bilinear interpolation on the color values. 

    // ### The below code might work weirdly or break something at the edges due to trying to sample things that don't exsit, the current method of accounting for this on line 82 is insuficient

    //We first need to find the x and y weight values. Remember, each invocation the compute shader runs on a probe, not a fragment, each probe is a workgroup an deach workgroup ius an indicidual dispatch
    // fx = ((workgroup.x * 8.0) + 4.0) - (TLP_workGroupID_xyz.x * 16 + 8) / (TRP_workGroupID_xyz.x * 16 + 8) - (TLP_workGroupID_xyz.x * 16 + 8)
    //float fx = (float((gl_WorkGroupID.x * 8) + 4) - float((TLP_workGroupID_xyz.x * 16 + 8))) / (float(TRP_workGroupID_xyz.x * 16 + 8) - float(TLP_workGroupID_xyz.x * 16 + 8));
    //float fy = (float((gl_WorkGroupID.y * 8) + 4) - float((TLP_workGroupID_xyz.y * 16 + 8))) / (float(BLP_workGroupID_xyz.y * 16 + 8) - float(TLP_workGroupID_xyz.y * 16 + 8)); // this depends on wether y goes up or down along the y axis from top to bottom (current assuming UP from top to bottom)

    float fx = (float((gl_WorkGroupID.x * 4) + 2) - float((TLP_workGroupID_xyz.x * 8 + 4))) / 8;
    float fy = (float((gl_WorkGroupID.y * 4) + 2) - float((TLP_workGroupID_xyz.y * 8 + 4))) / 8;

    vec4 biLinInterpolatedFinalColor = bilinearInterpolation(TLP_color, TRP_color, BLP_color, BRP_color, fx, fy);

    return biLinInterpolatedFinalColor; //THIS NEEDS TO BE ADDED TO VALUE AT THE END ###
}

void main()
{

    uint iterationID = (gl_LocalInvocationID.x) + gl_LocalInvocationID.y * gl_WorkGroupSize.x; //This means we start at the top left and go row by row

    float angle = radians((11.25 + (22.5 * iterationID)));
    vec2 dirVec = vec2(cos(angle), sin(angle)); //This vector is already normalized by default.

    ivec2 texelCoord = ivec2(gl_GlobalInvocationID.xy);

    float rayStartDistanceFromNode = lvl_0_interval;
    float xyIntervalsPerWorkgroup = 4.0;
    float xyOffsetPerWorkgroup = 2.0;

    vec2 rayOrigin = vec2((gl_WorkGroupID.x * xyIntervalsPerWorkgroup) + xyOffsetPerWorkgroup, (gl_WorkGroupID.y * xyIntervalsPerWorkgroup) + xyOffsetPerWorkgroup) + (dirVec * rayStartDistanceFromNode);

    vec2 ray = rayOrigin;// +dirVec;

    // ------

    vec4 value = vec4(0.0, 0.0, 0.0, 1.0); //Default value if ray does not hit a sphere.

    float distanceFromNearestSDF = lvl_1_interval - 0.1;
    float oldDistanceFromNearestSDF = distanceFromNearestSDF;
    int nearestIndex = 0;

    //Remember, canvas will be 512 by 512 in this test

    //ray equation = O + Pt

    float radius = 6.0;
    float totalRayTravelDistance = 0.0;

    for (int i = 0; i < 10; i++)
    {

        if (distanceFromNearestSDF < 0.1)
        {
            //value = vec4(0.0, 0.0, 1.0, 1.0); //Make fragment blue if ray intersects with a sphere.
            //nearestIndex = nearestIndex;
            value = vec4(u_circleColor[nearestIndex].x, u_circleColor[nearestIndex].y, u_circleColor[nearestIndex].z, 1.0);
            break;
        }

        if (distance(ray, rayOrigin) > lvl_1_interval)
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

    //### We need to maerge the color here with the relvant color from the higher cascasde level
    vec4 NplusOneColor = get_N_plus_1_4RayProbeAveragedColorValue(iterationID);

    value = value + NplusOneColor;
    //value.a = 1.0;

    //value = vec4(0.0, 1.0, 1.0, 1.0);
    imageStore(imgOutput, texelCoord, value);
}


