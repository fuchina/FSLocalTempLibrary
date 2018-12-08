//
//  FSFormModel.m
//  myhome
//
//  Created by FudonFuchina on 2017/8/20.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSFormModel.h"
#import "FATool.h"

@implementation FSFormModel

+ (NSArray<NSString *> *)tableFields{
    return @[@"time",@"abtype",@"bz",@"type",@"freq"];
}

+ (NSString *)parseABType:(NSString *)abtype{
    if ([abtype isKindOfClass:NSString.class] && abtype.length) {
        NSArray *types = [abtype componentsSeparatedByString:@"|"];
        NSString *atype = types.firstObject;
        NSString *btype = types.lastObject;
        NSString *parse = [[NSString alloc] initWithFormat:@"%@,%@",[FATool noticeForType:atype],[FATool noticeForType:btype]];
        return parse;
    }
    return nil;
}

+ (Tuple2 *)typesOfABType:(NSString *)abtype{
    if ([abtype isKindOfClass:NSString.class] && abtype.length) {
        NSArray *types = [abtype componentsSeparatedByString:@"|"];
        NSString *atype = types.firstObject;
        NSString *btype = types.lastObject;
        Tuple2 *t = [Tuple2 v1:atype v2:btype];
        return t;
    }
    return nil;
}

@end
