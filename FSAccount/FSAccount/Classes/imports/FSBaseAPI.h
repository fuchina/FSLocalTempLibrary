//
//  FSBaseAPI.h
//  myhome
//
//  Created by FudonFuchina on 2018/3/3.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDBMaster.h"
#import <UIKit/UIKit.h>

@interface FSBaseAPI : NSObject

// 必须有aid
+ (NSString *)deleteModel:(id)model table:(NSString *)table;

// 业务方法,model必须有aid
+ (void)deleteModelBusiness:(id)model table:(NSString *)table controller:(UIViewController *)controller success:(void (^)(void))success fail:(void(^)(NSString *error))fail cancel:(void (^)(void))cancel;

// 将某条数据的某个字段的值增加1
+ (NSString *)addFreq:(NSString *)table field:(NSString *)field model:(id)model;

// 更新某个表的某个字段的值
+ (NSString *)updateTable:(NSString *)table field:(NSString *)field value:(NSString *)value aid:(NSNumber *)aid;

@end
