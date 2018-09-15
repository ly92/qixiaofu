//
//  KnowledgeDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/9/5.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class KnowledgeDetailViewController: BaseViewController {
    class func spwan() -> KnowledgeDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Knowledge") as! KnowledgeDetailViewController
    }
    
    var dataChangeBlock : ((_ json : JSON) -> Void)?
    var knowledgeId = ""
    fileprivate var resultJson : JSON = []
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var praiseBtn: UIButton!
    @IBOutlet weak var visitLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.iconImgV.layer.cornerRadius = 20;
        //返回按钮
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named:"btn_back"), target: self, action: #selector(KnowledgeDetailViewController.backClick))
        self.loadDetailData()
    }
    
    @objc func backClick(){
        if self.dataChangeBlock != nil{
            self.dataChangeBlock!(self.resultJson)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    //加载详情数据
    func loadDetailData() {
        var params : [String : Any] = [:]
        params["post_id"] = self.knowledgeId
        NetTools.requestData(type: .post, urlString: KnowledgeDetailApi, parameters: params, succeed: { (result, msg) in
            self.resultJson = result
            
            
            self.nameLbl.text = result["nik_name"].stringValue
            self.titleLbl.text = result["post_title"].stringValue
            self.iconImgV.setHeadImageUrlStr(result["user_avatar"].stringValue)
            self.contentLbl.text = result["post_content"].stringValue
            
            func splitLength(preStr : String) -> String{
                var str = preStr
                if str.count > 10{
                    str.removeLast()
                    return splitLength(preStr: str)
                }
                return str
            }
            if Double(splitLength(preStr: result["input_time"].stringValue)) != nil{
                let date = Date(timeIntervalSince1970: Double(splitLength(preStr: result["input_time"].stringValue))!)
                if (date.isYesterday()){
                    self.timeLbl.text = "昨天" + Date.dateStringFromDate(format: Date.timeFormatString(), timeStamps: result["input_time"].stringValue)
                }else if date.isToday(){
                    if date.hourssBeforeDate(aDate: Date()) > 0{
                        self.timeLbl.text = "\(date.hourssBeforeDate(aDate: Date()))" + "小时前"
                    }else if date.minutesBeforeDate(aDate: Date()) > 0{
                        self.timeLbl.text = "\(date.minutesBeforeDate(aDate: Date()))" + "分钟前"
                    }else{
                        self.timeLbl.text = "刚刚"
                    }
                }else{
                    self.timeLbl.text = Date.dateStringFromDate(format: Date.datePointFormatString(), timeStamps: result["input_time"].stringValue)
                }
            }
            
            self.resultJson["viewnum"] = JSON(String.init(format: "%d", result["viewnum"].stringValue.intValue + 1))
            
            self.visitLbl.text = self.resultJson["viewnum"].stringValue + " 浏览"
            
            if result["upvote_state"].stringValue.intValue == 1{
                self.praiseBtn.isSelected = true
            }else{
                self.praiseBtn.isSelected = false
            }
            
            
            
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func praiseAction() {
        var params : [String : Any] = [:]
        params["post_id"] = self.knowledgeId
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: KnowledgePariseApi, parameters: params, succeed: { (error, msg) in
            self.loadDetailData()
            LYProgressHUD.showSuccess("操作成功！")
            //            self.praiseBtn.isSelected = true
            //            self.praiseBtn.isEnabled = false
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
}
