//
//  ScanActionViewController.swift
//  qixiaofu
//
//  Created by ly on 2017/8/18.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit
import AVFoundation

class ScanActionViewController: BaseViewController {

    var scanResultBlock : ((String) -> Void)?
    
    
    fileprivate var scanSession = AVCaptureSession()
    fileprivate var scanPane = UIView()
    fileprivate let line = UIImageView.init(image: #imageLiteral(resourceName: "scan_line"))
    fileprivate var haveSoundPlayed = false
    
    fileprivate var device = AVCaptureDevice.default(for: AVMediaType.video)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //1afa29
        //设置扫描框周边
        self.setUPAroundView()
        
        //设置扫描设备
        self.setUPScanDevice()
                
        
//        //超时提示返回
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6) {
//            LYAlertView.show("提示", "扫描超时，是否重新扫描？", "取消", "确定",{
//                if !self.scanSession.isRunning{
//                    self.scanSession.startRunning()
//                }
//            },{
//                self.navigationController?.popViewController(animated: true)
//            })
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.device = nil
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //设置扫描框周边
    func setUPAroundView() {
        self.scanPane = UIView(frame:CGRect.init(x: (kScreenW - 200)/2.0, y: kScreenH/2.0 - 100, width: 200, height: 200))
        self.scanPane.backgroundColor = UIColor.clear
        self.view.addSubview(self.scanPane)
        //扫描框
        let imgV = UIImageView(frame:self.scanPane.bounds)
        imgV.image = #imageLiteral(resourceName: "scanning_bg")
        imgV.contentMode = .scaleAspectFill
        self.scanPane.addSubview(imgV)
        
        //扫描线
        line.frame = CGRect.init(x: 5, y: 0, width: 190, height: 10)
        self.scanPane.addSubview(line)
        self.lineRoll()
        
//        //半透明背景
//        let bgView = UIView(frame:view.layer.bounds)
//        bgView.backgroundColor = UIColor.black
//        bgView.alpha = 0.5
//        self.view.addSubview(bgView)
//
        //周边半透明
        let topView = UIView(frame:CGRect.init(x: 0, y: 0, width: kScreenW, height: kScreenH/2.0 - 100))
        topView.backgroundColor = UIColor.RGBA(r: 0, g: 0, b: 0, a: 0.7)
        self.view.addSubview(topView)
        let rightView = UIView(frame:CGRect.init(x: (kScreenW - 200)/2.0 + 200, y: kScreenH/2.0 - 100, width: (kScreenW - 200)/2.0, height: 200))
        rightView.backgroundColor = UIColor.RGBA(r: 0, g: 0, b: 0, a: 0.7)
        self.view.addSubview(rightView)
        let bottomView = UIView(frame:CGRect.init(x: 0, y: kScreenH/2.0 + 100, width: kScreenW, height: kScreenH/2.0 - 100))
        bottomView.backgroundColor = UIColor.RGBA(r: 0, g: 0, b: 0, a: 0.7)
        self.view.addSubview(bottomView)
        let leftView = UIView(frame:CGRect.init(x: 0, y: kScreenH/2.0 - 100, width: (kScreenW - 200)/2.0, height: 200))
        leftView.backgroundColor = UIColor.RGBA(r: 0, g: 0, b: 0, a: 0.7)
        self.view.addSubview(leftView)
        
        //返回按钮
        let backBtn = UIButton(frame:CGRect.init(x: 5, y: 25, width: 55, height: 33))
        backBtn.setImage(#imageLiteral(resourceName: "back_white"), for: .normal)
        backBtn.addTarget(self, action: #selector(ScanActionViewController.backAction), for: .touchUpInside)
        self.view.addSubview(backBtn)
        
        //打开闪光灯按钮
        let btn = UIButton(frame:CGRect.init(x: kScreenW/2.0 - 50, y: kScreenH - 150, width: 100, height: 100))
        btn.setImage(#imageLiteral(resourceName: "torch_off"), for: .normal)
        btn.setImage(#imageLiteral(resourceName: "torch_on"), for: .selected)
        btn.addTarget(self, action: #selector(ScanActionViewController.btnAction(btn:)), for: .touchUpInside)
        self.view.addSubview(btn)
        
    }
    
    //返回
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //打开闪光灯按钮
    @objc func btnAction(btn:UIButton) {
        btn.isSelected = !btn.isSelected
        
        if btn.isSelected{
            //亮灯
            do{
                try device?.lockForConfiguration()
                device?.torchMode = AVCaptureDevice.TorchMode.on
                device?.flashMode = AVCaptureDevice.FlashMode.on
                device?.unlockForConfiguration()
            }catch{
            
            }
        }else{
            //关灯
            do{
                try device?.lockForConfiguration()
                device?.torchMode = AVCaptureDevice.TorchMode.off
                device?.flashMode = AVCaptureDevice.FlashMode.off
                device?.unlockForConfiguration()
            }catch{
            
            }
        }
    }

    //扫描线滚动
    func lineRoll() {
        if line.y == 190{
            UIView.animate(withDuration: 2.5, animations: {
                self.line.y = 0
            }) { (completion) in
                self.lineRoll()
            }
        }else{
            line.y = 0
            UIView.animate(withDuration: 2.5, animations: {
                self.line.y = 190
            }) { (completion) in
                self.lineRoll()
            }
        }
        
    }
    

    //设置扫描设备
    func setUPScanDevice() {
        
        //设置捕捉设备
        
        do{
            //设置设备的输入输出
            let input = try AVCaptureDeviceInput(device:device!)
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //设置会话
            let scanSession = AVCaptureSession()
            scanSession.canSetSessionPreset(AVCaptureSession.Preset.high)
            
            if scanSession.canAddInput(input){
                scanSession.addInput(input)
            }
            if scanSession.canAddOutput(output){
                scanSession.addOutput(output)
            }
            
            //设置扫描类型(二维码和条形码)
            output.metadataObjectTypes = [
                AVMetadataObject.ObjectType.qr,
                AVMetadataObject.ObjectType.code39,
                AVMetadataObject.ObjectType.code128,
                AVMetadataObject.ObjectType.code39Mod43,
                AVMetadataObject.ObjectType.ean13,
                AVMetadataObject.ObjectType.ean8,
                AVMetadataObject.ObjectType.code93
//                AVMetadataObjectTypeFace
            ]
            
            //预览图层
            let scanPreviewLayer = AVCaptureVideoPreviewLayer.init(session: scanSession)
            scanPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//            scanPreviewLayer.frame = view.layer.bounds
            scanPreviewLayer.frame = CGRect.init(x: (kScreenW - 200)/2.0, y: kScreenH/2.0 - 100, width: 200, height: 200)
            view.layer.insertSublayer(scanPreviewLayer, at: 0)
            
            //自动连续对焦
            do {
                try input.device.lockForConfiguration()
                input.device.focusMode = .continuousAutoFocus
                input.device.unlockForConfiguration()
            }catch{}
            
            //设置扫描区域
//            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil, queue: nil, using: { [weak self] (noti) in
//                output.rectOfInterest = (scanPreviewLayer?.metadataOutputRectOfInterest(for: self!.scanPane.frame))!
//            })
            
            //保存会话
            self.scanSession = scanSession
            
            if !scanSession.isRunning{
                scanSession.startRunning()
            }
            
        }catch{
            //摄像头不可用
            LYProgressHUD.showError("相机不可用")
            self.navigationController?.popViewController(animated: true)
        }
        
    }

}


extension ScanActionViewController : AVCaptureMetadataOutputObjectsDelegate{
    
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //停止扫描
        self.scanSession.stopRunning()
        
        if !self.haveSoundPlayed{
            //建立的SystemSoundID对象
            var soundID:SystemSoundID = 0
            //获取声音地址
            let path = Bundle.main.path(forResource: "scansound", ofType: "wav")
            //地址转换
            let baseURL = NSURL(fileURLWithPath: path!)
            //赋值
            AudioServicesCreateSystemSoundID(baseURL, &soundID)
            //提醒
            AudioServicesPlaySystemSound(soundID)
            
            self.haveSoundPlayed = true
        }
        //扫描结果
        if metadataObjects.count > 0{
            if let resultObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject{
                if self.scanResultBlock != nil{
                    self.navigationController?.popViewController(animated: true)
                    self.scanResultBlock!(resultObj.stringValue!)
                }
            }
        }
    }
}

