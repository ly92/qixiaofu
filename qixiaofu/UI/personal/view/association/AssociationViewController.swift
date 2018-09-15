//
//  AssociationViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/9.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias AssociationViewControllerBlock = (String,String) ->Void
class AssociationViewController: BaseTableViewController {

    var isTransferOrder = false//是否为转移订单时选择关联用户
    var transferBlock : AssociationViewControllerBlock?
    
    
    fileprivate var teacherJson : JSON = []//我的师傅-我的上级 A
    fileprivate var studentS : Array<JSON> = Array<JSON>()//我的徒弟-我的下级 B，如果当前用户为B则存放此B的C
    fileprivate var grandStudentS : Dictionary<String, Array<JSON>> = Dictionary<String, Array<JSON>>()//我下级的下级 C
    
    fileprivate var selectedIndex = -1 //仅在A用户存在子和孙时有用
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "关联用户"
        
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_Color
        self.tableView.register(UINib.init(nibName: "AssociationCell", bundle: Bundle.main), forCellReuseIdentifier: "AssociationCell")
        
        //
        self.loadData()
        
        self.tableView.es.addPullToRefresh {
            self.teacherJson = []
            self.studentS.removeAll()
            self.grandStudentS.removeAll()
            self.loadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        self.studentS.removeAll()
        self.grandStudentS.removeAll()
        
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: AssociationApi, succeed: { (result, msg) in
            self.tableView.es.stopPullToRefresh()
            //处理数据
            self.setUpData(result: result)
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    func setUpData(result : JSON) {
        //A 级数据
        self.teacherJson = result["user_to_me"]
        //B 级数据
        for subJson in result["me_to_user"].arrayValue {
            if subJson["jibie"].stringValue == "B"{
                self.studentS.append(subJson)
                //判断是否有此B的索引
                if !self.grandStudentS.keys.contains(subJson["member_id"].stringValue){
                    let arr = Array<JSON>()
                    self.grandStudentS[subJson["member_id"].stringValue] = arr
                }
            }else{
                //C 级数据
                //判断是否有此B的索引
                if self.grandStudentS.keys.contains(subJson["level2_id"].stringValue){
                    var arr = self.grandStudentS[subJson["level2_id"].stringValue]
                    arr?.append(subJson)
                    self.grandStudentS[subJson["level2_id"].stringValue] = arr
                }else{
                    //B用户的C
                    self.studentS.append(subJson)
                }
            }
        }
        
        self.tableView.reloadData()
        
        LYProgressHUD.dismiss()
    }
    
    
    
}

extension AssociationViewController{
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.teacherJson.isEmpty{
            //A用户，只有下级
            return self.studentS.count
        }else{
            if self.studentS.count > 0{
                //B用户有子时
                return 2
            }else{
                //B用户无子时，或者C用户
                return 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.teacherJson.isEmpty{
            //A用户，只有下级
            if self.selectedIndex == section{
                if self.studentS.count > section{
                    let bJson = self.studentS[section]
                    if self.grandStudentS.keys.contains(bJson["member_id"].stringValue){
                        let arr = self.grandStudentS[bJson["member_id"].stringValue]
                        return arr!.count + 1
                    }
                }
            }
            return 1
        }else{
            if self.studentS.count > 0{
                //B用户有子时
                if section == 0{
                    return 1
                }else{
                    return self.studentS.count
                }
            }else{
                //B用户无子时，或者C用户
                return 1
            }
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssociationCell", for: indexPath) as! AssociationCell
        //防止cell复用造成错误
        cell.iconLeftDis.constant = 8
        cell.arrowBtn.setImage(#imageLiteral(resourceName: "btn_next"), for: .normal)
        cell.refreshBlock = {() in
            self.loadData()
        }
        cell.rightArrowSelected = nil
        if self.teacherJson.isEmpty{
            //A用户，只有下级
            if indexPath.row == 0{
                cell.rightArrowSelected = {() in
                    self.selectedIndex = self.selectedIndex == indexPath.section ? -1 : indexPath.section
                    self.tableView.reloadData()
                }
                cell.subJson = self.studentS[indexPath.section]
//                if self.selectedIndex == indexPath.section{
//                    cell.arrowBtn.setImage(#imageLiteral(resourceName: "up_arrow"), for: .normal)
//                }else{
//                    cell.arrowBtn.setImage(#imageLiteral(resourceName: "down_arrow"), for: .normal)
//                }
            }else{
                if self.studentS.count > indexPath.section{
                    let bJson = self.studentS[indexPath.section]
                    if self.grandStudentS.keys.contains(bJson["member_id"].stringValue){
                        let arr = self.grandStudentS[bJson["member_id"].stringValue]
                        if arr!.count > indexPath.row - 1{
                            cell.subJson = arr![indexPath.row - 1]
                            cell.iconLeftDis.constant = 25
                        }
                    }
                }
            }
        }else{
            if self.studentS.count > 0{
                //B用户有子时
                if indexPath.section == 0{
                    cell.subJson = self.teacherJson
                }else{
                    if self.studentS.count > indexPath.row{
                        cell.subJson = self.studentS[indexPath.row]
                    }
                }
            }else{
                //B用户无子时，或者C用户
                cell.subJson = self.teacherJson
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var receiverId = ""
        var receiverName = ""
        if self.teacherJson.isEmpty{
            //A用户，只有下级
            if indexPath.row == 0{
                receiverId = self.studentS[indexPath.section]["member_id"].stringValue
                receiverName = self.studentS[indexPath.section]["member_name"].stringValue
                
            }else{
                if self.studentS.count > indexPath.section{
                    let bJson = self.studentS[indexPath.section]
                    if self.grandStudentS.keys.contains(bJson["member_id"].stringValue){
                        let arr = self.grandStudentS[bJson["member_id"].stringValue]
                        if arr!.count > indexPath.row - 1{
                            receiverId = arr![indexPath.row - 1]["member_id"].stringValue
                            receiverName = arr![indexPath.row - 1]["member_name"].stringValue
                        }
                    }
                }
            }
        }else{
            if self.studentS.count > 0{
                //B用户有子时
                if indexPath.section == 0{
                    receiverId = self.teacherJson["member_id"].stringValue
                    receiverName = self.teacherJson["member_name"].stringValue
                }else{
                    if self.studentS.count > indexPath.row{
                        receiverId = self.studentS[indexPath.row]["member_id"].stringValue
                        receiverName = self.studentS[indexPath.row]["member_name"].stringValue
                    }
                }
            }else{
                //B用户无子时，或者C用户
                receiverId = self.teacherJson["member_id"].stringValue
                receiverName = self.teacherJson["member_name"].stringValue
            }
        }
        
        if self.isTransferOrder{
            //转移对象
            if self.transferBlock != nil{
                self.transferBlock!(receiverId,receiverName)
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            //用户详情
            let engineerDetailVC = EngineerDetailViewController()
            engineerDetailVC.member_id = receiverId
            self.navigationController?.pushViewController(engineerDetailVC, animated: true)
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame:CGRect.init(x: 0, y: 0, width: kScreenW, height: 30))
        view.backgroundColor = BG_Color
        let lbl = UILabel(frame:CGRect.init(x: 15, y: 8, width: kScreenW - 30, height: 20))
        lbl.textColor = Text_Color
        lbl.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(lbl)

        if self.teacherJson.isEmpty{
            //A用户，只有下级
            if section == 0{
                lbl.text = "我邀请的"
                return view
            }
        }else{
            if self.studentS.count > 0{
                //B用户有子时
                if section == 0{
                    lbl.text = "邀请我的"
                    
                }else{
                    lbl.text = "我邀请的"
                }
                return view
            }else{
                //B用户无子时，或者C用户
                lbl.text = "邀请我的"
                return view
            }
        }

        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.teacherJson.isEmpty{
            //A用户，只有下级
            if section == 0{
                return 30
            }
        }else{
            if self.studentS.count > 0{
                //B用户有子时
                return 30
            }else{
                //B用户无子时，或者C用户
                return 30
            }
        }
        return 0.001
    }

}
