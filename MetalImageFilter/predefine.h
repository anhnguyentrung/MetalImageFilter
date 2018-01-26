//
//  predefine.metal
//  MetalImageFilter
//
//  Created by CodeLovers2 on 5/5/17.
//  Copyright © 2017 Anh Nguyen. All rights reserved.
//

#pragma once
using namespace metal;

typedef struct {
    float4 renderedCoordinate[[position]];
    float2 textureCoordinate;
} TextureMappingVertex;

constant float3 luminanceCoefficients = float3(0.2125, 0.7154, 0.0721);

float3 adjustBCS(float3 color, float brightness, float constrast, float saturation);
float3 ovelayBlender(float3 color, float3 filterColor);
float3 multiplyBlender(float3 color, float3 filterColor);
