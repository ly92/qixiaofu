//
//  HomeCourseDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/3/14.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class HomeCourseDetailViewController: BaseViewController {
    class func spwan() -> HomeCourseDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! HomeCourseDetailViewController
    }
    
    var courseId = ""//
    
    @IBOutlet weak var topImgV : UIImageView!//图片
    @IBOutlet weak var topViewH: NSLayoutConstraint!
    @IBOutlet weak var titleLbl : UILabel!//标题
    @IBOutlet weak var timeLbl : UILabel!//时间
    @IBOutlet weak var addressLbl : UILabel!//地点
    @IBOutlet weak var priceLbl : UILabel!//价格
    @IBOutlet weak var phoneLbl : UILabel!//手机号
    @IBOutlet weak var stopTimeLbl : UILabel!//截止时间
    @IBOutlet weak var contentLbl : UILabel!//内容
    @IBOutlet weak var scrollView : UIScrollView!//scrollview
    @IBOutlet weak var bottomBtn : UIButton!//底部按钮
    @IBOutlet weak var scrollContentH: NSLayoutConstraint!
    
    fileprivate var resultJson : JSON = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "课程详情"
       
        //
        self.topViewH.constant = kScreenW * 320 / 750
        
        self.loadDetailData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //加载数据
    func loadDetailData() {
        var params : [String : Any] = [:]
        params["id"] = self.courseId
        NetTools.requestData(type: .post, urlString: HomeCourseDetailApi, parameters: params, succeed: { (resultJson, msg) in
            self.resultJson = resultJson["salon_detail"]
            self.setUpUIData()
        }) { (error) in
            LYProgressHUD.showError(error ?? "网络错误，请重试!")
        }
    }
  
    
    //填充数据
    func setUpUIData() {
        self.topImgV.setImageUrlStr(self.resultJson["img"].stringValue)
        self.titleLbl.text = self.resultJson["name"].stringValue
        self.timeLbl.text = Date.dateStringFromDate(format: "MM月dd日", timeStamps: self.resultJson["start_time"].stringValue) + Date.dateStringFromDate(format: "HH:mm", timeStamps: self.resultJson["start_time"].stringValue) + "至" + Date.dateStringFromDate(format: "HH:mm", timeStamps: self.resultJson["end_time"].stringValue)
        self.addressLbl.text = self.resultJson["address"].stringValue
        self.priceLbl.text = "免费"
        self.phoneLbl.text = self.resultJson["phone"].stringValue + " (主办方)"
        self.stopTimeLbl.text = "报名截止时间 " + Date.dateStringFromDate(format: "MM-dd HH:mm", timeStamps: self.resultJson["end_time"].stringValue)
        self.contentLbl.text = self.resultJson["content"].stringValue
        
        let height = self.contentLbl.resizeHeight()
        
        self.scrollContentH.constant = kScreenW * 320 / 750 + 230 + height
        
        if self.scrollContentH.constant < self.scrollView.h{
            self.scrollContentH.constant = self.scrollView.h
        }
        if self.resultJson["is_end"].stringValue.intValue == 1{
            if !self.resultJson["mv_id"].stringValue.trim.isEmpty{
                self.bottomBtn.setTitle("观看回放", for: .normal)
            }else{
                self.bottomBtn.setTitle("已结束", for: .normal)
                self.bottomBtn.isEnabled = false
            }
        }else{
            if self.resultJson["is_sign"].stringValue.intValue == 1{
                self.bottomBtn.setTitle("已报名", for: .normal)
            }else{
                self.bottomBtn.setTitle("报名", for: .normal)
            }
        }
    }
    
    //按钮事件
    @IBAction func btnAction() {
        if self.resultJson["mv_id"].stringValue.trim.isEmpty{
            let customAlertView = UIAlertView.init(title: "报名", message: "请输入报名人数，最少1人", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "报名")
            customAlertView.alertViewStyle = .plainTextInput
            let nameField = customAlertView.textField(at: 0)
            nameField?.keyboardType = .default
            nameField?.placeholder = "报名人数"
            customAlertView.show()
        }else{
            let videoPlayVC = KnowledgeVideoPlayViewController.spwan()
            videoPlayVC.videoId = self.resultJson["mv_id"].stringValue
            self.navigationController?.pushViewController(videoPlayVC, animated: true)
        }
    }
    
}



extension HomeCourseDetailViewController : UIAlertViewDelegate{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1{
            let nameField = alertView.textField(at: 0)
            guard let num = nameField?.text else{
                LYProgressHUD.showError("请重试！")
                return
            }
            if num.isEmpty{
                LYProgressHUD.showError("不可为空！")
                return
            }
            
            if num.intValue <= 0{
                LYProgressHUD.showError("请输入正确数字")
                return
            }
            var params : [String : Any] = [:]
            params["id"] = self.resultJson["id"].stringValue
            params["num"] = num
            NetTools.requestData(type: .post, urlString: HomeCourseEnrollApi, parameters: params, succeed: { (resultJson, msg) in
                LYProgressHUD.showSuccess("报名成功！")
                self.bottomBtn.setTitle("已报名", for: .normal)
            }, failure: { (error) in
                LYProgressHUD.showError(error ?? "报名失败，请重试")
            })
            
        }
    }
    
}
