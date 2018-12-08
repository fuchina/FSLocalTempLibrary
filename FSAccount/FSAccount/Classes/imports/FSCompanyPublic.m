//
//  FSCompanyPublic.m
//  Expand
//
//  Created by Fuhope on 2017/12/20.
//  Copyright © 2017年 china. All rights reserved.
//

#import "FSCompanyPublic.h"
#import <FSTuple.h>

@implementation FSCompanyPublic

+ (NSString *)hansForCompanySubject:(NSString *)subject{
    if (!([subject isKindOfClass:NSString.class] && subject.length == 2)) {
        return nil;
    }
    Tuple2 *result = [self hansForCompanySubjectOfCurrentAssets:subject];
    if (result) {
        return result._2;
    }
    result = [self hansForCompanySubjectOfNonCurrentAssets:subject];
    if (result) {
        return result._2;
    }
    result = [self hansForCompanySubjectOfCurrentLiabilities:subject];
    if (result) {
        return result._2;
    }
    result = [self hansForCompanySubjectOfNonCurrentLiabilities:subject];
    if (result) {
        return result._2;
    }
    result = [self hansForCompanySubjectOfOwnersEquity:subject];
    if (result) {
        return result._2;
    }
    result = [self hansForCompanySubjectOfRevenues:subject];
    if (result) {
        return result._2;
    }
    result = [self hansForCompanySubjectOfCosts:subject];
    if (result) {
        return result._2;
    }
    result = [self hansForCompanySubjectOfOther:subject];
    return result._2;
}

+ (BOOL)isAssetOrCostSubject:(NSString *)subject{
    if (!([subject isKindOfClass:NSString.class] && subject.length == 2)) {
        return NO;
    }
    Tuple2 *result = [self hansForCompanySubjectOfCurrentAssets:subject];
    if (result) {
        return YES;
    }
    result = [self hansForCompanySubjectOfNonCurrentAssets:subject];
    if (result) {
        return YES;
    }
    result = [self hansForCompanySubjectOfCosts:subject];
    if (result) {
        return YES;
    }
    return NO;
}

+ (Tuple2 *)hansForCompanySubjectOfCurrentAssets:(NSString *)subject{
    NSArray *array = [self currentAssets];
    for (Tuple2 *t in array) {
        if ([subject isEqualToString:t._1]) {
            return t;
        }
    }
    return nil;
}

+ (Tuple2 *)hansForCompanySubjectOfNonCurrentAssets:(NSString *)subject{
    NSArray *array = [self nonCurrentAssets];
    for (Tuple2 *t in array) {
        if ([subject isEqualToString:t._1]) {
            return t;
        }
    }
    return nil;
}

+ (Tuple2 *)hansForCompanySubjectOfCurrentLiabilities:(NSString *)subject{
    NSArray *array = [self currentLiabilities];
    for (Tuple2 *t in array) {
        if ([subject isEqualToString:t._1]) {
            return t;
        }
    }
    return nil;
}

+ (Tuple2 *)hansForCompanySubjectOfNonCurrentLiabilities:(NSString *)subject{
    NSArray *array = [self nonCurrentLiabilities];
    for (Tuple2 *t in array) {
        if ([subject isEqualToString:t._1]) {
            return t;
        }
    }
    return nil;
}

+ (Tuple2 *)hansForCompanySubjectOfOwnersEquity:(NSString *)subject{
    NSArray *array = [self ownersEquity];
    for (Tuple2 *t in array) {
        if ([subject isEqualToString:t._1]) {
            return t;
        }
    }
    return nil;
}

+ (Tuple2 *)hansForCompanySubjectOfRevenues:(NSString *)subject{
    NSArray *array = [self revenues];
    for (Tuple2 *t in array) {
        if ([subject isEqualToString:t._1]) {
            return t;
        }
    }
    return nil;
}

+ (Tuple2 *)hansForCompanySubjectOfCosts:(NSString *)subject{
    NSArray *array = [self costs];
    for (Tuple2 *t in array) {
        if ([subject isEqualToString:t._1]) {
            return t;
        }
    }
    return nil;
}

+ (Tuple2 *)hansForCompanySubjectOfOther:(NSString *)subject{
    NSArray *array = [self otherNonSubjects];
    for (Tuple2 *t in array) {
        if ([subject isEqualToString:t._1]) {
            return t;
        }
    }
    return nil;
}

+ (NSArray *)currentAssets{
    static NSArray *array = nil;
    if (!array) {
        array = @[
                  [Tuple2 v1:_company_subject_ab v2:@"货币资金"],
                  [Tuple2 v1:_company_subject_ac v2:@"交易性金融资产"],
                  [Tuple2 v1:_company_subject_ad v2:@"应收票据"],
                  [Tuple2 v1:_company_subject_ae v2:@"应收账款"],
                  [Tuple2 v1:_company_subject_af v2:@"预付款项"],
                  [Tuple2 v1:_company_subject_ag v2:@"应收利息"],
                  [Tuple2 v1:_company_subject_ah v2:@"应收股利"],
                  [Tuple2 v1:_company_subject_ai v2:@"其他应收款"],
                  [Tuple2 v1:_company_subject_aj v2:@"存货"],
                  [Tuple2 v1:_company_subject_ak v2:@"一年内到期的非流动资产"],
                  [Tuple2 v1:_company_subject_al v2:@"其他流动资产"],
                  ];
    }
    return array;
}

+ (NSArray *)nonCurrentAssets{
    static NSArray *array = nil;
    if (!array) {
        array = @[
                  [Tuple2 v1:_company_subject_ba v2:@"可供出售金融资产"],
                  [Tuple2 v1:_company_subject_bc v2:@"持有至到期投资"],
                  [Tuple2 v1:_company_subject_bd v2:@"长期应收款"],
                  [Tuple2 v1:_company_subject_be v2:@"长期股权投资"],
                  [Tuple2 v1:_company_subject_bf v2:@"投资性房地产"],
                  [Tuple2 v1:_company_subject_bg v2:@"固定资产"],
                  [Tuple2 v1:_company_subject_bh v2:@"在建工程"],
                  [Tuple2 v1:_company_subject_bi v2:@"工程物资"],
                  [Tuple2 v1:_company_subject_bj v2:@"固定资产清理"],
                  [Tuple2 v1:_company_subject_bk v2:@"生产性生物资产"],
                  [Tuple2 v1:_company_subject_bl v2:@"油气资产"],
                  [Tuple2 v1:_company_subject_bm v2:@"无形资产"],
                  [Tuple2 v1:_company_subject_bn v2:@"开发支出"],
                  [Tuple2 v1:_company_subject_bo v2:@"商誉"],
                  [Tuple2 v1:_company_subject_bp v2:@"长期待摊费用"],
                  [Tuple2 v1:_company_subject_bq v2:@"递延所得税资产"],
                  [Tuple2 v1:_company_subject_br v2:@"其他非流动资产"],
                  ];
    }
    return array;
}

+ (NSArray *)currentLiabilities{
    static NSArray *array = nil;
    if (!array) {
        array = @[
                  [Tuple2 v1:_company_subject_ca v2:@"短期借款"],
                  [Tuple2 v1:_company_subject_cb v2:@"交易性金融负债"],
                  [Tuple2 v1:_company_subject_cd v2:@"应付票据"],
                  [Tuple2 v1:_company_subject_ce v2:@"应付账款"],
                  [Tuple2 v1:_company_subject_cf v2:@"预收款项"],
                  [Tuple2 v1:_company_subject_cg v2:@"应付职工薪酬"],
                  [Tuple2 v1:_company_subject_ch v2:@"应交税费"],
                  [Tuple2 v1:_company_subject_ci v2:@"应付利息"],
                  [Tuple2 v1:_company_subject_cj v2:@"应付股利"],
                  [Tuple2 v1:_company_subject_ck v2:@"其他应付款"],
                  [Tuple2 v1:_company_subject_cl v2:@"一年内到期的非"],
                  [Tuple2 v1:_company_subject_cm v2:@"其他流动负债"],
                  ];
    }
    return array;
}

+ (NSArray *)nonCurrentLiabilities{
    static NSArray *array = nil;
    if (!array) {
        array = @[
                  [Tuple2 v1:_company_subject_da v2:@"长期借款"],
                  [Tuple2 v1:_company_subject_db v2:@"应付债券"],
                  [Tuple2 v1:_company_subject_dc v2:@"长期应付款"],
                  [Tuple2 v1:_company_subject_de v2:@"专项应付款"],
                  [Tuple2 v1:_company_subject_df v2:@"递延所得税负债"],
                  [Tuple2 v1:_company_subject_dg v2:@"其他非流动性负债"],
                  ];
    }
    return array;
}

+ (NSArray *)ownersEquity{
    static NSArray *array = nil;
    if (!array) {
        array = @[
                  [Tuple2 v1:_company_subject_oa v2:@"股本"],
                  [Tuple2 v1:_company_subject_ob v2:@"资本公积"],
                  [Tuple2 v1:_company_subject_oc v2:@"库存股"],
                  [Tuple2 v1:_company_subject_od v2:@"盈余公积"],
                  [Tuple2 v1:_company_subject_oe v2:@"未分配利润"],
                  [Tuple2 v1:_company_subject_of v2:@"归属母公司股东权益"],
                  [Tuple2 v1:_company_subject_og v2:@"少数股东权益"],
                  ];
    }
    return array;
}

+ (NSArray *)revenues{
    static NSArray *array = nil;
    if (!array) {
        array = @[
                  [Tuple2 v1:_company_subject_za v2:@"营业收入"],
                  [Tuple2 v1:_company_subject_zh v2:@"公允价值变动收益"],
                  [Tuple2 v1:_company_subject_zi v2:@"投资收益"],
                  [Tuple2 v1:_company_subject_zj v2:@"其中：对联营合营企业投资收益"],
                  [Tuple2 v1:_company_subject_zl v2:@"营业外收入"],
                  ];
    }
    return array;
}

+ (NSArray *)costs{
    static NSArray *array = nil;
    if (!array) {
        array = @[
                  [Tuple2 v1:_company_subject_zb v2:@"营业成本"],
                  [Tuple2 v1:_company_subject_zc v2:@"营业税金及附加"],
                  [Tuple2 v1:_company_subject_zd v2:@"销售费用"],
                  [Tuple2 v1:_company_subject_ze v2:@"管理费用"],
                  [Tuple2 v1:_company_subject_zf v2:@"财务费用"],
                  [Tuple2 v1:_company_subject_zg v2:@"资产减值损失"],
                  [Tuple2 v1:_company_subject_zm v2:@"营业外支出"],
                  [Tuple2 v1:_company_subject_zn v2:@"非流动资产处置损失"],
                  [Tuple2 v1:_company_subject_zp v2:@"所得税费用"],
                  ];
    }
    return array;
}

+ (NSArray *)otherNonSubjects{
    static NSArray *array = nil;
    if (!array) {
        array = @[
                  [Tuple2 v1:_company_subject_aa v2:@"流动资产合计"],
                  [Tuple2 v1:_company_subject_bb v2:@"非流动资产合计"],
                  [Tuple2 v1:_company_subject_az v2:@"资产总计"],
                  [Tuple2 v1:_company_subject_cc v2:@"流动负债合计"],
                  [Tuple2 v1:_company_subject_dd v2:@"非流动负债合计"],
                  [Tuple2 v1:_company_subject_fz v2:@"负债合计"],
                  [Tuple2 v1:_company_subject_oo v2:@"所有者权益合计"],
                  [Tuple2 v1:_company_subject_zk v2:@"营业利润"],
                  [Tuple2 v1:_company_subject_zo v2:@"利润总额"],
                  [Tuple2 v1:_company_subject_zq v2:@"净利润"],
                  [Tuple2 v1:_company_subject_zr v2:@"归属于母公司所有者净利润"],
                  [Tuple2 v1:_company_subject_zs v2:@"少数股东损益"],
                  ];
    }
    return array;
}

@end



