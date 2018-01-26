//
//  toaster.metal
//  MetalImageFilter
//
//  Created by CodeLovers2 on 5/5/17.
//  Copyright © 2017 Anh Nguyen. All rights reserved.
//

#include <metal_stdlib>
#include "predefine.h"

using namespace metal;

float3 ovelayBlender2(float3 color, float3 filterColor){
    float3 filterResult;
    filterResult = 1.0 - (1.0 - (2.0 *(filterColor - 0.5)))*(1.0 - color);
    return filterResult;
}

vertex TextureMappingVertex mapTextureToaster(unsigned int vertex_id[[ vertex_id ]]) {
    float4x4 renderedCoordinates = float4x4(float4(-1.0, -1.0, 0.0, 1.0),
                                            float4(1.0, -1.0, 0.0, 1.0),
                                            float4(-1.0, 1.0, 0.0, 1.0),
                                            float4(1.0, 1.0, 0.0, 1.0));
    float4x2 textureCoordinates = float4x2(float2(0.0, 1.0),
                                           float2(1.0, 1.0),
                                           float2(0.0, 0.0),
                                           float2(1.0, 0.0));
    TextureMappingVertex outputVertex;
    outputVertex.renderedCoordinate = renderedCoordinates[vertex_id];
    outputVertex.textureCoordinate = textureCoordinates[vertex_id];
    
    return outputVertex;
}

fragment half4 displayTextureToaster(TextureMappingVertex mappingVertex[[ stage_in ]],
                              texture2d<float, access::sample> texture[[ texture(0) ]],
                              texture2d<float, access::sample> filterTexture[[ texture(1) ]]) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    float brightness = 1.0;
    float constrast = 1.0;
    float saturation = 1.0;
    float3 color = texture.sample(s, mappingVertex.textureCoordinate).bgr;
    float3 filterColor = filterTexture.sample(s, mappingVertex.textureCoordinate).bgr;
    float3 colorAdjustedBCS = adjustBCS(color, brightness, constrast, saturation);
    float3 colorAdjustedRB = float3(colorAdjustedBCS.r*1.3, colorAdjustedBCS.g, colorAdjustedBCS.b*0.9);
    float3 blendedColor = mix(colorAdjustedRB, ovelayBlender2(colorAdjustedRB, filterColor), 0.55);
    return half4(blendedColor.r, blendedColor.g, blendedColor.b, 1.0);
}

