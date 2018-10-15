//
//  KnowledgeVideoPlayViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/11/30.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON

class KnowledgeVideoPlayViewController: BaseTableViewController {
    class func spwan() -> KnowledgeVideoPlayViewController{
        return self.loadFromStoryBoard(storyBoard: "Knowledge") as! KnowledgeVideoPlayViewController
    }
    
    var videoId: String = ""
    var videoView = UIView()
    @IBOutlet weak var videoContentView: UIView!
    @IBOutlet weak var videoTitleLbl: UILabel!
    @IBOutlet weak var videoDescLbl: UILabel!
    @IBOutlet weak var playCountLbl: UILabel!
    @IBOutlet weak var comIconImgV: UIImageView!
    @IBOutlet weak var comNameLbl: UILabel!
    @IBOutlet weak var comTimeLbl: UILabel!
    @IBOutlet weak var comContentLbl: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var showMoreBtn: UIButton!
    @IBOutlet weak var praiseBtn: UIButton!
    @IBOutlet weak var otherCourseView: UIView!
    
    fileprivate var videoUrl = ""
    fileprivate var isShowMore = false
    fileprivate var isShowAttachment = false
    fileprivate var secLine = UIView()
    fileprivate var secBtn1 = UIButton()
    fileprivate var secBtn2 = UIButton()
    fileprivate var commentView : VideoCommentView?
    fileprivate var resultJson = JSON()
    //是否要关闭视频
    fileprivate var needCloseVideo = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadVideoDetail()
        self.loadCommentList()
        
        self.comIconImgV.layer.cornerRadius = 20
        
        //视频
        self.videoContentView.addSubview(self.videoView)
        self.videoView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(0)
            make.height.equalTo(kScreenW * 9 / 16 )
        }
        //按钮
        self.secLine.backgroundColor = UIColor.colorHex(hex: "fe7033")
        self.secLine.frame = CGRect.init(x: (kScreenW/2.0-70)/2.0, y: 50, width: 70, height: 2)
        self.secBtn1.setTitle("视频简介", for: .normal)
        self.secBtn1.setTitleColor(UIColor.colorHex(hex: "fe7941"), for: .normal)
        self.secBtn1.tag = 111
        self.secBtn1.addTarget(self, action: #selector(KnowledgeVideoPlayViewController.secBtnAction(_:)), for: .touchUpInside)
        self.secBtn1.frame = CGRect.init(x: 0, y: 0, width: kScreenW / 2.0, height: 58)
        self.secBtn2.setTitle("视频附件", for: .normal)
        self.secBtn2.setTitleColor(UIColor.black, for: .normal)
        self.secBtn2.tag = 222
        self.secBtn2.addTarget(self, action: #selector(KnowledgeVideoPlayViewController.secBtnAction(_:)), for: .touchUpInside)
        self.secBtn2.frame = CGRect.init(x: kScreenW / 2.0, y: 0, width: kScreenW / 2.0, height: 58)
        
        //返回按钮
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(backTarget: self, action: #selector(KnowledgeVideoPlayViewController.backClick))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.needCloseVideo{
            LYPlayerView.shared.stopPlay()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.needCloseVideo = true
    }
    
    @objc func backClick() {
        self.needCloseVideo = true
        self.navigationController?.popViewController(animated: true)
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        if self.isShowAttachment{
//            self.isShowAttachment = false
//            self.tableView.reloadData()
//        }
//    }
    
    func loadVideoDetail() {
        var params : [String : Any] = [:]
        params["video_id"] = self.videoId
        LYProgressHUD.showLoading()
        NetTools.requestData(type: .post, urlString: KVideoDetailApi1, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            //没有视频
            if resultJson["mv_sel"].arrayValue.count == 0{
                LYProgressHUD.showError("视频数据不存在")
                return
            }
            
            self.resultJson = resultJson
            self.videoUrl = resultJson["mv_link"].stringValue
            self.videoDescLbl.text = resultJson["mv_info"].stringValue
            self.videoTitleLbl.text = resultJson["mv_sender"].stringValue + " " + resultJson["mv_name"].stringValue
            self.title = resultJson["mv_name"].stringValue
            let count = resultJson["mv_see"].stringValue.intValue
            var countStr = ""
            if count > 10000{
                countStr = "\(count / 10000)" + "万次播放"
            }else{
                countStr = "\(count)" + "次播放"
            }
            self.playCountLbl.text = countStr
            let attachmentUrl = URL.init(string: resultJson["mv_ppt"].stringValue)
            if attachmentUrl != nil{
//                self.webView.loadRequest(URLRequest.init(url: attachmentUrl!))
            }
            if resultJson["is_thumb"].stringValue.intValue == 0{
                self.praiseBtn.setImage(#imageLiteral(resourceName: "video_fabulous_off"), for: .normal)
            }else{
                self.praiseBtn.setImage(#imageLiteral(resourceName: "video_fabulous_on"), for: .normal)
            }
            
            //先清理
            for view in self.otherCourseView.subviews{
                view.removeFromSuperview()
            }
            //其他视频
            for i in 0...resultJson["mv_sel"].arrayValue.count - 1{
                let view = UIView(frame:CGRect.init(x: 0, y: 40 * CGFloat(i), width: kScreenW-30, height: 40))
                self.otherCourseView.addSubview(view)
                
                let mv = resultJson["mv_sel"].arrayValue[i]
                
                let lbl = UILabel(frame:view.bounds)
                view.addSubview(lbl)
                lbl.font = UIFont.systemFont(ofSize: 14.0)
                lbl.textColor = Text_Color
                lbl.text = mv["mv_name"].stringValue
                
                let line = UIView(frame:CGRect.init(x: 0, y: 40, width: kScreenW-30, height: 1))
                line.backgroundColor = BG_Color
                view.addSubview(line)
                
                view.addTapActionBlock(action: {
                    self.videoId = mv["mv_id"].stringValue
                    self.loadVideoDetail()
                    self.loadCommentList()
                })
            }
            self.tableView.reloadData()
            
            self.playAction()
            
            
        }) { (error) in
            LYProgressHUD.showError(error ?? "网络连接失败！，请重试")
        }
        //增加播放量
        NetTools.requestData(type: .post, urlString: KVideoPlayCountApi, parameters: params, succeed: { (result, msg) in
        }) { (error) in
        }
        
    }
    
    //加载数据
    func loadCommentList() {
        var params : [String : Any] = [:]
        params["video_id"] = self.videoId
        params["curpage"] = "1"
        NetTools.requestData(type: .post, urlString: KVideoCommentListApi, parameters: params, succeed: { (resultJson, msg) in
            LYProgressHUD.dismiss()
            if resultJson.arrayValue.count > 0{
               let json = resultJson.arrayValue[0]
                self.comNameLbl.text = json["member_name"].stringValue
                self.comIconImgV.setHeadImageUrlStr(json["head_photo"].stringValue)
                self.comContentLbl.text = json["comment_contents"].stringValue
                
                func splitLength(preStr : String) -> String{
                    var str = preStr
                    if str.count > 10{
                        str.removeLast()
                        return splitLength(preStr: str)
                    }
                    return str
                }
                let date = Date(timeIntervalSince1970: Double(splitLength(preStr: json["comment_time"].stringValue))!)
                if (date.isYesterday()){
                    self.comTimeLbl.text = "昨天" + Date.dateStringFromDate(format: Date.timeFormatString(), timeStamps: json["comment_time"].stringValue)
                }else if date.isToday(){
                    if date.hourssBeforeDate(aDate: Date()) > 0{
                        self.comTimeLbl.text = "\(date.hourssBeforeDate(aDate: Date()))" + "小时前"
                    }else if date.minutesBeforeDate(aDate: Date()) > 0{
                        self.comTimeLbl.text = "\(date.minutesBeforeDate(aDate: Date()))" + "分钟前"
                    }else{
                        self.comTimeLbl.text = "刚刚"
                    }
                }else{
                    self.comTimeLbl.text = Date.dateStringFromDate(format: Date.datePointFormatString(), timeStamps: json["comment_time"].stringValue)
                }
            }
        }) { (error) in
            LYProgressHUD.showError(error ?? "网络连接失败！，请重试")
        }
    }
    
    
    
    @IBAction func operationAction(_ btn: UIButton) {
        if btn.tag == 11{
            //评论
            if self.commentView != nil{
                self.commentView?.removeFromSuperview()
                self.commentView = nil
            }else{
                let cell = self.tableView(self.tableView, cellForRowAt: IndexPath.init(row: 1, section: 0))
                self.commentView = VideoCommentView.init(frame: CGRect.init(x: 0, y: cell.frame.origin.y + 50, width: kScreenW, height: 300), videoId : self.videoId)
                self.commentView!.commentSuccessBlock = {() in
                    self.commentView = nil
                    self.loadCommentList()
                }
                self.tableView.addSubview(self.commentView!)
            }
        }else if btn.tag == 22{
            //喜欢
            if resultJson["is_thumb"].stringValue.intValue != 0{
                LYProgressHUD.showInfo("不能重复点赞")
                return
            }
            var params : [String : Any] = [:]
            params["video_id"] = self.videoId
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: KVideoPraiseApi, parameters: params, succeed: { (resultJson, msg) in
                LYProgressHUD.dismiss()
                self.praiseBtn.setImage(#imageLiteral(resourceName: "video_fabulous_on"), for: .normal)
                self.resultJson["is_thumb"] = JSON("1")
            }, failure: { (error) in
                LYProgressHUD.showError(error ?? "请重试")
            })
        }else if btn.tag == 33{
            //分享
            ShareView.show(url: self.resultJson["share_url"].stringValue, viewController: self)
        }else if btn.tag == 44{
            //赞赏
            LYPlayerView.shared.pause()
            self.needCloseVideo = false
        }else if btn.tag == 55{
            //展开更多
            self.isShowMore = !self.isShowMore
//            self.tableView.reloadData()
            self.tableView.reloadData()
            if self.isShowMore{
                self.showMoreBtn.setTitle("收起", for: .normal)
            }else{
                self.showMoreBtn.setTitle("展开更多", for: .normal)
            }
        }else if btn.tag == 66{
            //查看更多评论
            LYPlayerView.shared.pause()
            self.needCloseVideo = false
            let commentListVC = VideoCommentListViewController()
            commentListVC.videoId = self.videoId
            self.navigationController?.pushViewController(commentListVC, animated: true)
        }
        
    }
    
    @objc func secBtnAction(_ btn : UIButton){
        if btn.tag == 111 && self.isShowAttachment{
            self.secBtn1.setTitleColor(UIColor.colorHex(hex: "fe7941"), for: .normal)
            self.secBtn2.setTitleColor(UIColor.black, for: .normal)
            self.isShowAttachment = false
            self.tableView.reloadData()
        }else if btn.tag == 222 && !self.isShowAttachment{
            if self.resultJson["mv_ppt"].stringValue.isEmpty{
                LYProgressHUD.showInfo("无附件！")
            }else{
                LYPlayerView.shared.pause()
                self.needCloseVideo = false
                let webVC = BaseWebViewController.spwan()
                webVC.titleStr = "视频附件"
                webVC.urlStr = self.resultJson["mv_ppt"].stringValue
                self.navigationController?.pushViewController(webVC, animated: true)
            }
        }
    }
    
    // 视图是否自动旋转
    override var shouldAutorotate : Bool {
        get{
            return false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //播放视频
    func playAction() {
        let model = LYPlayerModel()
        model.videoURL = self.videoUrl
        LYPlayerView.shared.isAutoPlay = true
        LYPlayerView.shared.playerControlView(self.videoView, model)
    }
    
    deinit {
        LYPlayerView.shared.stopPlay()
    }
    
    
    
}

extension KnowledgeVideoPlayViewController{
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if indexPath.row == 0{
                return kScreenW * CGFloat(9 / 16.0)
            }else if indexPath.row == 1{
                return 50
            }
        }else if indexPath.section == 1{
            if self.isShowAttachment{
                return 0
            }
            if indexPath.row == 0{
                return 44
            }else if indexPath.row == 1{
                if self.isShowMore{
                    if self.videoDescLbl.resizeHeight() > 42{
                        return 64 + self.videoDescLbl.resizeHeight()
                    }
                }
                return 110
            }else if indexPath.row == 2{
                return CGFloat(self.otherCourseView.subviews.count * 40 + 46)
            }else if indexPath.row == 3{
                return 180
            }
        }else if indexPath.section == 2{
//            if indexPath.row == 0{
//                if self.isShowAttachment{
//                    return self.webView.scrollView.contentSize.height + 45
//                }else{
//                    return 0
//                }
//            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            let view = UIView()
            view.addSubview(self.secBtn1)
            view.addSubview(self.secBtn2)
            view.addSubview(self.secLine)
            if self.isShowAttachment{
                self.secLine.centerX = self.secBtn2.centerX
            }else{
                self.secLine.centerX = self.secBtn1.centerX
            }
            return view
        }else{
            return nil
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1{
            return 60
        }else{
            return 0.001
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView as? UITableView != nil{
            if self.tableView.contentOffset.y > kScreenW * 9 / 16{
                LYPlayerView.shared.pause()
            }
        }
    }
}

//extension KnowledgeVideoPlayViewController : UIWebViewDelegate{
//    func webViewDidFinishLoad(_ webView: UIWebView) {
//        self.tableView.reloadData()
//    }
//}



