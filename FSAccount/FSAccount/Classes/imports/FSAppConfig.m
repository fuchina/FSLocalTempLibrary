//
//  FSAppConfig.m
//  myhome
//
//  Created by Fudongdong on 2017/12/23.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSAppConfig.h"
#import "FSDBMaster.h"
#import "FSMacro.h"
#import "FSDBSupport.h"

@implementation FSAppConfig

+ (NSString *)saveObject:(NSString *)value forKey:(NSString *)key{
    if (!_fs_isValidateString(key)) {
        return @"key为空";
    }
    if ([value isKindOfClass:NSNumber.class]) {
        NSNumber *n = (NSNumber *)value;
        value = n.stringValue;
    }
    if (![value isKindOfClass:NSString.class]){
        return @"value为空";
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    FSAppConfigModel *model = [self modelForKey:key];
    if (model) {
        if ([value isEqualToString:model.content]) {
            return nil;
        }
        NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET content = '%@' WHERE aid = %@;",_tb_appcfg,value,model.aid];
        return [master updateWithSQL:sql];
    }
    NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (time,type,content) VALUES ('%@','%@','%@');",_tb_appcfg,@(_fs_integerTimeIntevalSince1970()),key,value];
    NSString *error = [master insertSQL:sql fields:FSAppConfigModel.tableFields table:_tb_appcfg];
    return error;
}

+ (FSAppConfigModel *)modelForKey:(NSString *)key{
    if (!_fs_isValidateString(key)) {
        return nil;
    }
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE type = '%@';",_tb_appcfg,key];
    NSArray *list = [FSDBSupport querySQL:sql class:FSAppConfigModel.class tableName:_tb_appcfg];
    FSAppConfigModel *model = list.firstObject;
    return model;
}

+ (NSString *)objectForKey:(NSString *)key{
    FSAppConfigModel *model = [self modelForKey:key];
    return model.content;
}

+ (void)removeObjectForKey:(NSString *)key{
    if (!_fs_isValidateString(key)) {
        return;
    }
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE type = '%@';",_tb_appcfg,key];
    NSArray *list = [FSDBSupport querySQL:sql class:FSAppConfigModel.class tableName:_tb_appcfg];
    FSAppConfigModel *model = list.firstObject;
    if (model) {
        FSDBMaster *master = [FSDBMaster sharedInstance];
        NSString *dSQL = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE aid = %@;",_tb_appcfg,model.aid];
        [master deleteSQL:dSQL];
    }
}

@end
