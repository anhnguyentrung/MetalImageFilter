//
//  predefine.metal
//  MetalImageFilter
//
//  Created by CodeLovers2 on 5/5/17.
//  Copyright © 2017 Anh Nguyen. All rights reserved.
//

#include <metal_stdlib>
#include "predefine.h"

using namespace metal;

float3 adjustBCS(float3 color, float brightness, float constrast, float saturation) {
    float3 black = float3(0.0, 0.0, 0.0);
    float3 middle = float3(0.5, 0.5, 0.5);
    float luminance = dot(color, luminanceCoefficients);
    float3 gray = float3(luminance, luminance, luminance);
    float3 colorAdjustedBrightness = mix(black, color, brightness);
    float3 colorAdjustedConstrast = mix(middle, colorAdjustedBrightness, constrast);
    float3 colorAdjustedSaturation = mix(gray, colorAdjustedConstrast, saturation);
    return colorAdjustedSaturation;
}

float3 ovelayBlender(float3 color, float3 filterColor){
    float3 filterResult;
    float luminance = dot(filterColor, luminanceCoefficients);
    
    if(luminance < 0.5)
        filterResult = 2.0 * filterColor * color;
    else
        filterResult = 1.0 - (1.0 - (2.0 *(filterColor - 0.5)))*(1.0 - color);
    
    return filterResult;
}

float3 multiplyBlender(float3 color, float3 filterColor){
    float3 filterResult;
    float luminance = dot(filterColor, luminanceCoefficients);
    
    if(luminance < 0.5)
        filterResult = 2.0 * filterColor * color;
    else
        filterResult = color;
    
    return filterResult;
}


