//
//  EPAfterSalerChooseSnViewController.swift
//  qixiaofu
//
//  Created by ly on 2018/5/16.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPAfterSalerChooseSnViewController: BaseViewController {
    class func spwan() -> EPAfterSalerChooseSnViewController{
        return self.loadFromStoryBoard(storyBoard: "Enterprise") as! EPAfterSalerChooseSnViewController
    }
    
    var orderJson = JSON()
    @IBOutlet weak var tableView: UITableView!
    fileprivate var selectedSns : Array<String> = Array<String>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "选择SN"
        
        self.tableView.register(UINib.init(nibName: "EPChooseSnCell", bundle: Bundle.main), forCellReuseIdentifier: "EPChooseSnCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAction() {
        if self.selectedSns.count == 0{
            LYProgressHUD.showError("请选择SN！")
            return
        }
        
        var tmpArray : Array<Dictionary<String,String>> = []
        var infoArray : Array<Dictionary<String,String>> = []
        for goods in self.orderJson["goods"].arrayValue{
            var sns : Array<String> = []
            for sn in goods["goods_sn"].arrayValue{
                if self.selectedSns.contains(sn["goods_sn"].stringValue.trim){
                    sns.append(sn["goods_sn"].stringValue.trim)
                }
            }
            if sns.count > 0{
                var dict : Dictionary<String,String> = [:]
                dict["goods_id"] = goods["goods_id"].stringValue
                dict["goods_num"] = String.init(format: "%d", sns.count)
                dict["goods_sn"] = sns.joined(separator: ",")
                dict["order_goods_id"] = goods["order_goods_id"].stringValue
                infoArray.append(dict)
                
                //计算价格，留存数据
                var tmpdict : Dictionary<String,String> = [:]
                tmpdict["goods_sns"] = sns.joined(separator: ",")
                tmpdict["goods_url"] = goods["goods_img"].stringValue
                tmpdict["goods_name"] = goods["goods_name"].stringValue
                let orderPrice = self.orderJson["order_price"].stringValue.floatValue
                let couponPrice = self.orderJson["coupon_price"].stringValue.floatValue
                let goodsPrice = goods["goods_price"].stringValue.floatValue
                let actualPrice = goodsPrice - couponPrice * goodsPrice / orderPrice
                tmpdict["goods_price"] = String.init(format: "%.2f", actualPrice)//分摊优惠券后的价格
                tmpArray.append(tmpdict)
            }
        }
        if infoArray.count == 0{
            LYProgressHUD.showError("出了点问题，请返回重新选择备件")
            return
        }
        
        let infoStr = infoArray.jsonString()
        let submitVC = EPSubmitAfterSalerViewController.spwan()
        submitVC.infoStr = infoStr
        submitVC.tmpArray = tmpArray
        submitVC.orderId = self.orderJson["order_id"].stringValue
        submitVC.addressInfo = self.orderJson["address"]
        self.navigationController?.pushViewController(submitVC, animated: true)
    }
    
    
    

}


extension EPAfterSalerChooseSnViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self
        .orderJson["goods"].arrayValue.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self
            .orderJson["goods"].arrayValue.count > section{
            let json = self.orderJson["goods"].arrayValue[section]
            return json["goods_sn"].arrayValue.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EPChooseSnCell", for: indexPath) as! EPChooseSnCell
        if self
            .orderJson["goods"].arrayValue.count > indexPath.section{
            let json = self.orderJson["goods"].arrayValue[indexPath.section]
            cell.priceLbl.text = "¥ " + json["goods_price"].stringValue
            if json["goods_sn"].arrayValue.count > indexPath.row{
                let subJson = json["goods_sn"].arrayValue[indexPath.row]
                if subJson["goods_state"].stringValue.intValue == 0{
                    cell.snLbl.text = "SN: " + subJson["goods_sn"].stringValue
                    cell.imgVW.constant = 15
                }else if subJson["goods_state"].stringValue.intValue == 1{
                    cell.snLbl.text = "SN: " + subJson["goods_sn"].stringValue + "   已退货"
                    cell.imgVW.constant = 0
                }else if subJson["goods_state"].stringValue.intValue == 2{
                    cell.snLbl.text = "SN: " + subJson["goods_sn"].stringValue + "   已换货"
                    cell.imgVW.constant = 0
                }
                if self.selectedSns.contains(subJson["goods_sn"].stringValue.trim){
                    cell.selectImgV.image = #imageLiteral(resourceName: "btn_checkbox_s")
                }else{
                    cell.selectImgV.image = #imageLiteral(resourceName: "btn_checkbox_n")
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self
            .orderJson["goods"].arrayValue.count > indexPath.section{
            let json = self.orderJson["goods"].arrayValue[indexPath.section]
            if json["goods_sn"].arrayValue.count > indexPath.row{
                return 30
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: kScreenW, height: 60))
        view.backgroundColor = BG_Color
        let subView = UIView(frame: CGRect.init(x: 0, y: 8, width: kScreenW, height: 52))
        subView.backgroundColor = UIColor.white
        let imgV = UIImageView(frame: CGRect.init(x: 15, y: 6, width: 40, height: 40))
        subView.addSubview(imgV)
        let lbl = UILabel(frame: CGRect.init(x: 60, y: 12, width: kScreenW - 70, height: 20))
        lbl.textColor = Text_Color
        lbl.font = UIFont.systemFont(ofSize: 14.0)
        subView.addSubview(lbl)
        view.addSubview(subView)
        if self
            .orderJson["goods"].arrayValue.count > section{
            let json = self.orderJson["goods"].arrayValue[section]
            imgV.setImageUrlStr(json["goods_img"].stringValue)
            lbl.text = json["goods_name"].stringValue
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self
            .orderJson["goods"].arrayValue.count > indexPath.section{
            let json = self.orderJson["goods"].arrayValue[indexPath.section]
            if json["goods_sn"].arrayValue.count > indexPath.row{
                let subJson = json["goods_sn"].arrayValue[indexPath.row]
                if subJson["goods_state"].stringValue.intValue == 0{
                    guard let index = self.selectedSns.index(of: subJson["goods_sn"].stringValue.trim) else{
                        self.selectedSns.append(subJson["goods_sn"].stringValue.trim)
                        self.tableView.reloadData()
                        return
                    }
                    self.selectedSns.remove(at: index)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}
