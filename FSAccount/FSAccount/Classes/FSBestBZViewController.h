//
//  FSBestBZViewController.h
//  myhome
//
//  Created by FudonFuchina on 2018/7/4.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSBaseController.h"
#import "FSBestMobanModel.h"

@interface FSBestBZViewController : FSBaseController

@property (nonatomic,copy) NSString                 *table;
@property (nonatomic,assign) BOOL                   editMode;
@property (nonatomic,copy) NSString                 *bz;
@property (nonatomic,copy)void (^selectedBZ)(FSBestBZViewController *c,FSBestMobanModel *model);
@property (nonatomic,copy)void (^deleteEvent)(FSBestBZViewController *c);

@end
