//
//  LogisticsInfoViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/4/16.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 快递单号查询：
 http://10.216.2.11/tp.php/Home/Public/kuaidi
 number=586927204779    //string     快递单号
 
 
 
 deliverystatus : 1:途中 2:派件中 3:已签收 4：派送失败
 
 */
class LogisticsInfoViewController: BaseTableViewController {

    var number = "586927204779"
    fileprivate var resultJson = JSON()
    
//    let arr = ["顺丰速运 已收取快件","快件在【北京大观园营业点】已装车,准备发往下一站","快件在【北京首都机场集散中心2】已装车,准备发往 【济南】","快件在【济南】已装车,准备发往 【济南天桥翡翠郡营业点】","快件派送不成功(因电话无人接听\\/关机\\/无信号，暂无法联系到收方客户),正在处理中,待再次派送","正在派送途中,请您准备签收(派件人:王伦国,电话:15715313860","快件交给王伦国，正在派送途中（联系电话：15715313860）","已签收,感谢使用顺丰,期待再次为您服务"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "物流信息"
        self.tableView.register(LogisticsInfoCell.self, forCellReuseIdentifier: "LogisticsInfoCell")
        self.tableView.separatorStyle = .none
        self.loadLogisticsData()
    }
    
    //加载物流信息
    func loadLogisticsData() {
        //1、物流号为空
        if self.number.isEmpty{
            LYProgressHUD.showError("物流号为空")
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        LYProgressHUD.showLoading()
        var params : [String : Any] = [:]
        params["number"] = self.number
        NetTools.requestData(type: .post, urlString: LogisticsInfoApi, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            if resultJson.isEmpty{
                LYProgressHUD.showError("无此物流信息!")
                self.showEmptyView()
            }else{
                self.resultJson = resultJson
                self.tableView.reloadData()
                self.hideEmptyView()
            }
        }) { (error) in
            LYProgressHUD.showError(error ?? "获取物流信息失败，请重试")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultJson["list"].arrayValue.count
//        return 8
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogisticsInfoCell", for: indexPath) as! LogisticsInfoCell
        if self.resultJson["list"].arrayValue.count > indexPath.row{
            let json = self.resultJson["list"].arrayValue[indexPath.row]
            cell.timeLbl.text = json["time"].stringValue
            cell.descLbl.text = json["status"].stringValue
        }
//        cell.timeLbl.text = "2018-03-13 13:12:17"
//        cell.descLbl.text = self.arr[indexPath.row]
//        let _ = cell.descLbl.resizeHeight()

        return cell
    }
 
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 44))
        view.backgroundColor = UIColor.RGBS(s: 210)
        
        let statusLbl = UILabel()
        let logisticsNameLbl = UILabel()
        let logisticsNumLbl = UILabel()
        statusLbl.textColor = Normal_Color
        statusLbl.font = UIFont.systemFont(ofSize: 16.0)
        statusLbl.textAlignment = .center
        logisticsNameLbl.textColor = Text_Color
        logisticsNameLbl.font = UIFont.systemFont(ofSize: 14.0)
        logisticsNumLbl.textColor = Text_Color
        logisticsNumLbl.font = UIFont.systemFont(ofSize: 12.0)
        view.addSubview(statusLbl)
        view.addSubview(logisticsNameLbl)
        view.addSubview(logisticsNumLbl)
        statusLbl.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalTo(0)
            make.width.equalTo(100)
        }
        logisticsNameLbl.snp.makeConstraints { (make) in
            make.top.equalTo(4)
            make.leading.equalTo(8)
            make.trailing.equalTo(statusLbl.snp.leading)
            make.height.equalTo(21)
        }
        logisticsNumLbl.snp.makeConstraints { (make) in
            make.leading.equalTo(8)
            make.top.equalTo(logisticsNameLbl.snp.bottom)
            make.trailing.equalTo(statusLbl.snp.leading)
            make.height.equalTo(21)
        }
        
        logisticsNameLbl.text = self.resultJson["expName"].stringValue
        logisticsNumLbl.text = "物流号:" + self.resultJson["number"].stringValue
//        logisticsNameLbl.text = "顺丰快递"
//        logisticsNumLbl.text = "物流号:1234567890987654"
        
        let deliverystatus = self.resultJson["deliverystatus"].stringValue.intValue
        if deliverystatus == 1{
            statusLbl.text = "运输中"
        }else if deliverystatus == 2{
            statusLbl.text = "派件中"
        }else if deliverystatus == 3{
            statusLbl.text = "已签收"
        }else if deliverystatus == 4{
            statusLbl.text = "派件失败"
        }else{
            statusLbl.text = "未知状态"
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.resultJson["list"].arrayValue.count > indexPath.row{
            let json = self.resultJson["list"].arrayValue[indexPath.row]
            let str = json["status"].stringValue
            let size = str.sizeFit(width: kScreenW-20, height: CGFloat(MAXFLOAT), fontSize: 12.0)
            if size.height > 20{
                return 35 + size.height
            }
            return 55
        }
        
//        let str = self.arr[indexPath.row]
//        let size = str.sizeFit(width: kScreenW-20, height: CGFloat(MAXFLOAT), fontSize: 12.0)
//        if size.height > 20{
//            return 35 + size.height
//        }
//        return 55
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

}

class LogisticsInfoCell: UITableViewCell {
    
    var timeLbl = UILabel()
    var descLbl = UILabel()
    var line = UIView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.addSubview(self.timeLbl)
        self.addSubview(self.descLbl)
        self.addSubview(self.line)
        self.timeLbl.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(8)
            make.height.equalTo(17)
        }
        
        self.descLbl.snp.makeConstraints { (make) in
            make.top.equalTo(self.timeLbl.snp.bottom)
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.bottom.equalTo(self.snp.bottom).offset(-8)
        }
        
        self.line.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(0)
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(1.0)
        }
        
        
        self.timeLbl.textColor = Text_Color
        self.timeLbl.font = UIFont.systemFont(ofSize: 14.0)
        
        self.descLbl.textColor = UIColor.darkGray
        self.descLbl.font = UIFont.systemFont(ofSize: 12.0)
        self.descLbl.numberOfLines = 0
        
        self.line.backgroundColor = BG_Color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
