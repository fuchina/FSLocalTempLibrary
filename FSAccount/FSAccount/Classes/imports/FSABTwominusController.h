//
//  FSABTwominusController.h
//  myhome
//
//  Created by FudonFuchina on 2017/5/21.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSBaseCompanyController.h"

@interface FSABTwominusController : FSBaseCompanyController

@property (nonatomic,copy) NSString         *accountName;
@property (nonatomic,strong) NSArray        *types;
@property (nonatomic,copy) NSString         *je;
@property (nonatomic,copy) NSString         *bz;
@property (nonatomic,copy) void (^completion)(FSABTwominusController *bController,NSArray *bEdArray,NSArray *bTracks);

@end
