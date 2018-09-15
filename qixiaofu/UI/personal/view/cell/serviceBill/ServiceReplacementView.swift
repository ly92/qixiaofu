//
//  ServiceReplacementView.swift
//  qixiaofu
//
//  Created by ly on 2017/9/13.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit


class ServiceReplacementView: UIView {
    
    var dataArray = Array<Dictionary<String, String>>(){
        didSet{
            self.tableView.reloadData()
        }
    }
    //1:工程师创建。2:工程师修改。3:客户确认前工程师查看（可编辑） 4:客户查看 5:客户确认后工程师查看（不可编辑）
    var showType = 1{
        didSet{
            self.tableView.reloadData()
        }
    }
    
    var selectDataBlock : ((Int) -> Void)?
    
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
        
        self.addSubview(self.tableView)
    }
    
}


extension ServiceReplacementView : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showType == 1 || self.showType == 2{
            let height  = CGFloat(self.dataArray.count * 35)
            if self.h != height + 40{
                self.h = height + 40
                self.tableView.h = height + 40
            }
            return self.dataArray.count + 1
        }else{
            let height  = CGFloat(self.dataArray.count * 35)
            if self.h != height{
                self.h = height
                self.tableView.h = height
            }
            return self.dataArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == self.dataArray.count{
            return 40
        }else{
            return 35
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.dataArray.count{
            var cell = tableView.dequeueReusableCell(withIdentifier: "ServiceReplacementViewCell1")
            if cell == nil{
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "ServiceReplacementViewCell1")
            }
            let imgV = UIImageView.init(image: #imageLiteral(resourceName: "service_bill_icon17"))
            imgV.frame = CGRect.init(x: (kScreenW - 175)/2.0, y: 12.5, width: 15, height: 15)
            let lbl = UILabel(frame:CGRect.init(x: (kScreenW - 175)/2.0 + 20, y: 10, width: 130, height: 21))
            lbl.text = "备件使用情况(可选)"
            lbl.textColor = Normal_Color
            lbl.font = UIFont.systemFont(ofSize: 14)
            cell?.addSubview(imgV)
            cell?.addSubview(lbl)
            return cell!
        }else{
            var cell = tableView.dequeueReusableCell(withIdentifier: "ServiceReplacementViewCell2")
            if cell == nil{
                cell = UITableViewCell.init(style: .value1, reuseIdentifier: "ServiceReplacementViewCell2")
            }
            
            if self.showType == 1 || self.showType == 2{
                cell?.accessoryType = .disclosureIndicator
            }else{
                cell?.accessoryType = .none
            }
            
            if self.dataArray.count > indexPath.row{
                let dict = self.dataArray[indexPath.row]
                cell?.textLabel?.text = dict["parts_pn"]
                cell?.textLabel?.textColor = UIColor.darkGray
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
                    cell?.detailTextLabel?.text = dict["store_room"]
            }
            
            let line = UIView(frame:CGRect.init(x: 0, y: 35, width: kScreenW-20, height: 1))
            line.backgroundColor = BG_Color
            cell?.addSubview(line)
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == self.dataArray.count{
            if self.selectDataBlock != nil{
                self.selectDataBlock!(666)
            }
        }else{
//            if self.showType == 1 || self.showType == 2{
                if self.dataArray.count > indexPath.row{
                    if self.selectDataBlock != nil{
                        self.selectDataBlock!(indexPath.row)
                    }
                }
//            }
        }
    }
    
}
