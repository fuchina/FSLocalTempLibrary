//
//  FSBaseAPI.m
//  myhome
//
//  Created by FudonFuchina on 2018/3/3.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBaseAPI.h"
#import <FSKit.h>
#import <FSRuntime.h>
#import <FSUIKit.h>

@implementation FSBaseAPI

+ (NSString *)deleteModel:(id)model table:(NSString *)table{
    if (!model) {
        return @"数据错误";
    }
    if (!_fs_isValidateString(table)) {
        return @"表不存在";
    }
    NSNumber *aid = [FSRuntime valueForGetSelectorWithPropertyName:@"aid" object:model];
    if (!aid) {
        return @"类型不匹配";
    }
    NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE aid = %@;",table,aid];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *error = [master deleteSQL:sql];
    return error;
}

+ (void)deleteModelBusiness:(id)model table:(NSString *)table controller:(UIViewController *)controller success:(void (^)(void))success fail:(void(^)(NSString *error))fail cancel:(void (^)(void))cancel{
    if (![controller isKindOfClass:UIViewController.class]) {
        return;
    }
    [FSUIKit alert:UIAlertControllerStyleActionSheet controller:controller title:NSLocalizedString(@"Cannot recover after deletion", nil) message:nil actionTitles:@[NSLocalizedString(@"Delete", nil)] styles:@[@(UIAlertActionStyleDestructive)] handler:^(UIAlertAction *action) {
        NSString *error = [self deleteModel:model table:table];
        if (!error) {
            if (success) {
                success();
            }
        }else{
            if (fail) {
                fail(error);
            }
        }
    } cancelTitle:NSLocalizedString(@"Cancel", nil) cancel:^(UIAlertAction *action) {
        if (cancel) {
            cancel();
        }
    } completion:nil];
}

+ (NSString *)addFreq:(NSString *)table field:(NSString *)field model:(id)model{
    if (!(_fs_isValidateString(table) && _fs_isValidateString(field) && model)) {
        return @"参数错误";
    }
    NSString *value = [FSRuntime valueForGetSelectorWithPropertyName:field object:model];
    NSString *newFreq = @([value integerValue] + 1).stringValue;
    [FSRuntime setValue:newFreq forPropertyName:field ofObject:model];
    NSNumber *aid = [FSRuntime valueForGetSelectorWithPropertyName:@"aid" object:model];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE aid = %@;",table,field,newFreq,aid];
    NSString *error = [master updateWithSQL:sql];
    return error;
}

+ (NSString *)updateTable:(NSString *)table field:(NSString *)field value:(NSString *)value aid:(NSNumber *)aid{
    if (!(_fs_isValidateString(table) && _fs_isValidateString(field) && _fs_isValidateString(value) && aid)) {
        return @"参数错误";
    }
    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE aid = %@;",table,field,value,aid];
    FSDBMaster *master = [FSDBMaster sharedInstance];
    return [master updateWithSQL:sql];
}

@end
