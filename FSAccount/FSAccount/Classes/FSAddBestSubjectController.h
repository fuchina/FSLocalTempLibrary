//
//  FSAddBestSubjectController.h
//  myhome
//
//  Created by FudonFuchina on 2018/3/29.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBaseController.h"

@interface FSAddBestSubjectController : FSBaseController

@property (nonatomic,copy) NSString     *table;
@property (nonatomic,copy) void (^addSubjectSuccess)(FSAddBestSubjectController *c);
@property (nonatomic,assign) NSInteger  index;

@end
