//
//  shader.metal
//  CityNetwork
//
//  Created by CodeLovers2 on 4/28/17.
//  Copyright © 2017 Anh Nguyen. All rights reserved.
//

#include <metal_stdlib>
#include "predefine.h"

using namespace metal;

vertex TextureMappingVertex mapTextureHudson(unsigned int vertex_id[[ vertex_id ]]) {
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

fragment half4 displayTextureHudson(TextureMappingVertex mappingVertex[[ stage_in ]],
                              texture2d<float, access::sample> texture[[ texture(0) ]],
                              texture2d<float, access::sample> filterTexture[[ texture(1) ]]) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    float brightness = 1.2;
    float constrast = 1.1;
    float saturation = 0.9;
    float3 color = texture.sample(s, mappingVertex.textureCoordinate).rgb;
    float3 filterColor = filterTexture.sample(s, mappingVertex.textureCoordinate).rgb;
    float3 colorAdjustedBCS = adjustBCS(color, brightness, constrast, saturation);
    float3 colorAddedBlue = float3(colorAdjustedBCS.r, colorAdjustedBCS.g, colorAdjustedBCS.b);
    float3 blendedColor = mix(colorAddedBlue, ovelayBlender(colorAddedBlue, filterColor), 0.4);
    return half4(blendedColor.r, blendedColor.g, blendedColor.b, 1.0);
}

