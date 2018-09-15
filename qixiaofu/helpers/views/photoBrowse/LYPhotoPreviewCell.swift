//
//  LYPhotoPreviewCell.swift
//  qixiaofu
//
//  Created by ly on 2017/7/4.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

protocol LYPhotoPreviewCellDelegate: class{
    func onImageSingleTap()
}

class LYPhotoPreviewCell: UICollectionViewCell , UIScrollViewDelegate{
    private var scrollView: UIScrollView?
    private var imageContainerView = UIView()
    private var imageView = UIImageView()
    private var descView = UIView()
    private var descLbl = UILabel()
    
    weak var delegate: LYPhotoPreviewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configView()
    }
    
    func configView() {
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView!.bouncesZoom = true
        self.scrollView!.maximumZoomScale = 2.5
        self.scrollView!.isMultipleTouchEnabled = true
        self.scrollView!.delegate = self
        self.scrollView!.scrollsToTop = false
        self.scrollView!.showsHorizontalScrollIndicator = false
        self.scrollView!.showsVerticalScrollIndicator = false
        self.scrollView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollView!.delaysContentTouches = false
        self.scrollView!.canCancelContentTouches = true
        self.scrollView!.alwaysBounceVertical = false
        self.addSubview(self.scrollView!)
        
        self.imageContainerView.clipsToBounds = true
        self.scrollView!.addSubview(self.imageContainerView)
        
        self.imageView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        self.imageView.clipsToBounds = true
        self.imageContainerView.addSubview(self.imageView)
        
        self.descView = UIView(frame:CGRect.init(x: 0, y: self.h - 150, width: self.w, height: 150))
        self.descView.backgroundColor = UIColor.clear
        let bgView = UIView(frame:self.descView.bounds)
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0.3
        self.descLbl = UILabel(frame:CGRect.init(x: 10, y: 10, width: self.w - 20, height: 21))
        self.descLbl.font = UIFont.systemFont(ofSize: 14.0)
        self.descLbl.numberOfLines = 0
        self.descLbl.textColor = UIColor.white
        self.descView.addSubview(bgView)
        self.descView.addSubview(descLbl)
        self.addSubview(self.descView)
        
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(LYPhotoPreviewCell.singleTap(tap:)))
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(LYPhotoPreviewCell.doubleTap(tap:)))
        
        doubleTap.numberOfTapsRequired = 2
        singleTap.require(toFail: doubleTap)
        
        self.addGestureRecognizer(singleTap)
        self.addGestureRecognizer(doubleTap)
    }
    
    func renderModel(image: UIImage) {
        self.renderModel(image: image, desc: "")
    }
    
    func renderModel(image: UIImage, desc: String) {
        self.imageView.image = image
        if desc.isEmpty{
            self.descView.isHidden = true
        }else{
            self.descLbl.text = desc
            self.descView.isHidden = false
            self.descLbl.h = self.descLbl.resizeHeight()
        }
        self.resizeImageView()
    }
    
    func resizeImageView() {
        self.imageContainerView.frame = CGRect(x:0, y:0, width: self.frame.width, height: self.imageContainerView.bounds.height)
        let image = self.imageView.image!
        if image.size.height / image.size.width > self.bounds.height / self.bounds.width {
            let height = floor(image.size.height / (image.size.width / self.bounds.width))
            var originFrame = self.imageContainerView.frame
            originFrame.size.height = height
            self.imageContainerView.frame = originFrame
        } else {
            var height = image.size.height / image.size.width * self.frame.width
            if height < 1 || height.isNaN {
                height = self.frame.height
            }
            height = floor(height)
            var originFrame = self.imageContainerView.frame
            originFrame.size.height = height
            self.imageContainerView.frame = originFrame
            self.imageContainerView.center = CGPoint(x:self.imageContainerView.center.x, y:self.bounds.height / 2)
        }
        
        if self.imageContainerView.frame.height > self.frame.height && self.imageContainerView.frame.height - self.frame.height <= 1 {
            
            var originFrame = self.imageContainerView.frame
            originFrame.size.height = self.frame.height
            self.imageContainerView.frame = originFrame
        }
        
        self.scrollView?.contentSize = CGSize(width: self.frame.width, height: max(self.imageContainerView.frame.height, self.frame.height))
        self.scrollView?.scrollRectToVisible(self.bounds, animated: false)
        self.scrollView?.alwaysBounceVertical = self.imageContainerView.frame.height > self.frame.height
        self.imageView.frame = self.imageContainerView.bounds
        
    }
    
    @objc func singleTap(tap:UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.onImageSingleTap()
        }
    }
    
    @objc func doubleTap(tap:UITapGestureRecognizer) {
        if (self.scrollView!.zoomScale > 1.0) {
            // 状态还原
            self.scrollView!.setZoomScale(1.0, animated: true)
        } else {
            let touchPoint = tap.location(in: self.imageView)
            let newZoomScale = self.scrollView!.maximumZoomScale
            let xsize = self.frame.size.width / newZoomScale
            let ysize = self.frame.size.height / newZoomScale
            
            self.scrollView!.zoom(to: CGRect(x: touchPoint.x - xsize/2, y: touchPoint.y-ysize/2, width: xsize, height: ysize), animated: true)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageContainerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0.0;
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0.0;
        self.imageContainerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY);
    }
   
}
