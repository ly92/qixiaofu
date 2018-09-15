//
//  EngineerDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/6/28.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EngineerDetailViewController: BaseTableViewController {

    var member_id : String?

//    fileprivate lazy var jsonModel : JSON = {
//        let jsonModel : JSON = []
//        return jsonModel
//    }()

    fileprivate var jsonModel : JSON = ["count" : "000"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "工程师详情"
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        self.tableView.estimatedRowHeight = 150
        self.tableView.allowsSelection = false
        self.tableView.register(UINib.init(nibName: "HomeCertificateCell", bundle: Bundle.main), forCellReuseIdentifier: "HomeCertificateCell")
        self.tableView.register(UINib.init(nibName: "EngineerDetailCell", bundle: Bundle.main), forCellReuseIdentifier: "EngineerDetailCell")
        self.tableView.register(UINib.init(nibName: "EngineerDetailCell2", bundle: Bundle.main), forCellReuseIdentifier: "EngineerDetailCell2")
        self.tableView.register(UINib.init(nibName: "EngineerCommentCell", bundle: Bundle.main), forCellReuseIdentifier: "EngineerCommentCell")
        self.tableView.register(UINib.init(nibName: "EngineerReplyCell", bundle: Bundle.main), forCellReuseIdentifier: "EngineerReplyCell")
        
        self.loadDetailData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension EngineerDetailViewController{
    func loadDetailData() {
        
        LYProgressHUD.showLoading()
        let params :[String : Any] = ["member_id" : self.member_id!]
        
        NetTools.requestData(type: .post, urlString: HomeEngineerDetailApi, parameters: params, succeed: { (resultDict, error) in
            self.jsonModel = resultDict
            
            self.tableView.reloadData()
            
            LYProgressHUD.dismiss()
        }) { (error) in
            LYProgressHUD.dismiss()
            LYProgressHUD.showError(error!)
        }
    }
}

extension EngineerDetailViewController{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.jsonModel["count"].stringValue == "000"{
            return 0
        }
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.jsonModel["count"].stringValue == "000"{
            return 0
        }
        
        switch section {
        case 0:
            return 4
        case 1:
            return self.jsonModel["cer_images"].arrayValue.count + 1
        case 2:
            if self.jsonModel["evaluation"].arrayValue.count == 2{
                if self.jsonModel["evaluation"].arrayValue[0]["reply_list"].arrayValue.count > 0{
                    if self.jsonModel["evaluation"].arrayValue[1]["reply_list"].arrayValue.count > 0{
                        return 4
                    }else{
                        return 3
                    }
                }else if self.jsonModel["evaluation"].arrayValue[1]["reply_list"].arrayValue.count > 0{
                    return 3
                }else{
                    return 2
                }
            }else if self.jsonModel["evaluation"].arrayValue.count == 1{
                if self.jsonModel["evaluation"].arrayValue[0]["reply_list"].arrayValue.count > 0{
                    return 2
                }else{
                    return 1
                }
            }
            return 0
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerDetailCell", for: indexPath) as! EngineerDetailCell
                cell.jsonModel = self.jsonModel
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerDetailCell2", for: indexPath) as! EngineerDetailCell2
                if indexPath.row == 1{
                    var serverRangeArr : Array<String> = Array<String>()
                    for subJson in jsonModel["service_sector"].arrayValue {
                        serverRangeArr.append(subJson["gc_name"].stringValue)
                    }
                    cell.typeLbl.text = "技能领域"
                    cell.contentLbl.text = serverRangeArr.joined(separator: ",")
                }else if indexPath.row == 2{
                    cell.typeLbl.text = "擅长品牌"
                    if jsonModel["service_brand"].stringValue.isEmpty{
                        cell.contentLbl.text = "未设置"
                    }else{
                        cell.contentLbl.text = jsonModel["service_brand"].stringValue
                    }
                }else{
                    cell.typeLbl.text = "从业年限"
                    cell.contentLbl.text = jsonModel["working_year"].stringValue + "年"
                }
                return cell
            }
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCertificateCell", for: indexPath) as! HomeCertificateCell
            if indexPath.row == 0{
                cell.titleLbl.text = "资质证书"
                cell.imgV.image = #imageLiteral(resourceName: "img_certificate")
                if self.jsonModel["cer_images"].arrayValue.count == 0{
                    cell.imgV.isHidden = true
                }
            }else{
                if self.jsonModel["cer_images"].arrayValue.count > indexPath.row - 1{
                    cell.titleLbl.text = self.jsonModel["cer_images"].arrayValue[indexPath.row - 1]["cer_image_name"].stringValue
                    cell.imgV.setHeadImageUrlStr(self.jsonModel["cer_images"].arrayValue[indexPath.row - 1]["cer_image"].stringValue)
                    cell.imgV.isHidden = false
                }
            }
            return cell
        case 2:
            if self.jsonModel["evaluation"].arrayValue.count == 2{
                if self.jsonModel["evaluation"].arrayValue[0]["reply_list"].arrayValue.count > 0{
                    if self.jsonModel["evaluation"].arrayValue[1]["reply_list"].arrayValue.count > 0{
                        if indexPath.row == 0{
                            let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerCommentCell", for: indexPath) as! EngineerCommentCell
                            cell.jsonModel = self.jsonModel["evaluation"].arrayValue[0]
                            return cell
                        }else if indexPath.row == 1{
                            let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerReplyCell", for: indexPath) as! EngineerReplyCell
                            cell.jsonModel = self.jsonModel["evaluation"].arrayValue[0]
                            return cell
                        }else if indexPath.row == 2{
                            let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerCommentCell", for: indexPath) as! EngineerCommentCell
                            cell.jsonModel = self.jsonModel["evaluation"].arrayValue[1]
                            return cell
                        }else{
                            let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerReplyCell", for: indexPath) as! EngineerReplyCell
                            cell.jsonModel = self.jsonModel["evaluation"].arrayValue[1]
                            return cell
                        }
                    }else{
                        if indexPath.row == 0{
                            let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerCommentCell", for: indexPath) as! EngineerCommentCell
                            cell.jsonModel = self.jsonModel["evaluation"].arrayValue[0]
                            return cell
                        }else if indexPath.row == 1{
                            let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerReplyCell", for: indexPath) as! EngineerReplyCell
                            cell.jsonModel = self.jsonModel["evaluation"].arrayValue[0]
                            return cell
                        }else if indexPath.row == 2{
                            let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerCommentCell", for: indexPath) as! EngineerCommentCell
                            cell.jsonModel = self.jsonModel["evaluation"].arrayValue[1]
                            return cell
                        }
                    }
                }else if self.jsonModel["evaluation"].arrayValue[1]["reply_list"].arrayValue.count > 0{
                    if indexPath.row == 0{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerCommentCell", for: indexPath) as! EngineerCommentCell
                        cell.jsonModel = self.jsonModel["evaluation"].arrayValue[0]
                        return cell
                    }else if indexPath.row == 1{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerCommentCell", for: indexPath) as! EngineerCommentCell
                        cell.jsonModel = self.jsonModel["evaluation"].arrayValue[1]
                        return cell
                    }else if indexPath.row == 2{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerReplyCell", for: indexPath) as! EngineerReplyCell
                        cell.jsonModel = self.jsonModel["evaluation"].arrayValue[1]
                        return cell
                    }
                }else{
                    if indexPath.row == 0{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerCommentCell", for: indexPath) as! EngineerCommentCell
                        cell.jsonModel = self.jsonModel["evaluation"].arrayValue[0]
                        return cell
                    }else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerCommentCell", for: indexPath) as! EngineerCommentCell
                        cell.jsonModel = self.jsonModel["evaluation"].arrayValue[1]
                        return cell
                    }
                }
            }else if self.jsonModel["evaluation"].arrayValue.count == 1{
                if self.jsonModel["evaluation"].arrayValue[0]["reply_list"].arrayValue.count > 0{
                    if indexPath.row == 0{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerCommentCell", for: indexPath) as! EngineerCommentCell
                        cell.jsonModel = self.jsonModel["evaluation"].arrayValue[0]
                        return cell
                    }else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerReplyCell", for: indexPath) as! EngineerReplyCell
                        cell.jsonModel = self.jsonModel["evaluation"].arrayValue[0]
                        return cell
                    }
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EngineerCommentCell", for: indexPath) as! EngineerCommentCell
                    cell.jsonModel = self.jsonModel["evaluation"].arrayValue[0]
                    return cell
                }
            }
            
        case 3:
            let cell = UITableViewCell()
            let btn = UIButton(frame:CGRect(x:40, y:15, width:kScreenW - 80, height:50))
            btn.backgroundColor = Normal_Color
            btn.setTitle("查看更多评价", for: .normal)
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.addTarget(self, action: #selector(EngineerDetailViewController.moreCommentAction), for: .touchUpInside)
            btn.clipsToBounds = true
            btn.layer.cornerRadius = 25
            cell.addSubview(btn)
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0{
            return 70
        }
        if indexPath.section == 3{
            return 80
        }
        return UITableViewAutomaticDimension
    }
    
    @objc func moreCommentAction() {
        let commentVC = CommentListViewController()
        commentVC.member_id = self.jsonModel["member_id"].stringValue
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2{
            let view = UIView(frame:CGRect(x:0, y:0, width:kScreenW, height:30))
            view.backgroundColor = UIColor.white
            let lbl = UILabel(frame:CGRect(x:10, y:0, width:kScreenW-10, height:30))
            lbl.textAlignment = .left
            lbl.font = UIFont.systemFont(ofSize: 15.0)
            lbl.textColor = UIColor.RGBS(s: 33)
            lbl.text = "口碑评价"
            view.addSubview(lbl)
            return view
        }
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 30
        }
        return 0
    }
}

/**
 {
	repCode = "00",
	repMsg = "",
	listData = 	{
 service_sector = 	(
 {
 gc_name = "X86服务器",
 },
 {
 gc_name = "监控设备",
 },
 {
 gc_name = "数据库",
 },
 ),
 cer_images = 	(
 {
 cer_image = "http://10.216.2.11/UPLOAD/sys/2017-06-20/~UPLOAD~sys~2017-06-20@1497964445.png",
 cer_image_name = "测试",
 },
 ),
 working_year = 1,
 is_real = "1",
 member_truename = "16",
 evaluation = 	(
 {
 content = "完成",
 time = "1496915412",
 eval_id = "113",
 member_truename = "12",
 member_id = "1009",
 member_avatar = "http://10.216.2.11/UPLOAD/sys/2017-06-12/~UPLOAD~sys~2017-06-12@1497274993.jpg240",
 stars = "5",
 reply_list = 	(
 {
 member_truename = "16",
 member_avatar = "http://10.216.2.11/UPLOAD/sys/2017-06-06/~UPLOAD~sys~2017-06-06@1496757625.jpg240",
 member_id = "1005",
 content = "测试你的时候才来后悔没买的是什么鬼？测试你的时候我们就要多注意休息？测试你的心是一个测试看看你自己不知道怎么着吧嗒掉落物品保险柜？测试你的心都碎了一个月就有多美瘦身的功效？测试你的心在一起就会！测试结果的事情？测试你的心是最棒的确是不是么么哒。测试结果是好是在我心里是最大限度减少到目前的情况下",
 time = "1498553710",
 },
 ),
 },
 {
 content = "tggvbb",
 time = "1496246141",
 eval_id = "104",
 member_truename = "15",
 member_id = "1006",
 member_avatar = "http://10.216.2.11/UPLOAD/sys/2017-05-31/~UPLOAD~sys~2017-05-31@1496235695.jpg240",
 stars = "5",
 reply_list = 	(
 ),
 },
 ),
 member_id = "1005",
 member_avatar = "http://10.216.2.11/UPLOAD/sys/2017-06-06/~UPLOAD~sys~2017-06-06@1496757625.jpg240",
 service_brand = "",
	},
 }

 */
