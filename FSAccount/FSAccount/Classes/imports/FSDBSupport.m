//
//  FSDBSupport.m
//  myhome
//
//  Created by FudonFuchina on 2017/8/26.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSDBSupport.h"
#import "FSKitDuty.h"
#import "FATool.h"
#import "FSDiaryModel.h"
#import "FSCryptor.h"
#import "FSPwdBookModel.h"
#import "FSContactModel.h"
#import "FSTuple.h"
#import "FSDate.h"
#import "FSRuntime.h"

@implementation FSDBSupport

+ (void)exportTables:(NSArray *)tables{
    if (!_fs_isValidateArray(tables)) {
        return;
    }
    [FSDBTool saveFileCallback:^Tuple2<NSString *,NSString *> *{
        NSString *fileName = [[NSString alloc] initWithFormat:@"%@App_%@",[FSKit appName],[self timeStr]];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@.txt",fileName]];
        
        FSDBMaster *master = [FSDBMaster sharedInstance];
        NSArray *cans = [self canExportTables];
        NSInteger order = 0;
        for (NSString *table in tables) {
            if (![cans containsObject:table]) {
                continue;
            }
            
            NSInteger count = [master countForTable:table];
            if (count == 0) {
                continue;
            }
            Tuple2 *t = [self nameOfTable:table];
            NSString *tbName = t._1;
            if (order == 0) {
                NSString *head = [[NSString alloc] initWithFormat:@"本文件于%@\n由[%@]APP生成\n\n%@:\n",[FSDate stringWithDate:[NSDate date] formatter:nil],[FSKit appName],tbName];
                [FSFile wirteToFile:path content:head];
            }else{
                NSString *valu = [[NSString alloc] initWithFormat:@"\n\n%@:\n",tbName];
                [FSFile wirteToFile:path content:valu];
            }
            
            if (count < 200) {
                NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@;",table];
                NSArray *list = [master querySQL:sql tableName:table];
                [self writeData:path list:list table:table];
            }else{
                NSInteger index = 0;
                NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ limit %@,200;",table,@(index * 200)];
                NSArray *list = [master querySQL:sql tableName:table];
                while (_fs_isValidateArray(list)) {
                    [self writeData:path list:list table:table];
                    index ++;
                    sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ limit %@,200;",table,@(index * 200)];
                    list = [master querySQL:sql tableName:table];
                }
            }
            order ++;
        }
        return [Tuple2 v1:path v2:fileName];
    }];
}

+ (void)writeData:(NSString *)path list:(NSArray *)list table:(NSString *)table{
    for (NSDictionary *dic in list) {
        NSMutableString *unit = [[NSMutableString alloc] init];
        NSArray *keys = [dic allKeys];
        for (NSString *key in keys) {
            NSString *value = dic[key];
            NSString *str = [self visionString:table key:key value:value];
            [unit appendFormat:@"\n%@",str];
        }
        [unit appendString:@"\n\n"];
        [FSFile wirteToFile:path content:unit];
    }
}

+ (NSString *)visionString:(NSString *)table key:(NSString *)key value:(NSString *)value{
    if ([key isEqualToString:@"aid"]) {
        return [[NSString alloc] initWithFormat:@"序号：%@",value];
    }
    if ([key isEqualToString:@"time"]) {
        return [[NSString alloc] initWithFormat:@"时间：%@",[FSKit ymdhsByTimeIntervalString:value]];
    }
    if ([table isEqualToString:_tb_contact]) { // FSContactModel
        if ([key isEqualToString:@"name"]){
            return [[NSString alloc] initWithFormat:@"名字：%@",[FSCryptor aes256DecryptString:value]];
        }else if ([key isEqualToString:@"phone"]){
            return [[NSString alloc] initWithFormat:@"手机：%@",[FSCryptor aes256DecryptString:value]];
        }else if ([key isEqualToString:@"type"]){
            return [[NSString alloc] initWithFormat:@"类型：%@",value];
        }
    }else if ([table isEqualToString:_tb_password]){    // FSPwdBookModel
        if ([key isEqualToString:@"name"]){
            return [[NSString alloc] initWithFormat:@"名字：%@",[FSCryptor aes256DecryptString:value]];
        }else if ([key isEqualToString:@"login"]){
            return [[NSString alloc] initWithFormat:@"帐号：%@",[FSCryptor aes256DecryptString:value]];
        }else if ([key isEqualToString:@"pwd"]){
            return [[NSString alloc] initWithFormat:@"密码：%@",[FSCryptor aes256DecryptString:value]];
        }else if ([key isEqualToString:@"phone"]){
            return [[NSString alloc] initWithFormat:@"手机：%@",[FSCryptor aes256DecryptString:value]];
        }else if ([key isEqualToString:@"mail"]){
            return [[NSString alloc] initWithFormat:@"邮箱：%@",[FSCryptor aes256DecryptString:value]];
        }else if ([key isEqualToString:@"note"]){
            return [[NSString alloc] initWithFormat:@"备注：%@",[FSCryptor aes256DecryptString:value]];
        }else if ([key isEqualToString:@"zone"]){
            return [[NSString alloc] initWithFormat:@"组名：%@",value];
        }
    }else if ([table isEqualToString:_tb_diary]){   // FSDiaryModel
        if ([key isEqualToString:@"content"]){
            return [[NSString alloc] initWithFormat:@"%@",[FSCryptor aes256DecryptString:value]];
        }else if ([key isEqualToString:@"zone"]){
            return [[NSString alloc] initWithFormat:@"类型：%@",value];
        }
    }
    return nil;
}

+ (NSMutableArray *)canExportTables{
    NSMutableArray *list = [[NSMutableArray alloc] initWithArray:@[_tb_contact,_tb_password,_tb_diary,_tb_abTrack,_tb_birth,_tb_location,_tb_alert]];
    NSArray *accounts = [self allAccounts];
    for (NSDictionary *dic in accounts) {
        [list addObject:dic[@"tb"]];
    }
    return list;
}

+ (Tuple2 *)nameOfTable:(NSString *)table{
    if (!_fs_isValidateString(table)) {
        return nil;
    }
    NSDictionary *maps = [self nameMapTable];
    NSArray *keys = [maps allKeys];
    if ([keys containsObject:table]) {
        return [Tuple2 v1:maps[table] v2:@(NO)];
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT name FROM %@ WHERE tb = '%@';",_tb_abname,table];
    NSArray *list = [master querySQL:sql tableName:table];
    if (list.count) {
        NSDictionary *dic = list.firstObject;
        NSString *name = dic[@"name"];
        if (_fs_isValidateString(name)) {
            return [Tuple2 v1:name v2:@(YES)];
        }
    }
    return nil;
}

+ (NSDictionary *)nameMapTable{
    static NSDictionary *dic = nil;
    if (!dic) {
        dic = @{
                _tb_contact:@"通讯录",
                _tb_password:@"密码",
                _tb_diary:@"日记",
                _tb_abTrack:@"账减记录",
                _tb_location:@"地址",
                _tb_birth:@"生日",
                _tb_alert:@"提醒",
                };
    }
    return dic;
}

+ (NSArray *)allAccounts{
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT tb FROM %@",_tb_abname];
    NSArray *list = [master querySQL:sql tableName:_tb_abname];
    return list;
}

+ (NSMutableArray *)querySQL:(NSString *)sql class:(Class)cname tableName:(NSString *)tableName{
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSMutableArray *list = [master querySQL:sql tableName:tableName];
    NSMutableArray *models = [[NSMutableArray alloc] initWithCapacity:list.count];
    for (NSDictionary *dic in list) {
        id model = [FSRuntime entity:cname dic:dic];
        if (model) {
            [models addObject:model];
        }
    }
    return models.count?models:nil;
}

+ (NSMutableArray *)querySQL:(NSString *)sql class:(Class)cname tableName:(NSString *)tableName eachCallback:(void(^)(id model))preCount{
    NSAssert(preCount != nil, @"preCount必须实现才调用这个方法");
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSMutableArray *list = [master querySQL:sql tableName:tableName];
    NSMutableArray *models = [[NSMutableArray alloc] initWithCapacity:list.count];
    for (NSDictionary *dic in list) {
        id model = [FSRuntime entity:cname dic:dic];
        if (model) {
            [models addObject:model];
            preCount(model);
        }
    }
    return models.count?models:nil;
}

+ (void)sendAccountList:(NSString *)accountName entity:(FSSQLEntity *)entity{
    [FSDBTool saveFileCallback:^Tuple2<NSString *,NSString *> *{
        NSString *fileName = [[NSString alloc] initWithFormat:@"Account_%@",[self timeStr]];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"Account_%@.txt",fileName]];
        
        FSDBMaster *master = [FSDBMaster sharedInstance];
        NSInteger count = [master countForTable:accountName];
        
        NSMutableString *valueString = [[NSMutableString alloc] initWithString:@"整体情况:\n"];
        NSArray *pList = [FSRuntime propertiesForClass:FSSQLEntity.class];
        for (int x = 0; x < pList.count; x ++) {
            NSString *p = [pList objectAtIndex:x];
            NSString *name = [FATool hansForShort:p];
            NSString *value = [FSRuntime valueForGetSelectorWithPropertyName:p object:entity];
            [valueString appendFormat:@"%@：%@\n",name,value];
        }
        [FSFile wirteToFile:path content:valueString];
        
        NSInteger index = 0;
        NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ order by cast(time as REAL) DESC limit %@,1;",accountName,@(index)];
        NSArray *list = [master querySQL:sql tableName:accountName];
        while (_fs_isValidateArray(list)) {
            NSDictionary *model = [list firstObject];
            NSString *atype = [model objectForKey:@"atype"];
            NSString *btype = [model objectForKey:@"btype"];
            NSString *aSuffx = [atype hasSuffix:_ING_KEY]?NSLocalizedString(@"Add", nil):NSLocalizedString(@"Reduce", nil);
            NSString *bSuffx = [btype hasSuffix:_ING_KEY]?NSLocalizedString(@"Add", nil):NSLocalizedString(@"Reduce", nil);
            NSString *type = [[NSString alloc] initWithFormat:@"%@%@ %@%@",[FATool hansForShort:atype],aSuffx,[FATool hansForShort:btype],bSuffx];
            
            NSString *content = [[NSString alloc] initWithFormat:@"序号：%@/%@\n时间：%@\n金额：%@\n类型：%@\n备注：%@",@(index + 1),@(count),[FSKit ymdhsByTimeIntervalString:model[@"time"]],[model objectForKey:@"je"],type,model[@"bz"]];
            NSString *value = [[NSString alloc] initWithFormat:@"\n\n%@",content];
            [FSFile wirteToFile:path content:value];
            
            index ++;
            sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ order by cast(time as REAL) DESC limit %@,1;",accountName,@(index)];
            list = [master querySQL:sql tableName:accountName];
        }
        return [Tuple2 v1:path v2:fileName];
    }];
}

+ (void)sendDiary{
    [FSDBTool saveFileCallback:^Tuple2<NSString *,NSString *> *{
        NSString *fileName = [[NSString alloc] initWithFormat:@"Diary_%@",[self timeStr]];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@.txt",fileName]];
        
        FSDBMaster *master = [FSDBMaster sharedInstance];
        NSInteger count = [master countForTable:_tb_diary];
        
        NSInteger index = 0;
        NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ order by time DESC limit %@,1;",_tb_diary,@(index)];
        NSArray *list = [master querySQL:sql tableName:_tb_diary];
        while (_fs_isValidateArray(list)) {
            NSDictionary *model = [list firstObject];
            NSString *content = [[NSString alloc] initWithFormat:@"%@      - %@/%@ -\n%@",[FSKit ymdhsByTimeIntervalString:model[@"time"]],@(index + 1),@(count),[FSCryptor aes256DecryptString:model[@"content"]]];
            NSString *value = [[NSString alloc] initWithFormat:@"%@%@",index?@"\n\n":@"",content];
            [FSFile wirteToFile:path content:value];
            
            index ++;
            sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ order by time DESC limit %@,1;",_tb_diary,@(index)];
            list = [master querySQL:sql tableName:_tb_diary];
        }
        return [Tuple2 v1:path v2:fileName];
    }];
}

+ (void)importDiary{
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSArray *array = [self from];
    for (NSString *str in array) {
        NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (time,content,zone) VALUES ('%@','%@','%@');",_tb_diary,@(_fs_integerTimeIntevalSince1970()),[FSCryptor aes256EncryptString:str],@"感悟"];
        NSString *error = [master insertSQL:sql fields:FSDiaryModel.tableFields table:_tb_diary];
        if (error) {
            return;
        }
    }
}

+ (NSArray *)from{
    NSString *str = [[NSString alloc] initWithContentsOfFile:@"/Users/fudonfuchina/Desktop/what.txt" encoding:NSUTF8StringEncoding error:nil];
    return [str componentsSeparatedByString:@" "];
}

+ (void)sendPasswords{
    [FSDBTool saveFileCallback:^Tuple2<NSString *,NSString *> *{
        NSString *fileName = [[NSString alloc] initWithFormat:@"Password_%@",[self timeStr]];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@.txt",fileName]];
        
        FSDBMaster *master = [FSDBMaster sharedInstance];
        NSInteger count = [master countForTable:_tb_password];
        
        NSString *flag = [[NSString alloc] initWithFormat:@"密码文件，Made by %@APP\n\n",[FSKit appName]];
        NSInteger index = 0;
        NSString *sql = [self sqlOfPassword:index];
        NSArray *list = [master querySQL:sql tableName:_tb_password];
        while (_fs_isValidateArray(list)) {
            NSDictionary *model = [list firstObject];
            NSString *phone = [FSCryptor aes256DecryptString:model[@"phone"]]?:@"无";
            NSString *mail = [FSCryptor aes256DecryptString:model[@"mail"]]?:@"无";
            NSString *note = [FSCryptor aes256DecryptString:model[@"note"]]?:@"无";
            NSString *content = [[NSString alloc] initWithFormat:@"%@%@      - %@/%@ -\n名字：%@\n帐号：%@\n密码：%@\n手机：%@\n邮箱：%@\n备注：%@\n组名：%@",index?@"\n\n":flag,[FSKit ymdhsByTimeIntervalString:model[@"time"]],@(index + 1),@(count),[FSCryptor aes256DecryptString:model[@"name"]],[FSCryptor aes256DecryptString:model[@"login"]],[FSCryptor aes256DecryptString:model[@"pwd"]],phone,mail,note,model[@"zone"]];
            [FSFile wirteToFile:path content:content];
            
            index ++;
            sql = [self sqlOfPassword:index];
            list = [master querySQL:sql tableName:_tb_password];
        }
        return [Tuple2 v1:path v2:fileName];
    }];
}

+ (NSString *)sqlOfPassword:(NSInteger)index{
    return [[NSString alloc] initWithFormat:@"SELECT * FROM %@ order by time DESC limit %@,1;",_tb_password,@(index)];
}

+ (NSString *)timeStr{
    NSString *time = [FSDate stringWithDate:[NSDate date] formatter:@"yyyyMMddHHmmss"];
    return time;
}

// @[Tuple2:year + @[Tuple3:date + sr + cb]]
+ (NSArray<Tuple2<NSString *,NSArray<Tuple3 *> *> *> *)incomesAndcostsByMonth:(NSInteger)year table:(NSString *)table first:(NSTimeInterval)first{
    first = MAX(first, 0);
    if (!_fs_isValidateString(table)) {
        return nil;
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    BOOL exist = [master checkTableExist:table];
    if (!exist) {
        return nil;
    }
    NSInteger count = [master countForTable:table];
    if (count == 0) {
        return nil;
    }
    NSInteger firstYear = year - 1;
    NSString *str = [[NSString alloc] initWithFormat:@"%@-01-01 00:00:00",@(firstYear)];
    NSDate *date = [FSDate dateByString:str formatter:nil];
    NSTimeInterval time = [date timeIntervalSince1970];
    if (time < first) {
        time = first;
        date = [[NSDate alloc] initWithTimeIntervalSince1970:first];
    }
    NSDateComponents *ct = [FSDate componentForDate:date];
    NSDateComponents *cn = [FSDate componentForDate:[NSDate date]];
    NSInteger days = [FSDate daysForMonth:cn.month year:cn.year];
    NSString *max = [[NSString alloc] initWithFormat:@"%@-%@-%@ 23:59:59",@(cn.year),[FSKit twoChar:cn.month],@(days)];
    NSDate *maxDate = [FSDate dateByString:max formatter:nil];
    NSTimeInterval maxTI = [maxDate timeIntervalSince1970];
    NSString *start = [[NSString alloc] initWithFormat:@"%@-%@-01 00:00:00",@(ct.year),[FSKit twoChar:ct.month]];
    NSDate *startDate = [FSDate dateByString:start formatter:nil];
    NSTimeInterval startTI = [startDate timeIntervalSince1970];
    
    NSMutableArray *tuples = [[NSMutableArray alloc] init];
    while (startTI < maxTI) {
        NSDate *sDate = [[NSDate alloc] initWithTimeIntervalSince1970:startTI];
        NSDateComponents *sc = [FSDate componentForDate:sDate];
        NSInteger nYear = sc.year;
        NSInteger nMonth = sc.month;
        NSInteger nDays = [FSDate daysForMonth:nMonth year:nYear];
        NSString *sMax = [[NSString alloc] initWithFormat:@"%@-%@-%@ 23:59:59",@(nYear),[FSKit twoChar:nMonth],@(nDays)];
        NSDate *mDate = [FSDate dateByString:sMax formatter:nil];
        NSTimeInterval mTI = [mDate timeIntervalSince1970];
        // startTI mTI
        Tuple3 *t3 = [self requestSROrCB:startTI end:mTI table:table];
        NSString *ye = @(nYear).stringValue;
        if (tuples.count > 0) {
            BOOL saved = NO;
            for (Tuple2 *t in tuples) {
                NSString *y = t._1;
                if ([y isEqualToString:ye]) {
                    NSMutableArray *as = t._2;
                    if ([as isKindOfClass:NSMutableArray.class]) {
                        [as addObject:t3];
                    }
                    saved = YES;
                    break;
                }
            }
            if (!saved) {
                NSMutableArray *a = [[NSMutableArray alloc] init];
                [a addObject:t3];
                Tuple2 *t2 = [Tuple2 v1:ye v2:a];
                [tuples addObject:t2];
            }
        }else{
            NSMutableArray *a = [[NSMutableArray alloc] init];
            [a addObject:t3];
            Tuple2 *t2 = [Tuple2 v1:ye v2:a];
            [tuples addObject:t2];
        }
        
        if (sc.month < 12) {
            nMonth ++;
        }else{
            nYear ++;
            nMonth = 1;
        }
        NSString *nStr = [[NSString alloc] initWithFormat:@"%@-%@-01 00:00:00",@(nYear),[FSKit twoChar:nMonth]];
        NSDate *nDate = [FSDate dateByString:nStr formatter:nil];
        startTI = [nDate timeIntervalSince1970];
    }
    
    [tuples sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return NSOrderedDescending;
    }];
    
    for (Tuple2 *t in tuples) {
        NSMutableArray *t3 = t._2;
        if ([t3 isKindOfClass:NSMutableArray.class]) {
            [t3 sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return NSOrderedDescending;
            }];
        }
    }
    return tuples;
}

// date   sr   cb
+ (Tuple3 *)requestSROrCB:(NSTimeInterval)start end:(NSTimeInterval)end table:(NSString *)table{
    static NSString *sring = nil;
    if (sring == nil) {
        sring = [[NSString alloc] initWithFormat:@"%@%@",_subject_SR,_ING_KEY];
    }
    static NSString *sred = nil;
    if (sred == nil) {
        sred = [[NSString alloc] initWithFormat:@"%@%@",_subject_SR,_ED_KEY];
    }
    static NSString *cbing = nil;
    if (cbing == nil) {
        cbing = [[NSString alloc] initWithFormat:@"%@%@",_subject_CB,_ING_KEY];
    }
    static NSString *cbed = nil;
    if (cbed == nil) {
        cbed = [[NSString alloc] initWithFormat:@"%@%@",_subject_CB,_ED_KEY];
    }
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (atype = '%@' OR btype = '%@' OR atype = '%@' OR btype = '%@' OR atype = '%@' OR btype = '%@' OR atype = '%@' OR btype = '%@') and cast(time as REAL) BETWEEN %@ AND %@;",table,sring,sring,sred,sred,cbing,cbing,cbed,cbed,@(start),@(end)];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSArray *list = [master querySQL:sql tableName:table];
    CGFloat sr = 0;
    CGFloat cb = 0;
    for (NSDictionary *model in list) {
        CGFloat je = [model[@"je"] doubleValue];
        NSString *atype = model[@"atype"];
        NSString *btype = model[@"btype"];
        if ([atype isEqualToString:sring] || [btype isEqualToString:sring]) {
            sr += je;
        }else if ([atype isEqualToString:sred] || [btype isEqualToString:sred]){
            sr = sr - je;
        }else if ([atype isEqualToString:cbing] || [btype isEqualToString:cbing]){
            cb += je;
        }else if ([atype isEqualToString:cbed] || [btype isEqualToString:cbed]){
            cb = cb - je;
        }
    }
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:((start + end) / 2)];
    Tuple3 *t3 = [Tuple3 v1:date v2:@(sr).stringValue v3:@(cb).stringValue];
    return t3;
}

+ (void)sendContacts{
    [FSDBTool saveFileCallback:^Tuple2<NSString *,NSString *> *{
        NSString *fileName = [[NSString alloc] initWithFormat:@"Contact_%@",[self timeStr]];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@.txt",fileName]];
        
        FSDBMaster *master = [FSDBMaster sharedInstance];
        NSInteger count = [master countForTable:_tb_contact];
        
        NSString *flag = [[NSString alloc] initWithFormat:@"通讯录文件，Made by %@APP\n\n",[FSKit appName]];
        NSInteger index = 0;
        NSString *sql = [self sqlOfContact:index];
        NSArray *list = [master querySQL:sql tableName:_tb_contact];
        while (_fs_isValidateArray(list)) {
            NSDictionary *model = [list firstObject];
            NSString *phone = [FSCryptor aes256DecryptString:model[@"phone"]];
            NSString *name = [FSCryptor aes256DecryptString:model[@"name"]];
            NSString *content = [[NSString alloc] initWithFormat:@"%@%@      - %@/%@ -\n名字：%@\n手机：%@\n类型：%@\n",index?@"\n\n":flag,[FSKit ymdhsByTimeIntervalString:model[@"time"]],@(index + 1),@(count),name,phone,model[@"type"]];
            [FSFile wirteToFile:path content:content];
            
            index ++;
            sql = [self sqlOfContact:index];
            list = [master querySQL:sql tableName:_tb_contact];
        }
        return [Tuple2 v1:path v2:fileName];
    }];
}

+ (NSString *)sqlOfContact:(NSInteger)index{
    return [[NSString alloc] initWithFormat:@"SELECT * FROM %@ order by time DESC limit %@,1;",_tb_contact,@(index)];
}

+ (NSString *)addField:(NSString *)field defaultValue:(NSString *)value toTable:(NSString *)table{
    BOOL checkField = [field isKindOfClass:NSString.class] && field.length;
    if (!checkField) {
        return @"字段不是字符串";
    }
    BOOL checkTable = [table isKindOfClass:NSString.class] && table.length;
    if (!checkTable) {
        return @"表不是字符串";
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSArray *keys = [master keywords];
    if ([keys containsObject:field]) {
        return @"字段名不能使用关键字";
    }
    BOOL exist = [master checkTableExist:table];
    if (!exist) {
        return @"表不存在";
    }
    NSArray *fs = [master allFields:table];
    BOOL fe = NO;
    for (NSDictionary *dic in fs) {
        NSString *f = [dic objectForKey:@"field_name"];
        if ([f isEqualToString:field]) {
            fe = YES;
            break;
        }
    }
    if (fe) {
        return @"表中已有该字段";
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"ALTER TABLE '%@' ADD '%@' TEXT NULL DEFAULT '%@';",table,field,value?:@""];
    NSString *error = [master execSQL:sql type:nil];
    return error;
}

+ (NSString *)updateField:(NSString *)field value:(NSString *)value ofTable:(NSString *)table{
    BOOL checkField = [field isKindOfClass:NSString.class] && field.length;
    if (!checkField) {
        return @"字段不是字符串";
    }
    BOOL checkTable = [table isKindOfClass:NSString.class] && table.length;
    if (!checkTable) {
        return @"表不是字符串";
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    BOOL exist = [master checkTableExist:table];
    if (!exist) {
        return @"表不存在";
    }
    NSArray<NSDictionary *> *tfs = [master allFields:table];
    BOOL fieldExist = NO;
    for (NSDictionary *dic in tfs) {
        NSString *fi = [dic objectForKey:@"field_name"];
        if ([fi isEqualToString:field]) {
            fieldExist = YES;
            break;
        }
    }
    if (!fieldExist) {
        return @"字段不存在";
    }

    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = '%@';",table,field,value?:@""];
    NSString *error = [master updateWithSQL:sql];
    return error;
}

+ (void)dayFlowOfAccount:(NSString *)account date:(NSDate *)date completion:(void(^)(CGFloat sr,CGFloat cb))completion{
//    NSInteger todayStart = [FSDate theFirstSecondOfDay:date];
//    NSInteger todayEnd = [FSDate theLastSecondOfDay:date];
//    NSString *srp = [[NSString alloc] initWithFormat:@"%@%@",_subject_SR,_ING_KEY];
//    NSString *srm = [[NSString alloc] initWithFormat:@"%@%@",_subject_SR,_ED_KEY];
//    NSString *cbp = [[NSString alloc] initWithFormat:@"%@%@",_subject_CB,_ING_KEY];
//    NSString *cbm = [[NSString alloc] initWithFormat:@"%@%@",_subject_CB,_ED_KEY];
//    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE (atype = '%@' OR atype = '%@' OR btype = '%@' OR btype = '%@') and time BETWEEN %@ AND %@ order by time DESC limit 0,10;",account,srp,srm,cbp,cbm,@(todayStart),@(todayEnd)];
//    NSMutableArray *array = [self querySQL:sql class:[FSABModel class] tableName:account];

}

@end
