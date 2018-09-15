//
//  TestChooseAddressViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/2/7.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class TestChooseAddressViewController: BaseTableViewController {

    fileprivate var resultJson : JSON = []
    
    var chooseAddressBlock : ((JSON) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "七小服收货地址"

        self.tableView.backgroundColor = BG_Color
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib.init(nibName: "TestChooseAddressCell", bundle: Bundle.main), forCellReuseIdentifier: "TestChooseAddressCell")
        
        self.loadAddressData()
    }

    func loadAddressData() {
        NetTools.requestData(type: .post, urlString: TestChooseAdderessApi, succeed: { (resultJson, msg) in
            self.resultJson = resultJson
            self.tableView.reloadData()
        }) { (error) in
            LYProgressHUD.showError(error ?? "请求失败，请返回重试")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.resultJson.arrayValue.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestChooseAddressCell", for: indexPath) as! TestChooseAddressCell
        if self.resultJson.arrayValue.count > indexPath.row{
            let subJson = self.resultJson.arrayValue[indexPath.row]
            cell.subJson = subJson
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.resultJson.arrayValue.count > indexPath.row{
            let subJson = self.resultJson.arrayValue[indexPath.row]
            if self.chooseAddressBlock != nil{
                self.chooseAddressBlock!(subJson)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.resultJson.arrayValue.count > indexPath.row{
            let subJson = self.resultJson.arrayValue[indexPath.row]
            let size = subJson[""].stringValue.sizeFit(width: kScreenW-16, height: CGFloat(MAXFLOAT), fontSize: 14)
            if size.height > 20{
                return 55 + size.height
            }else{
                return 75
            }
        }
        return 0
    }

}
