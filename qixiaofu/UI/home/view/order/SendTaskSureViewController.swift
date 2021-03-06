//
//  SendTaskSureViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/7/3.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import SwiftyJSON
import Speech
import AudioToolbox


class SendTaskSureViewController: BaseTableViewController {
    class func spwan() -> SendTaskSureViewController{
        return self.loadFromStoryBoard(storyBoard: "Home") as! SendTaskSureViewController
    }
    
    var isFeedback = false
    
    var redoOrderDataJson : JSON = []
    var isRedoOrder = false//是否为重新发布
    var top_price = "100"//置顶费
    
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var placeholderLbl: UILabel!
    @IBOutlet weak var topSwitch: UISwitch!
    @IBOutlet weak var topDayTF: UITextField!
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imgContentView: UIView!
    @IBOutlet weak var topPriceLbl: UILabel!
    @IBOutlet weak var voiceBtn: UIButton!
    @IBOutlet weak var voiceLbl: UILabel!
    
    fileprivate var imgViewH : CGFloat = 50


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
    
    
    fileprivate var photoView : LYPhotoBrowseView!//图片容器
    fileprivate var multiplePhotoView : LYMultiplePhotoBrowseView!//图片容器
    var params : [String : Any] = [:]
    
    fileprivate lazy var imgArray : Array<UIImage> = {
        let imgArray = Array<UIImage>()
        return imgArray
    }()
    
    var paymentJson : JSON = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isFeedback{
            self.navigationItem.title = "意见反馈"
            self.titleLbl.text = "反馈内容"
            self.placeholderLbl.text = "请输入反馈内容"
            self.sureBtn.setTitle("提交", for: .normal)
        }else{
            self.navigationItem.title = "发单"
            self.titleLbl.text = "交付标准"
            self.placeholderLbl.text = "请输入交付标准"
            self.sureBtn.setTitle("确认发单", for: .normal)
        }
        
        
        self.addPressAction()
        self.prepareSpeech()
//        self.tableView.addTapActionBlock { 
//            self.view.endEditing(true)
//        }
        
        self.setUpImgView()
        
        if self.isRedoOrder{
            self.contentTextView.text = self.redoOrderDataJson["bill_desc"].stringValue
            self.placeholderLbl.isHidden = !self.redoOrderDataJson["bill_desc"].stringValue.isEmpty
            self.topDayTF.text = self.redoOrderDataJson["top_day"].stringValue
            self.topDayTF.isEnabled = false
            var array : Array<String> = Array<String>()
            for subJson in self.redoOrderDataJson["image"].arrayValue {
                array.append(subJson.stringValue)
            }
            self.photoView.imgUrlArray = array
            
        }
        
        self.topPriceLbl.text = "价格：¥" + self.top_price + "元/天"
        
        self.sureBtn.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func topSwitchAction(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    @IBAction func sureAction() {
        self.view.endEditing(true)
        if self.isRedoOrder{
        self.redoOrderAction()
        }else{
        self.sendOrderOrFeedBack()
        }
        
    }
    
    //重新发布订单
    func redoOrderAction() {
        LYProgressHUD.showLoading()
        let content = self.contentTextView.text
        params["bill_desc"] = content
        NetTools.requestData(type: .post, urlString: RedoOrderApi, parameters: params, succeed: { (result, msg) in
            LYProgressHUD.showSuccess("发布成功!")
            self.navigationController?.popToRootViewController(animated: true)
        }) { (error) in
            LYProgressHUD.showError(error!)
        }
    }
    
    //发单-反馈
    func sendOrderOrFeedBack() {
        let content = self.contentTextView.text
        let top_day = self.topDayTF.text
        
        if self.isFeedback{
            if (content?.isEmpty)!{
                LYProgressHUD.showError("请输入反馈内容！")
                return
            }
        }
        
        func feedbackAction(_ images : String) {
            var params2 : [String : Any] = [:]
            params2["content"] = content!
            params2["member_name"] = LocalData.getUserName()
            params2["id"] = LocalData.getUserId()
            if !images.isEmpty{
                params2["images"] = images
            }
            LYProgressHUD.showLoading()
            NetTools.requestData(type: .post, urlString: FeedbackApi, parameters: params2, succeed: { (result, msg) in
                LYProgressHUD.dismiss()
                LYAlertView.show("提示", "提交成功，感谢您对七小服的支持!", "我知道了", {
                    self.navigationController?.popViewController(animated: true)
                })
            }, failure: { (error) in
                LYProgressHUD.showError("提交失败，请重试！")
            })
        }
        
        func sendTaskAction(_ images : String) {
            if self.topSwitch.isOn && !(top_day?.isEmpty)!{
                if top_day!.doubleValue > 0.0{
                    params["top_day"] = top_day
                }else{
                    LYProgressHUD.showError("请输入置顶天数")
                }
            }else{
                if params.keys.contains("top_day"){
                    params.remove(at: params.index(forKey: "top_day")!)
                }
            }
            if !(content?.isEmpty)!{
                params["bill_desc"] = content
            }else{
                if params.keys.contains("bill_desc"){
                    params.remove(at: params.index(forKey: "bill_desc")!)
                }
            }
            if !images.isEmpty{
                params["images"] = images
            }else{
                if params.keys.contains("images"){
                    params.remove(at: params.index(forKey: "images")!)
                }
            }
            print(params.description)
            let payVC = PaySendTaskViewController.spwan()
            payVC.paymentJson = paymentJson
            payVC.params = params
            payVC.top_price = self.top_price
            self.navigationController?.pushViewController(payVC, animated: true)
        }
        

        if self.multiplePhotoView.imgArray.count > 0{
            LYProgressHUD.showLoading()
            NetTools.upLoadImage(urlString : UploadAllImageApi,imgArray: self.multiplePhotoView.imgArray, success: { (result) in
                if self.isFeedback{
                    feedbackAction(result)
                }else{
                    LYProgressHUD.dismiss()
                    sendTaskAction(result)
                }
            }, failture: { (error) in
                LYProgressHUD.showError("图片上传失败！")
            })
        }else{
            if self.isFeedback{
                feedbackAction("")
            }else{
                LYProgressHUD.dismiss()
                sendTaskAction("")
            }
        }
    }
}

//MARK: - tabble
extension SendTaskSureViewController{
    
    func setUpImgView() {

        self.photoView = LYPhotoBrowseView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW - 16, height: self.imgViewH),superVC:self)
        self.photoView.backgroundColor = UIColor.white
        self.photoView.heightBlock = { [weak self] (height) in
            self?.imgViewH = height
        }
        self.photoView.maxPhotoNum = 9
        if self.isRedoOrder{
            self.photoView.canTakePhoto = false
            self.photoView.showDeleteBtn = false
        }
        
        self.multiplePhotoView = LYMultiplePhotoBrowseView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenW - 16, height: self.imgViewH),superVC:self)
        self.multiplePhotoView.backgroundColor = UIColor.white
        self.multiplePhotoView.heightBlock = {[weak self] (height) in
            self?.imgViewH = height
            self?.tableView.reloadData()
        }
        self.multiplePhotoView.maxPhotoNum = 9
        
        
        if self.isRedoOrder{
            self.imgContentView.addSubview(self.photoView)
        }else{
            self.imgContentView.addSubview(self.multiplePhotoView)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0{
            return 180
        }else if indexPath.section == 1{
            return self.imgViewH
        }else if indexPath.section == 2{
            if self.isFeedback{
                if indexPath.row == 3{
                    return 100
                }
                return 0
            }
            if self.isRedoOrder{
                if (indexPath.row == 0 || indexPath.row == 2){
                    return 0
                }else if (indexPath.row == 3){
                    return 100
                }
            }else{
                if (indexPath.row == 1 || indexPath.row == 2){
                    if self.topSwitch.isOn {
                        return 44
                    }else{
                        return 0
                    }
                }else if (indexPath.row == 3){
                    return 100
                }
            }
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.isFeedback{
            if ((scrollView as? UITableView) != nil){
                self.view.endEditing(true)
            }
        }
    }
    
}

extension SendTaskSureViewController : UITextViewDelegate,UITextFieldDelegate{

    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty{
            self.placeholderLbl.isHidden = false
        }else{
            self.placeholderLbl.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}



//语音识别
extension SendTaskSureViewController : SFSpeechRecognizerDelegate {
    //手势
    func addPressAction() {
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(SendTaskSureViewController.longPressAction(_:)))
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
            self.voiceLbl.text = "录入中..."
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        case .cancelled:
            //取消
            print("cancelled")
            self.voiceLbl.text = ""
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
            self.voiceLbl.text = ""
        case .failed:
            //失败
            print("failed")
            self.voiceLbl.text = ""
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
                        self.contentTextView.text = self.contentTextView.text! + result!.bestTranscription.formattedString
                    if self.contentTextView.text.count > 0{
                        self.placeholderLbl.isHidden = true
                    }
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

