//
//  Config.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/6/3.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

import UIKit

let KAmapKey = "c5301bb2b0677f87ed81ecdd5c1e5fbe"
let KBmapKey = "ET1AOo2SZuewsHnGUiAv6ThlynwrZlIm"
let KUMShareKey = "57bfe55d67e58e898a003e14"
let KWechatKey = "wx2ed53eb2e7badfc7"
let KWechatSecretKey = "50d414464252bc40d54445dcd373ac69"
let KTencentAppId = "1105595932"
let KTencentAppKey = "1kK4Ds2junCJlra6"
let KSinaAppSecret = "d8cc52556a836853d8c12dcdacc7a6aa"
let KSinaAppKey = "3551603297"
let KEasemobKey = "7xiaofu#7xiaofu"
let KEasemobId = "29152"
let KEasemobCertName = "dis"
let KAliPayScheme = "qixiaofuAlipay"
let KAliPayAppId = "2016091801919414"
let KJpushKey = "134f2e6898e617952d78e96f"
let KJpushSecret = "84eb4aa81ca29ca04ca0a39a"
let KAliPayPrivateKey = "MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMwP7ZPMkciLr1ap1wes0RRebboaRhyXXR1WI4RLeYSJibpSEQC/P8g/S5TTvjl4CoEBYPf9fFPMn3h9QEq6zwl6LpqgsK6WgLME1A22ARPWcEcjeNZvQ3lLv3wwmbohqbMxenOmxNIL3VvYzet6R0o4yT+dE1RIrDFmgD2VrIapAgMBAAECgYBAaO6mbjW9xUls42L6CzRbZ4re6RgkQiqj7eJ8CY6rpPYSF4FCaRtqy3/B1CwA28EFAzhmTl6F3NqhH3fBnsFmPh3S2O62KV2215Uvhpq3cm1T85vWHCAeOPh0mdo1eDu9eyyTEHO/yYpFh4XedDTvN8qreOaAWrmUs+qGuvAhAQJBAOZ6A9eroTlJM7fCDkWiWumPwVKYm94bxNrB7ZT8tSV+fRpRm538MbAjUr02e0EqtnYdbo0jVGRK9PvvxmwZF1ECQQDiqRFeJnPbctkB7QGLni7y6B3Zl0QlaTdvZeNTrUO5M8dXzv6iGze4Ps/Jc0cC/RnaQqJDa4Q4gmjTa1S3MNPZAkEA3rcVs3l0yIjGY1IwvHWRaJWz+P7j0BQBfGteDFTPL7Y1ahNmT5p+4Xig4ZseK/D8dNMoG1cCnBAbAMHJengcoQJAC/IZJjsklAZDhaR2FmOp2cd9+z/LqaUX9NkL2BcjoJkoAmq4ZNbGYwF8dgOLVI7+U9B7OM5r04ab+7iGaHk8UQJAD3wMeuUFphfsHTUyPWSFKGw1mVlkSlRRIHQdgCj2Cm7PesQK9cm9A3b4UBg7AIvOGEtroIBapwdCxr2nbndYgg=="
let KWechatPayNotiName = "WechatPayResultNotificationName"
let KWechatLoginNotiName = "WechatLoginResultNotificationName"


public let IsNotFirstOpen = "IsNotFirstOpen" + appVersion() //是否为第一次打开app
public let IsLogin = "IsLogin" //是否已登陆app
public let IsEPLogin = "IsEPLogin" //是否已登陆app
public let IsSystemMaintaining = "IsSystemMaintaining"//是否为系统维护中
public let IsTrueName = "IsTrueName" + LocalData.getUserPhone()//是否已实名认证
public let IsEPApproved = "IsEPApproved" + LocalData.getUserPhone()//企业信息已审核
public let IsALevelUser = "IsALevelUser"//是否为A等级用户
public let IsBeShowNoticeView = "IsBeShowNoticeView"//是否准备暂时公告
let KEnterAppNotification = "KEnterAppNotification"//点击引导页的btn发出通知
let KPickCouponSuccessNotification = "PickCouponSuccessNotification"//领券成功发出通知

class Config: NSObject {
    
}
