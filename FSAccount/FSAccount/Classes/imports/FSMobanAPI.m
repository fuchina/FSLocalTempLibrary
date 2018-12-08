//
//  FSMobanAPI.m
//  myhome
//
//  Created by FudonFuchina on 2018/4/30.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSMobanAPI.h"
#import <FSKit.h>
#import "FSAccountConfiger.h"
#import <FSDBMaster.h>
#import "FSMacro.h"
#import "FSFormModel.h"

@implementation FSMobanAPI

+ (void)addMobanWithBZ:(NSString *)bz atype:(NSString *)atype btype:(NSString *)btype type:(NSString *)type{
    BOOL goodStr = _fs_isValidateString(bz);
    BOOL goodtp = _fs_isValidateString(type);
    BOOL goodAtp = [atype isKindOfClass:NSString.class] && atype.length == 3 && ([atype hasSuffix:_ING_KEY] || [atype hasSuffix:_ED_KEY]);
    BOOL goodBtp = [btype isKindOfClass:NSString.class] && btype.length == 3 && ([btype hasSuffix:_ING_KEY] || [btype hasSuffix:_ED_KEY]);
    if (!(goodStr && goodAtp && goodBtp && goodtp)) {
        return;
    }
    NSString *abtype = [[NSString alloc] initWithFormat:@"%@|%@",atype,btype];
    
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE abtype = '%@' and bz = '%@';",_tb_abform,abtype,bz];
    NSArray *list = [master querySQL:sql tableName: _tb_abform];
    if (list.count) {
        NSDictionary *dic = list.firstObject;
        NSNumber *aid = [dic objectForKey:@"aid"];
        NSInteger freq = [[dic objectForKey:@"freq"] integerValue];
        [self updateFreq:aid freq:freq + 1];
        return;
    }
    sql = [[NSString alloc] initWithFormat:@"INSERT INTO %@ (time,abtype,bz,type,freq) VALUES ('%@','%@','%@','%@','%@');",_tb_abform,@(_fs_integerTimeIntevalSince1970()),abtype,bz,type,@(0)];
    [master insertSQL:sql fields:FSFormModel.tableFields table:_tb_abform];
}

+ (void)updateFreq:(NSNumber *)aid freq:(NSInteger)freq{
    if (![aid isKindOfClass:NSNumber.class]) {
        return;
    }
    [self updateTable:_tb_abform field:@"freq" value:@(freq + 1).stringValue aid:aid];
}

@end
