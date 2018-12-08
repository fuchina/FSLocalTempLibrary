//
//  FSMobanAPI.h
//  myhome
//
//  Created by FudonFuchina on 2018/4/30.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBaseAPI.h"

@interface FSMobanAPI : FSBaseAPI

+ (void)addMobanWithBZ:(NSString *)bz atype:(NSString *)atype btype:(NSString *)btype type:(NSString *)type;

+ (void)updateFreq:(NSNumber *)aid freq:(NSInteger)freq;

@end
