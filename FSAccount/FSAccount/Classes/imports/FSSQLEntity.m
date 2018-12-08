//
//  FSSQLEntity.m
//  myhome
//
//  Created by FudonFuchina on 2017/3/28.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSSQLEntity.h"
#import "FSKit.h"
#import "FSAccountConfiger.h"
#import <FSRuntime.h>

@implementation FSSQLEntity

- (instancetype)init{
    self = [super init];
    if (self) {
        NSArray *list = [FSRuntime propertiesForClass:self.class];
        for (NSString *name in list) {
            [FSRuntime setValue:@"0.00" forPropertyName:name ofObject:self];
        }
    }
    return self;
}

- (void)cacheTable:(NSString *)table{
    if (!([table isKindOfClass:NSString.class] && table.length)) {
        return;
    }
    static NSArray *ps = nil;
    if (!ps) {
         ps = [FSRuntime propertiesForClass:FSSQLEntity.class];
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (NSString *subject in ps) {
        id value = [FSRuntime valueForGetSelectorWithPropertyName:subject object:self];
        [dic setObject:value forKey:subject];
    }
    _fs_userDefaults_setObjectForKey(dic, table);
}

+ (NSArray *)timelessProperties{
    static NSArray *ps = nil;
    if (ps) {
        return ps;
    }
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *properties = [FSRuntime propertiesForClass:FSSQLEntity.class];
    for (NSString *subject in properties) {
        if ([subject isEqualToString:_subject_SR] || [subject isEqualToString:_subject_CB]) {
            continue;
        }
        [array addObject:subject];
    }
    ps = [array copy];
    return ps;
}

+ (FSSQLEntity *)entity:(NSString *)table{
    FSSQLEntity *entity = [[FSSQLEntity alloc] init];
    if (!([table isKindOfClass:NSString.class] && table.length)) {
        return entity;
    }
    static NSArray *ps = nil;
    if (!ps) {
        ps = [FSRuntime propertiesForClass:FSSQLEntity.class];
    }
    NSDictionary *dic = _fs_userDefaults_objectForKey(table);
    NSArray *keys = [dic allKeys];
    for (NSString *subject in keys) {
        SEL sel = [FSRuntime setterSELWithAttibuteName:subject];
        if ([entity respondsToSelector:sel]) {
            NSString *value = [dic objectForKey:subject];
            [entity performSelector:sel onThread:[NSThread currentThread] withObject:[[NSString alloc] initWithFormat:@"%.2f",[value doubleValue]] waitUntilDone:YES];
        }
    }
    return entity;
}

@end
