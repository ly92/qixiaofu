//
//  CourseDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/12/12.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class CourseDetailViewController: BaseTableViewController {
    class func spwan() -> CourseDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Knowledge") as! CourseDetailViewController
    }
    
    var courseId = ""
    fileprivate var status = "0"
    fileprivate var videoId = ""
    var coursePaySuccessBlock : ((Int) -> Void)?
    
    fileprivate var resultJson : JSON = []
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var courseDescLbl: UILabel!
    @IBOutlet weak var teacherDescLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var adressLbl: UILabel!
    @IBOutlet weak var priceDescLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var priceBgView: UIView!
    @IBOutlet weak var bigImgV: UIImageView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var shareImgV: UIImageView!
    @IBOutlet weak var shareImgVBottomDis: NSLayoutConstraint!
    
    fileprivate var signUpBtn = UIButton()
    fileprivate var bigImgH : CGFloat = 0
    fileprivate var shareImgH : CGFloat = 0
    fileprivate var showShareView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.priceBgView.layer.cornerRadius = 6
        self.navigationItem.title = "课程详情"
        self.setUpSignUpBtn()
        self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 50, right: 0)
        self.loadDetailData()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_share"), target: self, action: #selector(CourseDetailViewController.shareAction))
    }
    
    func loadDetailData() {
        var params : [String : Any] = [:]
        params["lession_id"] = self.courseId
        NetTools.requestData(type: .post, urlString: KCourseDetailApi, parameters: params, succeed: { (result, msg) in
            self.resultJson = result
            self.prepareUIdata()
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    func prepareUIdata() {
        /*
         self.titleLbl.text = self.resultJson["lession_name"].stringValue
         self.imgV.setImageUrlStrAndPlaceholderImg(self.resultJson["lession_img"].stringValue, #imageLiteral(resourceName: "course_banner"))
         self.courseDescLbl.text = self.resultJson["lession_detail"].stringValue
         self.teacherDescLbl.text = self.resultJson["lession_speaker_detail"].stringValue
         
         if self.resultJson["lession_end_time"].stringValue.intValue - self.resultJson["lession_start_time"].stringValue.intValue > 86400{
         let str1 = Date.dateStringFromDate(format: "yyyy年MM月dd日", timeStamps: self.resultJson["lession_start_time"].stringValue) + "-" + Date.dateStringFromDate(format: "dd日", timeStamps: self.resultJson["lession_end_time"].stringValue)
         let str2 = Date.dateStringFromDate(format: "HH:mm", timeStamps: self.resultJson["lession_start_time"].stringValue) + "~" + Date.dateStringFromDate(format: "HH:mm", timeStamps: self.resultJson["lession_end_time"].stringValue)
         self.timeLbl.text = str1 + " " + str2
         }else{
         self.timeLbl.text = Date.dateStringFromDate(format: "yyyy年MM月dd日 HH:mm", timeStamps: self.resultJson["lession_start_time"].stringValue) + "~" + Date.dateStringFromDate(format: "HH:mm", timeStamps: self.resultJson["lession_end_time"].stringValue)
         }
         self.adressLbl.text = self.resultJson["lession_address"].stringValue
         
         
         let newPrice = self.resultJson["lession_new_price"].stringValue
         let price = self.resultJson["lession_cost_price"].stringValue
         let attStr = NSMutableAttributedString()
         if self.status.intValue == 1{
         self.signUpBtn.setTitle("已报名", for: .normal)
         self.signUpBtn.isEnabled = false
         attStr.append(self.setUPPrice(price: price))
         }else if self.status.intValue == 2{
         self.signUpBtn.setTitle("已结束", for: .normal)
         self.signUpBtn.isEnabled = false
         attStr.append(self.setUPPrice(price: price))
         }else{
         self.signUpBtn.setTitle("立即报名", for: .normal)
         if newPrice.trim.isEmpty{
         attStr.append(self.setUPPrice(price: price))
         }else{
         attStr.append(self.setUPPrice(price: newPrice))
         
         attStr.append(NSAttributedString.init(string:"   ", attributes: nil))
         
         attStr.append(NSAttributedString.init(string: "¥" + price, attributes: [NSAttributedStringKey.strikethroughStyle : (1),.font : UIFont.systemFont(ofSize: 12.0),.foregroundColor : UIColor.gray]))
         }
         }
         
         self.priceLbl.attributedText = attStr
         */
        
        self.status = self.resultJson["lession_enroll_state"].stringValue
//        if self.status.intValue == 1{
//            self.signUpBtn.setTitle("已报名", for: .normal)
//            self.signUpBtn.isEnabled = false
//        }else
        self.videoId = self.resultJson["mv_id"].stringValue
        
        if self.status.intValue == 2{
            if self.videoId.trim.isEmpty{
                self.signUpBtn.setTitle("已结束", for: .normal)
                self.signUpBtn.isEnabled = false
            }else{
                self.signUpBtn.setTitle("观看回放", for: .normal)
            }
        }else{
            self.signUpBtn.setTitle("立即报名", for: .normal)
        }
        
        self.bigImgV.kf.setImage(with: URL(string:self.resultJson["lession_big_img"].stringValue), placeholder: #imageLiteral(resourceName: "course_cover"), options: nil, progressBlock: nil, completionHandler: { (image, error, memory, url) in
            if image != nil{
                self.bigImgH = image!.size.height / image!.size.width * kScreenW
            }
            self.tableView.reloadData()
            
        })
        self.setUPShareView()
        
    }
    
    //    func setUPPrice(price : String) -> NSAttributedString {
    //        let attStr = NSMutableAttributedString()
    //        let priceArr = price.components(separatedBy: ".")
    //        if priceArr.count == 2{
    //            attStr.append(NSAttributedString.init(string: "¥" + priceArr[0] + ".", attributes: [.font : UIFont.systemFont(ofSize: 20.0)]))
    //            attStr.append(NSAttributedString.init(string: priceArr[1], attributes: [.font : UIFont.systemFont(ofSize: 14.0)]))
    //        }else{
    //            attStr.append(NSAttributedString.init(string: "¥" + priceArr[0], attributes: [.font : UIFont.systemFont(ofSize: 20.0)]))
    //        }
    //        return attStr
    //    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        keyWindow.addSubview(self.signUpBtn)
        self.signUpBtn.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(0)
            make.height.equalTo(50)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.signUpBtn.removeFromSuperview()
    }
    
    //报名按钮
    func setUpSignUpBtn() {
        self.signUpBtn = UIButton.init(type: .custom)
        self.signUpBtn.setTitleColor(UIColor.colorHex(hex: "122536"), for: .normal)
        self.signUpBtn.setTitle("立即报名", for: .normal)
        self.signUpBtn.backgroundColor = UIColor.colorHex(hex: "47fdfe")
        self.signUpBtn.addTarget(self, action: #selector(CourseDetailViewController.signUpAction), for: .touchUpInside)
    }
    
    //报名事件
    @objc func signUpAction() {
        if self.videoId.trim.isEmpty{
            //        UserViewModel.haveTrueName(parentVC: self) {
            let payVC = PayCourseViewController.spwan()
            payVC.resultJson = self.resultJson
            payVC.paySuccessBlock = {(num) in
                LYProgressHUD.showSuccess("报名成功!")
                //                self.signUpBtn.setTitle("已报名", for: .normal)
                //                self.signUpBtn.isEnabled = false
                if self.coursePaySuccessBlock != nil{
                    self.coursePaySuccessBlock!(num)
                }
            }
            self.navigationController?.pushViewController(payVC, animated: true)
            //        }
        }else{
            let videoPlayVC = KnowledgeVideoPlayViewController.spwan()
            videoPlayVC.videoId = self.videoId
            self.navigationController?.pushViewController(videoPlayVC, animated: true)
        }

    }
    
    //分享
    @objc func shareAction() {
        
        if self.showShareView{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_share"), target: self, action: #selector(CourseDetailViewController.shareAction))
            self.showShareView = false
            self.tableView.reloadData()
        }else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", target: self, action: #selector(CourseDetailViewController.shareAction))
            self.showShareView = true
            self.tableView.reloadData()
            guard let image = self.tableView.getScreenshotImage(nil) else {
                return
            }
            ShareView.showImage(url: self.resultJson["lession_share_link"].stringValue, title: self.resultJson["lession_name"].stringValue, desc: "邀请您参加七小服培训", image: image, viewController: self)
        }
    }
    
    
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 6 {
            if self.showShareView{
                self.signUpBtn.isHidden = true
                tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
                return 0
            }else{
                self.signUpBtn.isHidden = false
                tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 50, right: 0)
                return self.bigImgH
            }
        }else if indexPath.row == 7 && self.showShareView{
            return self.shareImgH
        }else{
            return 0
        }
        /*
         switch indexPath.row {
         case 0:
         let height = (kScreenW - 24) / 2
         return height + 41
         case 1:
         let height = self.resultJson["lession_detail"].stringValue.sizeFit(width: kScreenW - 24, height: CGFloat(MAXFLOAT), fontSize: 14.0).height
         if height > 21{
         return height + 45
         }else{
         return 66
         }
         case 2:
         let height = self.resultJson["lession_speaker_detail"].stringValue.sizeFit(width: kScreenW - 24, height: CGFloat(MAXFLOAT), fontSize: 14.0).height
         if height > 21{
         return height + 45
         }else{
         return 66
         }
         case 3:
         //            let height = self.resultJson["lession_detail"].stringValue.sizeFit(width: kScreenW - 24, height: CGFloat(MAXFLOAT), fontSize: 14.0).height
         //            if height > 21{
         //                return height + 45
         //            }else{
         return 66
         //            }
         case 4:
         let height = self.resultJson["lession_address"].stringValue.sizeFit(width: kScreenW - 24, height: CGFloat(MAXFLOAT), fontSize: 14.0).height
         if height > 21{
         return height + 45
         }else{
         return 66
         }
         case 5:
         let height = self.priceDescLbl.resizeHeight()
         if height > 21{
         return height + 59
         }else{
         return 80
         }
         default:
         return 0
         }
         */
    }
    
    
    //MARK:分享海报
    func setUPShareView() {
        LYProgressHUD.showLoading()
        var topDis : CGFloat = 0
        let scal = CGFloat(self.resultJson["z_height"].stringValue.floatValue / self.resultJson["height"].stringValue.floatValue)
        self.shareImgV.kf.setImage(with: URL(string:self.resultJson["lession_bground_image"].stringValue), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, memory, url) in
            if image != nil{
                self.shareImgH = image!.size.height / image!.size.width * kScreenW
                topDis = self.shareImgH * scal
                subView()
            }
            LYProgressHUD.dismiss()
        })
        
        func subView(){
            var codeH = self.shareImgH-topDis-20-20
            if codeH < 70 {
                self.shareImgH += 70 - codeH
                self.shareImgVBottomDis.constant = 70 - codeH
                codeH = 70
            }else{
                codeH = 70
            }
            let subX = (kScreenW - 3 * codeH - 30) / 2.0
            let view = UIView(frame:CGRect.init(x: 0, y: topDis, width: kScreenW, height: self.shareImgH-topDis))
            self.shareView.addSubview(view)
            let subView = DrawView(frame:CGRect.init(x: subX, y: 10, width: kScreenW-subX * 2, height: codeH + 20))
            subView.draw(subView.bounds)
            view.addSubview(subView)
            let codeImgV = UIImageView(frame:CGRect.init(x: 10, y: 10, width: codeH, height: codeH))
            codeImgV.image = UIImageView.createQrcode(self.resultJson["lession_share_link"].stringValue)
            subView.addSubview(codeImgV)
            let inviteLbl = UILabel(frame:CGRect.init(x: 10+codeH+10, y: 10, width: 2*codeH, height: 21))
            subView.addSubview(inviteLbl)
            inviteLbl.text = LocalData.getUserName() + " 邀您学习"
            inviteLbl.textColor = UIColor.colorHex(hex: "141414")
            inviteLbl.font = UIFont.systemFont(ofSize: 15.0)
            let lbl2 = UILabel(frame:CGRect.init(x: 10+codeH+10, y: 40, width: 2*codeH, height: 37))
            lbl2.numberOfLines = 0
            lbl2.textColor = UIColor.colorHex(hex: "216082")
            lbl2.font = UIFont.systemFont(ofSize: 14.0)
            subView.addSubview(lbl2)
            lbl2.text = "现在扫码\n了解详情"
            
            
        }
    }
    
    
    
}
//边框
class DrawView: UIView {
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.lineJoinStyle = .round
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint.init(x: rect.size.width, y: 0))
        path.addLine(to: CGPoint.init(x: rect.size.width, y: rect.size.height))
        path.addLine(to: CGPoint.init(x: 0, y: rect.size.height))
        path.close()
        UIColor.white.setFill()
        path.fill()
        UIColor.gray.setStroke()
        path.stroke()
    }
}
