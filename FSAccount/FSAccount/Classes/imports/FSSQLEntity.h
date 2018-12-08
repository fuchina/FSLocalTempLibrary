//
//  FSSQLEntity.h
//  myhome
//
//  Created by FudonFuchina on 2017/3/28.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSSQLEntity : NSObject

@property (nonatomic,copy) NSString *sr;        // 收入
@property (nonatomic,copy) NSString *cb;        // 成本

@property (nonatomic,copy) NSString *ys;        // 应收
@property (nonatomic,copy) NSString *xj;        // 现金
@property (nonatomic,copy) NSString *ch;        // 存货
@property (nonatomic,copy) NSString *tz;        // 投资
@property (nonatomic,copy) NSString *gz;        // 固资
@property (nonatomic,copy) NSString *tx;        // 摊销
@property (nonatomic,copy) NSString *fz;        // 负债
@property (nonatomic,copy) NSString *ps;        // 预收
@property (nonatomic,copy) NSString *bj;        // 本金
@property (nonatomic,copy) NSString *gb;        // 股本

@property (nonatomic,copy) NSString *ph;        // 试算平衡数
@property (nonatomic,copy) NSString *ts;        // 今年收入
@property (nonatomic,copy) NSString *tc;        // 今年成本

- (void)cacheTable:(NSString *)table;

+ (NSArray *)timelessProperties;
+ (FSSQLEntity *)entity:(NSString *)table;

@end
