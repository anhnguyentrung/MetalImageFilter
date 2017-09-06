//
//  ViewController.swift
//  CityNetwork
//
//  Created by CodeLovers2 on 4/4/17.
//  Copyright © 2017 Anh Nguyen. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ImagePickerController: UIViewController {
    
    var metalImageView: MetalImageView!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var galleryButton: UIButton!
    @IBOutlet var cropButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var selectFilterScrollView: UIScrollView!
    let disposeBag = DisposeBag()
    let filters = ["original", "hudson", "earlybird", "aramo", "hefe", "mayfair", "rise", "toaster", "willow"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupView()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        cameraButton.rx.tap
            .flatMapLatest{[weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = .camera
                    picker.allowsEditing = false
                }
                .flatMap {$0.rx.didFinishPickingMediaWithInfo}
                .take(1)
            }
            .map { info in
                var originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
                if (originalImage.imageOrientation != .up) {
                    UIGraphicsBeginImageContextWithOptions(originalImage.size, false, originalImage.scale)
                    originalImage.draw(in: CGRect(x: 0, y: 0, width: originalImage.size.width, height: originalImage.size.height))
                    originalImage = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                }
                let ratio = originalImage.size.height / originalImage.size.width
                let mtlFrameWidth = self.metalImageView.frame.width
                let mtlFrameHeight = mtlFrameWidth * ratio
                self.metalImageView.frame = CGRect(x: 20, y: 50, width: mtlFrameWidth, height: mtlFrameHeight)
                self.saveButton.isHidden = false
                return originalImage
            }
            .bindTo(metalImageView.rx.image)
            .addDisposableTo(disposeBag)
        
        galleryButton.rx.tap
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = false
                    }
                    .flatMap {
                        $0.rx.didFinishPickingMediaWithInfo
                    }
                    .take(1)
            }
            .map { info in
                var originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
                if (originalImage.imageOrientation != .up) {
                    UIGraphicsBeginImageContextWithOptions(originalImage.size, false, originalImage.scale)
                    originalImage.draw(in: CGRect(x: 0, y: 0, width: originalImage.size.width, height: originalImage.size.height))
                    originalImage = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                }
                let ratio = originalImage.size.height / originalImage.size.width
                let mtlFrameWidth = self.metalImageView.frame.width
                let mtlFrameHeight = mtlFrameWidth * ratio
                self.metalImageView.frame = CGRect(x: 20, y: 50, width: mtlFrameWidth, height: mtlFrameHeight)
                self.saveButton.isHidden = false
                return originalImage
            }
            .bindTo(metalImageView.rx.image)
            .addDisposableTo(disposeBag)
        
        cropButton.rx.tap
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = true
                    }
                    .flatMap { $0.rx.didFinishPickingMediaWithInfo }
                    .take(1)
            }
            .map { info in
                var originalImage = info[UIImagePickerControllerEditedImage] as! UIImage
                if (originalImage.imageOrientation != .up) {
                    UIGraphicsBeginImageContextWithOptions(originalImage.size, false, originalImage.scale)
                    originalImage.draw(in: CGRect(x: 0, y: 0, width: originalImage.size.width, height: originalImage.size.height))
                    originalImage = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                }
                let ratio = originalImage.size.height / originalImage.size.width
                let mtlFrameWidth = self.metalImageView.frame.width
                let mtlFrameHeight = mtlFrameWidth * ratio
                self.metalImageView.frame = CGRect(x: 20, y: 50, width: mtlFrameWidth, height: mtlFrameHeight)
                self.saveButton.isHidden = false
                return originalImage
            }
            .bindTo(metalImageView.rx.image)
            .addDisposableTo(disposeBag)
        
        saveButton.rx.tap
            .subscribe(
                onNext: {[weak self] _ in
                    guard let self_ = self,
                    let mtlTexture = self_.metalImageView.currentDrawable?.texture
                    else{
                        return
                    }
                    let saveImage = mtlTexture.toImage()
                    UIImageWriteToSavedPhotosAlbum(saveImage!, self_, #selector(self_.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            )
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ImagePickerController {
    func setup(filters: [String], in scrollView: UIScrollView) {
        scrollView.contentSize = CGSize(width: CGFloat(filters.count) * scrollView.frame.height,
                                        height: scrollView.frame.height)
        for (index, filterName) in filters.enumerated() {
            let width = scrollView.frame.height
            let height = width
            let x = CGFloat(index) * width
            let filterButton = UIButton(frame: CGRect(x: x, y: 0, width: width, height: height))
            filterButton.setTitle(filterName, for: .normal)
            filterButton.addTarget(self, action: #selector(selectedFilter(sender:)), for: .touchUpInside)
            filterButton.tag = index
            scrollView.addSubview(filterButton)
        }
    }
    
    func setupView() {
        let mtlFrameWidth = view.frame.width - 40
        let mtlFrameHeight = mtlFrameWidth
        let mtlFrame = CGRect(x: 20, y: 50, width: mtlFrameWidth, height: mtlFrameHeight)
        metalImageView = MetalImageView(frame: mtlFrame, device: MTLCreateSystemDefaultDevice())
        self.view.insertSubview(metalImageView, at: 0)
        setup(filters: filters, in: selectFilterScrollView)
        saveButton.isHidden = true
    }
    
    func selectedFilter(sender: UIButton!) {
        let index = sender.tag
        self.metalImageView.filterName = filters[index]
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

