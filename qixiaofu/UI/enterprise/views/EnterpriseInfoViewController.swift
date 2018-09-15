//
//  EnterpriseInfoViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/4/19.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EnterpriseInfoViewController: BaseTableViewController {
    class func spwan() -> EnterpriseInfoViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! EnterpriseInfoViewController
    }
    @IBOutlet weak var logoImgV: UIImageView!
    @IBOutlet weak var epNameLbl: UILabel!
    @IBOutlet weak var epCodeLbl: UILabel!
    @IBOutlet weak var licenseImgV: UIImageView!
    
    var business_id = ""
    
    fileprivate var bigImgV = UIImageView()
    
    fileprivate var resultJson = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "企业信息"
        
        self.logoImgV.layer.cornerRadius = 22.5
        self.licenseImgV.layer.cornerRadius = 10
        self.loadEnterpriseInfo()
        
        self.bigImgV = UIImageView(frame: self.view.bounds)
        self.view.addSubview(bigImgV)
        self.bigImgV.isHidden = true
        self.bigImgV.contentMode = .scaleAspectFit
        self.bigImgV.backgroundColor = UIColor.black
        
        self.bigImgV.addTapActionBlock {
            self.bigImgV.isHidden = true
        }
        
        self.logoImgV.addTapActionBlock {
            self.bigImgV.setImageUrlStr(self.resultJson["company_logo"].stringValue)
            self.bigImgV.isHidden = false
        }
        self.licenseImgV.addTapActionBlock {
            self.bigImgV.setImageUrlStr(self.resultJson["company_license"].stringValue)
            self.bigImgV.isHidden = false
        }
    }
    
    //加载企业信息
    func loadEnterpriseInfo() {
        LYProgressHUD.showLoading()
        let params = ["business_id" : self.business_id]
        NetTools.requestData(type: .post, urlString: EnterpriseInfoApi, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            self.resultJson = resultJson
            self.prepareUIData()
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取企业信息失败！")
        }
    }
    
    //填充数据
    func prepareUIData() {
        self.logoImgV.setImageUrlStr(self.resultJson["company_logo"].stringValue)
        self.epNameLbl.text = self.resultJson["company_name"].stringValue
        self.epCodeLbl.text = self.resultJson["company_number"].stringValue
        self.licenseImgV.setImageUrlStr(self.resultJson["company_license"].stringValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.bigImgV.isHidden{
            self.bigImgV.isHidden = true
        }
    }

}
