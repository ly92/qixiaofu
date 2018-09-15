//
//  EPAfterSalerDetailStateCell.swift
//  qixiaofu
//
//  Created by ly on 2018/5/16.
//  Copyright © 2018年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class EPAfterSalerDetailStateCell: UITableViewCell {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var addressView: UIView!
    
    fileprivate let titleArray = ["审核中","审核通过","买家发货","商家收货","商家结算","完成"]
    fileprivate let titleArray2 = ["审核中","审核不通过"]
    fileprivate let titleArray3 = ["审核中","已取消"]
    
    fileprivate var dataArray : Array<Dictionary<String,String>> = []
    
    /**
     
     //1 审核中  2 审核通过 3 审核不通过 4 商家待收货  5 商家已收货  6 完成 7 取消 8 删除
     1 audit  3 audit_not_pass
     审核中----审核不通过
     1 audit  2 audit_pass  4 deliver  5 take_deliver  6 end     6 end
     审核中----审核通过-------买家发货-----商家收货----------商家结算----完成
     
     title ：标题
     time ：时间
     type : 0:未操作 1:已操作
     
     */
    
    //准备数据-提前写好数据模版
    func prepareData() {
        self.dataArray.removeAll()
        if orderJson["return_state"].stringValue.intValue == 3{
            for i in 0...1{
                var dict : Dictionary<String,String> = [:]
                dict["title"] = self.titleArray2[i]
                if i == 0{
                    dict["time"] = self.getTime(i)
                }else{
                    dict["time"] = self.getTime(6)
                }
                dict["time2"] = ""
                dict["type"] = "0"
                self.dataArray.append(dict)
            }
        }else if orderJson["return_state"].stringValue.intValue == 7{
            for i in 0...1{
                var dict : Dictionary<String,String> = [:]
                dict["title"] = self.titleArray3[i]
                if i == 0{
                    dict["time"] = self.getTime(i)
                }else{
                    dict["time"] = self.getTime(7)
                }
                dict["time2"] = ""
                dict["type"] = "0"
                self.dataArray.append(dict)
            }
        }else{
            for i in 0...5{
                var dict : Dictionary<String,String> = [:]
                dict["title"] = self.titleArray[i]
                dict["time"] = self.getTime(i)
                dict["time2"] = ""
                dict["type"] = "0"
                self.dataArray.append(dict)
            }
        }
        self.sortData()
    }
    
    //根据不同状态获取不同时间
    func getTime(_ index : Int) -> String {
        var time = ""
        if index == 0{
            //提交时间
            time = self.orderJson["operation"]["audit"].stringValue
        }else if index == 1{
            //审核通过时间
            time = self.orderJson["operation"]["audit_pass"].stringValue
        }else if index == 2{
            //买家发货时间
            time = self.orderJson["operation"]["deliver"].stringValue
        }else if index == 3{
            //商家收货时间
            time = self.orderJson["operation"]["take_deliver"].stringValue
        }else if index == 4 || index == 5{
            //商家结算-完成时间
            time = self.orderJson["operation"]["end"].stringValue
        }else if index == 6{
            //审核不通过时间
            time = self.orderJson["operation"]["audit_not_pass"].stringValue
        }else if index == 7{
            //取消时间
            time = self.orderJson["operation"]["cancel"].stringValue
        }
        let str1 = Date.dateStringFromDate(format: Date.dateFormatString(), timeStamps: time)
        let str2 = Date.dateStringFromDate(format: Date.secondFormatString(), timeStamps: time)
        return str1 + "\n" + str2
    }
    //根据不同状态设置字体颜色
    func resetType(_ index : Int) {
        for i in 0...index{
            var dict = self.dataArray[i]
            dict["type"] = "1"
            self.dataArray.remove(at: i)
            self.dataArray.insert(dict, at: i)
        }
        self.collectionView.reloadData()
    }
    //状态间的区分
    func sortData() {
        let state = self.orderJson["return_state"].stringValue.intValue
        switch state {
        case 1:
            //审核中
            self.resetType(0)
        case 2:
            //审核通过
            self.resetType(1)
        case 3:
            //审核不通过
            self.resetType(1)
        case 4:
            //商家待收货
            self.resetType(2)
        case 5:
            //商家已收货
            self.resetType(3)
        case 6:
            //完成
            self.resetType(5)
        case 7:
            //取消
            self.resetType(1)
        default:
            print("这个是什么")
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.register(UINib.init(nibName: "EPAfterSalerStateTypeCell", bundle: Bundle.main), forCellWithReuseIdentifier: "EPAfterSalerStateTypeCell")
    }
    
    var orderJson = JSON(){
        didSet{
            self.prepareData()
            
            let return_state = orderJson["return_state"].stringValue.intValue
            //1 审核中  2 审核通过 3 审核不通过 4 商家待收货  5 商家已收货  6 完成 7 取消 8 删除
            if return_state == 2{
                self.addressView.isHidden = false
                self.subView.isHidden = true
            }else if return_state == 5{
                self.addressView.isHidden = true
                self.subView.isHidden = false
            }else{
                self.addressView.isHidden = true
                self.subView.isHidden = true
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension EPAfterSalerDetailStateCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "EPAfterSalerStateTypeCell", for: indexPath) as! EPAfterSalerStateTypeCell
        if self.dataArray.count > indexPath.row{
            let dict = self.dataArray[indexPath.row]
            
            item.stateLbl.text = dict["title"]!
            item.timeLbl.text = dict["time"]!
            if dict["type"]!.intValue == 1{
                item.lineView.backgroundColor = UIColor.RGB(r: 99, g: 186, b: 7)
                item.stateLbl.textColor = UIColor.RGB(r: 99, g: 186, b: 7)
                item.iconImgV.image = #imageLiteral(resourceName: "after_saler_icon_1")
            }else{
                item.lineView.backgroundColor = UIColor.gray
                item.stateLbl.textColor = UIColor.darkGray
                item.iconImgV.image = #imageLiteral(resourceName: "after_saler_icon_2")
            }
            
            if indexPath.row == self.dataArray.count - 1{
                item.lineView.isHidden = true
            }else{
                item.lineView.isHidden = false
            }
        }
        
        return item
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 75, height: 85)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
