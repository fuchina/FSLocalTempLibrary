//
//  FSCompanyPublic.h
//  Expand
//
//  Created by Fuhope on 2017/12/20.
//  Copyright © 2017年 china. All rights reserved.
//

#import <Foundation/Foundation.h>

// 流动资产
static NSString *_company_subject_ab = @"ab";  // 货币资金
static NSString *_company_subject_ac = @"ac";  // 交易性金融资产
static NSString *_company_subject_ad = @"ad";  // 应收票据
static NSString *_company_subject_ae = @"ae";  // 应收账款
static NSString *_company_subject_af = @"af";  // 预付款项
static NSString *_company_subject_ag = @"ag";  // 应收利息
static NSString *_company_subject_ah = @"ah";  // 应收股利
static NSString *_company_subject_ai = @"ai";  // 其他应收款
static NSString *_company_subject_aj = @"aj";  // 存货
static NSString *_company_subject_ak = @"ak";  // 一年内到期的非流动资产
static NSString *_company_subject_al = @"al";  // 其他流动资产
static NSString *_company_subject_aa = @"aa";  // 流动资产合计
// 非流动资产
static NSString *_company_subject_ba = @"ba";  // 可供出售金融资产
static NSString *_company_subject_bc = @"bc";  // 持有至到期投资
static NSString *_company_subject_bd = @"bd";  // 长期应收款
static NSString *_company_subject_be = @"be";  // 长期股权投资
static NSString *_company_subject_bf = @"bf";  // 投资性房地产
static NSString *_company_subject_bg = @"bg";  // 固定资产
static NSString *_company_subject_bh = @"bh";  // 在建工程
static NSString *_company_subject_bi = @"bi";  // 工程物资
static NSString *_company_subject_bj = @"bj";  // 固定资产清理
static NSString *_company_subject_bk = @"bk";  // 生产性生物资产
static NSString *_company_subject_bl = @"bl";  // 油气资产
static NSString *_company_subject_bm = @"bm";  // 无形资产
static NSString *_company_subject_bn = @"bn";  // 开发支出
static NSString *_company_subject_bo = @"bo";  // 商誉
static NSString *_company_subject_bp = @"bp";  // 长期待摊费用
static NSString *_company_subject_bq = @"bq";  // 递延所得税资产
static NSString *_company_subject_br = @"br";  // 其他非流动资产
static NSString *_company_subject_bb = @"bb";  // 非流动资产合计
// 资产总计
static NSString *_company_subject_az = @"az";  // 资产总计
// 流动负债
static NSString *_company_subject_ca = @"ca";  // 短期借款
static NSString *_company_subject_cb = @"cb";  // 交易性金融负债
static NSString *_company_subject_cd = @"cd";  // 应付票据
static NSString *_company_subject_ce = @"ce";  // 应付账款
static NSString *_company_subject_cf = @"cf";  // 预收款项
static NSString *_company_subject_cg = @"cg";  // 应付职工薪酬
static NSString *_company_subject_ch = @"ch";  // 应交税费
static NSString *_company_subject_ci = @"ci";  // 应付利息
static NSString *_company_subject_cj = @"cj";  // 应付股利
static NSString *_company_subject_ck = @"ck";  // 其他应付款
static NSString *_company_subject_cl = @"cl";  // 一年内到期的非
static NSString *_company_subject_cm = @"cm";  // 其他流动负债
static NSString *_company_subject_cc = @"cc";  // 流动负债合计
// 非流动负债
static NSString *_company_subject_da = @"da";  // 长期借款
static NSString *_company_subject_db = @"db";  // 应付债券
static NSString *_company_subject_dc = @"dc";  // 长期应付款
static NSString *_company_subject_de = @"de";  // 专项应付款
static NSString *_company_subject_df = @"df";  // 递延所得税负债
static NSString *_company_subject_dg = @"dg";  // 其他非流动性负债
static NSString *_company_subject_dd = @"dd";  // 非流动负债合计
// 负债合计
static NSString *_company_subject_fz = @"fz";  // 负债合计
// 所有者权益
static NSString *_company_subject_oa = @"oa";  // 股本
static NSString *_company_subject_ob = @"ob";  // 资本公积
static NSString *_company_subject_oc = @"oc";  // 库存股
static NSString *_company_subject_od = @"od";  // 盈余公积
static NSString *_company_subject_oe = @"oe";  // 未分配利润
static NSString *_company_subject_of = @"of";  // 归属母公司股东
static NSString *_company_subject_og = @"og";  // 少数股东权益
static NSString *_company_subject_oo = @"oo";  // 所有者权益合计
// 收入表
static NSString *_company_subject_za = @"za";  // 营业收入
static NSString *_company_subject_zb = @"zb";  // 营业成本
static NSString *_company_subject_zc = @"zc";  // 营业税金及附加
static NSString *_company_subject_zd = @"zd";  // 销售费用
static NSString *_company_subject_ze = @"ze";  // 管理费用
static NSString *_company_subject_zf = @"zf";  // 财务费用
static NSString *_company_subject_zg = @"zg";  // 资产减值损失
static NSString *_company_subject_zh = @"zh";  // 公允价值变动收益
static NSString *_company_subject_zi = @"zi";  // 投资收益
static NSString *_company_subject_zj = @"zj";  // 其中：对联营合营企业投资收益
static NSString *_company_subject_zk = @"zk";  // 营业利润
static NSString *_company_subject_zl = @"zl";  // 营业外收入
static NSString *_company_subject_zm = @"zm";  // 营业外支出
static NSString *_company_subject_zn = @"zn";  // 非流动资产处置损失
static NSString *_company_subject_zo = @"zo";  // 利润总额
static NSString *_company_subject_zp = @"zp";  // 所得税费用
static NSString *_company_subject_zq = @"zq";  // 净利润
static NSString *_company_subject_zr = @"zr";  // 归属于母公司所有者净利润
static NSString *_company_subject_zs = @"zs";  // 少数股东损益

@interface FSCompanyPublic : NSObject

+ (NSString *)hansForCompanySubject:(NSString *)subject;
+ (BOOL)isAssetOrCostSubject:(NSString *)subject;

+ (NSArray *)currentAssets;            // 流动资产 {科目：中文名},下同
+ (NSArray *)nonCurrentAssets;         // 非流动资产
+ (NSArray *)currentLiabilities;       // 流动负债
+ (NSArray *)nonCurrentLiabilities;    // 非流动资产
+ (NSArray *)ownersEquity;             // 所有者权益
+ (NSArray *)revenues;                 // 收入项
+ (NSArray *)costs;                    // 成本费用项
+ (NSArray *)otherNonSubjects;         // 其他非会计科目项

@end
