
//
//  EPBillDetailReturnCell.swift
//  qixiaofu
//
//  Created by ly on 2018/5/24.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPBillDetailReturnCell: UITableViewCell {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var priceLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.tableView.register(UINib.init(nibName: "EnterpriseBillDetailCell", bundle: Bundle.main), forCellReuseIdentifier: "EnterpriseBillDetailCell_return")
    }

    var dataArray = JSON(){
        didSet{
            var totalPrice : Float = 0
            for list in dataArray.arrayValue{
                for goods in list["mingxi"].arrayValue{
                    totalPrice += goods["price"].stringValue.floatValue
                }
            }
            self.priceLbl.text = "退款金额：¥" + String.init(format: "%.2f", totalPrice)
            self.tableView.reloadData()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


extension EPBillDetailReturnCell : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.arrayValue.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataArray.arrayValue.count > section{
            let subJson = self.dataArray.arrayValue[section]
            return subJson["mingxi"].arrayValue.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.dataArray.arrayValue.count > indexPath.section{
            let subJson = self.dataArray.arrayValue[indexPath.section]
            if subJson["mingxi"].arrayValue.count > indexPath.row{
                let cell = tableView.dequeueReusableCell(withIdentifier: "EnterpriseBillDetailCell_return", for: indexPath) as! EnterpriseBillDetailCell
                let json = subJson["mingxi"].arrayValue[indexPath.row]
                cell.returnJson = json
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.dataArray.arrayValue.count > indexPath.section{
            let subJson = self.dataArray.arrayValue[indexPath.section]
            if subJson["mingxi"].arrayValue.count > indexPath.row{
                return 25
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 30))
        view.backgroundColor = UIColor.white
        let billLbl = UILabel(frame: CGRect.init(x: 15, y: 6, width: kScreenW - 180, height: 20))
        billLbl.textColor = Text_Color
        billLbl.font = UIFont.systemFont(ofSize: 13.0)
        billLbl.minimumScaleFactor = 0.8
        view.addSubview(billLbl)
        let timeLbl = UILabel(frame: CGRect.init(x: kScreenW - 160, y: 6, width: 150, height: 20))
        timeLbl.textColor = Text_Color
        timeLbl.font = UIFont.systemFont(ofSize: 12.0)
        timeLbl.textAlignment = .right
        view.addSubview(timeLbl)
        if self.dataArray.arrayValue.count > section{
            let subJson = self.dataArray.arrayValue[section]
            billLbl.text = "退货单号：" + subJson["return_no"].stringValue
            timeLbl.text = Date.dateStringFromDate(format: Date.timestampFormatString(), timeStamps: subJson["return_time"].stringValue)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
