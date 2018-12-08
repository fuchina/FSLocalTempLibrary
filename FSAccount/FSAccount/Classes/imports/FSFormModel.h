//
//  FSFormModel.h
//  myhome
//
//  Created by FudonFuchina on 2017/8/20.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FSTuple.h>

@interface FSFormModel : NSObject

@property (nonatomic,strong) NSNumber   *aid;
@property (nonatomic,copy) NSString     *time;
@property (nonatomic,copy) NSString     *abtype;
@property (nonatomic,copy) NSString     *bz;        // 备注
@property (nonatomic,copy) NSString     *type;      // 1个人2公司
@property (nonatomic,copy) NSString     *freq;      // 频率

+ (NSArray<NSString *> *)tableFields;

+ (NSString *)parseABType:(NSString *)abtype;
+ (Tuple2 *)typesOfABType:(NSString *)abtype;

@end
