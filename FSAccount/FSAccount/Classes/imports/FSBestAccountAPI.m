//
//  FSBestAccountAPI.m
//  myhome
//
//  Created by FudonFuchina on 2018/3/29.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestAccountAPI.h"
#import "FSDBMaster.h"
#import "FSMacro.h"
#import "FSDBSupport.h"
#import <FSDate.h>
#import "FSAPP.h"
#import <FSCalculator.h>

@implementation FSBestAccountDataModel

@end

@implementation FSBestAccountAPI

/*
 jeSort：     1，从大到小，2，从小到大，默认为0
 timeSort:   1.从近到远，2.从远到近，默认为1
 */
+ (void)listForBe:(NSString *)be table:(NSString *)table page:(NSInteger)page jeSort:(NSInteger)jeSort timeSort:(NSInteger)timeSort isPlus:(BOOL)isPlus call:(void(^)(NSArray<FSBestAccountCacheModel *> *list))list{
    if (!_fs_isValidateString(table)) {
        list(nil);
        return;
    }
    if (!be) {
        list(nil);
        return;
    }
    __block NSMutableArray *result = nil;
    _fs_dispatch_global_main_queue_async(^{
        NSArray<FSBestSubjectModel *> *beSubjects = [self allSubjectsIsBe:be table:table];
        if (!([beSubjects isKindOfClass:NSArray.class] && beSubjects.count)) {
            list(nil);
            return;
        }
        
        NSString *af = isPlus?@"and pa = '1'":@"and pa = '2'";
        NSString *bf = isPlus?@"and pb = '1'":@"and pb = '2'";
        NSMutableString *c = NSMutableString.new;
        for (FSBestSubjectModel *m in beSubjects) {
            [c appendFormat:@"((aj = '%@' %@) or (bj = '%@' %@)) or ",m.vl,af,m.vl,bf];
        }
        NSRange deleteRange = {c.length - 4,4};
        [c deleteCharactersInRange:deleteRange ];
        
        NSInteger unit = 20;
        NSString *sql = nil;
        if (jeSort == 1) {
            sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where (%@) order by cast(je as REAL) DESC limit %@,%@;",table,c,@(page * unit),@(unit)];
        }else if (jeSort == 2){
            sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where (%@) order by cast(je as REAL) ASC limit %@,%@;",table,c,@(page * unit),@(unit)];
        }else if (timeSort == 2){
            sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where (%@) order by cast(tm as INTEGER) ASC limit %@,%@;",table,c,@(page * unit),@(unit)];
        }else{
            sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where (%@) order by cast(tm as INTEGER) DESC limit %@,%@;",table,c,@(page * unit),@(unit)];
        }
        result = [FSDBSupport querySQL:sql class:FSBestAccountModel.class tableName:table];
        for (FSBestAccountModel *m in result) {
            [m countProperties:nil track:NO search:nil table:table];
        }
    }, ^{
        list(result);
    });
}

+ (NSArray<FSBestSubjectModel *> *)allSubjectsIsBe:(NSString *)be table:(NSString *)table{
    NSArray *alls = [self allSubjectsForTable:table];
    NSInteger beInt = be.integerValue;
    if ([alls isKindOfClass:NSArray.class] && alls.count) {
        NSMutableArray *filtereds = [[NSMutableArray alloc] init];
        for (FSBestSubjectModel *model in alls) {
            if (model.be.integerValue == beInt) {
                [filtereds addObject:model];
            }
        }
        return filtereds;
    }
    return nil;
}

+ (void)bestAccount_home_sub_thread:(NSString *)table be:(NSString *)be thisYear:(BOOL)thisYear call:(void(^)(NSArray<FSBestAccountCacheModel *> *list))list{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *_ab_cache = [self cacheTableForTable:table];  // order by time DESC
        NSString *sql = nil;
        if (thisYear) {
            NSDate *now = [NSDate date];
            NSDateComponents *c = [FSDate componentForDate:now];
            sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where (be = '%@' and yr = '%ld');",_ab_cache,be,c.year];
        }else{
            sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where be = '%@';",_ab_cache,be];
        }
        NSArray *value = [FSDBSupport querySQL:sql class:FSBestAccountCacheModel.class tableName:table];
        if (list) {
            list(value);
        }
    });
}

+ (void)bestAccount_home_sub_thread:(NSString *)table be:(NSString *)be year:(NSString *)year call:(void(^)(NSArray<FSBestAccountCacheModel *> *list))list{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *_ab_cache = [self cacheTableForTable:table];  // order by time DESC
        NSString *sql = nil;
        if (year) {
            sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where (be = '%@' and yr = '%@');",_ab_cache,be,year];
        }else{
            sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where be = '%@';",_ab_cache,be];
        }
        NSArray *value = [FSDBSupport querySQL:sql class:FSBestAccountCacheModel.class tableName:table];
        if (list) {
            list(value);
        }
    });
}

+ (NSMutableArray<FSBestAccountModel *> *)listForTable:(NSString *)table page:(NSInteger)page{
    if (!_fs_isValidateString(table)) {
        return nil;
    }
    NSInteger unit = 20;
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ order by cast(tm as INTEGER) DESC limit %@,%@;",table,@(page * unit),@(unit)];
    NSMutableArray *list = [FSDBSupport querySQL:sql class:FSBestAccountModel.class tableName:table];
    for (FSBestAccountModel *m in list) {
        [m countProperties:nil track:NO search:nil table:table];
    }
    return list;
}

// az函数，表遍历
+ (void)azFunction:(NSString *)table eachOne:(void(^)(NSDictionary *dic,NSString *table))callback{
    if (!_fs_isValidateString(table)) {
        return;
    }
    if (callback) {
        NSInteger page = 0;
        NSInteger unit = 1000;
        NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ limit 0,%@;",table,@(unit)];
        FSDBMaster *master = [FSDBMaster sharedInstance];
        NSArray *list = [master querySQL:sql tableName:table];
        BOOL isValidateArray = _fs_isValidateArray(list);
        if (!isValidateArray) {
            callback(nil,table);
        }else{
            while (_fs_isValidateArray(list)) {
                for (NSDictionary *dic in list) {
                    callback(dic,table);
                }
                page ++;
                sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ limit %@,%@;",table,@(page * unit),@(unit)];
                list = [master querySQL:sql tableName:table];
            }
        }
    }
}

+ (NSString *)key_azFunction:(NSString *)table{
    NSString *cache_key = [[NSString alloc] initWithFormat:@"%@_business_global",table];
    return cache_key;
}

+ (void)business_global:(NSString *)table callback:(void(^)(NSArray *array,NSArray *mass,FSBestAccountDataModel *model))callback{
    if (!_fs_isValidateString(table)) {
        return;
    }
    NSString *cache_key = [self key_azFunction:table];
    FSBestAccountDataModel *model = [[FSBestAccountDataModel alloc] init];

    NSString *mass_cache_key = [[NSString alloc] initWithFormat:@"%@_mass_k",table];
    NSString *model_cache_key = [[NSString alloc] initWithFormat:@"%@_model_k",table];

    NSString *tk = [[NSString alloc] initWithFormat:@"%@_tklist",table];
    NSString *saved = _fs_userDefaults_objectForKey(tk);
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ order by cast(ct as INTEGER) DESC limit 0,1;",table];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSArray *list = [master querySQL:sql tableName:table];
    if (_fs_isValidateArray(list)) {
        NSDictionary *data = list.firstObject;
        NSString *time = [data objectForKey:@"ct"];
        BOOL readCache = [saved integerValue] == [time integerValue];
        if (readCache) {
            NSString *nv_json = _fs_userDefaults_objectForKey(cache_key);
            NSArray *needValue = [FSKit objectFromJSonstring:nv_json];
            
            NSString *ms_json = _fs_userDefaults_objectForKey(mass_cache_key);
            NSArray *mass = [FSKit objectFromJSonstring:ms_json];

            NSString *mo_json = _fs_userDefaults_objectForKey(model_cache_key);
            NSDictionary *mdic = [FSKit objectFromJSonstring:mo_json];
            
            model.sr = [[mdic objectForKey:@"sr"] doubleValue];
            model.cb = [[mdic objectForKey:@"cb"] doubleValue];
            model.allsr = [[mdic objectForKey:@"allsr"] doubleValue];
            model.allcb = [[mdic objectForKey:@"allcb"] doubleValue];
            model.yearSR = [[mdic objectForKey:@"yearSR"] doubleValue];
            model.yearCB = [[mdic objectForKey:@"yearCB"] doubleValue];
            model.ldzc = [[mdic objectForKey:@"ldzc"] doubleValue];
            model.fldzc = [[mdic objectForKey:@"fldzc"] doubleValue];
            model.ldfz = [[mdic objectForKey:@"ldfz"] doubleValue];
            model.fldfz = [[mdic objectForKey:@"fldfz"] doubleValue];
            model.syzqy = [[mdic objectForKey:@"syzqy"] doubleValue];
            
            callback(needValue,mass,model);
            return;
        }else{
            _fs_userDefaults_setObjectForKey(time, tk);
        }
    }
    
    NSArray *subjects = [FSBestAccountAPI allSubjectsForTable:table];
    
    NSDate *today = [NSDate date];
    NSDateComponents *components = [FSDate componentForDate:today];
    NSInteger start = [FSDate theFirstSecondOfYear:components.year];
    NSInteger end = [FSDate theLastSecondOfYear:components.year];
    NSInteger start1Year = start - 365 * 24 * 3600;
    [self azFunction:table eachOne:^(NSDictionary *dic, NSString *table) {
        [self business_global_handle:table data:dic subjects:subjects dataModel:model start:start end:end start1Year:start1Year];
    }];
    
    NSString *srShow = [FSKit bankStyleDataThree:@(model.sr)];
    NSString *cbShow = [FSKit bankStyleDataThree:@(model.cb)];
    NSString *lzShow = [FSKit bankStyleDataThree:@(model.ldzc)];
    NSString *nzShow = [FSKit bankStyleDataThree:@(model.fldzc)];
    NSString *ldShow = [FSKit bankStyleDataThree:@(model.ldfz)];
    NSString *ndShow = [FSKit bankStyleDataThree:@(model.fldfz)];
    NSString *qyShow = [FSKit bankStyleDataThree:@(model.syzqy)];
    
    static NSString *_key_name = @"name";
    static NSString *_key_value = @"value";
    static NSString *_key_be = @"be";
    static NSString *_key_show = @"show";
    NSArray *needValue = @[
                @{_key_name:@"今年收入",_key_value:@(model.sr),_key_be:@(FSBestAccountSubjectType1SR),_key_show:srShow},
                @{_key_name:@"今年成本",_key_value:@(model.cb),_key_be:@(FSBestAccountSubjectType2CB),_key_show:cbShow},
                @{_key_name:@"流动资产",_key_value:@(model.ldzc),_key_be:@(FSBestAccountSubjectType3LDZC),_key_show:lzShow},
                @{_key_name:@"非流动资产",_key_value:@(model.fldzc),_key_be:@(FSBestAccountSubjectType4FLDZC),_key_show:nzShow},
                @{_key_name:@"流动负债",_key_value:@(model.ldfz),_key_be:@(FSBestAccountSubjectType5LDFZ),_key_show:ldShow},
                @{_key_name:@"非流动负债",_key_value:@(model.fldfz),_key_be:@(FSBestAccountSubjectType6FLDFZ),_key_show:ndShow},
                @{_key_name:@"所有者本金",_key_value:@(model.syzqy),_key_be:@(FSBestAccountSubjectType7SYZQY),_key_show:qyShow},
                           ];
    NSString *json = [FSKit jsonStringWithObject:needValue];
    _fs_userDefaults_setObjectForKey(json, cache_key);
    
    static CGFloat yearSeconds = 1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        yearSeconds = 365.2422 * 24 * 60 * 60;
    });
    NSInteger seconds = (NSInteger)[today timeIntervalSince1970];
    CGFloat passed = (seconds - start) / yearSeconds;
    passed = passed + 0.00001;

    CGFloat zzc = model.ldzc + model.fldzc;
    CGFloat fz = model.ldfz + model.fldfz;
    CGFloat jzc = zzc - fz;
    CGFloat lr = model.sr - model.cb;
    CGFloat jlv = 0;
    if (model.sr > 0) {
        jlv = lr / model.sr;
    }
    CGFloat roe = 0;
    if (jzc > 0) {
        roe = lr / jzc;
    }
    CGFloat y_roe = roe / passed;
    CGFloat roa = 0;
    if (zzc > 0) {
        roa = model.sr / zzc;
    }
    CGFloat y_roa = roa / passed;
    CGFloat fzl = 0;
    if (zzc > 0) {
        fzl = fz / zzc;
    }
    CGFloat fzl_ldzc = 0;
    if (zzc > 0) {
        fzl_ldzc = (MAX(fz - model.ldzc / 2, 0)) / zzc;
    }
    NSString *assets = [FSKit bankStyleDataThree:@(zzc)];
    NSString *debts = [FSKit bankStyleDataThree:@(fz)];
    NSString *jzcStr = [FSKit bankStyleDataThree:@(jzc)];
    NSString *lrStr = [FSKit bankStyleDataThree:@(lr)];
    NSString *jlvStr = [[NSString alloc] initWithFormat:@"%.2f%%",jlv * 100];
    NSString *roeStr = [[NSString alloc] initWithFormat:@"%.2f%% | %.2f%%",roe * 100,y_roe * 100];
    NSString *roaStr = [[NSString alloc] initWithFormat:@"%.2f%% | %.2f%%",roa * 100,y_roa * 100];
    NSString *fzlStr = [[NSString alloc] initWithFormat:@"%.2f%%",fzl * 100];
    NSString *fzlStr_lz = [[NSString alloc] initWithFormat:@"%.2f%%",fzl_ldzc * 100];
    
    NSString *zzl_color = nil;
    if (fzl > 0.6 || fzl_ldzc > 0.5) {
        zzl_color = @"1";
    }else{
        zzl_color = @"0";
    }

    NSString *text = [FSAPP messageForTable:table];
    text = text?:NSLocalizedString(@"Nothing", nil);
    NSArray *mass = @[
                      @{@"1":@"总资产",@"2":assets},
                      @{@"1":@"总负债",@"2":debts},
                      @{@"1":@"净资产",@"2":jzcStr},
                      @{@"1":@"净利润",@"2":lrStr},
                      @{@"1":@"净利率",@"2":jlvStr},
                      @{@"1":@"资产负债率",@"2":fzlStr,@"3":zzl_color},
                      @{@"1":@"减：一半流资",@"2":fzlStr_lz,@"3":zzl_color},
                      @{@"1":@"净资产收益率",@"2":roeStr},
                      @{@"1":@"总资产周转率",@"2":roaStr},
                      @{@"1":@"最新",@"2":text},
                      ];
    
    if (callback) {
        callback(needValue,mass,model);

        _fs_dispatch_global_queue_async(^{
            NSString *json = [FSKit jsonStringWithObject:mass];
            _fs_userDefaults_setObjectForKey(json, mass_cache_key);
            
            NSMutableDictionary *cacheModelDic = [[NSMutableDictionary alloc] init];
            [cacheModelDic setObject:@(model.sr) forKey:@"sr"];
            [cacheModelDic setObject:@(model.cb) forKey:@"cb"];
            [cacheModelDic setObject:@(model.allsr) forKey:@"allsr"];
            [cacheModelDic setObject:@(model.allcb) forKey:@"allcb"];
            [cacheModelDic setObject:@(model.yearSR) forKey:@"yearSR"];
            [cacheModelDic setObject:@(model.yearCB) forKey:@"yearCB"];
            [cacheModelDic setObject:@(model.ldzc) forKey:@"ldzc"];
            [cacheModelDic setObject:@(model.fldzc) forKey:@"fldzc"];
            [cacheModelDic setObject:@(model.ldfz) forKey:@"ldfz"];
            [cacheModelDic setObject:@(model.fldfz) forKey:@"fldfz"];
            [cacheModelDic setObject:@(model.syzqy) forKey:@"syzqy"];
            
            NSString *js = [FSKit jsonStringWithObject:cacheModelDic];
            _fs_userDefaults_setObjectForKey(js, model_cache_key);
        });
    }
}

+ (void)business_global_handle:(NSString *)table data:(NSDictionary *)dic subjects:(NSArray<FSBestSubjectModel *> *)subjects dataModel:(FSBestAccountDataModel *)model start:(NSInteger)start end:(NSInteger)end start1Year:(NSInteger)start1Year{
    if (dic == nil) {
        return;
    }
    static NSString *_sub_aj = @"aj";
    static NSString *_sub_bj = @"bj";
    
    NSString *aSubject = [dic objectForKey:_sub_aj];
    NSString *bSubject = [dic objectForKey:_sub_bj];
    
    NSString *bea = nil;NSString *beb = nil;
    NSInteger aBe = NSNotFound;
    NSInteger bBe = NSNotFound;
    for (FSBestSubjectModel *subModel in subjects) {
        if ([subModel.vl isEqualToString:aSubject]) {
            bea = subModel.be;
            aBe = [subModel.be integerValue];
        }
        if ([subModel.vl isEqualToString:bSubject]) {
            beb = subModel.be;
            bBe = [subModel.be integerValue];
        }
    }
    if (aBe == NSNotFound || bBe == NSNotFound) {
        return;
    }
    static NSString *_key_je = @"je";
    static NSString *_key_ap = @"pa";
    static NSString *_key_bp = @"pb";
    CGFloat je = [[dic objectForKey:_key_je] doubleValue];
    
    NSInteger ap = [[dic objectForKey:_key_ap] integerValue];
    NSInteger bp = [[dic objectForKey:_key_bp] integerValue];
    BOOL pr = (ap == 1 || ap == 2) && (bp == 1 || bp == 2);
    NSAssert(pr == YES, @"增减只能是1或2");
    if (!pr) {
        return;
    }
    BOOL isAPlus = (ap == 1);
    BOOL isBPlus = (bp == 1);
    
    static NSString *_sub_tm = @"tm";
    
    NSInteger tm = [[dic objectForKey:_sub_tm] integerValue];
    BOOL thisYear = (tm > start) && (tm < end);
    BOOL oneYear = (tm > start1Year) && (tm < end);

    [self subFunction_handleType:aBe model:model je:je isPlus:isAPlus thisYear:thisYear oneYear:oneYear];
    [self subFunction_handleType:bBe model:model je:je isPlus:isBPlus thisYear:thisYear oneYear:oneYear];
}

+ (void)subFunction_handleType:(FSBestAccountSubjectType)bBe model:(FSBestAccountDataModel *)model je:(CGFloat)je isPlus:(BOOL)isBPlus thisYear:(BOOL)thisYear oneYear:(BOOL)oneYear{
    if (bBe == FSBestAccountSubjectType1SR) {
        if (isBPlus) {
            if (thisYear) {
                model.sr += je;
            }
            if (oneYear) {
                model.yearSR += je;
            }
            model.allsr += je;
        }else{
            if (thisYear) {
                model.sr -= je;
            }
            if (oneYear) {
                model.yearSR -= je;
            }
            model.allsr -= je;
        }
    }else if (bBe == FSBestAccountSubjectType2CB){
        if (isBPlus) {
            if (thisYear) {
                model.cb += je;
            }
            if (oneYear) {
                model.yearCB += je;
            }
            model.allcb += je;
        }else{
            if (thisYear) {
                model.cb -= je;
            }
            if (oneYear) {
                model.yearCB -= je;
            }
            model.allcb -= je;
        }
    }else if (bBe == FSBestAccountSubjectType3LDZC){
        if (isBPlus) {
            model.ldzc += je;
        }else{
            model.ldzc -= je;
        }
    }else if (bBe == FSBestAccountSubjectType4FLDZC){
        if (isBPlus) {
            model.fldzc += je;
        }else{
            model.fldzc -= je;
        }
    }else if (bBe == FSBestAccountSubjectType5LDFZ){
        if (isBPlus) {
            model.ldfz += je;
        }else{
            model.ldfz -= je;
        }
    }else if (bBe == FSBestAccountSubjectType6FLDFZ){
        if (isBPlus) {
            model.fldfz += je;
        }else{
            model.fldfz -= je;
        }
    }else if (bBe == FSBestAccountSubjectType7SYZQY){
        if (isBPlus) {
            model.syzqy += je;
        }else{
            model.syzqy -= je;
        }
    }
}

+ (NSString *)yearMonthKey:(NSInteger)year month:(NSInteger)month{
    NSString *key = [[NSString alloc] initWithFormat:@"%@%@",@(year),[FSKit twoChar:month]];
    return key;
}

+ (NSString *)beNameForBe:(NSString *)be{
    NSArray *all = self.accountantClass;
    NSInteger n = be.integerValue;
    for (Tuple3 *t3 in all) {
        NSInteger v = [t3._2 integerValue];
        if (v == n) {
            return t3._1;
        }
    }
    return nil;
}

+ (NSArray<Tuple3 *> *)accountantClass{
    static NSArray  *list = nil;
    if (list) {
        return list;
    }
    list = @[
             [Tuple3 v1:@"收入"      v2:@(FSBestAccountSubjectType1SR) v3:@"2"],
             [Tuple3 v1:@"成本"      v2:@(FSBestAccountSubjectType2CB) v3:@"1"],
             [Tuple3 v1:@"流动资产"   v2:@(FSBestAccountSubjectType3LDZC) v3:@"1"],
             [Tuple3 v1:@"非流动资产"  v2:@(FSBestAccountSubjectType4FLDZC) v3:@"1"],
             [Tuple3 v1:@"流动负债"   v2:@(FSBestAccountSubjectType5LDFZ) v3:@"2"],
             [Tuple3 v1:@"非流动负债"  v2:@(FSBestAccountSubjectType6FLDFZ) v3:@"2"],
             [Tuple3 v1:@"所有者本金"  v2:@(FSBestAccountSubjectType7SYZQY) v3:@"2"],
             ];
    return list;
}

+ (NSString *)addSubject:(NSString *)name be:(NSString *)be jd:(NSString *)jd table:(NSString *)table{
    NSInteger ibe = [be integerValue];
    if (ibe < FSBestAccountSubjectType1SR || ibe > FSBestAccountSubjectType7SYZQY) {
        return @"科目属性不正确";
    }
    NSInteger ijd = [jd integerValue];
    if (!(ijd == 1 || ijd == 2)) {
        return @"借贷属性不正确";
    }

    if (!(_fs_isValidateString(name) && _fs_isValidateString(table))) {
        return @"参数错误";
    }
    if (name.length > 20) {
        return @"名字最多20个字符";
    }
    NSString *subjectTable = [self subjectTableForTable:table];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *select = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE nm = '%@';",subjectTable,name];
    NSArray *list = [master querySQL:select tableName:subjectTable];
    if (_fs_isValidateArray(list)) {
        NSDictionary *dic = list.firstObject;
        NSInteger be = [[dic objectForKey:@"be"] integerValue];
        NSArray *ls = [self accountantClass];
        NSString *find = nil;
        for (Tuple3 *t3 in ls) {
            NSInteger v = [t3._2 integerValue];
            if (v == be) {
                find = t3._1;
                break;
            }
        }
        NSString *error = [[NSString alloc] initWithFormat:@"'%@'在'%@'类里已存在",name,find];
        return error;
    }
    
    select = [[NSString alloc] initWithFormat:@"select count(*) from %@;",subjectTable];
    NSInteger count = [master countWithSQL:select table:subjectTable];
    if (count >= 200) {
        return @"每个账本最多只能增加200个科目";
    }
    
    select = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ order by cast(vl as INTEGER) DESC limit 0,1;",subjectTable];
    list = [master querySQL:select tableName:subjectTable];
    if (_fs_isValidateArray(list)) {
        NSDictionary *dic = list.firstObject;
        count = [dic[@"vl"] integerValue] + 1;
    }
    if (count < 1){
        count = 1;
    }
    
    select = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE vl = '%@';",subjectTable,@(count)];
    list = [master querySQL:select tableName:subjectTable];
    while (_fs_isValidateArray(list)) {
        count ++;
        select = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE vl = '%@';",subjectTable,@(count)];
        list = [master querySQL:select tableName:subjectTable];
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (tm,nm,be,jd,vl) VALUES ('%@','%@','%@','%@','%@');",subjectTable,@(_fs_integerTimeIntevalSince1970()),name,be,jd,@(count)];
    NSString *error = [master insertSQL:sql fields:FSBestSubjectModel.tableFields table:subjectTable];
    return error;
}

+ (NSString *)subjectTableForTable:(NSString *)table{
    if (!_fs_isValidateString(table)) {
        return nil;
    }
    NSString *subjectTable = [[NSString alloc] initWithFormat:@"%@%@",_SPEC_FLAG_S,table];
    return subjectTable;
}

+ (NSArray<FSBestSubjectModel *> *)allSubjectsForTable:(NSString *)table{
    if (!(_fs_isValidateString(table))) {
        return nil;
    }
    NSString *subjectTable = [self subjectTableForTable:table];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@;",subjectTable];
    NSArray *list = [FSDBSupport querySQL:sql class:FSBestSubjectModel.class tableName:subjectTable eachCallback:^(FSBestSubjectModel *model) {
        [model preCount];
    }];
    return list;
}

+ (NSString *)onlyPlusAccount:(NSString *)table je:(NSString *)je bz:(NSString *)bz date:(NSDate *)date aSubject:(FSBestSubjectModel *)aSubject bSubject:(FSBestSubjectModel *)bSubject inBlock:(void(^)(void(^callback)(void)))b{
    if (!_fs_isValidateString(table)) {
        return @"表不正确";
    }
    NSInteger time = 0;
    if (![date isKindOfClass:NSDate.class]) {
        date = [NSDate date];
        time = (NSInteger)[date timeIntervalSince1970];
    }else{
        time = (NSInteger)[date timeIntervalSince1970];
    }
    if (![aSubject isKindOfClass:FSBestSubjectModel.class]) {
        return @"科目不正确";
    }
    if (![bSubject isKindOfClass:FSBestSubjectModel.class]) {
        return @"科目不正确";
    }
    if (!(aSubject.isp == 1 || aSubject.isp == 2)) {
        return @"科目借贷不正确";
    }
    if (!(bSubject.isp == 1 || bSubject.isp == 2)) {
        return @"科目借贷不正确";
    }
    CGFloat jef = je.doubleValue;
    if (jef <= -0.01) {
        NSAssert(jef > 0, @"je is not right");
        return @"金额必须大于等于0";
    }
    NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (ct,tm,je,bz,aj,bj,pa,pb,ar,br) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@');",table,@(_fs_integerTimeIntevalSince1970()),@(time),je,bz,aSubject.vl,bSubject.vl,@(aSubject.isp),@(bSubject.isp),aSubject.isp == 1?je:@0,bSubject.isp == 1?je:@0];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *error = [master insertSQL:sql fields:FSBestAccountModel.tableFields table:table];
    if (error) {
        return error;
    }
    error = [self cacheFunction:table yearMonth:date je:je aSubject:aSubject bSubject:bSubject];
    if (error) {
        return error;
    }
    
    if (b) {
        void (^needExecBlock)(void) = ^ {
            [self addMobanForTable:table aj:aSubject bj:bSubject bz:bz];
        };
        
        _fs_dispatch_main_queue_async(^{
            b(needExecBlock);
        });
    }
    
    _fs_dispatch_global_queue_async(^{
        NSString *chk = [[NSString alloc] initWithFormat:@"accbeUpdated_chk_%@",table];
        _fs_userDefaults_setObjectForKey(@(_fs_integerTimeIntevalSince1970()), chk);
        
        NSString *message = [[NSString alloc] initWithFormat:@"%@：%.2f",bz,jef];
        [FSAPP addMessage:message table:table];
    });
    
    return error;
}

+ (NSString *)cacheFunction:(NSString *)table yearMonth:(NSDate *)date je:(NSString *)je aSubject:(FSBestSubjectModel *)aSubject bSubject:(FSBestSubjectModel *)bSubject{
    NSDateComponents *c = [FSDate componentForDate:date];
    NSNumber *year = @(c.year);
    NSString *month = [FSKit twoChar:c.month];
    NSString *error = [self cacheFunction_sub:table year:year month:month je:je subject:aSubject];
    if (error) {
        return error;
    }
    error = [self cacheFunction_sub:table year:year month:month je:je subject:bSubject];
    return error;
}

+ (NSString *)cacheFunction_sub:(NSString *)table year:(NSNumber *)year month:(NSString *)month je:(NSString *)je subject:(FSBestSubjectModel *)subject{
    NSAssert(table, @"table 为nil");
    if (!_fs_isValidateString(table)) {
        return @"表为空";
    }
    NSAssert(year, @"year 为nil");
    NSAssert(month.length == 2, @"month不对");
    if (month.length != 2) {
        return @"month 不对";
    }
    NSAssert(subject, @"subject 为nil");
    if (![subject isKindOfClass:FSBestSubjectModel.class]) {
        return @"科目不对";
    }
    if (!(subject.isp == 1 || subject.isp == 2)) {
        return @"增减不正确";
    }

    NSString *cacheTable = [self cacheTableForTable:table];
    NSString *select = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (be = '%@' and km = '%@' and yr = '%@' and mn = '%@');",cacheTable,subject.be,subject.vl,year,month];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    Class cacheModel = FSBestAccountCacheModel.class;
    NSArray *list = [FSDBSupport querySQL:select class:cacheModel tableName:table];
    if ([list isKindOfClass:NSArray.class] && list.count) {
        NSAssert(list.count == 1, @"list.count数据不对");
        FSBestAccountCacheModel *model = list.firstObject;
        
        NSString *p = model.p;
        NSString *m = model.m;
        if (subject.isp == 1) {
            p = _fs_highAccuracy_add(p, je);
        }else if (subject.isp == 2){
            m = _fs_highAccuracy_add(m, je);
        }
        NSAssert([model.aid isKindOfClass:NSNumber.class], @"aid 为空");
        select = [[NSString alloc] initWithFormat:@"UPDATE %@ SET p = '%@',m = '%@' WHERE aid = %@;",cacheTable,p,m,model.aid];
        NSString *error = [master updateWithSQL:select];
        return error;
    }
    NSString *p = subject.isp == 1?je:@"0";
    NSString *m = subject.isp == 1?@"0":je;
    NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (time,be,km,yr,mn,p,m) VALUES ('%@','%@','%@','%@','%@','%@','%@');",cacheTable,@(_fs_integerTimeIntevalSince1970()),subject.be,subject.vl,year,month,p,m];
    NSString *error = [master insertSQL:sql fields:FSBestAccountCacheModel.tableFields table:cacheTable];
    return error;
}

+ (BOOL)subjectsExist:(NSArray<FSBestSubjectModel *> *)subjects table:(NSString *)table{
    if (!_fs_isValidateString(table)) {
        return NO;
    }
    if (!_fs_isValidateArray(subjects)) {
        return NO;
    }
    NSInteger count = subjects.count;
    NSInteger counter = 0;
    NSArray *list = [self allSubjectsForTable:table];
    Class Class_FSBestSubjectModel = FSBestSubjectModel.class;
    for (FSBestSubjectModel *subject in subjects) {
        if (![subject isKindOfClass:Class_FSBestSubjectModel]) {
            return NO;
        }
        NSInteger sub = [subject.vl integerValue];
        if (sub < 1) {
            return NO;
        }
        for (FSBestSubjectModel *m in list) {
            NSInteger vl = [m.vl integerValue];
            if (vl == sub && vl > 0) {
                counter ++;
            }
        }
    }
    BOOL result = (count == counter);
    return result;
}

+ (BOOL)checkBalance:(FSBestSubjectModel *)aSubject bSubject:(FSBestSubjectModel *)bSubject table:(NSString *)table{
    NSAssert(table, @"checkBalance:table is null");
    if (!_fs_isValidateString(table)) {
        return NO;
    }
    if (!([aSubject isKindOfClass:FSBestSubjectModel.class] && [bSubject isKindOfClass:FSBestSubjectModel.class])) {
        NSAssert(table, @"checkBalance:subject is not right");
        return NO;
    }
    BOOL subjectsExist = [self subjectsExist:@[aSubject,bSubject] table:table];
    if (!subjectsExist) {
        NSAssert(subjectsExist == YES, @"checkBalance:subject not exist");
        return NO;
    }
    NSInteger aJD = [aSubject.jd integerValue];
    NSInteger bJD = [bSubject.jd integerValue];
    BOOL jr = (aJD == 1 || aJD == 2) && (bJD == 1 || bJD == 2);
    if (!jr) {
        NSAssert(jr == YES, @"checkBalance:jr is NO");
        return NO;
    }
    
    /*
     pre：资产科目和成本科目增加记入借方，其他科目增加都是记入贷方
     
     1.如果增加都记入借方，那么必须是一增一减：
     2.如果增加都记入贷方，那么必须是一增一减：
     3.如果一个增加记入借方，一个增加记入贷方，则必须都是增加或都是减少：
     */
    BOOL right = NO;
    if (aJD == bJD) {                           // 第1、2种情况
        right = (aSubject.isp + bSubject.isp == 3);
    }else if ((aJD + bJD) == 3){                // 第3种情况
        right = (aSubject.isp == bSubject.isp);
    }
    return right;
}

+ (NSString *)versatileAddAccount:(NSString *)table je:(NSString *)je bz:(NSString *)bz date:(NSDate *)date aSubject:(FSBestSubjectModel *)aSubject bSubject:(FSBestSubjectModel *)bSubject aMinused:(NSArray<FSBestAccountModel *> *)aMinus bMinused:(NSArray<FSBestAccountModel *> *)bMinus controller:(UIViewController *)controller inBlock:(void(^)(void(^callback)(void)))b{
    if (![controller isKindOfClass:UIViewController.class]) {
        return @"Controller不能为空";
    }
    if (!_fs_isPureFloat(je)) {
        return @"金额不正确";
    }
    if (!_fs_isValidateString(table)) {
        return @"表不存在";
    }
    if (!_fs_isValidateString(bz)) {
        return @"备注不能为空";
    }
    if (!(aSubject.isp == 1 || aSubject.isp == 2)) {
        return @"科目增减不正确";
    }
    if (!(bSubject.isp == 1 || bSubject.isp == 2)) {
        return @"科目增减不正确";
    }
    BOOL balance = [self checkBalance:aSubject bSubject:bSubject table:table];
    if (!balance) {
        return @"试算不平衡";
    }
    CGFloat jef = je.doubleValue;
    if (jef < 0.01) {
        return @"金额不能小于0.01";
    }

    NSInteger tm = 0;
    if ([date isKindOfClass:NSDate.class]) {
        tm = (NSInteger)[date timeIntervalSince1970];
    }else{
        tm = _fs_integerTimeIntevalSince1970();
    }
    
    NSInteger minus = 2 - (aSubject.isp == 1?1:0) - (bSubject.isp == 1?1:0);
    if (minus == 2) {
        if (_fs_isValidateArray(aMinus)) {
           NSString *error = [self minusedHandle:aMinus je:je bz:bz subject:aSubject table:table];
            if (error) {
                return error;
            }
        }else{
            return @"数组为空";
        }
        if (_fs_isValidateArray(bMinus)) {
            NSString *error = [self minusedHandle:bMinus je:je bz:bz subject:bSubject table:table];
            if (error) {
                return error;
            }
        }else{
            return @"数组为空";
        }
    }else if (minus == 1){
        if (_fs_isValidateArray(aMinus)) {
            if (!(aSubject.isp == 2 || bSubject.isp == 2)) {
                return @"数据不对";
            }
            NSString *error = [self minusedHandle:aMinus je:je bz:bz subject:aSubject.isp == 1?bSubject:aSubject table:table];
            if (error) {
                return error;
            }
        }else{
            return @"数组为空";
        }
    }else if (minus == 0){
        NSString *error = [self onlyPlusAccount:table je:je bz:bz date:date aSubject:aSubject bSubject:bSubject inBlock:b];
        return error;
    }else{
        return @"错误情况";
    }
    
    NSString *error = [self onlyPlusAccount:table je:je bz:bz date:date aSubject:aSubject bSubject:bSubject inBlock:b];
    return error;
}

+ (NSString *)trackTableForAccountTable:(NSString *)table{
    if (_fs_isValidateString(table)) {
        NSString *trackTable = [[NSString alloc] initWithFormat:@"%@%@",_SPEC_FLAG_T,table];
        return trackTable;
    }
    return nil;
}

+ (NSArray<FSBestSubjectModel *> *)subSubjectForType:(NSString *)be forTable:(NSString *)table{
    if (!(_fs_isValidateString(table) || !be)) {
        return nil;
    }
    NSString *subjectTable = [self subjectTableForTable:table];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE be = '%@';",subjectTable,be];
    NSArray *list = [FSDBSupport querySQL:sql class:FSBestSubjectModel.class tableName:subjectTable];
    return list;
}

+ (NSMutableArray<FSBestAccountModel *> *)listForSubject:(NSString *)subject table:(NSString *)table page:(NSInteger)page track:(BOOL)track asc:(BOOL)asc unit:(NSInteger)unit{
    if (!(_fs_isValidateString(subject) && _fs_isValidateString(table))) {
        return nil;
    }
    if (unit < 30) {
        unit = 30;
    }
    if (unit > 1000) {
        unit = 1000;
    }
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (aj = '%@' and cast(ar as real) > 0) OR (bj = '%@' and cast(br as real) > 0) order by cast(tm as INTEGER) %@ limit %@,%@;",table,subject,subject,asc?@"ASC":@"DESC",@(page * unit),@(unit)];
    
    NSMutableArray *list = [FSDBSupport querySQL:sql class:FSBestAccountModel.class tableName:table];
    
    NSArray *allSubjects = [self allSubjectsForTable:table];
    for (FSBestAccountModel *model in list) {
        [model countProperties:subject track:track search:nil table:table];
        
        for (int x = 0; x < 2; x ++) {
            NSString *vl = x?model.bj:model.aj;
            for (FSBestSubjectModel *m in allSubjects) {
                if ([vl isEqualToString:m.vl]) {
                    if (x) {
                        model.bBe = m.be;
                    }else{
                        model.aBe = m.be;
                    }
                    break;
                }
            }
        }
    }
    return list;
}

+ (NSMutableArray<FSBestAccountModel *> *)listForSubjectOfDetail:(NSString *)subject table:(NSString *)table page:(NSInteger)page track:(BOOL)track asc:(BOOL)asc isAll:(BOOL)isAll jeSort:(NSInteger)jeSort unit:(NSInteger)unit start:(NSInteger)start end:(NSInteger)end isPlus:(BOOL)isPlus{
    if (!(_fs_isValidateString(subject) && _fs_isValidateString(table))) {
        return nil;
    }
    if (unit < 30) {
        unit = 30;
    }
    if (unit > 1000) {
        unit = 1000;
    }
    
    NSString *sql = nil;
    BOOL noTimeZone = (start == 0 && end == 0);
    
    if (jeSort) {
        if (noTimeZone) {
            if (isPlus) {
                if (isAll) {
                    sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (aj = '%@' and pa != '2') OR (bj = '%@' and pb != '2') order by cast(je as REAL) %@ limit %@,%@;",table,subject,subject,jeSort == 1?@"ASC":@"DESC",@(page * unit),@(unit)];
                }else{
                    sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE ((aj = '%@' and pa != '2' and cast(ar as real) > 0) OR (bj = '%@' and pb != '2' and cast(br as real) > 0)) order by cast(je as REAL) %@ limit %@,%@;",table,subject,subject,jeSort == 1?@"ASC":@"DESC",@(page * unit),@(unit)];
                }
            }else{
                sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE ((aj = '%@' and pa != '1') OR (bj = '%@' and pb != '1')) order by cast(je as REAL) %@ limit %@,%@;",table,subject,subject,jeSort == 1?@"ASC":@"DESC",@(page * unit),@(unit)];
            }
        }else{
            if (isPlus) {
                if (isAll) {
                    sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE ((aj = '%@' and pa != '2') OR (bj = '%@' and pb != '2')) and (cast(tm as INTEGER) > %@ and cast(tm as INTEGER) < %@)) order by cast(je as REAL) %@ limit %@,%@;",table,subject,subject,@(start),@(end),jeSort == 1?@"ASC":@"DESC",@(page * unit),@(unit)];
                }else{
                    sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE ((aj = '%@' and pa != '2' and cast(ar as real) > 0) OR (bj = '%@' and pb != '2' and cast(br as real) > 0)) and (cast(tm as INTEGER) > %@ and cast(tm as INTEGER) < %@)) order by cast(je as REAL) %@ limit %@,%@;",table,subject,subject,@(start),@(end),jeSort == 1?@"ASC":@"DESC",@(page * unit),@(unit)];
                }
            }else{
                sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE ((aj = '%@' and pa != '1') OR (bj = '%@' and pb != '1')) and (cast(tm as INTEGER) > %@ and cast(tm as INTEGER) < %@) order by cast(je as REAL) %@ limit %@,%@;",table,subject,subject,@(start),@(end),jeSort == 1?@"ASC":@"DESC",@(page * unit),@(unit)];
            }
        }
    }else{
        NSString *allRest_aj = @"";
        NSString *allRest_bj = @"";
        if (!isAll) {
            allRest_aj = @"and cast(ar as real) > 0";
            allRest_bj = @"and cast(br as real) > 0";
        }
        if (noTimeZone) {
            if (isPlus) {
                if (isAll) {
                    sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (aj = '%@' and pa != '2') OR (bj = '%@' and pb != '2') order by cast(tm as INTEGER) %@ limit %@,%@;",table,subject,subject,asc?@"ASC":@"DESC",@(page * unit),@(unit)];
                }else{
                    sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (aj = '%@' and pa != '2' %@) OR (bj = '%@'  and pb != '2' %@) order by cast(tm as INTEGER) %@ limit %@,%@;",table,subject,allRest_aj,subject,allRest_bj,asc?@"ASC":@"DESC",@(page * unit),@(unit)];
                }
            }else{
                sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (aj = '%@' and pa != '1') OR (bj = '%@' and pb != '1') order by cast(tm as INTEGER) %@ limit %@,%@;",table,subject,subject,asc?@"ASC":@"DESC",@(page * unit),@(unit)];
            }
        }else{
            if (isPlus) {
                if (isAll) {
                    sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (((aj = '%@' and pa != '2') OR (bj = '%@' and pb != '2')) and (cast(tm as INTEGER) > %@ and cast(tm as INTEGER) < %@)) order by cast(tm as INTEGER) %@ limit %@,%@;",table,subject,subject,@(start),@(end),asc?@"ASC":@"DESC",@(page * unit),@(unit)];
                }else{
                    sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (((aj = '%@' and pa != '2' %@) OR (bj = '%@' and pb != '2' %@)) and (cast(tm as INTEGER) > %@ and cast(tm as INTEGER) < %@)) order by cast(tm as INTEGER) %@ limit %@,%@;",table,subject,allRest_aj,subject,allRest_bj,@(start),@(end),asc?@"ASC":@"DESC",@(page * unit),@(unit)];
                }
            }else{
                sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (((aj = '%@' and pa != '1') OR (bj = '%@' and pb != '1')) and (cast(tm as INTEGER) > %@ and cast(tm as INTEGER) < %@)) order by cast(tm as INTEGER) %@ limit %@,%@;",table,subject,subject,@(start),@(end),asc?@"ASC":@"DESC",@(page * unit),@(unit)];
            }
        }
    }
    
    NSMutableArray *list = [FSDBSupport querySQL:sql class:FSBestAccountModel.class tableName:table];
    
    for (FSBestAccountModel *model in list) {
        [model countProperties:subject track:track search:nil table:table];
    }
    return list;
}

+ (FSBestSubjectModel *)subjectForValue:(NSString *)vl table:(NSString *)table{
    if (!(_fs_isValidateString(vl) && _fs_isValidateString(table))) {
        return nil;
    }
    NSString *subjectTable = [self subjectTableForTable:table];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE vl = '%@';",subjectTable,vl];
    NSArray *list = [FSDBSupport querySQL:sql class:FSBestSubjectModel.class tableName:subjectTable];
    FSBestSubjectModel *model = list.firstObject;
    return model;
}

+ (NSString *)minusedHandle:(NSArray<FSBestAccountModel *> *)eds je:(NSString *)je bz:(NSString *)bz subject:(FSBestSubjectModel *)subject table:(NSString *)table{
    if (!_fs_isValidateArray(eds)) {
        return @"数组为空";
    }
    if (!_fs_isPureFloat(je)) {
        return @"金额不正确";
    }
    NSInteger km = [subject.vl integerValue];
    NSString *restToMinus = je;
    NSString *_zero_ = @"0";
    for (int x = 0; x < eds.count; x ++) {
        FSBestAccountModel *model = [eds objectAtIndex:x];
        NSInteger aj = [model.aj integerValue];
        NSInteger bj = [model.bj integerValue];
        NSInteger pa = [model.pa integerValue];
        NSInteger pb = [model.pb integerValue];
        NSString *value = _zero_;
        NSInteger isa = 0;
        if (km == aj && (pa == 1)) {
            value = model.ar;
            isa = 1;
        }else if (km == bj && (pb == 1)){
            value = model.br;
            isa = 2;
        }
        if (isa == 0) {
            NSAssert(isa != 0, @"怎么isa会等于0呢？");
            return @"数据错误";
        }
        
        NSString *space = _fs_highAccuracy_subtract(restToMinus, value);
        NSComparisonResult result = _fs_highAccuracy_compare(space, _zero_);
        if (result == NSOrderedDescending) {
            restToMinus = space;
            if (isa == 1) {
                model.arst = _zero_;
                NSString *error = [self updateMinusedModel:model table:table isA:isa tje:value bz:bz];
                if (error) {
                    return error;
                }
            }else if (isa == 2){
                model.brst = _zero_;
                NSString *error = [self updateMinusedModel:model table:table isA:isa tje:value bz:bz];
                if (error) {
                    return error;
                }
            }
        }else{
            NSString *rest = _fs_highAccuracy_subtract(value, restToMinus);
            if (isa == 1) {
                model.arst = rest;
                NSString *error = [self updateMinusedModel:model table:table isA:isa tje:restToMinus bz:bz];
                if (error) {
                    return error;
                }
            }else if (isa == 2){
                model.brst = rest;
                NSString *error = [self updateMinusedModel:model table:table isA:isa tje:restToMinus bz:bz];
                if (error) {
                    return error;
                }
            }
            break;
        }
    }
    return nil;
}

+ (NSString *)updateMinusedModel:(FSBestAccountModel *)model table:(NSString *)table isA:(NSInteger)isA tje:(NSString *)tje bz:(NSString *)bz{
    if (!_fs_isValidateString(table)) {
        return @"表为空";
    }
    if (![model isKindOfClass:FSBestAccountModel.class]) {
        return @"数据错误";
    }
    if (!(isA == 1 || isA == 2)) {
        return @"数据错误";
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *sql = nil;
    if (isA == 1) {
        sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET ar = '%@' WHERE aid = %@;",table,model.arst,model.aid];
    }else if (isA == 2){
        sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET br = '%@' WHERE aid = %@;",table,model.brst,model.aid];
    }
    NSString *error = [master updateWithSQL:sql];
    if (error) {
        return error;
    }
    
    NSString *e = [self insertTrackForTable:table model:model je:tje bz:bz markSubject:isA];
    if (e) {
        return e;
    }
    return nil;
}

+ (NSString *)insertTrackForTable:(NSString *)table model:(FSBestAccountModel *)model je:(NSString *)je bz:(NSString *)bz markSubject:(NSInteger)markSubject{
    if (!(markSubject == 1 || markSubject == 2)) {
        return @"科目不正确";
    }
    NSString *trackTable = [self trackTableForAccountTable:table];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (tm,lk,ms,je,bz) VALUES ('%@','%@','%@','%@','%@');",trackTable,@(_fs_integerTimeIntevalSince1970()),model.tm,@(markSubject),je,bz];
    NSString *error = [master insertSQL:sql fields:FSBestTrackModel.tableFields table:trackTable];
    if (error) {
        return error;
    }
    return nil;
}

+ (NSMutableArray<FSBestTrackModel *> *)tracksForModel:(FSBestAccountModel *)model markSubject:(NSInteger)markSubject table:(NSString *)table page:(NSInteger)page{
    if (!_fs_isValidateString(table)) {
        return nil;
    }
    if (![model isKindOfClass:FSBestAccountModel.class]) {
        return nil;
    }
    if (!(markSubject == 1 || markSubject == 2)) {
        return nil;
    }
    if (page < 0) {
        page = 0;
    }
    NSInteger unit = 200;
    NSString *tt = [self trackTableForAccountTable:table];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where (lk = '%@' and ms = '%@') order by cast(tm as INTEGER) DESC limit %@,%@;",tt,model.tm,@(markSubject),@(page * unit),@(unit)];
    NSMutableArray *list = [FSDBSupport querySQL:sql class:FSBestTrackModel.class tableName:tt eachCallback:^(FSBestTrackModel *model) {
        [model countProperties];
    }];
    return list;
}

+ (BOOL)subjectCanDelete:(NSString *)subjectValue table:(NSString *)table{
    if (!_fs_isValidateString(table)) {
        return NO;
    }
    if (!subjectValue) {
        return NO;
    }
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where (aj = '%@' or bj = '%@') limit 0,1;",table,subjectValue,subjectValue];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSArray *list = [master querySQL:sql tableName:table];
    return !_fs_isValidateArray(list);
}

+ (NSString *)editSubject:(FSBestSubjectModel *)model newName:(NSString *)newName table:(NSString *)table{
    if (!_fs_isValidateString(newName)) {
        return @"请输入名称";
    }
    if (newName.length > 20) {
        return @"名称不能超过20个字符";
    }
    if (![model isKindOfClass:FSBestSubjectModel.class]) {
        return nil;
    }
    NSString *subjectTable = [self subjectTableForTable:table];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *select = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE nm = '%@';",subjectTable,newName];
    NSArray *list = [master querySQL:select tableName:subjectTable];
    if (_fs_isValidateArray(list)) {
        return @"该科目名称已存在，请换一个新的";
    }
    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET nm = '%@' WHERE aid = %@;",subjectTable,newName,model.aid];
    NSString *error = [master updateWithSQL:sql];
    return error;
}

+ (NSArray<FSBestAccountModel *> *)searchAccount:(NSString *)account search:(NSString *)search{
    NSString *like = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (bz lIKE '%%%@%%' OR je LIKE '%%%@%%') order by cast(tm as INTEGER) DESC;",account,search,search];
    NSArray *array = [FSDBSupport querySQL:like class:FSBestAccountModel.class tableName:account];
    for (FSBestAccountModel *model in array) {
        [model countProperties:nil track:NO search:search table:account];
    }
    return array;
}

+ (NSString *)cacheTableForTable:(NSString *)table{
    NSString *key = [[NSString alloc] initWithFormat:@"%@%@",_SPEC_FLAG_C,table];
    return key;
}

+ (NSArray *)annalsAndFlows:(NSString *)table{
    NSArray *list = [self allCacheDataForTable:table];
    return list;
}

+ (NSArray<NSDictionary *> *)allCacheDataForTable:(NSString *)table{
    if (!_fs_isValidateString(table)) {
        return nil;
    }
    NSString *cacheTable = [self cacheTableForTable:table];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ order by cast(yr as INT) DESC;",cacheTable];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSArray *list = [master querySQL:sql tableName:cacheTable];
    return list;
}

+ (NSString *)amendTable:(NSString *)table{
    if (!_fs_isValidateString(table)) {
        return nil;
    }
    NSString *cacheTable = [self cacheTableForTable:table];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    BOOL exist = [master checkTableExist:cacheTable];
    if (exist) {
        NSString *error = [master dropTable:cacheTable];
        if (error) {
            return error;
        }
    }
    
    NSArray *allSubject = [self allSubjectsForTable:table];
    
    static NSString *je_f = @"je";
    static NSString *aj_f = @"aj";
    static NSString *bj_f = @"bj";
    static NSString *ap_f = @"pa";
    static NSString *bp_f = @"pb";
    static NSString *tm_f = @"tm";

    int unit = 1000;
    int page = 0;
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ limit %d,%d;",table,page * unit,unit];
    NSArray *list = [master querySQL:sql tableName:table];
    while (_fs_isValidateArray(list)) {
        for (NSDictionary *m in list) {
            NSString *je = [m objectForKey:je_f];
            NSInteger tm = [[m objectForKey:tm_f] integerValue];
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:tm];
            NSDateComponents *c = [FSDate componentForDate:date];
            
            NSString *aj = [m objectForKey:aj_f];
            NSInteger iAJ = [aj integerValue];
            NSString *abe = nil;
            for (FSBestSubjectModel *subject in allSubject) {
                NSInteger vl = [subject.vl integerValue];
                if (vl == iAJ) {
                    abe = subject.be;
                    break;
                }
            }
            if (abe) {
                NSInteger isp = [[m objectForKey:ap_f] integerValue];
                NSString *error = [self cacheBestAccountMonthData:table be:abe km:aj year:@(c.year).stringValue month:[FSKit twoChar:c.month] je:je isp:isp];
                if (error) {
                    return error;
                }
            }
            
            NSString *bj = [m objectForKey:bj_f];
            NSInteger iBJ = [bj integerValue];
            NSString *bbe = nil;
            for (FSBestSubjectModel *subject in allSubject) {
                NSInteger vl = [subject.vl integerValue];
                if (vl == iBJ) {
                    bbe = subject.be;
                    break;
                }
            }
            if (bbe) {
                NSInteger isp = [[m objectForKey:bp_f] integerValue];
                NSString *error = [self cacheBestAccountMonthData:table be:bbe km:bj year:@(c.year).stringValue month:[FSKit twoChar:c.month] je:je isp:isp];
                if (error) {
                    return error;
                }
            }
        }
        
        page ++;
        NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ limit %d,%d;",table,page * unit,unit];
        list = [master querySQL:sql tableName:table];
    }
    return nil;
}

+ (NSString *)cacheBestAccountMonthData:(NSString *)table be:(NSString *)be km:(NSString *)km year:(NSString *)year month:(NSString *)month je:(NSString *)je isp:(NSInteger)isp{
    if (!_fs_isValidateString(table)) {
        return @"表为空";
    }
    if (!(be && km && year)) {
        return @"数据错误";
    }
    if (!(isp == 1 || isp == 2)) {
        return @"isp不对";
    }
    if (!([month isKindOfClass:NSString.class] && month.length == 2)) {
        return @"数据错误";
    }
    if (!_fs_isValidateString(je)) {
        return @"金额不正确";
    }
    NSString *cacheTable = [self cacheTableForTable:table];
    NSString *select = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (be = '%@' and km = '%@' and yr = '%@' and mn = '%@');",cacheTable,be,km,year,month];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    Class cacheModel = FSBestAccountCacheModel.class;
    NSArray *list = [FSDBSupport querySQL:select class:cacheModel tableName:table];
    if ([list isKindOfClass:NSArray.class] && list.count) {
        NSAssert(list.count == 1, @"list.count数据不对");
        FSBestAccountCacheModel *model = list.firstObject;
        
        NSString *p = model.p;
        NSString *m = model.m;
        if (isp == 1) {
            p = _fs_highAccuracy_add(p, je);
        }else if (isp == 2){
            m = _fs_highAccuracy_add(m, je);
        }
        NSAssert([model.aid isKindOfClass:NSNumber.class], @"aid 为空");
        select = [[NSString alloc] initWithFormat:@"UPDATE %@ SET p = '%@',m = '%@' WHERE aid = %@;",cacheTable,p,m,model.aid];
        NSString *error = [master updateWithSQL:select];
        return error;
    }
    NSString *p = (isp == 1)?je:@"0";
    NSString *m = (isp == 1)?@"0":je;
    NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (time,be,km,yr,mn,p,m) VALUES ('%@','%@','%@','%@','%@','%@','%@');",cacheTable,@(_fs_integerTimeIntevalSince1970()),be,km,year,month,p,m];
    NSString *error = [master insertSQL:sql fields:FSBestAccountCacheModel.tableFields table:cacheTable];
    return error;
}

+ (NSString *)updateModel:(FSBestAccountModel *)model table:(NSString *)table{
    if (!_fs_isValidateString(table)) {
        return @"表为空";
    }
    if (![model isKindOfClass:FSBestAccountModel.class]) {
        return @"数据不对";
    }
    if (!_fs_isValidateString(model.bz)) {
        return @"数据不对";
    }
    if (!_fs_isValidateString(model.ar)) {
        return @"数据不对";
    }
    if (!_fs_isValidateString(model.br)) {
        return @"数据不对";
    }
    FSBestSubjectModel *aSubject = [self subjectForValue:model.aj table:table];
    aSubject.isp = [model.pa integerValue];
    FSBestSubjectModel *bSubject = [self subjectForValue:model.bj table:table];
    bSubject.isp = [model.pb integerValue];
    BOOL ph = [self checkBalance:aSubject bSubject:bSubject table:table];
    if (!ph) {
        return @"科目选择不正确";
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET bz = '%@',aj = '%@',bj = '%@',ar = '%@',br = '%@' WHERE aid = %@;",table,model.bz,model.aj,model.bj,model.ar,model.br,model.aid];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *error = [master updateWithSQL:sql];
    return error;
}

+ (CGFloat)trackMinusedForTable:(NSString *)table lk:(NSString *)lk isAJ:(BOOL)isAJ{
    if (!_fs_isValidateString(table)) {
        return 0;
    }
    if (!_fs_isValidateString(lk)) {
        return 0;
    }
    NSString *trackTable = [self trackTableForAccountTable:table];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where (lk = '%@' and ms = '%@');",trackTable,lk,isAJ?@1:@2];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSArray *list = [master querySQL:sql tableName:trackTable];
    if (_fs_isValidateArray(list)) {
        CGFloat sum = 0;
        static NSString *jef = @"je";
        for (NSDictionary *dic in list) {
            CGFloat je = [dic[jef] doubleValue];
            sum += je;
        }
        return sum;
    }
    return 0;
}

+ (NSString *)deleteSubjectWithType:(NSString *)vl table:(NSString *)table{
    if (!_fs_isValidateString(vl)) {
        return @"科目不对";
    }
    if (!_fs_isValidateString(table)) {
        return @"表不对";
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *select = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (aj = '%@' or bj = '%@');",table,vl,vl];
    NSArray *list = [master querySQL:select tableName:table];
    if (_fs_isValidateArray(list)) {
        return @"该科目下还有数据，不能删除";
    }
    
    NSString *subjectTable = [self subjectTableForTable:table];
    NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE vl = '%@';",subjectTable,vl];
    NSString *error = [master deleteSQL:sql];
    if (error) {
        return error;
    }
    
    //删除模板表中数据
    NSString *mTable = [self mobanTableForTable:table];
    NSString *mSql = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE (aj = '%@' or bj = '%@');",mTable,vl,vl];
    NSString *e = [master deleteSQL:mSql];
    return e;
}

+ (void)srAndCbForTable:(NSString *)table months:(NSInteger)months completion:(void(^)(NSString *sr,NSString *cb,NSInteger year,NSInteger month))completion{
    if (!completion) {
        return;
    }
    if (months < 1) {
        months = 12;
    }
    NSDate *date = [NSDate date];
    NSDateComponents *c = [FSDate componentForDate:date];
    NSInteger month = c.month;
    NSInteger year = c.year;
    
    NSInteger _yer_ = months / 12;
    NSInteger _mon_ = months % 12;
    
    NSInteger minYear = year - _yer_;
    NSInteger minMonth = month - _mon_;
    if (minMonth <= 0) {
        minMonth = 12 + minMonth;
        minYear --;
    }//算法经过测试,无误

    NSNumber *be_sr = @(FSBestAccountSubjectType1SR);
    NSNumber *be_cb = @(FSBestAccountSubjectType2CB);
    NSString *cacheTable = [self cacheTableForTable:table];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where ((be = '%@' or be = '%@') and cast(yr as INTEGER) > %@) order by cast(yr as INTEGER) DESC;",cacheTable,be_sr,be_cb,@(minYear - 1)];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSArray *list = [master querySQL:sql tableName:cacheTable];
    static NSString *_key_be = @"be";
    static NSString *_key_p = @"p";
    static NSString *_key_m = @"m";
    static NSString *_key_mn = @"mn";
    static NSString *_key_yr = @"yr";

    NSString *sr = nil;
    NSString *cb = nil;
    if (_fs_isValidateArray(list)) {
        for (NSDictionary *dic in list) {
            NSInteger m_month = [[dic objectForKey:_key_mn] integerValue];
            NSInteger m_year = [[dic objectForKey:_key_yr] integerValue];
            BOOL condition = (m_year = minYear) || (m_year == minYear && m_month >= minMonth);
            if (condition) {
                NSInteger m_be = [[dic objectForKey:_key_be] integerValue];
                if (m_be == FSBestAccountSubjectType1SR) {
                    NSString *m_p = [dic objectForKey:_key_p];
                    NSString *m_m = [dic objectForKey:_key_m];
                    NSString *delta = _fs_highAccuracy_subtract(m_p, m_m);
                    sr = _fs_highAccuracy_add(sr, delta);
                }else if (m_be == FSBestAccountSubjectType2CB){
                    NSString *m_p = [dic objectForKey:_key_p];
                    NSString *m_m = [dic objectForKey:_key_m];
                    NSString *delta = _fs_highAccuracy_subtract(m_p, m_m);
                    cb = _fs_highAccuracy_add(cb, delta);
                }
            }
        }
    }
    completion(sr,cb,minYear,minMonth);
}

+ (NSInteger)firstTimeForTable:(NSString *)table{
    if (!_fs_isValidateString(table)) {
        return 0;
    }
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ order by cast(tm as INTEGER) limit 0,1;",table];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSArray *list = [master querySQL:sql tableName:table];
    if (_fs_isValidateArray(list)) {
        NSDictionary *dic = list.firstObject;
        return [dic[@"tm"] integerValue];
    }
    return 0;
}

+ (NSString *)mobanTableForTable:(NSString *)table{
    if (!_fs_isValidateString(table)) {
        return nil;
    }
    NSString *subjectTable = [[NSString alloc] initWithFormat:@"%@%@",_SPEC_FLAG_M,table];
    return subjectTable;
}

+ (NSMutableArray<NSString *> *)allMobanForTable:(NSString *)table page:(NSInteger)page{
    page = MAX(0, page);
    NSInteger unit = 10000;
    NSString *mobanTable = [self mobanTableForTable:table];
//    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT DISTINCT bz,fq FROM %@ limit %@,%@;",mobanTable,@(page * unit),@(unit)];// DISTINCT bz,fq会不准
//    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT DISTINCT bz FROM %@ order by cast(fq as INTEGER) DESC limit %@,%@;",mobanTable,@(page * unit),@(unit)];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT bz,fq FROM %@ order by cast(fq as INTEGER) DESC limit %@,%@;",mobanTable,@(page * unit),@(unit)];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSMutableArray *list = [master querySQL:sql tableName:mobanTable];
    
    NSMutableArray *sole = [[NSMutableArray alloc] init];
    NSString *k = @"bz";
    for (NSDictionary *dic in list) {
        NSString *name = dic[k];
        if (![sole containsObject:name]) {
            [sole addObject:name];
        }
    }
    return sole;
}

+ (NSString *)addMobanForTable:(NSString *)table aj:(FSBestSubjectModel *)aj bj:(FSBestSubjectModel *)bj bz:(NSString *)bz{
    if (![aj isKindOfClass:FSBestSubjectModel.class]) {
        return @"科目不对";
    }
    if (![bj isKindOfClass:FSBestSubjectModel.class]) {
        return @"科目不对";
    }
    if (!(aj.isp == 1 || aj.isp == 2)) {
        return @"科目不对";
    }
    if (!(bj.isp == 1 || bj.isp == 2)) {
        return @"科目不对";
    }
    NSString *mobanTable = [self mobanTableForTable:table];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where ((aj = '%@' and bj = '%@' and ap = '%@' and bp = '%@' and bz = '%@') or (aj = '%@' and bj = '%@' and ap = '%@' and bp = '%@' and bz = '%@')) limit 0,1;",mobanTable,aj.vl,bj.vl,@(aj.isp),@(bj.isp),bz,bj.vl,aj.vl,@(aj.isp),@(bj.isp),bz];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSArray *list = [master querySQL:sql tableName:mobanTable];
    if (!_fs_isValidateArray(list)) {
        sql = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (tm,aj,ap,an,abe,abn,bj,bp,bn,bbe,bbn,fq,bz) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@');",mobanTable,@(_fs_integerTimeIntevalSince1970()),aj.vl,@(aj.isp),aj.nm,aj.be,aj.bn,bj.vl,@(bj.isp),bj.nm,bj.be,bj.bn,@0,bz];
        NSString *error = [master insertSQL:sql fields:FSBestMobanModel.tableFields table:mobanTable];
        if (error) {
            return error;
        }
    }
    return nil;
}

+ (NSArray<FSBestMobanModel *> *)mobansForTable:(NSString *)table bz:(NSString *)bz{
    NSString *mobanTable = [self mobanTableForTable:table];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where bz = '%@' order by cast(fq as INTEGER) DESC;",mobanTable,bz];
    NSArray *list = [FSDBSupport querySQL:sql class:FSBestMobanModel.class tableName:mobanTable];
    UIColor *black = UIColor.blackColor;
    UIColor *light = UIColor.grayColor;
    NSString *_flag_p = @"+";
    NSString *_flag_m = @"-";
    for (FSBestMobanModel *model in list) {
        BOOL isAP = model.ap.integerValue == 1;
        BOOL isBP = model.bp.integerValue == 1;
        UIColor *aColor = isAP?black:light;
        UIColor *bColor = isBP?black:light;
        NSString *a = [[NSString alloc] initWithFormat:@"%@(%@) %@",model.an,model.abn,isAP?_flag_p:_flag_m];
//        NSString *b = model.bn;
//        NSString *a = [[NSString alloc] initWithFormat:@"%@（%@）",model.an,model.abn];
        NSString *b = [[NSString alloc] initWithFormat:@"%@(%@) %@",model.bn,model.bbn,isBP?_flag_p:_flag_m];
        NSAttributedString *at = [FSKit attributedStringFor:a strings:@[a] color:aColor fontStrings:nil font:nil];
        NSAttributedString *bt = [FSKit attributedStringFor:b strings:@[b] color:bColor fontStrings:nil font:nil];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        [attr appendAttributedString:at];
        [attr appendAttributedString:bt];
        
        model.showA = at;
        model.showB = bt;
    }
    return list;
}

// @[@{@"year":@"2018",@"list":@[@{@"mn":@"07",@"ps":@"100",@"ms":@"50",@"rs":@"50",@"n":@"7月"}]}]
+ (NSMutableArray<NSDictionary *> *)allFlowsForTable:(NSString *)table page:(NSInteger)page{
    NSInteger unit = 2;
    NSString *cacheTable = [self cacheTableForTable:table];
    NSNumber *srbe = @(FSBestAccountSubjectType1SR);
    NSNumber *cbbe = @(FSBestAccountSubjectType2CB);
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT DISTINCT yr FROM %@ where (be = '%@' or be = '%@') order by cast(yr as INTEGER) DESC limit %@,%@;",cacheTable,srbe,cbbe,@(page * unit),@(unit)];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSArray *years = [master querySQL:sql tableName:cacheTable];
    BOOL hasData = _fs_isValidateArray(years);
    if (!hasData) {
        return nil;
    }
    static NSString *_key_yr = @"yr";
    static NSString *_key_p = @"p";
    static NSString *_key_m = @"m";
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:years.count];
    for (NSDictionary *dic in years) {
        NSString *yr = [dic objectForKey:_key_yr];
        
        NSString *dsql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where ((be = '%@' or be = '%@') and yr = '%@') order by cast(mn as INTEGER) DESC;",cacheTable,srbe,cbbe,yr];
        NSArray *details = [master querySQL:dsql tableName:cacheTable];
        if (_fs_isValidateArray(details)) {
            NSMutableArray *thisList = [[NSMutableArray alloc] init];
            static NSString *_key_n = @"n";
            
            static NSString *_key_mn = @"mn";
            static NSString *_key_be = @"be";
            for (NSDictionary *m in details) {
                NSString *mn = m[_key_mn];
                if (!mn) {
                    continue;
                }
                NSInteger be = [m[_key_be] integerValue];
                
                NSMutableDictionary *months = nil;
                for (NSMutableDictionary *savedMonths in thisList) {
                    NSInteger sm = [[savedMonths objectForKey:_key_mn] integerValue];
                    if (sm == [mn integerValue]) {
                        months = savedMonths;
                    }
                }
                if (!months) {
                    months = [[NSMutableDictionary alloc] init];
                    [months setObject:mn forKey:_key_mn];
                    NSString *name = [[NSString alloc] initWithFormat:@"%@月",mn];
                    [months setObject:name forKey:_key_n];
                    [thisList addObject:months];
                }
                
                CGFloat subP = [m[_key_p] doubleValue];
                CGFloat subM = [m[_key_m] doubleValue];
                if (be == FSBestAccountSubjectType1SR) {
                    CGFloat saved_p = [[months objectForKey:_key_p] doubleValue];
                    saved_p += (subP - subM);
                    [months setObject:@(saved_p) forKey:_key_p];
                }else if (be == FSBestAccountSubjectType2CB){
                    CGFloat saved_m = [[months objectForKey:_key_m] doubleValue];
                    saved_m += (subP - subM);
                    [months setObject:@(saved_m) forKey:_key_m];
                }
            }
            NSDictionary *yd = @{@"year":yr,@"list":thisList};
            [array addObject:yd];
        }
    }
    
    if (_fs_isValidateArray(array)) {
        static NSString *_key_r = @"r";
        static NSString *_key_ps = @"ps";
        static NSString *_key_ms = @"ms";
        static NSString *_key_rs = @"rs";
        static NSString *_key_jlv = @"jlv";
        static NSString *_key_c = @"c";

        for (NSDictionary *m in array) {
            NSArray *list = m[@"list"];
            if (_fs_isValidateArray(list)) {
                for (NSMutableDictionary *model in list) {
                    NSNumber *pm = model[_key_p];
                    NSNumber *mm = model[_key_m];
                    CGFloat p = pm.doubleValue;
                    CGFloat m = mm.doubleValue;
                    CGFloat r = p - m;
                    NSNumber *rm = @(r);
                    [model setObject:rm forKey:_key_r];
                    
                    CGFloat jlv = 0;
                    if (p != 0) {
                        jlv = r / p;
                    }
                    NSString *jlvv = [[NSString alloc] initWithFormat:@"%.2f%%",jlv * 100];
                    
                    NSString *ps = [FSKit bankStyleDataThree:pm];
                    NSString *ms = [FSKit bankStyleDataThree:mm];
                    NSString *rs = [FSKit bankStyleDataThree:rm];
                    [model setObject:ps forKey:_key_ps];
                    [model setObject:ms forKey:_key_ms];
                    [model setObject:rs forKey:_key_rs];
                    [model setObject:jlvv forKey:_key_jlv];
                    [model setObject:@(r > 0?YES:NO) forKey:_key_c];
                }
            }
        }
    }
    return array;
}

+ (NSMutableArray<FSBestAccountModel *> *)flowListForTable:(NSString *)table year:(NSString *)year month:(NSString *)month isSR:(BOOL)isSR{
    NSString *date = [[NSString alloc] initWithFormat:@"%@-%@-10 00:00:00",year,month];
    NSDate *d = [FSDate dateByString:date formatter:nil];
    NSInteger start = [FSDate theFirstSecondOfMonth:d] - 1;
    NSInteger end = [FSDate theLastSecondOfMonth:d] + 1;

    NSInteger page = 0;
    NSInteger unit = 100;
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where (cast(tm as INTEGER) > %@ and cast(tm as INTEGER) < %@) order by cast(tm as INTEGER) DESC limit %@,%@;",table,@(start),@(end),@(page * unit),@(unit)];
    NSMutableArray *list = [FSDBSupport querySQL:sql class:FSBestAccountModel.class tableName:table];
    
    NSMutableArray *needs = [[NSMutableArray alloc] init];
    while (_fs_isValidateArray(list)) {
        NSString *be = nil;
        NSArray *subjects = nil;
        if (isSR) {
            be = @(FSBestAccountSubjectType1SR).stringValue;
            subjects = [self subSubjectForType:be forTable:table];
        }else{
            be = @(FSBestAccountSubjectType2CB).stringValue;
            subjects = [self subSubjectForType:be forTable:table];
        }
        for (FSBestAccountModel *model in list) {
            NSInteger aj = model.aj.integerValue;
            NSInteger bj = model.bj.integerValue;
            for (FSBestSubjectModel *sj in subjects) {
                NSInteger vl = sj.vl.integerValue;
                BOOL aSame = (vl == aj);
                if (aSame) {
                    model.aIsFlow = YES;
                }
                if (aSame || bj == vl) {
                    [needs addObject:model];
                }
            }
        }
        for (FSBestAccountModel *m in needs) {
            [m countProperties:m.aIsFlow?m.aj:m.bj track:YES search:nil table:table];
        }
        
        page ++;
        sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where (cast(tm as INTEGER) > %@ and cast(tm as INTEGER) < %@) order by cast(tm as INTEGER) DESC limit %@,%@;",table,@(start),@(end),@(page * unit),@(unit)];
        list = [FSDBSupport querySQL:sql class:FSBestAccountModel.class tableName:table];
    }
    return needs;
}

// 1.heads  2.deltas 3.rests
+ (NSDictionary *)annalsForTable:(NSString *)table year:(NSInteger)year useCacheIfExist:(BOOL)useCache{
    NSString *cacheKey = [[NSString alloc] initWithFormat:@"%@_%ld_annals",table,year];
    if (useCache) {
        NSDictionary *cacheData = _fs_userDefaults_objectForKey(cacheKey);
        if ([cacheData isKindOfClass:NSDictionary.class] && cacheData.count) {
            return cacheData;
        }
    }
    
    NSString *cacheTable = [self cacheTableForTable:table];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *existSQL = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where yr = '%ld' limit 0,1;",cacheTable,year - 1];
    NSArray *exists = [master querySQL:existSQL tableName:cacheTable];
    NSDictionary *front = nil;
    if (_fs_isValidateArray(exists)) {
        front = [self annalsForTable:table year:year - 1 useCacheIfExist:useCache];
    }

    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ where yr = '%ld';",cacheTable,year];
    NSArray *list = [master querySQL:sql tableName:cacheTable];
    
    if (_fs_isValidateArray(list)) {
        NSMutableDictionary *all = [[NSMutableDictionary alloc] init];
        CGFloat sr = 0;CGFloat cb = 0;CGFloat ldzc = 0;CGFloat fldzc = 0;CGFloat ldfz = 0;CGFloat fldfz = 0;CGFloat syzqy = 0;
        static NSString *_key_p = @"p";
        static NSString *_key_m = @"m";
        static NSString *_key_be = @"be";
        for (NSDictionary *m in list) {
            CGFloat pv = [m[_key_p] doubleValue];
            CGFloat mv = [m[_key_m] doubleValue];
            CGFloat be = [m[_key_be] integerValue];
            
            CGFloat delta = pv - mv;
            if (be == FSBestAccountSubjectType1SR) {
                sr += delta;
            }else if (be == FSBestAccountSubjectType2CB){
                cb += delta;
            }else if (be == FSBestAccountSubjectType3LDZC){
                ldzc += delta;
            }else if (be == FSBestAccountSubjectType4FLDZC){
                fldzc += delta;
            }else if (be == FSBestAccountSubjectType5LDFZ){
                ldfz += delta;
            }else if (be == FSBestAccountSubjectType6FLDFZ){
                fldfz += delta;
            }else if (be == FSBestAccountSubjectType7SYZQY){
                syzqy += delta;
            }
        }
        
        CGFloat lr = sr - cb;
        CGFloat jlv = 0;
        if (sr > 0) {
            jlv = lr / sr;
        }
        
        NSArray *frontRests = [front objectForKey:@"3"];
        CGFloat restLDZC = [frontRests[0] doubleValue];
        CGFloat restFLDZC = [frontRests[1] doubleValue];
        CGFloat restLDFZ = [frontRests[2] doubleValue];
        CGFloat restFLDFZ = [frontRests[3] doubleValue];
        CGFloat restSYZQY = [frontRests[4] doubleValue];

        CGFloat nowLDZC = ldzc + restLDZC;
        CGFloat nowFLDZC = fldzc + restFLDZC;
        CGFloat nowLDFZ = ldfz + restLDFZ;
        CGFloat nowFLDFZ = fldfz + restFLDFZ;
        CGFloat nowSYZQY = syzqy + restSYZQY;

        CGFloat assets = nowLDZC + nowFLDZC;
        CGFloat debts = nowLDFZ + nowFLDFZ;
        CGFloat jzc = assets - debts;
        
        CGFloat restJZC = (restLDZC + restFLDZC - restLDFZ - restFLDFZ);
        CGFloat zzl = 0;
        if (assets > 0) {
            zzl = debts / assets;
        }
        
        CGFloat powJZC = (restJZC + jzc) / 2;
        CGFloat roe = 0;
        if (powJZC > 0) {
            roe = lr / powJZC;
        }
        
        CGFloat restZC = restLDZC + restFLDZC;
        CGFloat powerZC = (restZC + assets) / 2;
        CGFloat atr = 0;
        if (powerZC > 0) {
            atr = sr / powerZC;
        }
        
        NSArray *deltas = @[@(ldzc),@(fldzc),@(ldfz),@(fldfz),@(syzqy)];
        NSArray *rests = @[@(nowLDZC),@(nowFLDZC),@(nowLDFZ),@(nowFLDFZ),@(nowSYZQY)];
        NSArray *heads = @[@(sr),@(cb),@(lr),@(jlv),@(assets),@(debts),@(jzc),@(zzl),@(roe),@(atr)];
        
        [all setObject:heads forKey:@"1"];
        [all setObject:deltas forKey:@"2"];
        [all setObject:rests forKey:@"3"];
        
        _fs_userDefaults_setObjectForKey(all, cacheKey);
        
        return all;
    }
    return nil;
}

@end
