//
//  FSAPP.m
//  myhome
//
//  Created by FudonFuchina on 2017/9/28.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSAPP.h"
#import "FSAppConfig.h"
#import <FSKit.h>

@implementation FSAPP

/*
 @{table:message}
 */
+ (void)addMessage:(NSString *)message table:(NSString *)table{
    if (!([message isKindOfClass:NSString.class] && message.length)) {
        return;
    }
    if (!([table isKindOfClass:NSString.class] && table.length)) {
        return;
    }
    NSString *json = [self objectForKey:_table_message_ud_key];
    NSDictionary *list = [FSKit objectFromJSonstring:json];
    if ([list isKindOfClass:NSDictionary.class] && list.count) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:list];
        [dic setObject:message forKey:table];
        NSString *js = [FSKit jsonStringWithObject:dic];
        [self setObject:js forKey:_table_message_ud_key];
    }else{
        NSString *js = [FSKit jsonStringWithObject:@{table:message}];
        [self setObject:js forKey:_table_message_ud_key];
    }
    [self setObject:message forKey:_message_newest_ud_key];
}

static NSString *_table_message_ud_key = @"_table_message_ud_key";
static NSString *_message_newest_ud_key = @"_message_newest_ud_key";
+ (NSString *)messageForTable:(NSString *)table{
    if (!([table isKindOfClass:NSString.class] && table.length)) {
        return nil;
    }
    NSString *value = [self objectForKey:_table_message_ud_key];
    NSDictionary *dic = [FSKit objectFromJSonstring:value];
    if ([dic isKindOfClass:NSDictionary.class]) {
        return [dic objectForKey:table];
    }
    return nil;
}

+ (NSString *)theNewestMessage{
    return [self objectForKey:_message_newest_ud_key];
}

+ (void)setObject:(NSString *)instance  forKey:(NSString *)key{
    [FSAppConfig saveObject:instance forKey:key];
}

+ (NSString *)objectForKey:(NSString *)key{
    return [FSAppConfig objectForKey:key];
}

+ (void)removeObjectForKey:(NSString *)key{
    [FSAppConfig removeObjectForKey:key];
}

@end
