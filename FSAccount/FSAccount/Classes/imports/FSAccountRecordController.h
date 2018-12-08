//
//  FSAccountRecordController.h
//  myhome
//
//  Created by FudonFuchina on 2017/4/16.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSBaseController.h"

@interface FSAccountRecordController : FSBaseController

@property (strong, nonatomic) void(^block)(FSBaseController *bVC,NSDate *date);

@end
