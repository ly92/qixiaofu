//
//  JobDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/10/19.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class JobDetailViewController: BaseViewController {
    class func spwan() -> JobDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! JobDetailViewController
    }
    
    var idType = 1 //1工程师 2所属招聘方 3非所属招聘方
    var jobId = ""
    
    @IBOutlet weak var jobNameLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var companyLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var moneyLbl: UILabel!
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var responsibilityLbl: UILabel!
    @IBOutlet weak var qualificationLbl: UILabel!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var employmentBottomView: UIView!
    @IBOutlet weak var engineerBottomView: UIView!
    
    fileprivate var resultJson = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "招聘详情"
        
        if self.idType == 1{
            self.employmentBottomView.isHidden = true
            self.engineerBottomView.isHidden = false
        }else if self.idType == 2{
            self.employmentBottomView.isHidden = false
            self.engineerBottomView.isHidden = true
        }else if self.idType == 3{
            self.employmentBottomView.isHidden = true
            self.engineerBottomView.isHidden = true
        }
        
        self.loadJobDetail()
    }
    
    
    
    //详情数据
    func loadJobDetail() {
        var params : [String : Any] = [:]
        params["id"] = self.jobId
        NetTools.requestData(type: .post, urlString: JobDetailApi,parameters: params, succeed: { (resultJson, msg) in
            self.resultJson = resultJson
            
            self.jobNameLbl.text = resultJson["type_name"].stringValue + "(" + (resultJson["nature"].stringValue.intValue == 1 ? "内部招聘" : "外派驻场") + ")"
            self.stateLbl.text = resultJson["status"].stringValue.intValue == 1 ? "招聘中" : "已暂停"
            self.companyLbl.text = resultJson["company_is_show"].stringValue.intValue == 1 ? resultJson["company_name"].stringValue : "***************"
            self.addressLbl.text = resultJson["area_info"].stringValue
            self.moneyLbl.text = resultJson["salary_low"].stringValue + "~" + resultJson["salary_heigh"].stringValue + "K"
            self.numberLbl.text = resultJson["nums"].stringValue
            self.responsibilityLbl.text = resultJson["duty"].stringValue
            self.qualificationLbl.text = resultJson["condition"].stringValue
            
            
            
            
        }) { (error) in
            LYProgressHUD.showError(error ?? "网络请求错误！")
        }
    }
    

    @IBAction func btnAction(_ btn: UIButton) {
        if btn.tag == 11{
            let historyVC = ChatOrRecommendListViewController.spwan()
            self.navigationController?.pushViewController(historyVC, animated: true)
        }else if btn.tag == 22{
            let historyVC = ChatOrRecommendListViewController.spwan()
            historyVC.isChatHistory = true
            self.navigationController?.pushViewController(historyVC, animated: true)
        }else if btn.tag == 33{
            LYAlertView.show("提示", "暂停后可重新开始招聘", "取消", "确定",{
            })
        }else if btn.tag == 44{
            print("联系招聘官")
        }else if btn.tag == 55{
            LYAlertView.show("提示", "您未上传简历附件，可发送简历附件到邮箱qixiaofu@7xiaofu.com完成上传 ", "知道了")
        }
    }
    
    

}
