//
//  GoodsSearchListViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/11/10.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON
import Speech
import AudioToolbox


class GoodsSearchListViewController: BaseViewController {
    class func spwan() -> GoodsSearchListViewController{
        return self.loadFromStoryBoard(storyBoard: "Shop") as! GoodsSearchListViewController
    }
    
    var ocrKeys = ""
    
    fileprivate var curpage : NSInteger = 1
    var keyWord = ""
    fileprivate lazy var dataArray : Array<JSON> = {
        let dataArray = Array<JSON>()
        return dataArray
    }()
    fileprivate var area_list : JSON = []
    fileprivate var selectedIds : Array<String> = Array<String>()
    fileprivate var rsg_msg = ""
    @IBOutlet weak var tabbleView: UITableView!
    @IBOutlet weak var subControl: UIControl!
    
    @IBOutlet weak var emptyView2: UIView!
    @IBOutlet weak var hotCollectionView: UICollectionView!
    @IBOutlet weak var historyCollectionView: UICollectionView!
    
    @IBOutlet weak var hotView: UIView!
    @IBOutlet weak var hotViewH: NSLayoutConstraint!
    
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var historyViewH: NSLayoutConstraint!
    @IBOutlet weak var voiceLbl: UILabel!
    @IBOutlet weak var voiceBtn: UIButton!
    
    
    //语音识别
    fileprivate var speechRecognizer : SFSpeechRecognizer? {
        get{
            let local = Locale.init(identifier: "zh_CN")
            let reco = SFSpeechRecognizer.init(locale: local)
            return reco
        }
    }
    fileprivate var recognitionRequest : SFSpeechAudioBufferRecognitionRequest?
    fileprivate var recognitionTask : SFSpeechRecognitionTask?
    fileprivate let audioEngine = AVAudioEngine()
    
    
    let searchBar : UISearchBar = UISearchBar()
    fileprivate lazy var hotArray : Array<String> = {
        let hotArray = ["IBM","HP","X86","LINUX","UNIX","监控设备"]
        return hotArray
    }()
    fileprivate lazy var historyArray : Array<String> = {
        let historyArray = Array<String>()
        return historyArray
    }()
    fileprivate var haveMore = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hotCollectionView.register(UINib.init(nibName: "SearchWordCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SearchWordCell")
        self.historyCollectionView.register(UINib.init(nibName: "SearchWordCell", bundle: Bundle.main), forCellWithReuseIdentifier: "SearchWordCell")
        self.tabbleView.register(UINib.init(nibName: "CollectGoodsCell", bundle: Bundle.main), forCellReuseIdentifier: "CollectGoodsCell")
        
        self.historyArray = LocalData.getSearchHistoryArray()
        
        self.subControl.addTarget(self, action: #selector(GoodsSearchListViewController.endSearchEdit), for: .touchDown)
        
        self.setUpSearchNavView()
        self.setUpSubViews()
        
        self.addRefresh()
        
        //ocr请求数据
        if ocrKeys != ""{
            LYProgressHUD.showLoading()
            self.keyWord = ocrKeys
            self.loadData(1)
            self.searchBar.resignFirstResponder()
        }
        
        //语音识别
        self.addPressAction()
        self.prepareSpeech()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        LYProgressHUD.dismiss()
    }
    
    func addRefresh() {
        self.tabbleView.es.addPullToRefresh {
            [weak self] in
            self?.curpage = 1
                self?.loadData()
        }
        
//        self.tabbleView.es.addInfiniteScrolling {
//            [weak self] in
//            self?.curpage += 1
//                self?.loadData()
//        }
    }
    
    //停止刷新
    func stopRefresh() {
        self.tabbleView.es.stopLoadingMore()
        self.tabbleView.es.stopPullToRefresh()
        if self.dataArray.count > 0{
            self.emptyView2.isHidden = true
        }else{
            self.emptyView2.isHidden = false
        }
    }
    
    //3.右侧列表数据
    func loadData(_ type : Int = 0) {
        self.subControl.isHidden = true
        if type == 0{
            self.searchBar.text = keyWord
        }
        self.haveMore = false
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            var params : [String : Any] = [:]
//            params["gc_id"] = self.g//商品分类ID
            params["keywords"] = keyWord
            params["curpage"] = "\(self.curpage)"//页数
            NetTools.requestData(type: .post, urlString: EPGoodsListApi, parameters: params, succeed: { (resultJson, msg) in
                if self.curpage == 1{
                    self.dataArray.removeAll()
                }

                for subJson in resultJson.arrayValue{
                    self.dataArray.append(subJson)
                }
                self.stopRefresh()
                //判断是否有更多
                if resultJson.arrayValue.count < 10{
                    self.tabbleView.es.noticeNoMoreData()
                    self.haveMore = false
                }else{
                    self.tabbleView.es.resetNoMoreData()
                    self.haveMore = true
                }
                LYProgressHUD.dismiss()
                //重加载tabble
                self.tabbleView.reloadData()
                
            }) { (error) in
                self.stopRefresh()
                LYProgressHUD.showError(error!)
            }
        }else{
            var params : [String : Any] = [:]
            params["store_id"] = "1"//店铺ID
            //        params["gc_id"] = self.gc_id//商品分类ID
            params["key"] = "1"// 排序类型【1:销量】【2:人气（访问量）】【3:价格】【4:新品】
            params["order"] = "1"//排序方式【1:升序】【2:降序】
            params["curpage"] = "\(self.curpage)"//页数
            if !keyWord.isEmpty{
                params["keyword"] = keyWord
            }
            if self.selectedIds.count > 0{
                let ids = self.selectedIds.joined(separator: ",")
                params["area_id"] = ids
            }
            
            NetTools.requestData(type: .post, urlString: SearchShopGoodsListApi, parameters: params, succeed: { (resultJson, msg) in
                if self.curpage == 1{
                    self.dataArray.removeAll()
                }
                for subJson in resultJson["goods_list"].arrayValue{
                    self.dataArray.append(subJson)
                }
                self.area_list = resultJson["area_list"]
                self.rsg_msg = resultJson["res.msg"].stringValue
                //停止刷新
                self.stopRefresh()
                //判断是否可以加载更多
                if resultJson["goods_list"].arrayValue.count < 10{
                    self.tabbleView.es.noticeNoMoreData()
                    self.haveMore = false
                }else{
                    self.tabbleView.es.resetNoMoreData()
                    self.haveMore = true
                }
                //重加载tabble
                self.tabbleView.reloadData()
            }) { (error) in
                self.stopRefresh()
                LYProgressHUD.showError(error!)
            }
        }
        
        
    }
    
    @objc func filtrateAction() {
        let filtV = FiltrateView.loadFromNib() as! FiltrateView
        filtV.selectedIds = self.selectedIds
        filtV.show(with: self.area_list)
        filtV.filtrateBlock = {[weak self] (array) -> Void in
            self?.selectedIds = array
            self?.curpage = 1
            self?.loadData()
        }
    }
    
    //delete search history
    @IBAction func deleteSearchHistory() {
        LocalData.removeSearchHistory()
        self.historyArray.removeAll()
        self.setUpSubViews()
        self.historyCollectionView.reloadData()
    }
    
    @IBAction func chatAction() {
        //联系客服
        esmobChat(self, "kefu1", 1)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension GoodsSearchListViewController{
    func setUpSearchNavView() {
        if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
            
        }else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "筛选", target: self, action: #selector(GoodsSearchListViewController.filtrateAction))
        }
        searchBar.placeholder = "请输入品牌型号、地点等搜索"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW-120, height: 44))
        searchBar.frame = view.bounds
        view.addSubview(searchBar)
        self.navigationItem.titleView = view
        guard let searchBarTF = searchBar.value(forKey: "searchField") as? UITextField else {
            return
        }
        searchBarTF.font = UIFont.systemFont(ofSize: 15.0)
    }
    
    @objc func endSearchEdit() {
        searchBar.resignFirstResponder()
        self.subControl.isHidden = true
    }
    
    func setUpSubViews() {
        //推荐搜索viwe
        if self.hotArray.count == 0{
            self.hotView.isHidden = true
            self.hotViewH.constant = 0
        }else if self.hotArray.count % 2 == 0{
            self.hotView.isHidden = false
            self.hotViewH.constant = CGFloat(self.hotArray.count / 2 * 27 + 60)
        }else{
            self.hotView.isHidden = false
            self.hotViewH.constant = CGFloat(self.hotArray.count / 2 * 27 + 27 + 60)
        }
        
        //历史搜索view
        if self.historyArray.count == 0{
            self.historyView.isHidden = true
            self.historyViewH.constant = 0
        }else if self.historyArray.count % 2 == 0{
            self.historyView.isHidden = false
            self.historyViewH.constant = CGFloat(self.historyArray.count / 2 * 27 + 60)
        }else{
            self.historyView.isHidden = false
            self.historyViewH.constant = CGFloat(self.historyArray.count / 2 * 27 + 27 + 60)
        }
        
    }
}

//MARK: - UISearchBarDelegate
extension GoodsSearchListViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        if !(searchBar.text?.isEmpty)!{
            LocalData.saveSearchHistory(searchWord: searchBar.text!)
        }
        self.endSearchEdit()

        self.keyWord = searchBar.text!
        self.curpage = 1
        self.loadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        self.subControl.isHidden = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.subControl.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.endSearchEdit()
    }
}

//MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension GoodsSearchListViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == hotCollectionView{
            return self.hotArray.count
        }else if collectionView == historyCollectionView{
            return self.historyArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchWordCell", for: indexPath) as! SearchWordCell
        
        if collectionView == hotCollectionView{
            if self.hotArray.count > indexPath.row{
                cell.titleLbl.text = self.hotArray[indexPath.row]
            }
        }else{
            if self.historyArray.count > indexPath.row{
                cell.titleLbl.text = self.historyArray[indexPath.row]
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        var searchWord = ""
        
        if collectionView == hotCollectionView{
            if self.hotArray.count > indexPath.row{
                searchWord = self.hotArray[indexPath.row]
            }
        }else{
            if self.historyArray.count > indexPath.row{
                searchWord = self.historyArray[indexPath.row]
            }
        }
        self.endSearchEdit()
        LocalData.saveSearchHistory(searchWord: searchWord)
        
        self.keyWord = searchWord
        self.curpage = 1
        self.loadData()
        
        
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension GoodsSearchListViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:(kScreenW - 55)/2.0, height:25)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,left: 5,bottom: 5,right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension GoodsSearchListViewController : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectGoodsCell", for: indexPath) as! CollectGoodsCell
        if self.dataArray.count > indexPath.row{
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                cell.epSubJson = self.dataArray[indexPath.row]
            }else{
                cell.subJson = self.dataArray[indexPath.row]
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.dataArray.count > indexPath.row{
            let subJson = self.dataArray[indexPath.row]
            let detailVC = GoodsDetailViewController.spwan()
            if LocalData.getYesOrNotValue(key: KEnterpriseVersion){
                detailVC.goodsId = subJson["goods_commonid"].stringValue
            }else{
                detailVC.goodsId = subJson["goods_id"].stringValue
            }
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.rsg_msg.isEmpty{
            return nil
        }else{
            let view = UIView(frame:CGRect.init(x: 0, y: 0, width: kScreenW, height: 40))
            view.backgroundColor = UIColor.RGB(r: 253, g: 250, b: 230)
            let lbl = UILabel(frame:CGRect.init(x: 10, y: 0, width: kScreenW - 20, height: 40))
            lbl.numberOfLines = 0
            lbl.textColor = Text_Color
            lbl.font = UIFont.systemFont(ofSize: 14.0)
            lbl.text = self.rsg_msg
            view.addSubview(lbl)
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.rsg_msg.isEmpty{
            return 0.001
        }
        return 40
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.dataArray.count - 1 && self.haveMore{
            self.curpage += 1
            self.loadData(1)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }


}









//语音识别
extension GoodsSearchListViewController : SFSpeechRecognizerDelegate {
    //手势
    func addPressAction() {
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(GoodsSearchListViewController.longPressAction(_:)))
        longPress.minimumPressDuration = 0.2
        self.voiceBtn.addGestureRecognizer(longPress)
    }
    //手势处理
    @objc func longPressAction(_ pan : UILongPressGestureRecognizer) {
        switch pan.state {
        case .began:
            //开始
            if self.audioEngine.isRunning{
                self.audioEngine.stop()
                if self.recognitionRequest != nil{
                    self.recognitionRequest?.endAudio()
                }
            }
            self.startRecording()
            self.voiceBtn.setImage(#imageLiteral(resourceName: "voice_icon2"), for: .normal)
            self.voiceLbl.isHidden = false
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        case .cancelled:
            //取消
            print("cancelled")
            self.voiceLbl.isHidden = true
        case .changed:
            //
            let _ = 1
        //            print("changed")
        case .ended:
            //结束
            self.voiceBtn.setImage(#imageLiteral(resourceName: "voice_icon1"), for: .normal)
            self.audioEngine.stop()
            if self.recognitionRequest != nil{
                self.recognitionRequest?.endAudio()
            }
            self.voiceLbl.isHidden = true
        case .failed:
            //失败
            print("failed")
            self.voiceLbl.isHidden = true
        case .possible:
            //
            print("possible")
        }
    }
    //
    func prepareSpeech(){
        SFSpeechRecognizer.requestAuthorization { (hander) in
            switch hander{
            case .notDetermined:
                //语音识别未授权
                print("语音识别未授权")
            case .denied:
                //用户未授权使用语音识别
                print("用户未授权使用语音识别")
            case .restricted:
                //语音识别在这台设备上受到限制
                print("语音识别在这台设备上受到限制")
            case .authorized:
                //开始录音
                print("开始录音")
            }
        }
    }
    
    func startRecording() {
        if self.recognitionTask != nil{
            self.recognitionTask?.cancel()
            self.recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation)
        } catch {
        }
        
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = self.audioEngine.inputNode
        self.recognitionRequest?.shouldReportPartialResults = true
        self.recognitionTask = self.speechRecognizer?.recognitionTask(with: self.recognitionRequest!, resultHandler: { (result, error) in
            var isFinal = false
            if result != nil{
                isFinal = result!.isFinal
                if isFinal{
                    self.endSearchEdit()
                    self.keyWord = result!.bestTranscription.formattedString
                    self.curpage = 1
                    self.loadData()
                }
            }
            
            if error != nil || isFinal{
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionTask = nil
                self.recognitionRequest = nil
                
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            if self.recognitionRequest != nil{
                self.recognitionRequest?.append(buffer)
            }
        }
        self.audioEngine.prepare()
        do {
            try self.audioEngine.start()
        } catch  {
        }
    }
    
}

