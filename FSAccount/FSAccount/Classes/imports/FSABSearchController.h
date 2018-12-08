//
//  FSABSearchController.h
//  myhome
//
//  Created by fudon on 2017/5/22.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSShakeBaseController.h"

@interface FSABSearchController : FSShakeBaseController

@property (nonatomic,strong) UIView     *resultView;

@property (nonatomic,copy) void (^searchEvent)(FSABSearchController *searchController,NSString *text);
@property (nonatomic,copy) UITableView* (^resultTableView)(FSABSearchController *searchController);

@end
