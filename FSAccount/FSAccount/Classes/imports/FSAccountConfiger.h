//
//  FSAccountConfiger.h
//  myhome
//
//  Created by FudonFuchina on 2017/4/2.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#ifndef FSAccountConfiger_h
#define FSAccountConfiger_h

// 科目只能是两个字母表示
static NSString *_subject_SR = @"sr";    // 收入
static NSString *_subject_CB = @"cb";    // 成本

static NSString *_subject_YS = @"ys";    // 应收
static NSString *_subject_XJ = @"xj";    // 现金
static NSString *_subject_TZ = @"tz";    // 投资
static NSString *_subject_CH = @"ch";    // 存货
static NSString *_subject_GZ = @"gz";    // 固资
static NSString *_subject_TX = @"tx";    // 摊销

static NSString *_subject_FZ = @"fz";    // 负债
static NSString *_subject_PS = @"ps";    // 预收

static NSString *_subject_QY = @"qy";    // 净资产
static NSString *_subject_BJ = @"bj";    // 本金
static NSString *_subject_GB = @"gb";    // 股本

static NSString *_subject_ZC = @"zc";    // 资产
/*---------------------------------------------------------------------------------------------*/

static NSString *_hanzi_JE = @"je";    // 金额
static NSString *_hanzi_ZZL= @"zzl";   // 资债率
static NSString *_hanzi_ZZL_NOCASH = @"ncs";   // 资债率(不含现金)
static NSString *_hanzi_LR = @"lr";    // 利润
static NSString *_hanzi_JLV= @"jlv";   // 净利率
static NSString *_hanzi_PH = @"ph";    // 试算平衡
static NSString *_hanzi_TTR= @"ttr";   // 周转率
static NSString *_hanzi_JZS= @"jzs";   // 净资产收益率


static NSString *_ING_KEY    = @"p";    // 加
static NSString *_ED_KEY     = @"m";    // 减


#endif /* FSAccountConfiger_h */
