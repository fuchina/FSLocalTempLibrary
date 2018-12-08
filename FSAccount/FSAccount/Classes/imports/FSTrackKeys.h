//
//  FSTrackKeys.h
//  myhome
//
//  Created by FudonFuchina on 2018/12/1.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#ifndef FSTrackKeys_h
#define FSTrackKeys_h

#import <FSTrack.h>

#pragma mark    UMeng_Event
static NSString *_UMeng_Event_start         = @"start";             // 启动
static NSString *_UMeng_Event_savesql       = @"savesql";           // 保存数据
static NSString *_UMeng_Event_scanQR        = @"scanQR";            // 扫描二维码
static NSString *_UMeng_Event_makeQR        = @"makeQR";            // 生成二维码
static NSString *_UMeng_Event_set           = @"set";               // 设置页面

static NSString *_UMeng_Event_acc_do        = @"acc_do";            // 记一笔
static NSString *_UMeng_Event_acc_mb        = @"acc_mb";            // 模板记
static NSString *_UMeng_Event_acc_su        = @"acc_su";            // 记成功
static NSString *_UMeng_Event_acc_li        = @"acc_li";            // 看报表
static NSString *_UMeng_Event_acc_show      = @"acc_show";          // 账本说明
static NSString *_UMeng_Event_acc_flow      = @"acc_flow";          // 查看流水
static NSString *_UMeng_Event_acc_flow_detail= @"acc_flow_detail";  // 查看流水
static NSString *_UMeng_Event_acc_expect    = @"acc_expect";        // 前景预测
static NSString *_UMeng_Event_acc_picture   = @"acc_picture";       // 流水图片
static NSString *_UMeng_Event_acc_change_page = @"acc_change_page";   // 账本修改页
static NSString *_UMeng_Event_acc_change_success = @"acc_change_success";   // 账本数据修改成功
static NSString *_UMeng_Event_acc_change_fail = @"acc_change_fail"; // 账数修改失败
static NSString *_UMeng_Event_seeAccNotice    = @"seeAccNotice";    // 查看科目定义

static NSString *_UMeng_Event_loan_su       = @"loan_count_su";     // 贷款计算器页面
static NSString *_UMeng_Event_jisuanqi      = @"isuanqi";           // 计算器
static NSString *_UMeng_Event_m_page        = @"m_page";            // 点赞页面
static NSString *_UMeng_Event_m_scan        = @"m_scan";            // 支付页面
static NSString *_UMeng_Event_pwd_add       = @"pwd_add";           // 增加密码

static NSString *_UMeng_Event_alert         = @"alert";             // 生成提醒
static NSString *_UMeng_Event_diary         = @"diary";             // 生成日记
static NSString *_UMeng_Event_birth         = @"birth";             // 生成生日
static NSString *_UMeng_Event_locat         = @"locat";             // 生成地址
static NSString *_UMeng_Event_conta         = @"conta";             // 生成通讯录

static NSString *_UMeng_Event_feedback      = @"feedback";          // 反馈
static NSString *_UMeng_Event_url_add       = @"url_add";           // 增加网址
static NSString *_UMeng_Event_url_tap       = @"url_tap";           // 点击网址
static NSString *_UMeng_Event_to_wechat     = @"to_wechat";         // 发到微信
static NSString *_UMeng_Event_to_mail       = @"to_mail";           // 发到邮箱

static NSString *_UMeng_Event_export_scan   = @"export_scan";       // 导出数据_扫描模式
static NSString *_UMeng_Event_export_file   = @"export_file";       // 导出数据_文件模式
static NSString *_UMeng_Event_export_contact= @"export_contact";    // 导出通讯录
static NSString *_UMeng_Event_export_password= @"export_password";  // 导出密码
static NSString *_UMeng_Event_export_diary   = @"export_diary";     // 导出日记

static NSString *_UMeng_Event_money_next     = @"money_next";       // 下期任务
//static NSString *_UMeng_Event_money_first    = @"money_first";      // 点赞首页
//static NSString *_UMeng_Event_money_click    = @"money_click";      // 点赞按钮
//static NSString *_UMeng_Event_money_wepay    = @"money_wepay";      // 微信和支付宝图片

static NSString *_UMeng_Event_cent_start       = @"cent_start";       // App Store评分开始
static NSString *_UMeng_Event_cent_success     = @"cent_success";     // App Store评分成功
static NSString *_UMeng_Event_cent_fail        = @"cent_fail";        // App Store评分失败
static NSString *_UMeng_Event_cent_home        = @"cent_home";        // App Store首页评分

static NSString *_UMeng_Event_db_import        = @"db_import";        // 导入数据库
static NSString *_UMeng_Event_db_import_success = @"db_import_success";// 导入数据库成功
static NSString *_UMeng_Event_share_confirm    = @"share_confirm";      // 分享推荐截图
static NSString *_UMeng_Event_envir_english    = @"envir_english";      // 英文环境用户
static NSString *_UMeng_Event_envir_hans       = @"envir_hans";         // 汉语环境用户
static NSString *_UMeng_Event_acc_alldata      = @"acc_alldata";        // 全览页遍历账本超过5秒
static NSString *_UMeng_Event_app_foreground   = @"app_foreground";     // app回到前台
static NSString *_UMeng_Event_wap_navigation   = @"wap_navigation";     // 分类网站
static NSString *_UMeng_Event_wap_nav_push     = @"wap_nav_push";       // 分类网站-跳转
static NSString *_UMeng_Event_old_user         = @"old_user";           // 老用户
static NSString *_UMeng_Event_watch_video      = @"watch_video";        // 查看教程
static NSString *_UMeng_Event_transfer_db_success = @"transfer_db_success"; // 转移数据库成功
static NSString *_UMeng_Event_transfer_page    = @"transfer_page";      // 发送数据库页面
static NSString *_UMeng_Event_receive_page     = @"receive_page";       // 接收数据库页
static NSString *_UMeng_Event_see_noteView     = @"see_noteView";       // 查看锁屏页说明

static NSString *_UMeng_Event_jjjsq            = @"jjjsq";              // 加减计算器
static NSString *_UMeng_Event_annalDetail      = @"annalDetail";        // 年报详情页

/*
 [MobClick event:_UMeng_Event_to_mail];
 */

#endif /* FSTrackKeys_h */
