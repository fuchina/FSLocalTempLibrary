//
//  FSBestUpdateController.h
//  FSKit_Example
//
//  Created by Guazi on 2018/6/27.
//  Copyright © 2018年 topchuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSBestAccountModel.h"

@interface FSBestUpdateController : UIViewController

@property (nonatomic,strong) FSBestAccountModel     *model;
@property (nonatomic,copy) NSString                 *table;
@property (nonatomic,assign) NSInteger              isAJ;
@property (nonatomic,copy) void (^updatedCallback)(void);

@end
