//
//  FSABOneminusController.h
//  myhome
//
//  Created by FudonFuchina on 2017/5/21.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSBaseCompanyController.h"
#import "FSABModel.h"

@interface FSABOneminusController : FSBaseCompanyController

@property (nonatomic,copy) NSString     *accountName;
@property (nonatomic,copy) NSString     *je;
@property (nonatomic,copy) NSString     *bz;
@property (nonatomic,copy) NSString     *type;
@property (nonatomic,copy) NSString     *message;
@property (nonatomic,copy) NSString     *time;
@property (nonatomic,copy) void (^selectBlock)(FSABOneminusController *bController,NSArray<FSABModel *> *bEdArray,NSArray *bTracks);

@end
