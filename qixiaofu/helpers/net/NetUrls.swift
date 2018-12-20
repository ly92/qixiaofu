//
//  NetUrls.swift
//  qixiaofu
//
//  Created by 李勇 on 2017/6/3.
//  Copyright © 2017年 q4ixiaofu. All rights reserved.
//

import UIKit

let officialServer = "http://www.7xiaofu.com/"//正式服务器
let testServer = "http://10.216.2.11/"//测试服务器（内网）
//let usedServer = officialServer
let usedServer = testServer
let DeBug = false

/************************************ 登录 ********************************************/
//登录
let LoginApi = "api/index.php?act=login&op=index"
//退出
let LogoutApi = "api/index.php?act=logout&op=index"
//注册获取验证码
let VerificationCodeApi = "api/index.php?act=send&op=code"
//注册 
let RegisterApi = "/api/index.php?act=login&op=register"
//个人其他资料显示
let ShowMemberInfoApi = "tp.php/Home/My/showMemberInfo"
//用户注册协议
let RegisterRulesApi = usedServer + "download/xieyi/xieyi.html"
//忘记密码重设
let ForgetPwdApi = "api/index.php?act=shop&op=forget_member_password"
//重置支付密码
let ResetPayPwdApi = "tp.php/Home/My/checkVerify"
//请求更新
let iOSVersionApi = "tp.php/Home/Member/iOSVersion"
//第三方登录验证
let ThirdLoginApi = "api/index.php?act=login&op=third_partylogin&type=1"
//绑定第三方账户
let BinDingThirdAccountApi = "api/index.php?act=login&op=party_newlogin&type=1"
//位置上传
let UpdateUserLocationApi = "tp.php/Home/My/user_location"


/************************************ 首页 ********************************************/
//首页数据
let HomeMainApi = "tp.php/Home/Index/Index/"
//新首页数据
let HomeMainNewApi = "tp.php/Home/Main/index"
//更多功能
let HomeMoreApi = "tp.php/Home/Main/main_list"
//沙龙详情
let HomeCourseDetailApi = "tp.php/Home/Main/salon_detail"
//沙龙报名
let HomeCourseEnrollApi = "tp.php/Home/Main/salon_sign_up"
//更多沙龙数据
let HomeMoreCourseApi = "tp.php/Home/Main/salon_list"
//接单订单列表
let HomeTaskListApi = "tp.php/Home/Index/BillList/"
//小七推荐订单列表
let HomeRecommandTaskListApi = "tp.php/Home/Index/reMore/"
//接单订单详情
let HomeTaskDetailApi = "tp.php/Home/Index/BillDetail/"
//检查是否已报名
let CheckEnrollApi = "tp.php/Home/Member/isenroll"
//点击接单
let HomeReceiveTaskApi = "/tp.php/Home/Member/takeBill/"
//报名申请
let requestEnrollApi = "tp.php/Home/Member/enrollBill/"
//工程师列表列表
let HomeEngineerListApi = "tp.php/Home/Index/engList/"
//小七推荐工程师列表
let HomeRecommandEngineerListApi = "tp.php/Home/Index/engMore/"
//工程师详情
let HomeEngineerDetailApi = "tp.php/Home/Index/engDetail/"
//评价列表,客户对工程师的评价
let HomeEngineerCommentListApi = "tp.php/Home/Index/engEvalList"
//评价列表,工程师对客户的评价
let HomeCustomerCommentListApi = "tp.php/Home/Index/clientCommentList/"
//评价列表,//我的接单，接单详情，我的发单，发单详情中的订单号
let HomeOrderCommentListApi = "tp.php/Home/My/orderComment"
//发单时的必要因素
let SendTaskEssentialDataApi = "tp.php/Home/Member/showaddbill"
//发单
let SendTaskApi = "tp.php/Home/Member/addbill"
//发单时的分类和型号
let SendTaskFacilityTypeApi = "tp.php/Home/Member/facility_type"
//上传图片
let UploadImageApi = "tp.php/Home/Public/Upload"
//同时上传多张图片
let UploadAllImageApi = "tp.php/Home/Public/Upload666"
//匹配工程师列表
let MatchEngineerListApi = "tp.php/Home/Member/billMatchEngList"
//所有工程师库存分布
let MapMatchEngineerListApi = "api/index.php?act=goods&op=engStorageList2"
//匹配工程师
let MatchEngineerApi = "tp.php/Home/Member/billMatchEngRemind"
//接单-订单列表-所有可接订单
let HomeAllTaskListApi = "tp.php/Home/Index/searchALLBill"
//设置空闲时间
let SetSpaceTimeApi = "tp.php/Home/Member/tackDataSave/"
//公告列表
let NoticeListApi = "tp.php/Home/Notice/index"
//公告详情
let NoticeDetailApi = "tp.php/Home/Notice/notice_info"
//扫码吃早餐
let HaveBreakfastApi = "tp.php/Home/Member/fudou_deduct"
//优惠券大礼包
let CouponGiftBagApi = "tp.php/Home/Main/coupon_push"


/************************************ 驻场招聘 ********************************************/
//驻场招聘（搜索）列表
let JobListApi = "tp.php/Home/Engineer/index"
//职位类别
let JobTypeListApi = "tp.php/Home/Engineer/job_type"
//发布招聘&招聘详情编辑
let PublishJobApi = "tp.php/Home/Engineer/send_job"
//我的发布
let MyJobListApi = "tp.php/Home/Engineer/sended_job"
//招聘详情
let JobDetailApi = "tp.php/Home/Engineer/job_details"
//推荐工程师
let JobRecommendEngListApi = "tp.php/Home/Engineer/engineer_recommend"
//更改招聘状态  status  招聘状态，1招聘，2暂停，3删除
let JobOperationApi = "tp.php/Home/Engineer/is_continue"
//招聘时立即沟通
let JobChatApi = "tp.php/Home/Engineer/chats"
//沟通历史
let JobChatHistoryApi = "tp.php/Home/Engineer/chat_history"
//发送简历
let JobEngSendResumeApi = "tp.php/Home/Engineer/resume"


/************************************ 优惠券 ********************************************/
//七小服优惠券列表
//let CouponListApi = "tp.php/Home/Main/coupon_list"
let CouponListApi = "tp.php/Home/Main/coupon_list_new"
//领取优惠券
let CouponTakeApi = "tp.php/Home/Main/coupon_receive"
//我的优惠券列表
//let MyCouponListApi = "tp.php/Home/Main/my_coupon_list"
let MyCouponListApi = "tp.php/Home/Main/my_coupon_list_new"
//本次可用的优惠券
let CouponCanUseApi = "tp.php/Home/Main/my_coupon_choose"//coupon 优惠券类别值待测为1代卖为2代存为3
let CouponCanShopUseApi = "tp.php/Home/Main/coupon_choice"//pay 本次支付所需要的钱数
/************************************ 商城 ********************************************/
//左侧列表数据,banner数据
let ShopCategoryDataApi = "api/index.php?act=goods_class"
//商品列表数据
let ShopGoodsListApi = "api/index.php?act=goods&op=goods_list"
//搜索商品列表数据
let SearchShopGoodsListApi = "tp.php/Home/RepositoryType/seachgoods?op=goods_list&act=goods"
//商品详情数据
let ShopGoodsDetailApi = "api/index.php?act=goods&op=goods_detail"
//收藏商品
let CollectGoodsApi = "api/index.php?act=member_favorites&op=favorites_add"
//取消收藏
let CancelCollectGoodsApi = "api/index.php?act=member_favorites&op=favorites_del"
//收藏列表
let CollectGoodsListApi = "api/index.php?act=member_favorites&op=favorites_list"
//商品库存位置
let GoodsLocationApi = "api/index.php?act=goods&op=storageDetail"
//所有工程师库存分布
let EngineersLocationApi = "api/index.php?act=goods&op=engStorageList"
//加入购物车
let GoodsAddToCarApi = "api/index.php?act=member_cart&op=cart_add"
//支付前加载数据
let GoodsPreparePayDataApi = "api/index.php?act=member_buy&op=buy_step1"
//支付前加载数据
let GoodsPayOrderApi = "api/index.php?act=member_buy&op=buy_step2"

//代测分类数据
let TestServiceApi = "tp.php/Home/Determinand/index"
//提交代测数据
let SubmitTestServiceApi = "tp.php/Home/Determinand/adddeterminand"
//代测订单列表
let TestOrderListApi = "tp.php/Home/Determinand/determinandorder"
//代测订单详情
let TestOrderDetailApi = "tp.php/Home/Determinand/determinandorderinfo"
//代测订单删除单个商品
let TestServiceDeleteOneApi = "tp.php/Home/Determinand/deletegoods"
//代测物品寄回
let TestServiceBackOwnerApi = "tp.php/Home/Determinand/goodssendback"
//代测订单删除整个订单
let TestServiceDeleteAllApi = "tp.php/Home/Determinand/deleteorder"
//代测订单取消整个订单
let TestServiceCancelOrderApi = "tp.php/Home/Determinand/removeorder"
//代测物品邮寄地址
let TestChooseAdderessApi = "tp.php/Home/Determinand/seachaddress"
//支付
let TestPayOrderApi = "tp.php/Home/Member/paydeterminand"
//发货
let TestLogisticsApi = "tp.php/Home/Determinand/sendorder"
//确认收货
let TestSureLogisticsApi = "tp.php/Home/Determinand/confirmorder"
//去代卖设置价格
let TestPriceForSealGoodsApi = "tp.php/Home/Determinand/goodssale"
//仓储套餐
let StoragePriceApi = "tp.php/Home/Determinand/depotprice"
//仓储套餐购买
let StorageMealBuyApi = "tp.php/Home/Determinand/reletpay"
//代卖订单列表
let AgencySealListApi = "tp.php/Home/Determinand/mysale"
//代卖详情接口
let AgencySealDetailApi = "tp.php/Home/Determinand/mysaleinfo"
//取消代卖
let CancelSealApi = "tp.php/Home/Determinand/oversale"
//删除代卖记录
let DeleteSealApi = "tp.php/Home/Determinand/detelesale"
//代卖者发货----dead api
let SealLogisticeApi = "tp.php/Home/Determinand/updateawb"
//代卖修改价格
let ChangeSealPriceApi = "tp.php/Home/Determinand/changeprice"
//代卖取消客户确认收货
let SealConsigneeApi = "tp.php/Home/Determinand/confirmgoods"
//代卖发起售后
let AddAfterSaleApi = "tp.php/Home/Determinand/after_sale"
//查看代卖售后详情
let AfterSaleDetailApi = "tp.php/Home/Determinand/after_info"
//确认售后问题
let EndAfterSaleApi = "tp.php/Home/Determinand/confirm_after"
//解决不了售后，同意退款
let AfterSaleRefundApi = "tp.php/Home/Determinand/confirm_givemoney"
//物流信息
let LogisticsInfoApi = "tp.php/Home/Public/kuaidi"

/************************************ 信息 ********************************************/
//系统消息
let SysTermMessageApi = "api/index.php"
//消息详情
let MessageDetaileApi = "api/index.php?act=member_index&op=show_message"



/************************************  我  ********************************************/
//个人信息
let PersonalInfoApi = "tp.php/Home/My/showMemberInfo"
//用户信息
let UserInfoApi = "tp.php/Home/Public/getMemberInfoByPhone/"
//修改个人信息
let ChangePersonalInfoApi = "tp.php/Home/My/updateMemberInfo"
//更改工程师简历
let ChangeResumeApi = "tp.php/Home/Engineer/engineer_info"
//服务领域数据
let ServerRangeListApi = "tp.php/Home/Index/getClass"
//加分请求
let AddReditsApi = "tp.php/Home/My/addIntegral"//1:注册 2:实名认证 3:完成第一个订单加分
//关联用户
let ConnectMemberApi = "tp.php/Home/My/myUniAcc"
//关联用户设置备注名
let SetConnectMemberNameApi = "tp.php/Home/My/setMemberNote"
//是否设置了密码
let HaveSetPayPasswordApi = "tp.php/Home/My/checkPayPwd"
//修改用户头像
//let ChangePersonalIconApi = "api/index.php?act=member_index&op=upheadimg"
let ChangePersonalIconApi = "tp.php/Home/My/uploadImage"
//添加或者修改证书
let AddCertificateApi = "tp.php/Home/My/updateMemberInfoCer"
//删除改证书
let DeleteCertificateApi = "tp.php/Home/My/delMemberInfoCer"
//实名认证信息
let IdentityInfoApi = "tp.php/Home/My/showMyReal"
//实名认证信息提交
let IdentitySubmitApi = "tp.php/Home/My/updateMyReal"
//回复评论
let ReplayCommentApi = "tp.php/Home/Member/addReply"
//检验签到状态
let CheckSignStateApi = "tp.php/Home/My/signShow"
//签到
let SignApi = "tp.php/Home/My/sign"
//积分列表
let CreditsListApi = "tp.php/Home/My/signList"
//意见反馈
let FeedbackApi = "tp.php/Home/My/feedBack"
//设置支付密码
let SetPayPwdApi = "tp.php/Home/My/setPayPwd"
//修改支付密码
let ChangePayPwdApi = "tp.php/Home/My/upPayPwd"
//修改登录密码
let ChangeLoginPwdApi = "api/index.php?act=member_index&op=edit_password"
//收货地址列表
let AddressListApi = "api/index.php?act=member_address&op=address_list"
//添加收货地址
let AddAddressApi = "api/index.php?act=member_address&op=address_add"
//删除收货地址
let DeleteAddressApi = "api/index.php?act=member_address&op=address_del"
//设为默认收货地址
let SetDefaultAddressApi = "api/index.php?act=member_address&op=address_set_default"
//编辑收货地址
let EditAddressApi = "api/index.php?act=member_address&op=address_edit"
//全国地址
let AddressAreaListApi = "api/index.php?act=member_address&op=area_list"
//购物车列表
let ShopCarListApi = "api/index.php?act=member_cart&op=cart_list"
//购物车列表-修改数量
let ShopCarEditCountApi = "api/index.php?act=member_cart&op=cart_edit_quantity"
//购物车列表-删除某物品
let ShopCarDeleteGoodsApi = "api/index.php?act=member_cart&op=cart_del"
//钱包页面
let WalletApi = "tp.php/home/my/showBalance"
//钱包概述
let WalletInfoApi = "tp.php/Home/My/wallet_info"
//钱包明细列表
let WalletDetailApi = "tp.php/home/my/showBalanceDetail"
//钱包充值
let RechargeWalletApi = "tp.php/Home/My/recharge"
//钱包充值-处理结果
let RechargeDealApi = "tp.php/Home/My/rechargeDeal"
//钱包提现
let WithDrawWalletApi = "tp.php/Home/My/reCash"

/************************************  我的发单/接单  ********************************************/
//我的发单列表
let MySendOrderListApi = "tp.php/Home/My/myBillList"
//我的发单-报名列表
let MySendEnrollListApi = "tp.php/Home/Member/enrollsendtype"
//工程师报名列表
let EnrollEngineerListApi = "tp.php/Home/Member/enrollList"
//指定接单人
let AuthorizedEngApi = "tp.php/Home/Member/makeBill"
//指定接单人-可能需要付款
let AuthorizedEngPayApi = "tp.php/Home/Member/makeenrollpay"
//我的发单详情
let MySendOrderDetailApi = "tp.php/Home/My/myBillDetail"
//评价工程师
let AddCommentToEngineerApi = "tp.php/Home/My/addEngEvaluation"
//评价客户
let AddCommentToCustomerApi = "tp.php/Home/My/addClientEvaluation"
//客户取消订单
let CancelCustomerOrderApi = "tp.php/Home/My/offBill"
//客户撤销订单
let UndoCustomerOrderApi = "tp.php/Home/My/undoBill"
//客户确认完成
let CompleteCustomerOrderApi = "tp.php/Home/My/comBill"
//客户删除订单
let DeleteCustomerOrderApi = "tp.php/Home/My/myBillDel"
//客户确认未完成订单
let UNCompleteCustomerOrderApi = "tp.php/Home/My/noBill"

//我的接单列表
let MyReceiveOrderListApi = "tp.php/Home/My/myOtList"
//我的接单-报名列表
let MyReceiveEnrollListApi = "tp.php/Home/Member/enrolltype"
//取消我的接单
let CancelEngineerOrderApi = "tp.php/Home/My/engOffBill"
//删除我的接单
let DeleteEngineerOrderApi = "tp.php/Home/My/engDelBill"
//同意调价
let AgreeOrUnAgreeChangePriceApi = "tp.php/Home/My/upBillPriceEng"
//工程师开始工作
let EngineerStartWorkApi = "tp.php/Home/My/engStartWork"
// 拒绝转移
let EngineerRefuseTransferMove = "tp.php/Home/My/refuseMove";
//同意转移
let EngineerAgreeTransferMove = "tp.php/Home/My/billMove";
//接单详情
let ReceiveDetailDataApi = "tp.php/Home/My/myOtDetail"
//未支付订单-支付
let RepayOrderApi = "tp.php/Home/My/rePayBill"
//客户完成补单
let CustomerFinishOrderApi = "tp.php/Home/My/engComBill"
//工程师完成接单
let EngineerFinishOrderApi = "tp.php/Home/My/engSuccBill"
//工程师修改报价
let EngineerRechangePriceApi = "tp.php/Home/Member/repeat_quotation"
//备件sn码列表
let ReplacementPartListApi = "tp.php/Home/My/getEngGoodsSn"
//调价-原价比较高
let ChangeDownPriceApi = "tp.php/Home/My/upBillPriceGuest"
//调价-原价比较低
let ChangeUpPriceApi = "tp.php/Home/My/upBillPriceGuestPay"
//加载订单详细信息
let RedoOrderDataApi = "tp.php/Home/My/showReSetBill"
//添加服务单
let AddServiceBillApi = "tp.php/Home/My/serviceReportAdd"
//服务单详情
let ServiceBillDetailApi = "tp.php/Home/My/showServiceReportInfo"
//新件服务单前请求数据
let PrepareServiceBillDetailApi = "tp.php/Home/My/serviceReportInfo"
//修改服务单
let ModifyServiceBillApi = "tp.php/Home/My/serviceReportModify"
//重新发布订单
let RedoOrderApi = "tp.php/Home/My/reSetBill"
//空闲时间列表
let FreeTimeListApi = "tp.php/Home/Member/showFreeTime"
//关联用户列表
let AssociationApi = "tp.php/Home/My/myUniAcc1"
//订单转移
let TransferOrderApi = "tp.php/Home/My/startMove"
//销库存
let SpendInventoryApi = "tp.php/Home/My/clearEngGoodsSn"
//更改库存地址
let ChangeInventoryAddressApi = "tp.php/Home/My/saveEngGoodsSnArea"
//小库存-筛选-搜索
let SearchInventoryApi = "tp.php/Home/My/searchEngGoodsSn"

// 商城订单列表
let ShopOrderListApi = "api/index.php?act=member_order&op=order_list"
//取消商城订单
let ShopOrderCancelApi = "api/index.php?act=member_order&op=order_cancel"
//发货前删除订单
let ShopOrderBreforeDeliverApi = "api/index.php?act=member_order&op=add_return_all"
//发货后删除订单
let ShopOrderAfterDeliverApi = "api/index.php?act=member_order&op=order_delete"
//确认收货
let ShopOrderTakeDeliverApi = "api/index.php?act=member_order&op=order_receive"
//提醒发货
let ShopOrderRemindDeliverApi = "tp.php/Home/My/addStoreMsg"
//未支付商城订单-支付
let ShopOrderPayApi = "api/index.php?act=member_order&op=checkstand_saveapi/index.php?act=member_order&op=checkstand_save"

//商城订单详情
let ShopOrderDetailApi = "api/index.php?act=member_order&op=show_order"
//退换货第一步
let PurchaseExchangeApiStepOne = "api/index.php?act=member_order&op=refund_return_step_one"
//退换货第二步
let PurchaseExchangeApiStepTwo = "api/index.php?act=member_order&op=refund_return_step_two"
//退换货第三步//退换货完成订单
let ChangeOrRefundDoneApi = "api/index.php?act=member_order&op=refund_return_step_three"
//退换货时sn列表
let PurchaseExchangeSnsApi = "tp.php/Home/My/getReturnGoodsSn"


/************************************  知识库  ********************************************/
//知识库筛选条件
let KnowledgeCategoryApi = "tp.php/Home/RepositoryType/index"
//知识库列表
let KnowledgeListApi = "tp.php/Home/RepositoryType/seachpost"
//知识库详情
let KnowledgeDetailApi = "tp.php/Home/RepositoryType/postinfo"
//知识库点赞
let KnowledgePariseApi = "tp.php/Home/RepositoryType/upvote"

//培训列表
let KCourseListApi = "tp.php/Home/Lession/index"
//培训详情
let KCourseDetailApi = "tp.php/Home/Lession/lession_info"
//支付培训
let KCoursePayApi = "tp.php/Home/Member/paylession"

//服豆列表
let KCouponListApi = "tp.php/Home/My/fudouList"

//视频列表
let KVideoListApi = "tp.php/Home/Mv/index"
let KVideoListApi1 = "tp.php/Home/Mv/index1"
//视频详情接口
let KVideoDetailApi = "tp.php/Home/Mv/video_info"
let KVideoDetailApi1 = "tp.php/Home/Mv/video_info1"
//视频点赞接口
let KVideoPraiseApi = "tp.php/Home/Mv/thumb_up"
//增加视频播放量
let KVideoPlayCountApi = "tp.php/Home/Mv/video_amount"
//视频标签
let KVideoTagListApi = "tp.php/Home/Mv/review_label"
//评论列表
let KVideoCommentListApi = "tp.php/Home/Mv/review_list"
//视频评论
let KVideoCommentApi = "tp.php/Home/Mv/video_review"
//视频打赏
let KVideoRewardApi = "tp.php/Home/Mv/review_reward"

/************************************  插件  ********************************************/
//插件列表
let PluginListApi = "tp.php/Home/Plug/pluglist"
//插件详情
let PluginDetailApi = "tp.php/Home/Plug/pluginfo"
//根据付款码请求付款数据
let PluginPayDataApi = "tp.php/Home/Plug/searchprice"
//插件付款
let PluginPayApi = "tp.php/Home/Member/payplug"
//插件购买记录
let PluginBuyHistoryApi = "tp.php/Home/Plug/searchorder"



/************************************  企业采购  ********************************************/
//获取验证码
let EnterpriseVerificationCodeApi = "tp.php/Company/Register/companycode"//type 1 代表注册验证码  2 代表忘记密码  3代表忘记支付密码
//企业注册
let EnterpriseRegisterApi = "tp.php/Company/Register/company_register"
//企业账户登录
let EnterpriseLoginApi = "tp.php/Company/Register/company_login"
//企业退出账户
let EnterpriseLogoutApi = "tp.php/Company/CompanySet/logout"
//企业实名认证
let EnterpriseIdVertifiApi = "tp.php/Company/Management/updatecompanyReal"
//企业实名认证信息
let EPIDInfoApi = "tp.php/Company/Management/showComapnyReal"
//企业采购中心
let EnterpriseCenterApi = "tp.php/Company/Management/buycenter"
//企业信息
let EnterpriseInfoApi = "tp.php/Company/Management/businessinfo"
//企业账户管理
let EnterpriseManagerAccountApi = "tp.php/Company/Management/index"
//添加子账户
let EnterpriseAddAccountApi = "tp.php/Company/Management/addmanagement"
//设置为主账户
let EnterpriseSetMainAccountApi = "tp.php/Company/Management/setmanagement"
//禁用子账户
let EnterpriseDeleteAccountApi = "tp.php/Company/Management/delmanagement"
//禁用后启用子账户
let EnterpriseUnDeleteAccountApi = "tp.php/Company/Management/openmanagement"
//主账户修改子账户信息
let EnterpriseEditAccountApi = "tp.php/Company/Management/updatemanagement"
//修改登录密码-未忘记原登录密码
let EnterpriseVertifiPwdApi = "tp.php/Company/Management/editpassword"
//修改登录密码-忘记原登录密码
let EnterpriseVertifiForgetPwdApi = "tp.php/Company/Register/forget_company_password"
//账户成员订单量
let EnterpriseAccountBillApi = "tp.php/Company/Management/accountorder"
//某人的账单
let EnterpriseDetailBillApi = "tp.php/Company/Management/allorder"
//忘记支付密码
let EnterpriseForgetPayPwdApi = "tp.php/Company/Register/forget_company_paypassword"
//修改支付密码
let EnterpriseVertifiPayPwdApi = "tp.php/Company/CompanySet/change_paypassword"
//设置支付密码
let EnterpriseSetPayPwdApi = "tp.php/Company/CompanySet/set_paypassword"
//测试标准列表
let TestStandardListApi = "tp.php/Company/Standard/test_standard_list"
//添加测试标准
let AddTestStandardApi = "tp.php/Company/Standard/test_standard_add"
//选择测试标准
let ChooseTestStandardApi = "tp.php/Company/Standard/test_standard_choose"
//删除测试标准
let DeleteTestStandardApi = "tp.php/Company/Standard/test_standard_del"
//包装标准列表
let PackageStandardListApi = "tp.php/Company/Standard/package_standard_list"
//添加包装标准
let AddPackageStandardApi = "tp.php/Company/Standard/package_standard_add"
//选择包装标准
let ChoosePackageStandardApi = "tp.php/Company/Standard/package_standard_choose"
//删除包装标准
let DeletePackageStandardApi = "tp.php/Company/Standard/package_standard_del"

/************************************  企业采购--商城  ********************************************/
//商品分类和banner
let EPShopClassicApi = "tp.php/Company/CompanyGoods/goods_type"
//商品列表接口
let EPGoodsListApi = "tp.php/Company/CompanyGoods/goods_list"
//商品详情接口
let EPGoodsDetailApi = "tp.php/Company/CompanyGoods/goods_info"
//三方比价
let EPGoodsPriceApi = "tp.php/Company/Register/interim"
//收藏商品
let EPCollectGoodsApi = "tp.php/Company/CompanyGoods/college_goods"//goods_id  参数,,,,暂时 不用
//商品添加到购物车
let EPAddGoodsToCarApi = "tp.php/Company/CompanyOrder/shopping_cart_add"
//我的购物车
let EPShopCarListApi = "tp.php/Company/CompanyOrder/shopping_cart_show"
//购物车商品删除
let EPDeleteShopCarSingleApi = "tp.php/Company/CompanyOrder/shopping_cart_del"
//商品下单
let EPShopBuyApi = "tp.php/Company/CompanyOrder/order_add"
//商品线下支付
let EPShopPayOfflineApi = "tp.php/Company/CompanyOrder/order_off_line_pay"
//商品钱包支付
let EPShopPayWalletApi = "tp.php/Company/CompanyOrder/order_wallet_pay"
//商品第三方支付
let EPShopPayOnlineApi = "tp.php/Company/CompanyOrder/order_third_pay"
//我的优惠券列表
let EPMyCouponListApi = "tp.php/Company/CompanyCoupon/company_user_coupon_list"//type 1为未使用列表 2为已使用列表 3为已过期列表
//领券中心
let EPCouponListApi = "tp.php/Company/CompanyCoupon/coupon_list"
//领取优惠券
let EPReceiveCouponApi = "tp.php/Company/CompanyCoupon/coupon_receive"
//可用优惠券
let EPShopUsefulCouponApi = "tp.php/Company/CompanyOrder/coupon_choose"
//钱包明细
let EPMoneyInfoApi = "tp.php/Company/Management/money_list"
//钱包充值
let EPMoneyRechargeApi = "tp.php/Company/Management/company_recharge"
//钱包提现
let EPMoneyWithdrawApi = "tp.php/Company/Management/company_reCash"
//检查是否设置支付密码
let EPCheckPayPwdApi = "tp.php/Company/Management/checkComapnyPayPwd"
//收货地址
let EPAddressListApi = "tp.php/Company/CompanySet/address_list"
//修改收货地址
let EPVertifiAddressApi = "tp.php/Company/CompanySet/address_edit"
//增加收货地址
let EPAddAddressApi = "tp.php/Company/CompanySet/add_company_address"
//删除收货地址
let EPDeleteAddressApi = "tp.php/Company/CompanySet/address_del"
//设置为默认地址
let EPSetDefaultAddressApi = "tp.php/Company/CompanySet/companyaddress_set_default"
//省市区
let EPAddressInfoListApi = "tp.php/Company/CompanySet/area_list"
//商城订单列表
let EPShopOrderListApi = "tp.php/Company/CompanyOrder/company_order_list"
//商城订单详情
let EPShopOrderDetailApi = "tp.php/Company/CompanyOrder/company_order_info"
//订单删除
let EPShopOrderDeleteApi = "tp.php/Company/CompanyOrder/company_order_del"
//收货
let EPShopOrderReceiveApi = "tp.php/Company/CompanyOrder/company_order_receive"
//收货前取消
let EPShopOrderCancelApi = "tp.php/Company/CompanyOrder/company_order_cancle"


/************************************  企业采购--售后  ********************************************/
//退换货提交申请
let EPExcgangeOrReturnApi = "tp.php/Company/CompanyReturn/return_add"
//填写退换货寄回的物流号
let EPReturnLogisticsApi = "tp.php/Company/CompanyReturn/return_send_goods"
//退换货订单列表
let EPExchangeListApi = "tp.php/Company/CompanyReturn/company_return_list"
//退换货订单详情
let EPExchangeDetailApi = "tp.php/Company/CompanyReturn/company_return_info"
//退换货取消申请
let EPExchangeCancelApi = "tp.php/Company/CompanyReturn/return_goods_change"
//退换货删除申请记录
let EPExchangeDeleteApi = "tp.php/Company/CompanyReturn/return_goods_del"


/************************************  企业采购--消息  ********************************************/
//消息列表
let EPMessageListApi = "tp.php/Company/Message/message_list"
//未读消息数量
let EPMessageUnReadCountApi = "tp.php/Company/Message/message_count"
//标示已读
let EPMessageReadApi = "tp.php/Company/Message/message_read"
//全部标示已读
let EPMessageReadAllApi = "tp.php/Company/Message/message_read_all"
//删除
let EPMessageDeleteApi = "tp.php/Company/Message/message_del"
//全部删除
let EPMessageDeleteAllApi = "tp.php/Company/Message/message_del_all"





class NetUrls: NSObject {

}


