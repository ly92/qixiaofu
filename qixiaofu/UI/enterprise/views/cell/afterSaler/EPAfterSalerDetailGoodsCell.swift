//
//  EPAfterSalerDetailGoodsCell.swift
//  qixiaofu
//
//  Created by ly on 2018/5/23.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPAfterSalerDetailGoodsCell: UITableViewCell {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var priceLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tableView.register(UINib.init(nibName: "EPChooseSnCell", bundle: Bundle.main), forCellReuseIdentifier: "EPChooseSnCell")
    }
    
    var orderJson = JSON(){
        didSet{
            self.tableView.reloadData()
            
            var num = 0
            var totalPrice : Float = 0
            for goods in orderJson["goods"].arrayValue{
                totalPrice += goods["return_price"].stringValue.floatValue
                num += goods["snprice"].arrayValue.count
            }
            if orderJson["type"].stringValue.intValue == 1{
                self.priceLbl.text = "共" + String.init(format: "%d", num) + "件商品 退款金额：¥" + String.init(format: "%.2f", totalPrice)
            }else{
                self.priceLbl.text = "共" + String.init(format: "%d", num) + "件商品"
            }
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}



extension EPAfterSalerDetailGoodsCell : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.orderJson["goods"].arrayValue.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.orderJson["goods"].arrayValue.count > section{
            let json = self.orderJson["goods"].arrayValue[section]
            return json["snprice"].arrayValue.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EPChooseSnCell", for: indexPath) as! EPChooseSnCell
        if self.orderJson["goods"].arrayValue.count > indexPath.section{
            let json = self.orderJson["goods"].arrayValue[indexPath.section]
            if json["snprice"].arrayValue.count > indexPath.row{
                cell.snLbl.text = "SN: " + json["snprice"].arrayValue[indexPath.row]["goods_sn"].stringValue
            }
            cell.imgVW.constant = 0
            cell.priceLbl.text = "实付 ¥" + json["snprice"].arrayValue[indexPath.row]["goods_price"].stringValue
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.orderJson["goods"].arrayValue.count > indexPath.section{
            let json = self.orderJson["goods"].arrayValue[indexPath.section]
            if json["snprice"].arrayValue.count > indexPath.row{
                return 30
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 50))
//        view.backgroundColor = BG_Color
        let subView = UIView(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 50))
        subView.backgroundColor = UIColor.white
        let imgV = UIImageView(frame: CGRect.init(x: 15, y: 5, width: 40, height: 40))
        subView.addSubview(imgV)
        let lbl = UILabel(frame: CGRect.init(x: 60, y: 15, width: kScreenW - 70, height: 20))
        lbl.textColor = Text_Color
        lbl.font = UIFont.systemFont(ofSize: 14.0)
        subView.addSubview(lbl)
        view.addSubview(subView)
        if self.orderJson["goods"].arrayValue.count > section{
            let json = self.orderJson["goods"].arrayValue[section]
            imgV.setImageUrlStr(json["goods_img"].stringValue)
            lbl.text = json["goods_name"].stringValue
        }
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
