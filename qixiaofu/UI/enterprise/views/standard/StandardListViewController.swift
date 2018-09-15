//
//  StandardListViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/3.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class StandardListViewController: BaseViewController {
    class func spwan() -> StandardListViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! StandardListViewController
    }
    
    var isPackageStandard = false
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var resultJson = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.isPackageStandard{
            self.navigationItem.title = "包装标准"
            self.loadPackageStandradData()
        }else{
            self.navigationItem.title = "测试标准"
            self.loadTestStandradData()
        }
        
        self.tableView.register(UINib.init(nibName: "AddStandardCell", bundle: Bundle.main), forCellReuseIdentifier: "AddStandardCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addStandardAction() {
        let addStandardVC = AddStandardViewController.spwan()
        addStandardVC.isAdd = true
        addStandardVC.refreshBlock = {() in
            if self.isPackageStandard{
                self.loadPackageStandradData()
            }else{
                self.loadTestStandradData()
            }
        }
        addStandardVC.isPackageStandard = self.isPackageStandard
        self.navigationController?.pushViewController(addStandardVC, animated: true)
    }
    
    //加载包装标准数据
    func loadPackageStandradData() {
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: PackageStandardListApi, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            self.resultJson = resultJson
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取数据失败，请重试！")
        }
    }
    
    //加载测试标准数据
    func loadTestStandradData() {
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: TestStandardListApi, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            self.resultJson = resultJson
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取数据失败，请重试！")
        }
    }


}

extension StandardListViewController : UITableViewDelegate, UITableViewDataSource{
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.resultJson["qixiaofu"].arrayValue.count
        }else{
            return self.resultJson["personal"].arrayValue.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "StandardListCell")
        if cell == nil{
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "StandardListCell")
        }
        cell?.textLabel?.textColor = Text_Color
        cell?.detailTextLabel?.textColor = UIColor.lightGray
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0)
        cell?.selectionStyle = .none
        
        let line = UIView(frame: CGRect.init(x: 0, y: 44, width: kScreenW, height: 1))
        line.backgroundColor = BG_Color
        cell?.addSubview(line)

        if indexPath.section == 0{
            if self.resultJson["qixiaofu"].arrayValue.count > indexPath.row{
                let json = self.resultJson["qixiaofu"].arrayValue[indexPath.row]
                if self.isPackageStandard{
                    cell?.textLabel?.text = json["package_name"].stringValue
                }else{
                    cell?.textLabel?.text = json["test_name"].stringValue
                }
                cell?.detailTextLabel?.text = "可使用"
            }
        }else{
            if self.resultJson["personal"].arrayValue.count > indexPath.row{
                let json = self.resultJson["personal"].arrayValue[indexPath.row]
                if self.isPackageStandard{
                    cell?.textLabel?.text = json["package_name"].stringValue
                }else{
                    cell?.textLabel?.text = json["test_name"].stringValue
                }
                let audit_state = json["audit_state"].stringValue.intValue //审核状态 0为待审核 1为审核通过 2为审核不通过
                if audit_state == 0{
                    cell?.detailTextLabel?.text = "审核中"
                }else if audit_state == 1{
                    cell?.detailTextLabel?.text = "可使用"
                }else if audit_state == 2{
                    cell?.detailTextLabel?.text = "未审核通过"
                }
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 50))
        let subView = UIView(frame: CGRect.init(x: 0, y: 9, width: kScreenW, height: 40))
        view.backgroundColor = BG_Color
        subView.backgroundColor = UIColor.white
        
        let lbl = UILabel(frame: CGRect.init(x: 10, y: 10, width: kScreenW-20, height: 20))
        lbl.font = UIFont.systemFont(ofSize: 16.0)
        lbl.textColor = Text_Color
        
        if section == 0{
            lbl.text = "七小服标准"
        }else{
            lbl.text = "个人标准"
        }
        
        view.addSubview(subView)
        subView.addSubview(lbl)
        
        return view
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0{
            if self.resultJson["qixiaofu"].arrayValue.count > indexPath.row{
                let json = self.resultJson["qixiaofu"].arrayValue[indexPath.row]
                let detailVC = QxfStandDetailViewController.spwan()
                detailVC.resultJson = json
                detailVC.isPackageStandard = self.isPackageStandard
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }else{
            if self.resultJson["personal"].arrayValue.count > indexPath.row{
                let json = self.resultJson["personal"].arrayValue[indexPath.row]
                let addStandardVC = AddStandardViewController.spwan()
                addStandardVC.resultJson = json
                addStandardVC.refreshBlock = {() in
                    if self.isPackageStandard{
                        self.loadPackageStandradData()
                    }else{
                        self.loadTestStandradData()
                    }
                }
                addStandardVC.isPackageStandard = self.isPackageStandard
                self.navigationController?.pushViewController(addStandardVC, animated: true)
            }
        }
    }
    
    
    //MARK:删除
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0{
            return UITableViewCellEditingStyle.none
        }
        return UITableViewCellEditingStyle.delete
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            if editingStyle == .delete{
                //删除
                var params : [String:String] = [:]
                var url = ""
                let json = self.resultJson["personal"].arrayValue[indexPath.row]
                params["id"] = json["id"].stringValue
                if self.isPackageStandard{
                    url = DeletePackageStandardApi
                }else{
                    url = DeleteTestStandardApi
                }
                LYProgressHUD.showLoading()
                NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
                    LYProgressHUD.showSuccess("操作成功！")
                    if self.isPackageStandard{
                        self.loadPackageStandradData()
                    }else{
                        self.loadTestStandradData()
                    }
                }) { (error) in
                    LYProgressHUD.showError(error ?? "操作失败，请重试！")
                }
            }
        }
    }
    
}
