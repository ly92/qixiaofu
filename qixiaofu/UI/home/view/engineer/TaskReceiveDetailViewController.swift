//
//  TaskReceiveDetailViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/6/22.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON

class TaskReceiveDetailViewController: BaseTableViewController {
    class func spwan() -> TaskReceiveDetailViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! TaskReceiveDetailViewController
    }
    
    var task_id : String = ""
    var dataChangeBlock : ((Int) -> Void)?//1:刷新 2:删除
    
    fileprivate var task_user_id : String = ""
    
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var taskNameLbl: UILabel!
    @IBOutlet weak var serverRangeLbl: UILabel!
    @IBOutlet weak var brandTypeLbl: UILabel!
    @IBOutlet weak var amountUnitLbl: UILabel!
    @IBOutlet weak var serverControlLbl: UILabel!
    @IBOutlet weak var serverTypeLbl: UILabel!
    @IBOutlet weak var serverTimeLbl: UILabel!
    @IBOutlet weak var serverAreaLbl: UILabel!
    @IBOutlet weak var memoLbl: UILabel!
    @IBOutlet weak var serverPriceLbl: UILabel!
    @IBOutlet weak var serverPriceTitleLbl: UILabel!
    @IBOutlet weak var imgsView: UIView!
    @IBOutlet weak var receiveTaskBtn: UIButton!
    @IBOutlet weak var changePriceBtn: UIButton!
    @IBOutlet weak var visitLbl: UILabel!
    @IBOutlet weak var coreCodeImgV: UIImageView!
    
    fileprivate var photoBrowseView = LYPhotoBrowseView.init(frame: CGRect())
    fileprivate var resultDict : JSON = []
    //    fileprivate var serverImgV : UIImageView?
    fileprivate var isEnrolled = false
    //是否展示二维码
    fileprivate var shouldShowCode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.receiveTaskBtn.layer.cornerRadius = 20
        self.iconImgV.layer.cornerRadius = 20
        
        self.navigationItem.title = "项目详情"
        
        let commentItem = UIBarButtonItem(title:"评价",target:self,action:#selector(TaskReceiveDetailViewController.rightItemAction))
        let shareItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "Share_code"), target: self, action: #selector(TaskReceiveDetailViewController.shareItemAction))
        
        self.navigationItem.rightBarButtonItems = [commentItem,shareItem]
        
        photoBrowseView = LYPhotoBrowseView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW - 10, height: self.imgsView.h), superVC: self)
        self.imgsView.addSubview(photoBrowseView)
        photoBrowseView.heightBlock = { (height) in
            self.tableView.reloadData()
            self.prepareViews(resultDict: self.resultDict)
        }
        self.loadDetailData()
        //返回按钮
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(backTarget: self, action: #selector(TaskReceiveDetailViewController.backClick))
        
        
        
        self.memoLongPressPan()
    }
    
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        super.viewDidAppear(animated)
    //        if self.serverImgV != nil{
    //            guard let window = UIApplication.shared.keyWindow else{
    //                return
    //            }
    //            window.addSubview(self.serverImgV!)
    //        }
    //    }
    
    //    override func viewWillDisappear(_ animated: Bool) {
    //        super.viewWillDisappear(animated)
    //        if self.serverImgV != nil{
    //            self.serverImgV?.removeFromSuperview()
    //        }
    //    }
    
    @objc func backClick(){
        if self.dataChangeBlock != nil{
            self.dataChangeBlock!(1)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func showDescAction() {
        let dict1 = ["title" : "直接报名", "desc" : "表示对价格满意"]
        let dict2 = ["title" : "报价报名", "desc" : "表示对价格不满意，可以输入自己接受的价格每个账号只有一次报价机会，报价报名后不可改为直接报名，或者选择报更低的价格来提高自己的竞争力"]
        NoticeView.showWithText("提示",[dict1,dict2])
    }
    
    @IBAction func changePriceAction() {
        UserViewModel.haveTrueName(parentVC: self) {
            let customAlertView = UIAlertView.init(title: "我的报价", message: "请输入期望的报价，可高于或低于原价", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "报名")
            customAlertView.alertViewStyle = .plainTextInput
            let nameField = customAlertView.textField(at: 0)
            nameField?.keyboardType = .default
            nameField?.placeholder = "输入期望价格"
            customAlertView.show()
        }
        
        //        DispatchQueue.global().async {
        //            HChatClient.shared().login(withUsername: LocalData.getUserPhone(), password: "11")
        //        }
        //        let chatVC = HDChatViewController.init(conversationChatter: "kefu1")
        //        self.navigationController?.pushViewController(chatVC!, animated: true)
    }
    
    @IBAction func receiveTaskAction() {
        UserViewModel.haveTrueName(parentVC: self) {
            var memo = self.resultDict["price_info"].stringValue.trim
            if memo.isEmpty{
                memo = "完成订单时如使用七小服商城自营备件，平台另外奖励部分金额"
            }
            LYAlertView.show("确定报名？", memo, "取消", "确定", {
                var params : [String:Any] = [:]
                params["bill_id"] = self.task_id
                params["bill_user_id"] = self.resultDict["bill_user_id"].stringValue
                params["enroll_mobile"] = LocalData.getUserPhone()
                params["offer_price"] = ""
                //报名
                NetTools.requestData(type: .post, urlString: requestEnrollApi, parameters: params, succeed: { (resultJson, error) in
                    //检查是否已报名
                    self.isEnrolled = true
                    self.tableView.reloadData()
                }) { (error) in
                    LYProgressHUD.showError(error!)
                }
                //                NetTools.requestData(type: .post, urlString: HomeReceiveTaskApi, parameters: params, succeed: { (resultJson, error) in
                //                    LYAlertView.show("接单成功", "查看订单详情", "取消", "确定", {
                //                        let orderDetailVC = MySendOrderDetailViewController.spwan()
                //                        orderDetailVC.orderId = resultJson["bill_id"].stringValue
                //                        orderDetailVC.isMyReceive = true
                //                            orderDetailVC.moveState = resultJson["state"].stringValue
                //                        self.navigationController?.pushViewController(orderDetailVC, animated: true)
                //                    })
                //                    //刷新数据
                //                    self.loadDetailData()
                //                    if self.baseRefreshBlock != nil{
                //                        self.baseRefreshBlock!()
                //                    }
                //                }) { (error) in
                //                    LYProgressHUD.showError(error!)
                //                }
            })
        }
    }
    
    
    
}

extension TaskReceiveDetailViewController{
    func loadDetailData() {
        LYProgressHUD.showLoading()
        let params :[String : Any] = ["id" : self.task_id]
        
        NetTools.requestData(type: .post, urlString: HomeTaskDetailApi, parameters: params, succeed: { (resultDict, error) in
            
            var arrM = Array<String>()
            for subJson in resultDict["image"].arrayValue{
                arrM.append(subJson.stringValue)
            }
            self.photoBrowseView.showImgUrlArray = arrM
            self.photoBrowseView.showDeleteBtn = false
            self.photoBrowseView.canTakePhoto = false
            self.resultDict = resultDict
            self.prepareViews(resultDict: resultDict)
            
            LYProgressHUD.dismiss()
        }) { (error) in
            LYProgressHUD.dismiss()
            LYProgressHUD.showError(error!)
        }
    }
    
    func prepareViews(resultDict:JSON) {
        self.iconImgV.setHeadImageUrlStr(resultDict["bill_user_avatar"].stringValue)
        self.nameLbl.text = resultDict["bill_user_name"].stringValue
        self.timeLbl.text = Date.dateStringFromDate(format: Date.datesPointFormatString(), timeStamps: resultDict["inputtime"].stringValue)
        self.stateLbl.text = GetStateName(state: resultDict["bill_statu"].stringValue)
        self.taskNameLbl.text = resultDict["entry_name"].stringValue
        self.serverRangeLbl.text = resultDict["service_sector"].stringValue
        self.brandTypeLbl.text = resultDict["service_brand"].stringValue
        self.amountUnitLbl.text = resultDict["number"].stringValue
        self.serverControlLbl.text = resultDict["service_form"].stringValue
        self.serverTypeLbl.text = resultDict["service_type"].stringValue
        self.serverTimeLbl.text = Date.dateStringFromDate(format: Date.dateHPointFormatString(), timeStamps: resultDict["service_stime"].stringValue) + "-" + Date.dateStringFromDate(format: Date.dateHPointFormatString(), timeStamps: resultDict["service_etime"].stringValue)
        self.serverAreaLbl.text = resultDict["service_address"].stringValue
        self.memoLbl.text = resultDict["bill_desc"].stringValue
        self.serverPriceLbl.text = "¥" + resultDict["service_price"].stringValue
        
        self.task_user_id = resultDict["bill_user_id"].stringValue
        
        self.visitLbl.text = resultDict["visit_count"].stringValue + "浏览"
        
        //是否可接单//接单按钮是否可点击 1：可点击
        if resultDict["bill_statu"].stringValue.intValue == 1{
            //是否为自己的单子 is it mine
            if LocalData.getUserInviteCode().hasSuffix(resultDict["bill_user_id"].stringValue){
                self.isEnrolled = true
            }else{
                //检查是否已报名
                self.checkEnroll()
            }
        }else{
            self.isEnrolled = true
        }
        
        //价格为0的不显示价格
        if resultDict["service_price"].stringValue.floatValue > 0{
            self.serverPriceLbl.isHidden = false
            self.serverPriceTitleLbl.isHidden = false
        }else{
            self.isEnrolled = true
            self.serverPriceLbl.isHidden = true
            self.serverPriceTitleLbl.isHidden = true
        }
        
        self.coreCodeImgV.image = UIImageView.createQrcodeWithImage(#imageLiteral(resourceName: "app_icon"), resultDict["share"].stringValue)
        
        self.tableView.reloadData()
    }
    
    
    //检查是否已报名
    func checkEnroll() {
        let params :[String : Any] = ["bill_id" : self.task_id]
        NetTools.requestData(type: .post, urlString: CheckEnrollApi, parameters: params, succeed: { (result, msg) in
            if result["state"].stringValue.intValue == 1{
                self.stateLbl.text = "已报名"
                self.isEnrolled = true
            }else{
                self.isEnrolled = false
            }
            self.tableView.reloadData()
        }, failure: { (error) in
        })
    }
    
    
    //查看评价
    @objc func rightItemAction() {
        let commentVC = CommentListViewController()
        commentVC.member_id = self.task_user_id
        commentVC.isCustomerList = true
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    //分享
    @objc func shareItemAction() {
        self.shouldShowCode = true
        self.tableView.reloadData()
        //        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
        guard let image = self.tableView.getScreenshotImage(nil) else {
            self.shouldShowCode = false
            self.tableView.reloadData()
            return
        }
        self.shouldShowCode = false
        self.tableView.reloadData()
        
        ShareView.showImage(url: self.resultDict["share"].stringValue, title: self.resultDict["title"].stringValue, desc: "七小服项目订单", image: image, viewController: self)
        //        }
        
        //        ShareView.show(url: self.resultDict["share"].stringValue, title: self.resultDict["title"].stringValue, desc: "七小服项目订单", viewController: self)
    }
    
    //压缩图片到100K以内
    func zipImage(currentImage: UIImage) -> UIImage{
        //高保真压缩图片质量
        //UIImageJPEGRepresentation此方法可将图片压缩，但是图片质量基本不变，第二个参数即图片质量参数。
        guard let imageData = UIImageJPEGRepresentation(currentImage, 1.0) else {
            return currentImage
        }
        if imageData.count > 100 * 1024{
            let scale = 102400 / CGFloat(imageData.count)
            guard let imageData1 = UIImageJPEGRepresentation(currentImage, scale) else {
                return currentImage
            }
            guard let newImg = UIImage.init(data: imageData1) else{
                return currentImage
            }
            
            UIGraphicsBeginImageContext(CGSize.init(width: currentImage.size.width, height: currentImage.size.height))
            newImg.draw(in: CGRect(x: 0, y: 0, width: currentImage.size.width, height:currentImage.size.height))
            let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return newImage
        }
        return currentImage
    }
    
    //点击交付标准复制
    func memoLongPressPan() {
        self.memoLbl.addTapActionBlock {
            UIPasteboard.general.string = self.memoLbl.text
            LYProgressHUD.showInfo("复制成功")
        }
    }
    
}


extension TaskReceiveDetailViewController{
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 70
        }else if indexPath.row == 11{
            return photoBrowseView.heightValue
        }else if indexPath.row == 12{
            if self.isEnrolled{
                return 0
            }
            if self.shouldShowCode{
                return 0
            }
            return 80
        }
        
        if indexPath.row == 2{
            let desc = resultDict["service_sector"].stringValue
            let height = desc.sizeFit(width: kScreenW - 80, height: CGFloat.greatestFiniteMagnitude, fontSize: 14.0).height + 4
            if height > 25 {
                return height
            }
        }
        
        if indexPath.row == 8{
            let desc = resultDict["service_address"].stringValue
            let height = desc.sizeFit(width: kScreenW - 80, height: CGFloat.greatestFiniteMagnitude, fontSize: 14.0).height + 4
            if height > 25 {
                return height
            }
        }
        
        if indexPath.row == 9{
            let desc = resultDict["bill_desc"].stringValue
            let height = desc.sizeFit(width: kScreenW - 80, height: CGFloat.greatestFiniteMagnitude, fontSize: 14.0).height + 4
            if height > 25 {
                return height
            }
        }
        
        if indexPath.row == 13{
            if self.shouldShowCode{
                return 180
            }else{
                return 0
            }
        }
        return 21
    }
}


extension TaskReceiveDetailViewController : UIAlertViewDelegate{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1{
            let nameField = alertView.textField(at: 0)
            guard let price = nameField?.text else{
                LYProgressHUD.showError("请重试！")
                return
            }
            if price.isEmpty{
                LYProgressHUD.showError("不可为空！")
                return
            }
            if price.floatValue <= 0{
                LYProgressHUD.showError("请输入大于0的正确的金额")
                return
            }
            
            if price.floatValue == self.resultDict["service_price"].stringValue.floatValue{
                var params : [String:Any] = [:]
                params["bill_id"] = self.task_id
                params["bill_user_id"] = self.resultDict["bill_user_id"].stringValue
                params["enroll_mobile"] = LocalData.getUserPhone()
                params["offer_price"] = ""
                //报名
                NetTools.requestData(type: .post, urlString: requestEnrollApi, parameters: params, succeed: { (resultJson, error) in
                    //检查是否已报名
                    self.isEnrolled = true
                    self.tableView.reloadData()
                    LYProgressHUD.showSuccess("报名成功！")
                }) { (error) in
                    LYProgressHUD.showError(error!)
                }
            }else{
                var params : [String:Any] = [:]
                params["bill_id"] = self.task_id
                params["bill_user_id"] = self.resultDict["bill_user_id"].stringValue
                params["enroll_mobile"] = LocalData.getUserPhone()
                params["offer_price"] = price
                //报名
                NetTools.requestData(type: .post, urlString: requestEnrollApi, parameters: params, succeed: { (resultJson, error) in
                    //已报名
                    var memo = self.resultDict["price_info"].stringValue.trim
                    if memo.isEmpty{
                        memo = "完成订单时如使用七小服商城自营备件，平台另外奖励部分金额"
                    }
                    self.isEnrolled = true
                    self.tableView.reloadData()
                    LYProgressHUD.showSuccess("报名成功！")
                }) { (error) in
                    LYProgressHUD.showError(error!)
                }
            }
        }
    }
}
/**
 {
 repCode = "00",
 repMsg = "",
 listData = 	{
 bill_user_name = "听说这里有只哈",
 bill_desc = "联想加油",
 title = "UNIX服务器,X86服务器,监控设备,虚拟化",
 image = 	(
 ),
 bill_statu = "1",
 service_price = "10.00",
 bill_user_avatar = "http://10.216.2.11/UPLOAD/sys/2017-06-14/~UPLOAD~sys~2017-06-14@1497380473.jpg240",
 other_service_sector = <null>,
 service_sector = "UNIX服务器",
 other_service_brand = "",
 bill_user_id = "986",
 is_top = "0",
 number = "1台",
 id = "603",
 service_etime = 1498107600,
 service_brand = "浏览海量商品",
 service_city = "北京市东莞",
 inputtime = 1497880576,
 button_type = 1,
 service_form = "远程服务",
 service_address = "北京市海淀区东莞",
 entry_name = "测试发单4",
 service_type = "调试",
 service_stime = 1497848400,
 },
 }
 
 */
