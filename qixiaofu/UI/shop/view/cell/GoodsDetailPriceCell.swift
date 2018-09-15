//
//  GoodsDetailPriceCell.swift
//  qixiaofu
//
//  Created by ly on 2017/11/1.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class GoodsDetailPriceCell: UITableViewCell {
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var oldPriceLbl: UILabel!
    @IBOutlet weak var saleLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var hourLbl: UILabel!
    @IBOutlet weak var minLbl: UILabel!
    @IBOutlet weak var secLbl: UILabel!
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    
    
    
    fileprivate var timer = Timer()//打折计时器
    fileprivate var endTime = 0//距离结束时间
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.hourLbl.layer.cornerRadius = 3
        self.minLbl.layer.cornerRadius = 3
        self.secLbl.layer.cornerRadius = 3
    }

    deinit {
        self.timer.invalidate()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var subJson : JSON = [] {
        didSet{
            var temJson = JSON()
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                temJson = subJson
            }else{
                temJson = subJson["goods_info"]
            }
            
            let price = "¥ " + temJson["goods_price"].stringValue
            let attrPrice = NSMutableAttributedString.init(string: price)
            attrPrice.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 18), range: NSRange.init(location: 0, length: 2))
            self.priceLbl.attributedText = attrPrice
            
            let oldPrice = "¥" + temJson["goods_discount_price"].stringValue
            self.oldPriceLbl.attributedText = NSAttributedString.init(string: oldPrice, attributes: [NSAttributedStringKey.strikethroughStyle : (1)])
            self.saleLbl.text = "已抢：" + "0" + "件"
            let disTime = temJson["countdown"].stringValue.intValue
            let showTimer = temJson["is_show_discount_time"].stringValue.intValue
            if disTime > 0 && showTimer == 1{
                self.endTime = disTime
                self.setUpTimer()
                self.lbl1.isHidden = false
                self.lbl2.isHidden = false
                self.lbl3.isHidden = false
                self.dayLbl.isHidden = false
                self.hourLbl.isHidden = false
                self.minLbl.isHidden = false
                self.secLbl.isHidden = false
            }else{
                self.lbl1.isHidden = true
                self.lbl2.isHidden = true
                self.lbl3.isHidden = true
                self.dayLbl.isHidden = true
                self.hourLbl.isHidden = true
                self.minLbl.isHidden = true
                self.secLbl.isHidden = true
            }
        }
    }
    
    //MARK: - 计时器
    func setUpTimer() {
        self.timer.invalidate()
        self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(GoodsDetailPriceCell.changeEndTime), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer, forMode: .defaultRunLoopMode)
        timer.fire()
    }
    
    @objc func changeEndTime() {
        if self.endTime > 86400{
            self.dayLbl.text = "\(self.endTime / 86400)天"
        }
        self.hourLbl.text = "\(self.endTime % 86400 / 3600)"
        self.minLbl.text = "\(self.endTime % 86400 % 3600 / 60)"
        self.secLbl.text = "\(self.endTime % 86400 % 3600 % 60)"
        
        self.endTime = self.endTime - 1
    }
    
    
}
/**
 {
 "listData" : {
 "share_content" : "最专业的服务平台！",
 "mansong_server_list" : [
 
 ],
 "goods_image" : [
 "http:\/\/10.216.2.11\/data\/upload\/shop\/store\/goods\/1\/1_05612187128183955_360.jpg"
 ],
 "store_server" : [
 
 ],
 "share_title" : "七小服",
 "goods_info" : {
 "goods_costprice" : "0.00",
 "xianshi_info" : null,
 "plateid_bottom" : "0",
 "gc_id_1" : "266",
 "gc_id_2" : "295",
 "gc_id_3" : "482",
 "have_gift" : "0",
 "color_id" : "0",
 "goods_serial" : "123",
 "virtual_indate" : "0",
 "goods_freight" : "0.00",
 "goods_discount" : "0",
 "goods_storage" : 18,
 "presell_deliverdate" : "0",
 "goods_storage_alarm" : "1",
 "goods_collect" : "0",
 "goods_img_laber" : "",
 "goods_price" : "2.00",
 "areaid_1" : "1",
 "areaid_2" : "1",
 "countdown" : 288446,
 "is_appoint" : "0",
 "share" : "http:\/\/10.216.2.11\/api\/goods568.html",
 "goods_salenum" : "0",
 "goods_stcids" : "",
 "goods_table" : "阿萨大大的阿三阿斯顿阿斯顿阿德",
 "goods_attr" : [
 {
 "name" : "类型",
 "0" : "不限"
 },
 {
 "name" : "型号",
 "0" : "不限"
 }
 ],
 "g_biaoqian" : "",
 "from_commonid" : "0",
 "price_percent" : "0.666667",
 "goods_click" : 106,
 "goods_id" : "568",
 "is_jingxuan" : "0",
 "goods_desc_url" : "http:\/\/10.216.2.11\/api\/index.php?act=goods&op=goods_body&store_id=1&goods_id=568",
 "goods_vat" : "0",
 "is_presell" : "0",
 "groupbuy_info" : null,
 "evaluation_count" : "0",
 "goods_jingle" : "",
 "virtual_invalid_refund" : "0",
 "is_own_shop" : "1",
 "plateid_top" : "0",
 "goods_promotion_type" : "0",
 "sell_goods_count" : "0",
 "is_virtual" : "0",
 "is_discount" : "1",
 "end_discount_time" : "1509811200",
 "goods_name" : "fjhkd",
 "cuxiao_image" : "cuxiao568.png",
 "engineer_storage" : "0",
 "transport_title" : "",
 "virtual_limit" : "0",
 "goods_specname" : "",
 "goods_discount_price" : "3",
 "goods_marketprice" : "999999.00",
 "copy_from" : "0",
 "start_discount_time" : "1506960000",
 "is_fcode" : "0",
 "mobile_body" : "<div>阿萨大大大叔的阿斯顿阿斯顿<\/div>",
 "appoint_satedate" : "0",
 "goods_promotion_price" : "2.00",
 "evaluation_good_star" : "5",
 "transport_id" : "0",
 "goods_url" : "http:\/\/10.216.2.11\/shop\/index.php?act=goods&op=index&goods_id=568"
 },
 "gift_array" : [
 
 ],
 "store_info" : {
 "avatar" : "http:\/\/10.216.2.11\/data\/upload\/shop\/common\/default_user_portrait.gif",
 "store_ww" : "",
 "member_name" : "yongbaoliyoujia",
 "store_qq" : "",
 "good_percent" : 100,
 "store_credit" : {
 "store_deliverycredit" : {
 "credit" : 5,
 "percent_class" : "equal",
 "percent_text" : "持平",
 "percent" : "----",
 "text" : "发货速度"
 },
 "store_desccredit" : {
 "credit" : 5,
 "percent_class" : "equal",
 "percent_text" : "持平",
 "percent" : "----",
 "text" : "描述相符"
 },
 "store_servicecredit" : {
 "credit" : 5,
 "percent_class" : "equal",
 "percent_text" : "持平",
 "percent" : "----",
 "text" : "服务态度"
 }
 },
 "member_id" : "1",
 "store_name" : "",
 "store_id" : "1",
 "all" : 0,
 "store_phone" : ""
 },
 "mansong_info" : null,
 "share_img_url" : "http:\/\/10.216.2.11\/data\/upload\/shop\/common\/05307988131094346.png",
 "share_link_url" : "http:\/\/10.216.2.11\/api\/index.php?act=invite&op=download",
 "IsHaveBuy" : 0,
 "is_fav" : 0
 },
 "repMsg" : "",
 "repCode" : "00"
 }
 */
