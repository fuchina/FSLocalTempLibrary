//
//  FSAddBestMobanController.h
//  myhome
//
//  Created by FudonFuchina on 2018/7/2.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBaseController.h"

@interface FSAddBestMobanController : FSBaseController

@property (nonatomic,copy) NSString     *account;
@property (nonatomic,copy) NSString     *bz;
@property (nonatomic,copy)void (^addSuccess)(FSAddBestMobanController *c);

@end
