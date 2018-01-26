//
//  willow.metal
//  MetalImageFilter
//
//  Created by CodeLovers2 on 5/5/17.
//  Copyright © 2017 Anh Nguyen. All rights reserved.
//

#include <metal_stdlib>
#include "predefine.h"

using namespace metal;

vertex TextureMappingVertex mapTextureWillow(unsigned int vertex_id[[ vertex_id ]]) {
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

fragment half4 displayTextureWillow(TextureMappingVertex mappingVertex[[ stage_in ]],
                              texture2d<float, access::sample> texture[[ texture(0) ]],
                              texture2d<float, access::sample> filterTexture[[ texture(1) ]]) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    float3 color = texture.sample(s, mappingVertex.textureCoordinate).bgr;
    float luminance = dot(color, luminanceCoefficients);
    float3 gray = float3(luminance, luminance, luminance);
    float3 adjustedColor = adjustBCS(gray, 2.5, 1.1, 1.0);
    return half4(adjustedColor.r, adjustedColor.g, adjustedColor.b, 1.0);
}

