//
//  CreateQrcodeView.swift
//  qixiaofu
//
//  Created by ly on 2017/10/23.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class CreateQrcodeView: UIView {

    var animateFrame : CGRect = CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH)
    var urlStr = ""
    var icon : UIImage?
    
    var shareBlock : (() -> Void)?
    
    init(frame:CGRect?,urlStr:String, image:UIImage?) {
        self.urlStr = urlStr
        self.icon = image
        if frame == nil{
            self.animateFrame = CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH)
            super.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH))
        }else{
            self.animateFrame = frame!
            super.init(frame: frame!)
        }
        self.setUpUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        let bgBtn = UIButton(frame:self.bounds)
        bgBtn.backgroundColor = UIColor.RGBSA(s: 0, a: 0.3)
        bgBtn.addTarget(self, action: #selector(CreateQrcodeView.hide), for: .touchUpInside)
        self.addSubview(bgBtn)
        
        let centerView = UIView()
        centerView.x = self.w / 5.0
        centerView.w = self.w * 3 / 5.0
        centerView.h = centerView.w + 80
        centerView.y = (self.h - centerView.h) / 2.0
        centerView.backgroundColor = UIColor.white
        centerView.clipsToBounds = true
        centerView.layer.cornerRadius = 5
        self.addSubview(centerView)
        
        let shareBtn = UIButton(frame:CGRect.init(x: centerView.w-50, y: 0, width: 50, height: 50))
        shareBtn.setImage(#imageLiteral(resourceName: "Share_code"), for: .normal)
        shareBtn.addTarget(self, action: #selector(CreateQrcodeView.share), for: .touchUpInside)
        centerView.addSubview(shareBtn)
        
        let codeImgV = UIImageView(frame:CGRect.init(x: 30, y: shareBtn.frame.maxY + 5, width: centerView.w - 60, height: centerView.w-60))
        codeImgV.image = self.createQrcodeWithImage()
        centerView.addSubview(codeImgV)
        
        let titleLbl = UILabel(frame:CGRect.init(x: 10, y: codeImgV.frame.maxY + 20, width: centerView.w - 20, height: 21))
        titleLbl.font = UIFont.systemFont(ofSize: 14.0)
        titleLbl.textColor = UIColor.colorHex(hex: "111111")
        titleLbl.textAlignment = .center
        titleLbl.text = "扫二维码，加入七小服"
        centerView.addSubview(titleLbl)
    }
    
    
    func createQrcodeWithImage() -> UIImage?{
        let qrImg = self.createQrcode()
        if self.icon != nil && qrImg != nil{
           //开启上下文
            UIGraphicsBeginImageContext(qrImg!.size)
            //把二维码画到上下文
            qrImg!.draw(in: CGRect.init(origin: CGPoint.zero, size: qrImg!.size))
            
            //把前景图画到二维码上
            let w :CGFloat = 80
            self.icon!.draw(in: CGRect.init(x: (qrImg!.size.width - w) * 0.5, y: (qrImg!.size.height - w) * 0.5, width: w, height: w))
            
            //获取新图片
            let newImg = UIGraphicsGetImageFromCurrentImageContext()
            
            //关闭上下文
            UIGraphicsEndImageContext()
            
            return newImg
        }
        
        return qrImg
    }
    
    func createQrcode() -> UIImage? {
        //1.创建一个二维码滤镜实例(CIFilter)
        let filter = CIFilter.init(name: "CIQRCodeGenerator")
        // 滤镜恢复默认设置
        filter?.setDefaults()
        
        //2.给滤镜添加数据
        guard let data = self.urlStr.data(using: String.Encoding.utf8) else {
            return nil
        }
        filter?.setValue(data, forKey: "inputMessage")
        
        //3.生成二维码
        guard let ciImg = filter?.outputImage else {
            return nil
        }
        
        //4.调整清晰度
        //创建Transform
        let scale = kScreenW / ciImg.extent.width
        let transform = CGAffineTransform.init(scaleX: scale, y: scale)
        //放大图片
        let bigImg = ciImg.transformed(by: transform)

        return UIImage.init(ciImage: bigImg)
    }
    
    func show() {
        self.frame = CGRect.zero
        UIApplication.shared.keyWindow?.addSubview(self)
        UIApplication.shared.keyWindow?.bringSubview(toFront: self)
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = self.animateFrame
        })
    }
    
    @objc func hide() {
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = CGRect.zero
        }) { (completion) in
            self.removeFromSuperview()
        }
    }
    
    @objc func share() {
        //推荐给好友
        if (self.shareBlock != nil){
            self.hide()
            self.shareBlock!()
        }
    }
    
}
