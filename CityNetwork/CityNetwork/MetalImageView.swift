//
//  MetalImageView.swift
//  CityNetwork
//
//  Created by CodeLovers2 on 4/14/17.
//  Copyright © 2017 Anh Nguyen. All rights reserved.
//

import UIKit
import Metal
import MetalKit

class MetalImageView: MTKView {
    var metalTexture: MTLTexture? {
        didSet {
            if let metalTexture_ = metalTexture {
                self.drawableSize = CGSize(width: metalTexture_.width, height: metalTexture_.height)
                setNeedsDisplay()
            }
        }
    }
    
    var filterTexture: MTLTexture?
    
    var image: UIImage? {
        didSet {
            guard let image_ = image,
                let device = self.device
            else {
                    return
            }
            
            do {
                metalTexture = try MTKTextureLoader(device: device).newTexture(with: image_.cgImage!, options: nil)
            } catch _ as NSError {
                return
            }
            initRenderPinelineState()
        }
    }
    
    var filterName: String? {
        didSet {
            guard let filterName_ = filterName,
                let device = self.device
            else {
                    return
            }
            let filterImage: UIImage!
            if filterName_ == "hudson" ||
               filterName_ == "hefe" ||
               filterName_ == "toaster" {
                filterImage = UIImage(named: filterName_)
            }
            else {
                filterImage = UIImage(named: "filter2")
            }
            
            do {
                filterTexture = try MTKTextureLoader(device: device).newTexture(with: filterImage!.cgImage!, options: nil)
            } catch _ as NSError {
                return
            }
            initRenderPinelineState()
        }
    }

    var commandQueue: MTLCommandQueue?
    
    internal var renderPipelineState: MTLRenderPipelineState?
    
    override init(frame:CGRect, device: MTLDevice?) {
        super.init(frame: frame, device: device)
        initCommon()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        initCommon()
    }
    
    private func initCommon() {
        framebufferOnly = false
        colorPixelFormat = .bgra8Unorm
        contentScaleFactor = UIScreen.main.scale
        drawableSize = CGSize(width: frame.width*contentScaleFactor, height: frame.height*contentScaleFactor)
    }
    
    private func initRenderPinelineState() {
        guard
            let device = self.device,
            let library = device.newDefaultLibrary()
        else { return }
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.sampleCount = 1
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .invalid
        var functionName = ""
        if filterName != nil
            && filterName != "original" {
            functionName = filterName!.capitalizingFirstLetter()
        }
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "mapTexture" + functionName)
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "displayTexture" + functionName)
        
        do {
            try renderPipelineState = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
        catch {
            return
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard
            let device = self.device,
            let metalTexture = self.metalTexture
        else { return }
        let commandBuffer = device.makeCommandQueue().makeCommandBuffer()
        var textures = [MTLTexture]()
        if let _ = filterTexture {
            textures = [metalTexture, filterTexture!]
        } else {
            textures = [metalTexture, metalTexture]
        }
        render(textures: textures, commandBuffer: commandBuffer, device: device)
    }
    
    private func render(textures: [MTLTexture], commandBuffer: MTLCommandBuffer, device: MTLDevice) {
        guard
            let currentRenderPassDescriptor = self.currentRenderPassDescriptor,
            let currentDrawable = self.currentDrawable,
            let renderPinelineState = renderPipelineState
        else { return }
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)
        encoder.pushDebugGroup("render frame")
        encoder.setRenderPipelineState(renderPinelineState)
        encoder.setFragmentTexture(textures[0], at: 0)
        encoder.setFragmentTexture(textures[1], at: 1)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
        encoder.popDebugGroup()
        encoder.endEncoding()
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }

}
