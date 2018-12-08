//
//  FSMacro.h
//  ShareEconomy
//
//  Created by FudonFuchina on 16/4/23.
//  Copyright © 2016年 FudonFuchina. All rights reserved.
//

#ifndef FSMacro_h
#define FSMacro_h

#import "FSViewManager.h"
#import "FSKitDuty.h"
#import "UIViewExt.h"
#import "FSToast.h"
#import <FuSoft.h>
#import "FSTrackKeys.h"

/**********************************************************************************************/

typedef NS_ENUM(NSInteger, FSDBGroupType) {
    FSDBGroupTypeUnknown = 0,
    FSDBGroupTypeDiary = 1,                 // 日记
    FSDBGroupTypePassword = 2,              // 密码
} NS_ENUM_AVAILABLE_IOS(8_0);

/**********************************************************************************************/

#define THISCOLOR                  RGBCOLOR(18, 152, 233, 1)    // 主色
#define FSAPPCOLOR                 THISCOLOR
#define FSYellowColor              RGBCOLOR(253, 111, 55, 1)
#define APPCOLOR                   RGBCOLOR(250, 80, 100, 1)    // 差不多是苹果news的LOGO颜色
#define HAAPPCOLOR                 RGBCOLOR(246, 105, 128, 1)
#define FS_RedColor                RGBCOLOR(249, 49, 105, 1)
#define FS_GreenColor              RGBCOLOR(64, 171, 62, 1)

#define FS_TextColor_Dark          RGBCOLOR(16,16,16,1)
#define FS_TextColor_Normal        RGBCOLOR(88,88,88,1)
#define FS_TextColor_Light         RGBCOLOR(160,160,160,1)

#define FS_Font_Small              FONTFC(14)
#define FS_Font_Normal             FONTFC(15)
#define FS_Font_Big                FONTFC(20)

/**********************************************************************************************/
// NSUserDefaults-Key
static NSString *_theAccountChangeTime  = @"theLatestTimeOfSavedAccount";   // 账本记录后收入或成本项有变动时更新时间的key
static NSString *_type_account          = @"_type_account";
static NSString *_type_count            = @"_type_count";

static NSString *_UDKey_FirstPageShow   = @"_UDKey_FirstPageShow";          // 首页滚动条显示
static NSString *_UDKey_ImportNewDB     = @"_UDKey_ImportNewDB";            // 从外面导入一个新数据库

/**********************************************************************************************/
// NSNotification
static NSString     *_Notifi_refreshAccount = @"_Notifi_refreshAccount";                           // 刷新账本通知
static NSString     *_Notifi_refreshContact = @"_Notifi_refreshContact";                           // 刷新通讯录通知
static NSString     *_Notifi_refreshUrlPage = @"_Notifi_refreshUrlPage";                           // 刷新网页
static NSString     *_Notifi_sendSqlite3 = @"_Notifi_sendSqlite3";                                 // 导出数据库通知
static NSString     *_Notifi_refreshZone = @"_Notifi_refreshZone";                                 // 刷新组
static NSString     *_Notifi_registerLocalNotification = @"_Notifi_registerLocalNotification";     // 注册本地通知
static NSString     *_Notifi_DetailUpdateCacheData = @"_Notifi_DetailUpdateCacheData";             // 自定义账本数据更新通知

/**********************************************************************************************/
static NSString *_feedback_Email            = @"fuswift@163.com";

/**********************************************************************************************/

static NSString *_transfer_table_name   = @"_transfer_table_name";        // 数据转移的表名
static NSString *_transfer_class_name   = @"_transfer_class_name";        // 数据转移的类名

/**********************************************************************************************/

#pragma mark    SQLite3_Tables

#pragma mark 加密表
static NSString *_tb_contact     = @"contact";       // 通讯录记录表
static NSString *_tb_birth       = @"birthday";      // 生日记录表
static NSString *_tb_diary       = @"diary";         // 日记表
static NSString *_tb_alert       = @"futurealert";   // 提醒表
static NSString *_tb_password    = @"password";      // 密码表
static NSString *_tb_card        = @"_tb_card";      // 卡号

#pragma mark 暂时未加密，建议加密的表
static NSString *_tb_location    = @"location";      // 地址表
static NSString *_tb_contact_s   = @"cntct_s";       // 系统所有通讯录
static NSString *_tb_group       = @"_tb_grps";      // 组表

#pragma mark 不加密表
static NSString *_tb_abTrack     = @"accounttrack";  // 账本增减记录表
static NSString *_tb_abname      = @"tb_abname";     // 账本名
static NSString *_tb_abform      = @"ab_forms";      // 账本模板

static NSString *_tb_net         = @"tb_net";        // 增加网址
static NSString *_tb_url         = @"tb_url"  ;      // 网址导航

static NSString *_tb_appcfg      = @"b_cfg";         // app配置表
static NSString *_tb_bs_vanke    = @"bs_vanke";      // 资产负债表（万科）
static NSString *_tb_bs_bonus    = @"bs_bonus";      // 分红记录

static NSString *_tb_ch_goods    = @"im_goods";      // 库存-商品表

// 特别标记
static NSString *_SPEC_FLAG_A   = @"a_";             // 账本名前缀：a_0
static NSString *_SPEC_FLAG_T   = @"t_";             // 自定义账本的Track表前缀：t_a_0
static NSString *_SPEC_FLAG_C   = @"c_";             // 自定义账本的cache表前缀：c_a_0
static NSString *_SPEC_FLAG_S   = @"s_";             // 自定义账本的subject科目表前缀：s_a_0
static NSString *_SPEC_FLAG_M   = @"x_";             // 自定义账本的moban表前缀：x_a_0

/**********************************************************************************************/

#endif /* FSMacro_h */
