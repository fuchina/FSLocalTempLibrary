//
//  FSBestMobanController.h
//  myhome
//
//  Created by FudonFuchina on 2018/7/2.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBaseController.h"

@interface FSBestMobanController : FSBaseController

@property (nonatomic,copy) NSString     *account;
@property (nonatomic,assign) BOOL       selectMode;
@property (nonatomic,copy) void(^addSuccess)(FSBestMobanController *c);

@end
