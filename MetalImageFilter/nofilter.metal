//
//  nofilter.metal
//  MetalImageFilter
//
//  Created by CodeLovers2 on 5/8/17.
//  Copyright © 2017 Anh Nguyen. All rights reserved.
//

#include <metal_stdlib>
#include "predefine.h"

using namespace metal;

vertex TextureMappingVertex mapTexture(unsigned int vertex_id[[ vertex_id ]]) {
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

fragment half4 displayTexture(TextureMappingVertex mappingVertex[[ stage_in ]],
                                    texture2d<float, access::sample> texture[[ texture(0) ]],
                                    texture2d<float, access::sample> filterTexture[[ texture(1) ]]) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    float3 color = texture.sample(s, mappingVertex.textureCoordinate).rgb;
    return half4(color.r, color.g, color.b, 1.0);
}
