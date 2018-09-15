//
//  ChooseAreaViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/28.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias ChooseAreaViewControllerBlock = (String,String,String,Array<String>) -> Void
class ChooseAreaViewController: BaseViewController {
    
    var chooseAeraBlock : ChooseAreaViewControllerBlock?
    
    

    var btn1 = UIButton()
    var btn2 = UIButton()
    var btn3 = UIButton()
    var line = UIView()
    var tableView = UITableView()
    
    var dataArray : JSON = []
    
    var provinceId = ""//省
    var provinceName = ""//省
    var cityId = ""//市
    var cityName = ""//市
    var areaId = ""//区
    var areaName = ""//区
    
    var chooseIndex : Int = 0 //0未选 1已选省 2已选市 3已选区
    var requestId = "0"
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "选择地区"
        
        self.prepareUIViews()
        
        self.loadAreaData()
    }

    func prepareUIViews() {
        
        //基础设置
        self.view.backgroundColor = BG_Color
        
        //1.顶部已选地区
        let topView = UIView(frame:CGRect.init(x: 0, y: 1, width: kScreenW, height: 44))
        self.btn1 = UIButton(frame:CGRect.init(x: 0, y: 0, width: kScreenW / 3.0, height: 40))
        self.btn1.setTitleColor(Text_Color, for: .normal)
        self.btn1.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        self.btn1.addTarget(self, action: #selector(ChooseAreaViewController.provinceAction), for: .touchUpInside)
        self.btn1.setTitle("选择", for: .normal)
        topView.addSubview(self.btn1)
        
        self.btn2 = UIButton(frame:CGRect.init(x: kScreenW / 3.0, y: 0, width: kScreenW / 3.0, height: 40))
        self.btn2.setTitleColor(Text_Color, for: .normal)
        self.btn2.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        self.btn2.addTarget(self, action: #selector(ChooseAreaViewController.cityAction), for: .touchUpInside)
        topView.addSubview(self.btn2)
        
        self.btn3 = UIButton(frame:CGRect.init(x: kScreenW / 3.0 * 2.0, y: 0, width: kScreenW / 3.0, height: 40))
        self.btn3.setTitleColor(Text_Color, for: .normal)
        self.btn3.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        self.btn3.addTarget(self, action: #selector(ChooseAreaViewController.areaAction), for: .touchUpInside)
        topView.addSubview(self.btn3)
        
        self.view.addSubview(topView)
        
        //line
        self.line = UIView(frame:CGRect.init(x: 0, y: 41, width: kScreenW / 3.0, height: 1))
        self.line.backgroundColor = Normal_Color
        topView.addSubview(self.line)
        
        
        //2.列表
        self.tableView = UITableView(frame:CGRect.init(x: 0, y: 53, width: kScreenW, height: kScreenH - 53 - 64))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = BG_Color
        self.view.addSubview(tableView)
        
    }
    
    @objc func provinceAction() {
        self.chooseIndex = 0
        self.line.x = 0
        self.requestId = "0"
        self.loadAreaData()
    }
    
    @objc func cityAction() {
        self.chooseIndex = 1
        self.line.x = kScreenW / 3.0
        self.requestId = self.provinceId
        self.loadAreaData()
    }
    
    @objc func areaAction() {
        
    }
    
    
    func loadAreaData() {
        var params : [String : Any] = [:]
        var url = ""
        params["store_id"] = "1"
        params["area_id"] = requestId
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            url = EPAddressInfoListApi
        }else{
            url = AddressAreaListApi
        }
        NetTools.requestData(type: .post, urlString: url, parameters: params, succeed: { (result, msg) in
            self.dataArray = result
            self.tableView.reloadData()
        }) { (error) in
            self.dataArray = []
            self.tableView.reloadData()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension ChooseAreaViewController : UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.arrayValue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ChooseAreaViewCell")
        if cell == nil{
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "ChooseAreaViewCell")
        }
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        cell?.textLabel?.textColor = Text_Color
        if self.dataArray.arrayValue.count > indexPath.row{
            cell?.textLabel?.text = self.dataArray.arrayValue[indexPath.row]["area_name"].stringValue
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.dataArray.arrayValue.count > indexPath.row{
            let id = self.dataArray.arrayValue[indexPath.row]["area_id"].stringValue
            let name = self.dataArray.arrayValue[indexPath.row]["area_name"].stringValue
            
            requestId = id
            
            switch self.chooseIndex {
            case 0:
                self.provinceId = id
                self.provinceName = name
                self.btn1.setTitle(name, for: .normal)
                self.btn2.setTitle("", for: .normal)
                self.btn3.setTitle("", for: .normal)
                self.chooseIndex = 1
                self.line.x = 0
            case 1:
                self.cityId = id
                self.cityName = name
                self.btn2.setTitle(name, for: .normal)
                self.btn3.setTitle("", for: .normal)
                self.chooseIndex = 2
                self.line.x = kScreenW / 3.0
            case 2:
                self.areaId = id
                self.areaName = name
                self.btn3.setTitle(name, for: .normal)
                self.chooseIndex = 3
                
                if self.chooseAeraBlock != nil{
                    self.chooseAeraBlock!(self.provinceId,self.cityId,self.areaId,[self.provinceName,self.cityName,self.areaName])
                    self.navigationController?.popViewController(animated: true)
                }
                
            default:
                print("")
            }
            
            self.loadAreaData()
        }
        
    }
}
