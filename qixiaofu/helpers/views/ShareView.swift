//
//  ShareView.swift
//  qixiaofu
//
//  Created by ly on 2017/7/18.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

class ShareView: UIView {
    
    fileprivate var bottomView : UIView = UIView()
    fileprivate var title = "七小服"
    fileprivate var desc = "7X24小时技能服务平台"
    fileprivate var vc = UIViewController()
    fileprivate var url = "http://www.7xiaofu.com/download/popularize/qixiaofuPopularize.html"
    fileprivate var image = #imageLiteral(resourceName: "app_icon")
    fileprivate var isShareImage = false
    
    
    func setUpSubViews() {
        //1.背景图
        self.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH)
        UIApplication.shared.keyWindow?.addSubview(self)
        UIApplication.shared.keyWindow?.bringSubview(toFront: self)
        self.addTapActionBlock {
            self.cancelAction()
        }
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        //图片名称
        let title = ["微信","朋友圈","QQ","QQ空间","微博","短信","更多"]
        
        
        //底部图片
        let width : CGFloat = 60
        let merge = (kScreenW - 240) / 5.0
        let topMarge : CGFloat = 20
        bottomView = UIView(frame:CGRect.init(x: 0, y: kScreenH - width * 2 - 50 - topMarge * 3, width: kScreenW, height: width * 2 + 50 + topMarge * 3))
        bottomView.backgroundColor = UIColor.white
        
        for i in 1...7{
            let btn = UIButton(frame:CGRect.init(x: (width + merge) * CGFloat((i - 1) % 4) + merge, y: CGFloat(i / 5) * (width + topMarge) + topMarge, width: width, height: width))
            btn.tag = i
            btn.setImage(UIImage(named:"share_icon_" + "\(i)"), for: .normal)
            if self.isShareImage{
                btn.addTarget(self, action: #selector(ShareView.sharePictureAction(_:)), for: .touchUpInside)
            }else{
                btn.addTarget(self, action: #selector(ShareView.shareAction(_:)), for: .touchUpInside)
            }
            
            let lbl = UILabel(frame:CGRect.init(x: (width + merge) * CGFloat((i - 1) % 4) + merge, y: CGFloat(i / 5 + 1) * (width + topMarge)-5, width: width, height: topMarge))
            lbl.text = title[i-1]
            lbl.font = UIFont.systemFont(ofSize: 12.0)
            lbl.textColor = Text_Color
            lbl.textAlignment = .center
            bottomView.addSubview(btn)
            bottomView.addSubview(lbl)
        }
        
        let cancelBtn = UIButton(frame:CGRect.init(x: 0, y: (width + topMarge) * 2 + topMarge, width: kScreenW, height: 50))
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(UIColor.RGBS(s: 33), for: .normal)
        cancelBtn.backgroundColor = UIColor.white
        cancelBtn.addTarget(self, action: #selector(ShareView.cancelAction), for: .touchUpInside)
        bottomView.addSubview(cancelBtn)
        
        self.addSubview(bottomView)
    }
    
    func show(_ showImage : Bool, _ url : String, _ title : String, _ desc : String, _ image:UIImage? , _ viewController : UIViewController) {
        self.isShareImage = showImage
        
        self.setUpSubViews()
        
        if !url.isEmpty{
            self.url = url
        }
        if !title.isEmpty{
            self.title = title
        }
        if !desc.isEmpty{
            self.desc = desc
        }
        if image != nil{
            self.image = image!
        }
        self.vc = viewController
        
        let width : CGFloat = 60
        self.bottomView.y = kScreenH
        UIView.animate(withDuration: 0.25) { 
            self.bottomView.y = kScreenH - width * 2 - 50 - 20 * 3
        }
    }
    
    class func show(url:String, title:String, desc:String, image:UIImage? ,viewController : UIViewController) {
        ShareView().show(false,url, title , desc, image, viewController)
    }
    class func show(url:String, title:String, desc:String, viewController : UIViewController) {
        ShareView().show(false,url, title , desc, nil, viewController)
    }
    class func show(viewController : UIViewController) {
        ShareView().show(false,"", "", "", nil, viewController)
    }
    class func show(url:String, viewController : UIViewController) {
        ShareView().show(false, url, "" , "", nil, viewController)
    }
    
    class func showImage(url:String, title:String, desc:String, image:UIImage ,viewController : UIViewController) {
        ShareView().show(true,url, title , desc, image, viewController)
    }
    
    @objc func cancelAction() {
        self.removeFromSuperview()
    }
    
    
    @objc func shareAction(_ btn : UIButton) {
        
        let messageObject = UMSocialMessageObject()
        //        let thumbUrl = "https://mobile.umeng.com/images/pic/home/social/img-1.png"
        let shareObject = UMShareWebpageObject.shareObject(withTitle: self.title, descr: self.desc, thumImage: self.image)
        shareObject?.webpageUrl = self.url
        messageObject.shareObject = shareObject
        
        var type = UMSocialPlatformType.wechatSession
        switch btn.tag {
        case 1:
            type = .wechatSession
        case 2:
            type = .wechatTimeLine
        case 3:
            type = .QQ
        case 4:
            type = .qzone
        case 5:
            type = .sina
        case 6:
            type = .sms
        default:
            type = .wechatSession
        }
        
        if btn.tag == 7{
            let items:[Any] = [NSURL(string: self.url)!, self.title, self.image
            ]
            //新建自定义的分享对象数组
            let acts = [UIActivity()]
            //根据分享内容和自定义的分享按钮调用分享视图
            let actView:UIActivityViewController =
                UIActivityViewController(activityItems: items, applicationActivities: acts)
            //要排除的分享按钮，不显示在分享框里
            actView.excludedActivityTypes = [.postToWeibo, .print]
            //显示分享视图
            vc.present(actView, animated:true, completion:nil)
        }else if btn.tag == 6{
            UMSocialManager.default().share(to: type, messageObject: messageObject, currentViewController: self.vc) { (data, error) in
                if error != nil{
                    
                }else{
                    
                }
            }
        }else{
            if UMSocialManager.default().isInstall(type){
                UMSocialManager.default().share(to: type, messageObject: messageObject, currentViewController: self.vc) { (data, error) in
                    if error != nil{
                        
                    }else{
                        
                    }
                }
            }else{
                LYProgressHUD.showError("您未安装应用客户端，请尝试其他通道")
            }
        }
        
        //选中任何一个后都让分享页消失
        self.cancelAction()
    }

}


extension ShareView{
    
    @objc func sharePictureAction(_ btn : UIButton) {
        let messageObject = UMSocialMessageObject()
        //        let thumbUrl = "https://mobile.umeng.com/images/pic/home/social/img-1.png"
        let shareObject = UMShareImageObject.shareObject(withTitle: self.title, descr: self.desc, thumImage: self.image)
        shareObject?.shareImage = self.image
        messageObject.shareObject = shareObject
        
        var type = UMSocialPlatformType.wechatSession
        switch btn.tag {
        case 1:
            type = .wechatSession
        case 2:
            type = .wechatTimeLine
        case 3:
            type = .QQ
        case 4:
            type = .qzone
        case 5:
            type = .sina
        case 6:
            type = .sms
        default:
            type = .wechatSession
        }
        
        if btn.tag == 7{
            let items:[Any] = [NSURL(string: self.url)!, self.title, self.image
            ]
            //新建自定义的分享对象数组
            let acts = [UIActivity()]
            //根据分享内容和自定义的分享按钮调用分享视图
            let actView:UIActivityViewController =
                UIActivityViewController(activityItems: items, applicationActivities: acts)
            //要排除的分享按钮，不显示在分享框里
            actView.excludedActivityTypes = [.postToWeibo, .print]
            //显示分享视图
            vc.present(actView, animated:true, completion:nil)
        }else if btn.tag == 6{
            UMSocialManager.default().share(to: type, messageObject: messageObject, currentViewController: self.vc) { (data, error) in
                if error != nil{
                    
                }else{
                    
                }
            }
        }else{
            if UMSocialManager.default().isInstall(type){
                UMSocialManager.default().share(to: type, messageObject: messageObject, currentViewController: self.vc) { (data, error) in
                    if error != nil{
                        
                    }else{
                        
                    }
                }
            }else{
                LYProgressHUD.showError("您未安装应用客户端，请尝试其他通道")
            }
        }
        
        //选中任何一个后都让分享页消失
        self.cancelAction()
    }
    
    
}
