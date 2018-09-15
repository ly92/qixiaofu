//
//  MachineTypeView.swift
//  qixiaofu
//
//  Created by ly on 2017/9/21.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON


class MachineTypeView: UIView {
    var parentVC : UIViewController!
    var dataArray = Array<Dictionary<String, String>>(){
        didSet{
            self.tableView.reloadData()
        }
    }
    //1:工程师创建。2:工程师修改。3:工程师查看 4:客户查看
    var showType = 1{
        didSet{
            self.tableView.reloadData()
        }
    }
    var dataChangedBlock : ((Array<Dictionary<String, String>>) -> Void)?
    
    fileprivate var tableView: UITableView = UITableView()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        
        self.frame = frame
        self.backgroundColor = UIColor.clear
        
        self.setUpTable()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpTable() {
        self.tableView.frame = self.bounds
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.isScrollEnabled = false
        self.tableView.register(UINib.init(nibName: "MachineTypeCell", bundle: Bundle.main), forCellReuseIdentifier: "MachineTypeCell")
        
        self.addSubview(self.tableView)
    }
    
}


extension MachineTypeView : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let height  = CGFloat(self.dataArray.count * 35)
        if self.h != height{
            self.h = height
            self.tableView.h = height
        }
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MachineTypeCell", for: indexPath) as! MachineTypeCell
        cell.showType = self.showType
        cell.parentVC = self.parentVC
        
        if self.dataArray.count > indexPath.row{
            let dict = self.dataArray[indexPath.row]
            cell.leftTF.text = dict["equipment_type"]
            cell.rightTF.text = dict["equipment_pn"]
        }
        
        if indexPath.row == 0{
            cell.reduceBtn.isHidden = true
        }
        cell.operationBlock = {type in
            //1:add 2:reduce
            if type == 1{
                self.dataArray.append(Dictionary<String, String>())
                self.tableView.reloadData()
            }else{
                if self.dataArray.count > indexPath.row{
                    self.dataArray.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
            }
            if self.dataChangedBlock != nil{
                self.dataChangedBlock!(self.dataArray)
            }
        }
        cell.editDoneBlock = {() in
            var left = ""
            if !(cell.leftTF.text?.isEmpty)! {
                left = cell.leftTF.text!
            }
            var right = ""
            if !(cell.rightTF.text?.isEmpty)!{
                right = cell.rightTF.text!
            }
            if self.dataArray.count > indexPath.row{
                var json = self.dataArray[indexPath.row]
                json["equipment_type"] = left
                json["equipment_pn"] = right
                self.dataArray.remove(at: indexPath.row)
                self.dataArray.insert(json, at: indexPath.row)
                if self.dataChangedBlock != nil{
                    self.dataChangedBlock!(self.dataArray)
                }
            }
        }
        
            return cell
    }
}


