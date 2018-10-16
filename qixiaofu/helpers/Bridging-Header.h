//
//  Bridging-Header.h
//  qixiaofu
//
//  Created by 李勇 on 2017/6/7.
//  Copyright © 2017年 qixiaofu. All rights reserved.
//

//#ifndef Bridging_Header_h
//#define Bridging_Header_h

#import <UIKit/UIKit.h>




#import <CommonCrypto/CommonDigest.h>

//高德地图
//#import <AMapFoundationKit/AMapFoundationKit.h>
//#import <MAMapKit/MAMapKit.h>
//#import <AMapSearchKit/AMapSearchKit.h>
//#import <AMapLocationKit/AMapLocationKit.h>


#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件
#import <BaiduTraceSDK/BaiduTraceSDK.h>//鹰眼轨迹

#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "RSADataSigner.h"


// U-Share核心SDK
#import <UMSocialCore/UMSocialCore.h>
// U-Share分享面板SDK，未添加分享面板SDK可将此行去掉
#import <UShareUI/UShareUI.h>

//极光推送
#import "JPUSHService.h"
#import <UserNotifications/UserNotifications.h>
#import <AdSupport/AdSupport.h>

//环信
#import <HyphenateLite/HyphenateLite.h>
#import <HelpDeskLite/HelpDeskLite.h>
#import "EaseUI.h"
#import "HelpDeskUI.h"
#import "HDChatViewController.h"

//下载
#import "ZFDownloadManager.h"
#import "ZFCommonHelper.h"

//异常监测
#import <Bugly/Bugly.h>

//百度OCR
#import <AipOcrSdk/AipOcrSdk.h>


//#import "EMSDK.h"

//#endif /* Bridging_Header_h */
