//
//  FSBestAddAccountController.h
//  myhome
//
//  Created by FudonFuchina on 2018/4/1.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBaseController.h"

@interface FSBestAddAccountController : FSBaseController

@property (nonatomic,copy) NSString     *accountName;
@property (nonatomic,copy) void(^addSuccess)(FSBestAddAccountController *c);

@end
