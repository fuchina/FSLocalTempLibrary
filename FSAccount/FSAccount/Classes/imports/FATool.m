//
//  FATool.m
//  myhome
//
//  Created by fudon on 2017/3/27.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FATool.h"
#import "FSDBMaster.h"
#import <FSKit.h>
#import "FSCompanyPublic.h"
#import <FSRuntime.h>

@implementation FATool

+ (NSDictionary *)allAccountSubjects{
    static NSDictionary *dic = nil;
    if (!dic) {
        dic = @{
                _subject_SR:NSLocalizedString(@"Earning", nil),
                _subject_CB:NSLocalizedString(@"Cost",nil),
                
                _subject_XJ:NSLocalizedString(@"Cash",nil),
                _subject_YS:NSLocalizedString(@"Receivables",nil),
                _subject_CH:NSLocalizedString(@"Inventory",nil),
                _subject_TZ:NSLocalizedString(@"Investment",nil),
                _subject_GZ:NSLocalizedString(@"Fixed assets",nil),
                _subject_TX:NSLocalizedString(@"Amortization",nil),
                _subject_ZC:NSLocalizedString(@"Assets",nil),

                _subject_PS:NSLocalizedString(@"Advances received",nil),
                _subject_FZ:NSLocalizedString(@"Liabilities",nil),
                
                _subject_QY:NSLocalizedString(@"Net asset",nil),
                _subject_BJ:NSLocalizedString(@"Owner's equity",nil),
                _subject_GB:NSLocalizedString(@"Capital stock",nil),
                
                _hanzi_JE:NSLocalizedString(@"Money",nil),
                _hanzi_ZZL:NSLocalizedString(@"Debt asset ratio",nil),
                _hanzi_ZZL_NOCASH:NSLocalizedString(@"Without Cash",nil),
                _hanzi_LR:NSLocalizedString(@"Profit",nil),
                _hanzi_JLV:NSLocalizedString(@"Net profit margin",nil),
                _hanzi_PH:NSLocalizedString(@"Trial balancing",nil),
                _hanzi_TTR:NSLocalizedString(@"Turnover rate",nil),
                _hanzi_JZS:@"ROE",
                };
    }
    return dic;
}

+ (NSString *)hansForShort:(NSString *)type{
    return [self hansForShort:type isCompany:NO];
}

+ (NSString *)hansForShort:(NSString *)type isCompany:(BOOL)isCompany{
    if (!isCompany) {
        NSDictionary *dic = [self allAccountSubjects];
        NSArray *keys = [dic allKeys];
        for (NSString *key in keys) {
            if ([type hasPrefix:key]) {
                return [dic objectForKey:key];
            }
        }
        return nil;
    }
    if (type.length == 3) {
        NSString *subject = [type substringToIndex:2];
        return [FSCompanyPublic hansForCompanySubject:subject];
    }else if (type.length == 2){
        return [FSCompanyPublic hansForCompanySubject:type];
    }
    return nil;
}

+ (BOOL)checkSubjectContainedInSubjects:(NSString *)subject{
    if (!([subject isKindOfClass:NSString.class] && subject.length)) {
        return NO;
    }
    if ([subject hasSuffix:_ED_KEY]) {
        if (subject.length > _ED_KEY.length) {
            subject = [subject stringByReplacingOccurrencesOfString:_ED_KEY withString:@""];
        }
    }
    if ([subject hasSuffix:_ING_KEY]) {
        if (subject.length > _ING_KEY.length) {
            subject = [subject stringByReplacingOccurrencesOfString:_ING_KEY withString:@""];
        }
    }
    NSDictionary *dic = [self allAccountSubjects];
    NSArray *keys = [dic allKeys];
    BOOL contain = [keys containsObject:subject];
    return contain;
}

+ (NSString *)noticeForType:(NSString *)type{
    if (type.length < 2) {
        return nil;
    }
    NSString *str = [self hansForShort:[type substringWithRange:NSMakeRange(0, 2)]];
    NSString *flag = nil;
    if ([type hasSuffix:_ING_KEY]) {
        flag = NSLocalizedString(@"Add", nil);
    }else if ([type hasSuffix:_ED_KEY]){
        flag = NSLocalizedString(@"Reduce", nil);
    }else{
        flag = @"Unknown";
    }
    return [[NSString alloc] initWithFormat:@"%@ %@",str,flag];
}

+ (NSArray *)debtors{
    static NSArray *debtors = nil;
    if (!debtors) {
        debtors = [self suffixWithFront:_ING_KEY back:_ED_KEY];
    }
    return debtors;
}

+ (NSArray *)creditors{
    static NSArray *creditors = nil;
    if (!creditors) {
        creditors = [self suffixWithFront:_ED_KEY back:_ING_KEY];
    }
    return creditors;
}

+ (NSArray *)suffixWithFront:(NSString *)front back:(NSString *)back{
    NSMutableArray *makers = [[NSMutableArray alloc] init];
    for (NSString *asset in [self allAssetSubjects]) {
        NSString *value = [[NSString alloc] initWithFormat:@"%@%@",asset,front];
        [makers addObject:value];
    }
    for (NSString *asset in [self allCostSubjects]) {
        NSString *value = [[NSString alloc] initWithFormat:@"%@%@",asset,front];
        [makers addObject:value];
    }
    for (NSString *asset in [self allEquitySubjects]) {
        NSString *value = [[NSString alloc] initWithFormat:@"%@%@",asset,back];
        [makers addObject:value];
    }
    for (NSString *asset in [self allDebtSubjects]) {
        NSString *value = [[NSString alloc] initWithFormat:@"%@%@",asset,back];
        [makers addObject:value];
    }
    for (NSString *asset in [self allIncomeSubjects]) {
        NSString *value = [[NSString alloc] initWithFormat:@"%@%@",asset,back];
        [makers addObject:value];
    }
    return makers;
}

+ (NSArray *)allAssetSubjects{
    static NSArray *assets = nil;
    if (!assets) {
        assets = @[_subject_YS,_subject_XJ,_subject_TZ,_subject_CH,_subject_GZ,_subject_TX];
    }
    return assets;
}

+ (NSArray *)allDebtSubjects{
    static NSArray *debts = nil;
    if (!debts) {
        debts = @[_subject_FZ,_subject_PS];
    }
    return debts;
}

+ (NSArray *)allEquitySubjects{
    static NSArray *equitys = nil;
    if (!equitys) {
//        equitys = @[_subject_QY,_subject_BJ,_subject_GB];
        equitys = @[_subject_BJ,_subject_GB];
    }
    return equitys;
}

+ (NSArray *)allIncomeSubjects{
    static NSArray *incomes = nil;
    if (!incomes) {
        incomes = @[_subject_SR];
    }
    return incomes;
}

+ (NSArray *)allCostSubjects{
    static NSArray *costs = nil;
    if (!costs) {
        costs = @[_subject_CB];
    }
    return costs;
}
/*
 1.借方：资产ing，负债ed，收入ed,成本ing；权益ed;
 2.贷方：资产ed，负债ing,收入ing,成本ed；权益ing
 */
+ (BOOL)balanceCheck:(NSArray *)array{
    if (array.count != 2) {
        return NO;
    }
    NSArray *debtors =   [self debtors];
    NSArray *creditors = [self creditors];
    
    NSInteger debtorCount = 0;NSInteger creditCount = 0;
    NSString *first = array[0];NSString *second = array[1];
    if ([debtors containsObject:first]) {
        debtorCount ++;
    }
    if ([creditors containsObject:first]) {
        creditCount ++;
    }
    if ([debtors containsObject:second]) {
        debtorCount ++;
    }
    if ([creditors containsObject:second]) {
        creditCount ++;
    }
    
    return debtorCount == 1 && creditCount == 1;
}

+ (BOOL)isDebtor:(NSString *)type{
    NSArray *array = [self debtors];
    for (NSString *model in array) {
        if ([type isEqualToString:model]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isCreditor:(NSString *)type{
    NSArray *array = [self creditors];
    for (NSString *model in array) {
        if ([type isEqualToString:model]) {
            return YES;
        }
    }
    return NO;
}

+ (NSString *)checkPropertyIsNull:(id)instance{
    NSArray *ps = [FSRuntime propertiesForClass:[instance class]];
    for (NSString *pro in ps) {
        id object = [FSRuntime valueForGetSelectorWithPropertyName:pro object:instance];
        if (!object) {
            return pro;
        }
    }
    return nil;
}

@end
