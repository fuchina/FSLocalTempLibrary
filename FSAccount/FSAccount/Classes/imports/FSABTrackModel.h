//
//  FSABTrackModel.h
//  myhome
//
//  Created by fudon on 2017/5/22.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSABTrackModel : NSObject

@property (nonatomic,strong) NSNumber   *aid;
@property (nonatomic,copy) NSString     *time;
@property (nonatomic,copy) NSString     *link;  // 哪条数据的记录，对应FSAccModel.aid
@property (nonatomic,copy) NSString     *type;  // "a" 或 "b" 对应FSAccModel.atype 或 btype
@property (nonatomic,copy) NSString     *je;
@property (nonatomic,copy) NSString     *bz;
@property (nonatomic,copy) NSString     *accname; // 账本不止一个表

+ (NSArray<NSString *> *)tableFields;

@end
