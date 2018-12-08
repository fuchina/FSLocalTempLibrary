//
//  FSBestExpectController.h
//  myhome
//
//  Created by FudonFuchina on 2018/7/1.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBestAccountAPI.h"
#import "FSShakeBaseController.h"

@interface FSBestExpectController : FSShakeBaseController

@property (nonatomic,copy) NSString                 *accountName;
@property (nonatomic,strong) FSBestAccountDataModel *model;

@end
